import DeckMateCore
import Foundation
import IOKit.hid

/// A small diary of what happens with the box, for the first real test: ~/Library/Logs/AMS Deck Mate/box.log
enum BoxLog {
    static let url: URL = {
        let folder = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Logs/AMS Deck Mate", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let file = folder.appendingPathComponent("box.log")
        // At each start the diary is cut back, so it never grows without end.
        if let text = try? String(contentsOf: file, encoding: .utf8), let short = Diary.trimmed(text) {
            try? short.write(to: file, atomically: true, encoding: .utf8)
        }
        return file
    }()
    private static let queue = DispatchQueue(label: "box.log")
    private static var written = 0

    static func note(_ text: String) {
        queue.async {
            guard written < 2000 else { return }      // never grows without end
            written += 1
            let line = ISO8601DateFormatter().string(from: Date()) + "  " + text + "\n"
            if let handle = try? FileHandle(forWritingTo: url) {
                handle.seekToEndOfFile()
                handle.write(Data(line.utf8))
                try? handle.close()
            } else {
                try? Data(line.utf8).write(to: url)
            }
        }
    }
}

/// The Stream Deck box on its cable: finds it, lights its keys, hears its presses.
/// 🚨 Written without the box at hand (14 Nov 2026); see StreamDeckProtocol.
final class DeckDevice {
    enum State: Equatable {
        case absent
        case connected(name: String, serial: String)
        /// The Mac did not let the app open the box (words for the screen).
        case blocked(String)
        /// A Stream Deck this app cannot drive yet.
        case unsupported(String)
    }

    var onState: ((State) -> Void)?
    /// A key went down (true) or came up (false). Always on the main thread.
    var onKey: ((Int, Bool) -> Void)?

    private(set) var state: State = .absent { didSet { if state != oldValue { onState?(state) } } }
    private let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    private var device: IOHIDDevice?
    private var down = [Bool](repeating: false, count: StreamDeckProtocol.keyCount)
    private let sending = DispatchQueue(label: "box.sending")
    private var loggedFirstReport = false
    private var started = false

    func start() {
        guard !started else { return }
        started = true
        let ids = Array(StreamDeckProtocol.products.keys) + Array(StreamDeckProtocol.unsupportedProducts.keys)
        let matches = ids.map { [kIOHIDVendorIDKey: StreamDeckProtocol.vendorID, kIOHIDProductIDKey: $0] as [String: Any] }
        IOHIDManagerSetDeviceMatchingMultiple(manager, matches as CFArray)
        let me = Unmanaged.passUnretained(self).toOpaque()
        IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, _, _, device in
            guard let context else { return }
            Unmanaged<DeckDevice>.fromOpaque(context).takeUnretainedValue().attached(device)
        }, me)
        IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, _, _, device in
            guard let context else { return }
            Unmanaged<DeckDevice>.fromOpaque(context).takeUnretainedValue().removed(device)
        }, me)
        IOHIDManagerRegisterInputReportCallback(manager, { context, _, _, _, _, report, length in
            guard let context, length > 0 else { return }
            let data = Data(bytes: report, count: length)
            Unmanaged<DeckDevice>.fromOpaque(context).takeUnretainedValue().heard(data)
        }, me)
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        let result = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        BoxLog.note("start: open = \(String(format: "0x%08X", result))")
        if result == kIOReturnNotPermitted {
            state = .blocked("The Mac has not allowed AMS Deck Mate to use the box yet. Allow it in System Settings, Privacy & Security, Input Monitoring, then open the app again.")
        } else if result == kIOReturnExclusiveAccess {
            state = .blocked("Another app is holding the box. Quit Elgato's app, then plug the box in again.")
        }
    }

    private func number(_ device: IOHIDDevice, _ key: String) -> Int {
        (IOHIDDeviceGetProperty(device, key as CFString) as? NSNumber)?.intValue ?? 0
    }

    private func attached(_ found: IOHIDDevice) {
        let product = number(found, kIOHIDProductIDKey)
        BoxLog.note("attached: product \(String(format: "0x%04X", product))")
        if let old = StreamDeckProtocol.unsupportedProducts[product] {
            if device == nil { state = .unsupported(old) }
            return
        }
        guard let name = StreamDeckProtocol.products[product] else { return }
        device = found
        down = [Bool](repeating: false, count: StreamDeckProtocol.keyCount)
        let serial = (IOHIDDeviceGetProperty(found, kIOHIDSerialNumberKey as CFString) as? String) ?? ""
        state = .connected(name: name, serial: serial)
    }

    private func removed(_ gone: IOHIDDevice) {
        guard let device, device == gone else {
            if case .unsupported = state { state = .absent }
            return
        }
        BoxLog.note("removed")
        self.device = nil
        state = .absent
    }

    private func heard(_ report: Data) {
        if !loggedFirstReport {
            loggedFirstReport = true
            BoxLog.note("first report (\(report.count) bytes): " + report.prefix(24).map { String(format: "%02X", $0) }.joined(separator: " "))
        }
        guard let states = StreamDeckProtocol.keyStates(fromInput: report) else { return }
        for (index, isDown) in states.enumerated() where isDown != down[index] {
            down[index] = isDown
            onKey?(index, isDown)
        }
    }

    var isConnected: Bool { device != nil }

    private func send(_ report: Data, _ type: IOHIDReportType, to device: IOHIDDevice, what: String) {
        let result = report.withUnsafeBytes { raw -> IOReturn in
            guard let bytes = raw.bindMemory(to: UInt8.self).baseAddress else { return kIOReturnError }
            return IOHIDDeviceSetReport(device, type, CFIndex(report[0]), bytes, report.count)
        }
        if result != kIOReturnSuccess { BoxLog.note("\(what) failed: \(String(format: "0x%08X", result))") }
    }

    /// Shows a picture (JPEG, already turned for the box) on a key.
    func show(_ jpeg: Data, on key: Int) {
        guard let device else { return }
        let packets = StreamDeckProtocol.imagePackets(key: key, jpeg: jpeg)
        sending.async { [weak self] in
            for packet in packets { self?.send(packet, kIOHIDReportTypeOutput, to: device, what: "picture for key \(key)") }
        }
    }

    func setBrightness(_ percent: Int) {
        guard let device else { return }
        let report = StreamDeckProtocol.brightness(percent)
        sending.async { [weak self] in self?.send(report, kIOHIDReportTypeFeature, to: device, what: "brightness") }
    }

    /// Hands the box back with the Elgato logo on it. Waits until it is sent (used when the app quits).
    func giveBack() {
        guard let device else { return }
        let report = StreamDeckProtocol.resetToLogo()
        sending.sync { send(report, kIOHIDReportTypeFeature, to: device, what: "reset") }
    }
}

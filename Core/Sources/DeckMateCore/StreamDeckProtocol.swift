import Foundation

/// How a 15-key Stream Deck (Original v2, MK.2 and its variants) is spoken to over the cable.
/// Byte layouts as in the open drivers python-elgato-streamdeck and the Rust crate elgato-streamdeck.
/// 🚨 Written without the box at hand (14 Nov 2026): not yet proven on the real hardware.
public enum StreamDeckProtocol {
    public static let vendorID = 0x0FD9
    /// The 15-key boxes that share this way of talking, by product number.
    public static let products: [Int: String] = [
        0x006D: "Stream Deck (2019)",
        0x0080: "Stream Deck MK.2",
        0x00A5: "Stream Deck MK.2",
        0x00B9: "Stream Deck MK.2 Module",
        0x00E4: "Stream Deck MK.2 Module",
    ]
    /// The first Stream Deck (2017) talks differently and is not driven yet.
    public static let unsupportedProducts: [Int: String] = [0x0060: "Stream Deck (2017)"]

    public static let keyCount = 15
    public static let columns = 5
    public static let rows = 3
    /// A key's picture is 72 x 72 points, sent as a JPEG turned upside down (flipped both ways).
    public static let keyPixels = 72
    public static let packetSize = 1024
    public static let headerSize = 8
    public static let featureSize = 32

    /// A key picture cut into the packets the box wants. Each packet is 1024 bytes:
    /// 02 07 <key> <1 on the last packet> <length low> <length high> <packet number low> <high>, then the data.
    public static func imagePackets(key: Int, jpeg: Data) -> [Data] {
        let room = packetSize - headerSize
        let bytes = [UInt8](jpeg)
        var packets: [Data] = []
        var offset = 0
        var number = 0
        repeat {
            let count = min(room, bytes.count - offset)
            var packet = [UInt8](repeating: 0, count: packetSize)
            packet[0] = 0x02
            packet[1] = 0x07
            packet[2] = UInt8(clamping: key)
            packet[3] = offset + count >= bytes.count ? 1 : 0
            packet[4] = UInt8(count & 0xFF)
            packet[5] = UInt8(count >> 8)
            packet[6] = UInt8(number & 0xFF)
            packet[7] = UInt8(number >> 8)
            packet.replaceSubrange(headerSize..<(headerSize + count), with: bytes[offset..<(offset + count)])
            packets.append(Data(packet))
            offset += count
            number += 1
        } while offset < bytes.count
        return packets
    }

    /// Which keys are down, from what the box reports: 01 00 0F 00, then one byte per key.
    /// The Mac may hand the report over with or without its first byte (the report number), so both are read.
    public static func keyStates(fromInput report: Data) -> [Bool]? {
        let bytes = [UInt8](report)
        let offset = bytes.first == 0x01 ? 4 : 3
        guard bytes.count >= offset + keyCount else { return nil }
        return bytes[offset..<(offset + keyCount)].map { $0 != 0 }
    }

    /// Feature report: brightness 0 to 100.
    public static func brightness(_ percent: Int) -> Data {
        feature([0x03, 0x08, UInt8(min(100, max(0, percent)))])
    }

    /// Feature report: back to the Elgato logo.
    public static func resetToLogo() -> Data {
        feature([0x03, 0x02])
    }

    private static func feature(_ start: [UInt8]) -> Data {
        Data(start + [UInt8](repeating: 0, count: featureSize - start.count))
    }

    /// The serial number sits from byte 2 of feature report 06; the text ends at the first zero byte.
    public static func serial(fromFeature report: Data) -> String {
        let bytes = [UInt8](report).dropFirst(2).prefix { $0 != 0 }
        return String(decoding: bytes, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

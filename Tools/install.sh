#!/bin/bash
# Runs the rule tests, builds AMS Deck Mate (Mac) and puts it in ~/Applications, then starts it under the keeper.
# Stops at the first thing that fails, so a failed build never touches the app that is installed.
set -euo pipefail
cd "$(dirname "$0")/.."
NAME="AMS Deck Mate"
APP="$HOME/Applications/$NAME.app"
BUILT="$PWD/build/Build/Products/Release/$NAME.app"
SERVICE="gui/$(id -u)/com.schabbauer.AMSDeckMate.keeper"

(cd Core && swift test 2>&1 | grep -E "Executed|error:|failed" | tail -2)
xcodegen generate >/dev/null
xcodebuild -scheme "$NAME" -configuration Release -derivedDataPath build build 2>&1 | grep -E "error:|BUILD"
codesign --verify --deep --strict "$BUILT"

# A polite stop: the app saves, gives the box back and ends cleanly, so the keeper does not open it again.
pkill -TERM -x "$NAME" 2>/dev/null || true
for _ in $(seq 1 25); do pgrep -xq "$NAME" || break; sleep 0.2; done
if pgrep -xq "$NAME"; then launchctl bootout "$SERVICE" 2>/dev/null || true; pkill -KILL -x "$NAME" 2>/dev/null || true; sleep 0.5; fi

ditto "$BUILT" "$APP"
# Opened by hand, the app writes the keeper's start order and hands itself over to the keeper.
open -g "$APP"
for _ in $(seq 1 40); do
    launchctl print "$SERVICE" 2>/dev/null | grep -q "state = running" && break
    sleep 0.2
done
echo "Installed: $NAME $(defaults read "$APP/Contents/Info" CFBundleShortVersionString) ($(defaults read "$APP/Contents/Info" CFBundleVersion))"
if launchctl print "$SERVICE" 2>/dev/null | grep -q "state = running"; then echo "Running under the keeper"; else echo "warning: NOT running under the keeper"; pgrep -lx "$NAME" || echo "and not running at all"; fi

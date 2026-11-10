#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$DIR/build"
DMG_DIR="$BUILD_DIR/dmg"
DMG_PATH="$DIR/Lumina.dmg"

echo "==> Compiling Lumina..."
swiftc -O -target arm64-apple-macos13.0 \
  -framework AppKit -framework SwiftUI -framework Metal -framework MetalKit -framework ServiceManagement -framework CoreGraphics \
  "$DIR"/Sources/*.swift \
  -o "$DIR/Lumina"

APP_PATH="$BUILD_DIR/Lumina.app"
rm -rf "$BUILD_DIR" "$DMG_PATH"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"
mkdir -p "$DMG_DIR"

cp "$DIR/Lumina" "$APP_PATH/Contents/MacOS/Lumina"
chmod +x "$APP_PATH/Contents/MacOS/Lumina"
cp "$DIR/assets/AppIcon.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"
cp "$DIR/Info.plist" "$APP_PATH/Contents/Info.plist"

echo "==> Ad-hoc code signing..."
codesign -s - --force --deep "$APP_PATH"

cp -R "$APP_PATH" "$DMG_DIR/"
ln -s /Applications "$DMG_DIR/Applications"

echo "==> Creating Lumina.dmg..."
hdiutil create -volname "Lumina" -srcfolder "$DMG_DIR" -ov -format UDZO "$DMG_PATH"

echo "==> Done! Output: $DMG_PATH"

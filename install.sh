#!/bin/bash

# PowerBar Installation Script
set -e

APP_NAME="PowerBar"
BUILD_PATH=".build/release/PowerBar"
INSTALL_PATH="/Applications/PowerBar.app"

echo "📦 Installing PowerBar..."

# Check if build exists
if [ ! -f "$BUILD_PATH" ]; then
    echo "❌ Error: PowerBar executable not found at $BUILD_PATH"
    echo "   Run ./build.sh first to build the app."
    exit 1
fi

# Clean up previous installation if it exists
if [ -d "$INSTALL_PATH" ]; then
    echo "🧹 Removing previous installation..."
    rm -rf "$INSTALL_PATH"
fi

# Create app bundle structure
echo "🏗️  Creating app bundle..."
mkdir -p "$INSTALL_PATH/Contents/MacOS"
mkdir -p "$INSTALL_PATH/Contents/Resources"

# Copy executable
echo "📋 Copying executable..."
cp "$BUILD_PATH" "$INSTALL_PATH/Contents/MacOS/PowerBar"
chmod +x "$INSTALL_PATH/Contents/MacOS/PowerBar"

# Copy Info.plist
echo "📄 Copying Info.plist..."
cp "Info.plist" "$INSTALL_PATH/Contents/Info.plist"

# Copy icon
echo "🎨 Copying app icon..."
if [ -f "PowerBar.icns" ]; then
    cp "PowerBar.icns" "$INSTALL_PATH/Contents/Resources/PowerBar.icns"
    echo "✅ Icon copied successfully"
else
    echo "⚠️  Warning: PowerBar.icns not found"
fi

# Note: No wrapper needed - PowerBar has hardcoded paths to macmon
# Info.plist already points to PowerBar directly

# Code sign the app for Gatekeeper compatibility (enables Finder launch)
echo "🔐 Code signing app bundle..."
codesign -f -s - "$INSTALL_PATH"

# ----> ОСЬ КЛЮЧОВЕ ВИПРАВЛЕННЯ <----
# Оновити дату модифікації, щоб Finder/LaunchServices оновили кеш іконок
echo "🔄 Refreshing icon cache for macOS..."
touch "$INSTALL_PATH"

echo "✅ PowerBar installed successfully!"
echo "📍 Installation location: $INSTALL_PATH"
echo ""
echo "🚀 To launch PowerBar:"
echo "   open /Applications/PowerBar.app"
echo ""
echo "💡 Tip: You can add PowerBar to Login Items in System Settings"
echo "   to start it automatically when you log in." 
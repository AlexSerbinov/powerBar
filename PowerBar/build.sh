#!/bin/bash

# PowerBar Build Script
set -e

echo "🔨 Building PowerBar..."

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo "❌ Error: Package.swift not found. Run this script from the PowerBar directory."
    exit 1
fi

# Check if macmon is available
if ! command -v macmon &> /dev/null; then
    echo "⚠️  Warning: macmon is not installed or not in PATH"
    echo "   Install it first: brew install macmon"
    echo "   Or download from: https://github.com/vladkens/macmon"
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build

# Build in release mode
echo "🏗️  Building PowerBar in release mode..."
swift build -c release

# Check if build succeeded
if [ -f ".build/release/PowerBar" ]; then
    echo "✅ Build successful!"
    echo "📍 Executable location: .build/release/PowerBar"
    echo ""
    echo "🚀 To run PowerBar:"
    echo "   ./.build/release/PowerBar"
    echo ""
    echo "🔧 To install to Applications:"
    echo "   ./install.sh"
else
    echo "❌ Build failed!"
    exit 1
fi 
#!/bin/bash

echo "🔄 PowerBar Full Rebuild & Restart Script"
echo "========================================="

# Step 1: Kill existing PowerBar processes
echo "🛑 Stopping PowerBar processes..."
pkill -f PowerBar
sleep 1

# Step 2: Remove from Applications
echo "🗑️  Removing PowerBar from Applications..."
if [ -d "/Applications/PowerBar.app" ]; then
    rm -rf "/Applications/PowerBar.app"
    echo "✅ PowerBar.app removed from Applications"
else
    echo "ℹ️  PowerBar.app not found in Applications"
fi

# Step 3: Clean build directory
echo "🧹 Cleaning build directory..."
rm -rf .build
echo "✅ Build directory cleaned"

# Step 4: Build the project
echo "🔨 Building PowerBar..."
./build.sh
if [ $? -ne 0 ]; then
    echo "❌ Build failed! Exiting..."
    exit 1
fi

# Step 5: Install to Applications
echo "📦 Installing PowerBar..."
./install.sh
if [ $? -ne 0 ]; then
    echo "❌ Installation failed! Exiting..."
    exit 1
fi

# Step 6: Launch PowerBar
echo "🚀 Launching PowerBar..."
open /Applications/PowerBar.app

# Step 7: Wait a moment and show status
sleep 2
if pgrep -f PowerBar > /dev/null; then
    echo "✅ PowerBar is running!"
    echo "📊 You can now:"
    echo "   • Click the menu bar icon to see power consumption"
    echo "   • Select 'Show Power Graph' to view the graph"
    echo "   • Use ⌘G shortcut for quick graph access"
else
    echo "⚠️  PowerBar may not be running. Check Console.app for errors."
fi

echo ""
echo "🎉 Rebuild and restart complete!" 
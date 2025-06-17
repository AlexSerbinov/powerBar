# PowerBar

macOS menu bar application that displays real-time power consumption using data from the `macmon` utility.

## Features

- 📊 Real-time power consumption display in menu bar
- ⚡ Shows total power usage in watts (e.g., "4.8W")
- 📋 Detailed breakdown via tooltip and menu (CPU, GPU, RAM, System)
- 🔄 Auto-refresh with macmon's default interval (1000ms)
- 🎯 Lightweight menu bar only app (no dock icon)
- ❌ Error handling for macmon unavailability

## Requirements

- macOS 13.0 or later
- `macmon` utility installed and available in PATH
  - Install via: `brew install macmon` (if available)
  - Or download from: [macmon repository](https://github.com/vladkens/macmon)

## Installation

### Option 1: Build from Source

1. Clone this repository
2. Open terminal and navigate to PowerBar directory
3. Build and run:
   ```bash
   swift build -c release
   .build/release/PowerBar
   ```

### Option 2: Xcode

1. Open `PowerBar` folder in Xcode
2. Build and run the project
3. The app will appear in your menu bar

## Usage

1. Launch PowerBar
2. Check your menu bar for power consumption display (e.g., "2.4W")
3. Click the menu bar item to see:
   - Detailed power breakdown
   - Refresh option
   - Start/Stop monitoring
   - Quit option

## Menu Options

- **Power Details**: Shows CPU, GPU, RAM, System power breakdown
- **Refresh**: Restart macmon connection
- **Start/Stop Monitoring**: Toggle power monitoring
- **Quit PowerBar**: Exit the application

## Troubleshooting

**"macmon is not installed or not in PATH"**
- Install macmon utility first
- Ensure it's accessible via command line: `macmon --version`

**"macmon process terminated unexpectedly"**
- Check if macmon has proper permissions
- Try running `macmon pipe` manually in terminal

**Power display shows "Error"**
- macmon might not be responding
- Use "Refresh" from the menu
- Restart PowerBar

## Technical Details

- Built with Swift and SwiftUI
- Uses AppKit for menu bar integration
- Launches `macmon pipe` as subprocess
- Parses JSON output in real-time
- Reactive UI updates via Combine framework

## License

MIT License - see LICENSE file for details. 
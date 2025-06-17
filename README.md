# PowerBar

A sleek macOS menu bar application that displays real-time power consumption data using the `macmon` utility. PowerBar provides instant and averaged power metrics directly in your menu bar with customizable time periods.

![PowerBar Screenshot](https://via.placeholder.com/400x200/2D2D2D/FFFFFF?text=PowerBar+Menu+Bar+App)

## ✨ Features

### 📊 Real-time Power Monitoring
- **Instant Power Display**: Shows current power consumption in menu bar (e.g., "14.2W")
- **Detailed Breakdown**: CPU, GPU, RAM, and System power consumption via tooltip
- **Multiple Display Modes**: Choose between instant readings or time-averaged values

### ⏱️ Flexible Averaging Options
- **5 seconds** - Quick smoothing for immediate trends
- **10 seconds** - Short-term averaging
- **30 seconds** - Medium-term trends
- **1 minute** - Balanced view of power usage
- **5 minutes** - Longer-term patterns
- **10 minutes** - Extended monitoring
- **30 minutes** - Half-hour averages
- **1 hour** - Long-term power consumption
- **All Time Average** - Complete session average since app start

### 🎯 User Experience
- **Menu Bar Only**: Lightweight app with no dock icon (`LSUIElement = YES`)
- **Auto-refresh**: Continuous updates every ~1 second via macmon
- **Error Handling**: Graceful degradation when macmon is unavailable
- **Native macOS Integration**: Follows system appearance and conventions

## 📋 Requirements

### System Requirements
- **macOS 13.0** or later
- **Apple Silicon** or Intel Mac with power monitoring support

### Dependencies
- **macmon utility** - Required for power data collection
  - Install via Homebrew: `brew install macmon`
  - Or download from: [macmon GitHub repository](https://github.com/vladkens/macmon)
  - Verify installation: `macmon --version`

## 🚀 Installation

### Option 1: Pre-built Release (Recommended)
1. Download the latest `PowerBar.app` from [Releases](https://github.com/AlexSerbinov/powerBar/releases)
2. Move to `/Applications/` folder
3. Right-click and select "Open" to bypass Gatekeeper (first launch only)

### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/AlexSerbinov/powerBar.git
cd powerBar

# Build the application
./build.sh

# Install to Applications folder
./install.sh

# Launch PowerBar
open /Applications/PowerBar.app
```

### Option 3: Development Build
```bash
# Quick development run
swift build -c release
./.build/release/PowerBar
```

## 🎮 Usage

### Getting Started
1. **Launch PowerBar** - The app will appear in your menu bar
2. **Check Display** - Look for power consumption (e.g., "13.4W") in the menu bar
3. **Access Menu** - Click the menu bar item to see all options

### Menu Structure
```
PowerBar Menu
├── Show
│   ├── ✓ Instant                    # Real-time power readings
│   ├── 5 seconds                    # 5-second average
│   ├── 10 seconds                   # 10-second average
│   ├── 30 seconds                   # 30-second average
│   ├── 1 minute                     # 1-minute average
│   ├── 5 minutes                    # 5-minute average
│   ├── 10 minutes                   # 10-minute average
│   ├── 30 minutes                   # 30-minute average
│   ├── 1 hour                       # 1-hour average
│   └── All Time Average             # Complete session average
└── Quit PowerBar                    # Exit application
```

### Display Modes Explained

#### Instant Mode (Default)
- Shows real-time power consumption as reported by macmon
- Updates approximately every second
- Best for: Monitoring immediate power changes, testing power states

#### Averaging Modes
- Calculates moving averages over specified time periods
- Smooths out power spikes and provides trend information
- Maintains history buffer (up to 1 hour) for calculations
- Best for: Understanding sustained power usage patterns

## 🔧 Technical Details

### Architecture
- **Language**: Swift 5.9+
- **Frameworks**: AppKit, SwiftUI, Combine
- **Build System**: Swift Package Manager
- **Process Management**: Subprocess integration with macmon

### Data Flow
1. **macmon Integration**: Launches `macmon pipe` as subprocess
2. **JSON Parsing**: Reads streaming JSON data from macmon stdout
3. **Data Processing**: Parses power metrics and maintains history buffer
4. **UI Updates**: Reactive updates via Combine publishers
5. **Menu Bar Display**: Real-time updates in NSStatusItem

### Key Components
```
PowerBar/
├── Sources/PowerBar/
│   ├── main.swift                    # App entry point
│   ├── Models/
│   │   └── MacMonMetrics.swift       # Data models for macmon JSON
│   ├── Services/
│   │   └── PowerManager.swift        # Process management & averaging
│   └── Controllers/
│       └── MenuBarController.swift   # Menu bar UI and interactions
├── Package.swift                     # Swift Package Manager configuration
├── Info.plist                       # App bundle configuration
└── build scripts                    # Build and installation automation
```

### Power Metrics
PowerBar displays the following metrics from macmon:
- **All Power**: Total system power consumption
- **CPU Power**: Processor power usage
- **GPU Power**: Graphics processor power
- **RAM Power**: Memory subsystem power
- **System Power**: Other system components

## 🛠️ Development

### Building
```bash
# Clean build
make clean && make build

# Development run
make run

# Install to Applications
make install
```

### Project Structure
- **Reactive Architecture**: Uses Combine for data flow
- **Error Handling**: Comprehensive error states and recovery
- **Memory Management**: Efficient history buffer with automatic cleanup
- **Process Lifecycle**: Proper subprocess management and cleanup

## 🐛 Troubleshooting

### Common Issues

#### "macmon is not installed or not in PATH"
```bash
# Install macmon
brew install macmon

# Verify installation
macmon --version
which macmon
```

#### "macmon process terminated unexpectedly"
- Check macmon permissions: `macmon pipe` should run without sudo
- Verify macmon works independently: `macmon --help`
- Restart PowerBar: Quit and relaunch the application

#### Power display shows "Error" or "--"
- macmon might not be responding properly
- Try running `macmon pipe` manually in Terminal
- Check Console.app for PowerBar error messages
- Restart both macmon and PowerBar

#### Menu bar icon missing or blank
- Icon cache issue - restart Finder: `killall Finder`
- Reinstall: `./install.sh` to refresh app bundle
- Check `/Applications/PowerBar.app/Contents/Resources/` for icon file

### Debug Mode
Run PowerBar from Terminal to see debug output:
```bash
# Kill any running instance
pkill -f PowerBar

# Run with debug output
./.build/release/PowerBar
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [macmon](https://github.com/vladkens/macmon) - Essential power monitoring utility
- Apple's AppKit and SwiftUI frameworks
- Swift Package Manager for dependency management

---

**PowerBar** - Keep track of your Mac's power consumption, one watt at a time. ⚡ 
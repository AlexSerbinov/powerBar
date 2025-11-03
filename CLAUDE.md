# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Running
- `make build` or `./build.sh` - Build PowerBar in release mode
- `make run` - Build and run PowerBar directly for testing
- `swift build -c release` - Direct Swift build command
- `make install` or `./install.sh` - Install PowerBar.app to /Applications folder
- `make restart` or `./rebuild_and_run.sh` - Full rebuild, reinstall, and restart cycle

### Development Utilities
- `make check` - Verify macmon dependency is installed
- `make test` or `swift test` - Run Swift unit tests
- `make clean` - Clean build artifacts from .build directory
- `make help` - Show all available make targets

### Dependencies
- **macmon** utility is required for power data collection (`brew install macmon`)
- macOS 13.0+ required for Swift Charts framework

## Architecture Overview

PowerBar is a native macOS menu bar application built with Swift and AppKit that provides real-time power consumption monitoring.

### Core Architecture Pattern
**MVC + Reactive Programming**: Uses Combine framework for reactive data flow between components:
- **Model**: `MacMonMetrics` (power data), `BatteryInfo` (battery state)  
- **Service**: `PowerManager` (subprocess management + data processing), `BatteryService` (battery calculations)
- **Controller**: `MenuBarController` (menu bar UI + user interactions)
- **View**: `PowerGraphView` (SwiftUI charts integration)

### Key Design Principles

**Subprocess Integration**: PowerBar launches `macmon pipe` as a subprocess and parses streaming JSON output for real-time power metrics.

**Reactive Data Flow**: All components use Combine publishers/subscribers:
```swift
powerManager.$currentMetrics → MenuBarController updates
powerManager.$displayMode → UI state changes
powerManager.$errorMessage → Error handling
```

**Time-Based Averaging**: Maintains rolling power history buffer (up to 6 hours) for calculating averages across different time periods (5s to 1h + all-time).

**Menu Bar Only App**: Uses `LSUIElement = YES` and `NSApp.setActivationPolicy(.accessory)` to hide from dock.

### Component Responsibilities

**PowerManager** (`Sources/PowerBar/Services/PowerManager.swift`):
- Manages macmon subprocess lifecycle
- Parses JSON power metrics from macmon stdout
- Maintains power history buffer with automatic cleanup
- Calculates time-based averages (5s, 10s, 30s, 1min, 5min, 10min, 30min, 1h, all-time)
- Provides reactive publishers for UI updates

**MenuBarController** (`Sources/PowerBar/Controllers/MenuBarController.swift`):
- Creates and manages NSStatusItem (menu bar presence)
- Builds dynamic menus with current values shown in titles
- Handles user interactions (display mode switching, interval changes)
- Integrates battery time calculations using BatteryService
- Manages SwiftUI popover for power graphs

**BatteryService** (`Sources/PowerBar/Services/BatteryService.swift`):
- Interfaces with `ioreg` command to get battery hardware data
- Calculates remaining battery time using current power consumption
- Converts mAh/mV to Wh for energy calculations
- Supports different power averaging modes for battery estimates

### Data Models

**MacMonMetrics**: Codable struct for macmon JSON parsing with snake_case mapping
- Key fields: `sysPower`, `allPower`, `cpuPower`, `gpuPower`, `ramPower`
- Extensions provide formatted strings for UI display

**DisplayMode**: Enum supporting instant readings or time-based averages
- `.instant` - Real-time power values
- `.average(seconds: Int)` - Moving averages (0 = all-time max)

### Build System Structure

**App Bundle Creation**: Custom install.sh script creates proper .app bundle structure:
- Copies executable to `Contents/MacOS/`
- Includes Info.plist with LSUIElement configuration  
- Adds PowerBar.icns icon to Resources
- Creates wrapper script for proper working directory

**Swift Package Manager**: Uses Package.swift with macOS 13+ target for Swift Charts integration.

### Error Handling Patterns

**Graceful Degradation**: App continues running even when:
- macmon process terminates unexpectedly
- JSON parsing fails on individual lines  
- Battery information is unavailable

**Process Recovery**: PowerManager can restart macmon subprocess when changing update intervals.

**User Feedback**: Error states are reflected in menu bar display ("Error", "Loading...", "Stopped") and tooltips.

## Important Implementation Notes

- Power values are displayed using `sysPower` field (not `allPower`) for consistency with system expectations
- History buffer maintains 6-hour maximum for graph display while supporting various averaging periods
- Battery time calculations require external power state detection to avoid showing estimates while charging
- Menu titles dynamically show current settings ("Show Consumption: 5 minutes", "Update Interval: 1000ms")
- Graph integration uses SwiftUI embedded in NSPopover for modern chart visualization

## Debugging

Run PowerBar from terminal to see debug output:
```bash
pkill -f PowerBar  # Kill existing instance
./.build/release/PowerBar  # Run with console output
```

Key debug information includes power manager state changes, averaging calculations, and battery service operations.
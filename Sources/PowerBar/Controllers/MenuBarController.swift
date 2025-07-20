import Cocoa
import SwiftUI
import Combine

// MARK: - Menu Bar Controller
class MenuBarController: ObservableObject {
    private var statusItem: NSStatusItem?
    private var powerManager = PowerManager()
    private var cancellables = Set<AnyCancellable>()
    private var graphPopover: NSPopover?
    
    // Battery time remaining
    private var batteryTimeMenuItem: NSMenuItem?
    private var batteryDisplayMode: DisplayMode = .average(seconds: 300) // Default to 5 minutes for battery
    
    // Update intervals in milliseconds
    private let availableIntervals = [100, 250, 500, 1000, 2500]
    
    // MARK: - Setup
    
    func setup() {
        createStatusItem()
        setupObservers()
        powerManager.startMonitoring()
    }
    
    func cleanup() {
        powerManager.stopMonitoring()
        statusItem?.statusBar?.removeStatusItem(statusItem!)
        statusItem = nil
    }
    
    // MARK: - Private Methods
    
    private func createStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem?.button else {
            print("Failed to create status item button")
            return
        }
        
        // Configure button
        button.title = "Loading..."
        button.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)

        // Create menu
        updateMenu()
    }
    
    private func updateMenu() {
        guard let statusItem = statusItem else { return }
        
        let menu = NSMenu()
        
        // Power details item
        let detailsItem = NSMenuItem(title: "Power Details", action: nil, keyEquivalent: "")
        detailsItem.isEnabled = false
        menu.addItem(detailsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Display mode menu - показуємо поточний режим в назві
        let currentDisplayModeText = powerManager.displayMode.displayName
        let displayModeItem = NSMenuItem(title: "Averaging Period: \(currentDisplayModeText)", action: nil, keyEquivalent: "")
        let displayModeSubmenu = NSMenu()
        
        // Instant consumption
        let instantItem = NSMenuItem(title: "Instant", action: #selector(setDisplayMode(_:)), keyEquivalent: "")
        instantItem.target = self
        instantItem.tag = -1 // Special tag for instant mode
        displayModeSubmenu.addItem(instantItem)
        
        displayModeSubmenu.addItem(NSMenuItem.separator())
        
        // Average options directly in submenu (no nested submenu)
        for period in powerManager.availableAveragePeriods {
            let avgItem = NSMenuItem(title: friendlyName(for: period), action: #selector(setDisplayMode(_:)), keyEquivalent: "")
            avgItem.target = self
            avgItem.tag = period
            displayModeSubmenu.addItem(avgItem)
        }
        
        displayModeItem.submenu = displayModeSubmenu
        menu.addItem(displayModeItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Update interval submenu - показуємо поточний інтервал в назві
        let intervalItem = NSMenuItem(title: "Refresh Rate: \(powerManager.updateInterval)ms", action: nil, keyEquivalent: "")
        let intervalSubmenu = NSMenu()
        
        for interval in availableIntervals {
            let intervalSubItem = NSMenuItem(title: "\(interval)ms", action: #selector(setInterval(_:)), keyEquivalent: "")
            intervalSubItem.target = self
            intervalSubItem.tag = interval
            intervalSubmenu.addItem(intervalSubItem)
        }
        
        intervalItem.submenu = intervalSubmenu
        menu.addItem(intervalItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Battery time remaining item with submenu
        batteryTimeMenuItem = NSMenuItem(title: "Battery: Calculating...", action: nil, keyEquivalent: "")
        
        // Create battery submenu
        let batterySubmenu = NSMenu()
        
        // Instant consumption for battery
        let batteryInstantItem = NSMenuItem(title: "Instant", action: #selector(setBatteryDisplayMode(_:)), keyEquivalent: "")
        batteryInstantItem.target = self
        batteryInstantItem.tag = -1 // Special tag for instant mode
        batterySubmenu.addItem(batteryInstantItem)
        
        batterySubmenu.addItem(NSMenuItem.separator())
        
        // Average options for battery
        for period in powerManager.availableAveragePeriods {
            let avgItem = NSMenuItem(title: friendlyName(for: period), action: #selector(setBatteryDisplayMode(_:)), keyEquivalent: "")
            avgItem.target = self
            avgItem.tag = period
            batterySubmenu.addItem(avgItem)
        }
        
        batteryTimeMenuItem?.submenu = batterySubmenu
        menu.addItem(batteryTimeMenuItem!)
        
        menu.addItem(NSMenuItem.separator())
        
        // Graph item
        let graphItem = NSMenuItem(title: "Show Power Graph", action: #selector(showGraph), keyEquivalent: "g")
        graphItem.target = self
        menu.addItem(graphItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitItem = NSMenuItem(title: "Quit PowerBar", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        
        // Update the menu items after creation
        updateDisplayModeMenu()
        updateIntervalMenu()
    }
    
    // MARK: - Helper Methods
    
    private func friendlyName(for seconds: Int) -> String {
        if seconds == 0 {
            return "All Time Average"
        }
        
        switch seconds {
        case 5: return "5 seconds"
        case 10: return "10 seconds"
        case 15: return "15 seconds"
        case 20: return "20 seconds"
        case 30: return "30 seconds"
        case 60: return "1 minute"
        case 300: return "5 minutes"
        case 600: return "10 minutes"
        case 1800: return "30 minutes"
        case 3600: return "1 hour"
        default: return "\(seconds) seconds"
        }
    }
    
    private func setupObservers() {
        // Observe power manager changes
        powerManager.$currentMetrics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
                self?.updateDetailsMenuItem()
                self?.updateBatteryInfo()
            }
            .store(in: &cancellables)
        
        powerManager.$isRunning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
                self?.updateDetailsMenuItem()
            }
            .store(in: &cancellables)
        
        powerManager.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
                self?.updateDetailsMenuItem()
            }
            .store(in: &cancellables)
        
        powerManager.$updateInterval
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateIntervalMenu()
            }
            .store(in: &cancellables)
        
        powerManager.$displayMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDisplayModeMenu()
                self?.updateBatteryInfo()
            }
            .store(in: &cancellables)
        
        // Initial battery update
        updateBatteryInfo()
        updateBatteryDisplayModeMenu()
    }
    
    private func updateStatusItem() {
        guard let button = statusItem?.button else { return }
        
        button.title = powerManager.statusText
        button.toolTip = powerManager.tooltipText
        
        // Change appearance based on status
        if powerManager.errorMessage != nil {
            button.appearsDisabled = true
        } else {
            button.appearsDisabled = false
        }
    }
    
    private func updateDetailsMenuItem() {
        guard let menu = statusItem?.menu else { return }
        
        // Update details item
        if let detailsItem = menu.item(at: 0) {
            if let metrics = powerManager.currentMetrics {
                detailsItem.title = metrics.detailedBreakdown.replacingOccurrences(of: "\n", with: " | ")
            } else if let error = powerManager.errorMessage {
                detailsItem.title = "Error: \(error)"
            } else {
                detailsItem.title = "Power Details"
            }
        }
    }
    
    private func updateIntervalMenu() {
        guard let menu = statusItem?.menu,
              let intervalItem = menu.item(withTitle: "Refresh Rate") ?? 
                                 menu.items.first(where: { $0.title.hasPrefix("Refresh Rate") }),
              let submenu = intervalItem.submenu else { return }
        
        // Update the main menu item title with current interval
        intervalItem.title = "Refresh Rate: \(powerManager.updateInterval)ms"
        
        // Update checkmarks for current interval
        for item in submenu.items {
            item.state = (item.tag == powerManager.updateInterval) ? .on : .off
        }
    }
    
    private func updateDisplayModeMenu() {
        guard let menu = statusItem?.menu,
              let showItem = menu.item(withTitle: "Averaging Period") ?? 
                             menu.items.first(where: { $0.title.hasPrefix("Averaging Period") }),
              let showSubmenu = showItem.submenu else { return }
        
        // Update the main menu item title with current mode
        let currentDisplayModeText = powerManager.displayMode.displayName
        showItem.title = "Averaging Period: \(currentDisplayModeText)"
        
        // Update checkmarks for display mode
        for item in showSubmenu.items {
            if item.tag == -1 {
                // Instant mode
                item.state = (powerManager.displayMode == .instant) ? .on : .off
            } else if item.tag >= 0 {
                // Average mode (including tag 0 for max)
                if case .average(let seconds) = powerManager.displayMode, seconds == item.tag {
                    item.state = .on
                } else {
                    item.state = .off
                }
            }
        }
    }
    
    private func updateBatteryDisplayModeMenu() {
        guard let batterySubmenu = batteryTimeMenuItem?.submenu else { return }
        
        // Update checkmarks for battery display mode
        for item in batterySubmenu.items {
            if item.tag == -1 {
                // Instant mode
                item.state = (batteryDisplayMode == .instant) ? .on : .off
            } else if item.tag >= 0 {
                // Average mode (including tag 0 for max)
                if case .average(let seconds) = batteryDisplayMode, seconds == item.tag {
                    item.state = .on
                } else {
                    item.state = .off
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func setDisplayMode(_ sender: NSMenuItem) {
        print("MenuBarController: Setting display mode with tag \(sender.tag)")
        if sender.tag == -1 {
            // Instant mode
            print("MenuBarController: Setting instant mode")
            powerManager.setDisplayMode(.instant)
        } else if sender.tag >= 0 {
            // Average mode (including tag 0 for max)
            print("MenuBarController: Setting average mode for \(sender.tag) seconds")
            powerManager.setDisplayMode(.average(seconds: sender.tag))
        }
    }
    
    @objc private func setInterval(_ sender: NSMenuItem) {
        let newInterval = sender.tag
        powerManager.setUpdateInterval(newInterval)
    }
    
    @objc private func setBatteryDisplayMode(_ sender: NSMenuItem) {
        print("MenuBarController: Setting battery display mode with tag \(sender.tag)")
        if sender.tag == -1 {
            // Instant mode
            print("MenuBarController: Setting battery instant mode")
            batteryDisplayMode = .instant
        } else if sender.tag >= 0 {
            // Average mode (including tag 0 for max)
            print("MenuBarController: Setting battery average mode for \(sender.tag) seconds")
            batteryDisplayMode = .average(seconds: sender.tag)
        }
        
        updateBatteryDisplayModeMenu()
        updateBatteryInfo()
    }

    @objc private func showGraph() {
        print("MenuBarController: showGraph called!")
        if graphPopover == nil {
            print("MenuBarController: Creating new popover")
            let view = PowerGraphView(powerManager: powerManager)
            let hosting = NSHostingController(rootView: view)
            let popover = NSPopover()
            popover.contentSize = NSSize(width: 340, height: 260)
            popover.behavior = .transient
            popover.contentViewController = hosting
            graphPopover = popover
        }

        if let button = statusItem?.button, let popover = graphPopover {
            print("MenuBarController: Showing popover")
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        } else {
            print("MenuBarController: Failed to show popover - button or popover is nil")
        }
    }
    
    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - Battery Methods
    
    private func updateBatteryInfo() {
        guard let batteryInfo = BatteryService.getBatteryInfo() else {
            print("MenuBarController: Battery info unavailable")
            batteryTimeMenuItem?.title = "Battery: Unavailable"
            batteryTimeMenuItem?.isHidden = false
            return
        }
        
        // Always show the battery menu item
        batteryTimeMenuItem?.isHidden = false
        
        // Get power value based on battery's own display mode
        guard let currentPowerW = powerManager.getPowerValue(for: batteryDisplayMode) else {
            print("MenuBarController: No power value available for battery mode \(batteryDisplayMode)")
            batteryTimeMenuItem?.title = "Battery: Calculating..."
            return
        }
        
        print("MenuBarController: Using power value: \(String(format: "%.1f", currentPowerW))W for battery calculation (mode: \(batteryDisplayMode))")
        
        // Format the remaining energy in Wh
        let remainingWh = String(format: "%.1f", batteryInfo.remainingEnergyWh)
        
        // Calculate remaining time using current displayed power
        if let remainingTime = BatteryService.calculateRemainingTime(batteryInfo: batteryInfo, averagePowerW: currentPowerW) {
            let formattedTime = BatteryService.formatRemainingTime(remainingTime)
            
            if batteryInfo.isOnBatteryPower {
                batteryTimeMenuItem?.title = "Battery: \(formattedTime) remaining - \(remainingWh)Wh"
                print("MenuBarController: Battery time updated: \(formattedTime) remaining (on battery) - \(remainingWh)Wh")
            } else {
                batteryTimeMenuItem?.title = "Battery: \(formattedTime) remaining (charging) - \(remainingWh)Wh"
                print("MenuBarController: Battery time updated: \(formattedTime) remaining (charging) - \(remainingWh)Wh")
            }
        } else {
            // If we can't calculate time, at least show the energy remaining
            if batteryInfo.isOnBatteryPower {
                batteryTimeMenuItem?.title = "Battery: \(remainingWh)Wh remaining"
                print("MenuBarController: Battery energy updated: \(remainingWh)Wh remaining (on battery)")
            } else {
                batteryTimeMenuItem?.title = "Battery: \(remainingWh)Wh remaining (charging)"
                print("MenuBarController: Battery energy updated: \(remainingWh)Wh remaining (charging)")
            }
        }
    }
} 
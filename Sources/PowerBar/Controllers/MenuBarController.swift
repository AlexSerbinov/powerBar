import Cocoa
import SwiftUI
import Combine

// MARK: - Menu Bar Controller
class MenuBarController: ObservableObject {
    private var statusItem: NSStatusItem?
    private var powerManager = PowerManager()
    private var cancellables = Set<AnyCancellable>()
    
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
        
        // Display mode menu - simplified structure
        let displayModeItem = NSMenuItem(title: "Show Consumption", action: nil, keyEquivalent: "")
        let displayModeSubmenu = NSMenu()
        
        // Instant consumption
        let instantItem = NSMenuItem(title: "Instant", action: #selector(setDisplayMode(_:)), keyEquivalent: "")
        instantItem.target = self
        instantItem.tag = -1 // Special tag for instant mode
        displayModeSubmenu.addItem(instantItem)
        
        displayModeSubmenu.addItem(NSMenuItem.separator())
        
        // Average options directly in submenu (no nested submenu)
        for period in powerManager.availableAveragePeriods {
            let avgItem = NSMenuItem(title: "\(period)s Average", action: #selector(setDisplayMode(_:)), keyEquivalent: "")
            avgItem.target = self
            avgItem.tag = period
            displayModeSubmenu.addItem(avgItem)
        }
        
        displayModeItem.submenu = displayModeSubmenu
        menu.addItem(displayModeItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Update interval submenu
        let intervalItem = NSMenuItem(title: "Update Interval", action: nil, keyEquivalent: "")
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
        
        // Quit item
        let quitItem = NSMenuItem(title: "Quit PowerBar", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    private func setupObservers() {
        // Observe power manager changes
        powerManager.$currentMetrics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
                self?.updateDetailsMenuItem()
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
            }
            .store(in: &cancellables)
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
              let intervalItem = menu.item(withTitle: "Update Interval"),
              let submenu = intervalItem.submenu else { return }
        
        // Update checkmarks for current interval
        for item in submenu.items {
            item.state = (item.tag == powerManager.updateInterval) ? .on : .off
        }
    }
    
    private func updateDisplayModeMenu() {
        guard let menu = statusItem?.menu,
              let showItem = menu.item(withTitle: "Show Consumption"),
              let showSubmenu = showItem.submenu else { return }
        
        // Update checkmarks for display mode
        for item in showSubmenu.items {
            if item.tag == -1 {
                // Instant mode
                item.state = (powerManager.displayMode == .instant) ? .on : .off
            } else if item.tag > 0 {
                // Average mode
                if case .average(let seconds) = powerManager.displayMode, seconds == item.tag {
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
        } else if sender.tag > 0 {
            // Average mode
            print("MenuBarController: Setting average mode for \(sender.tag) seconds")
            powerManager.setDisplayMode(.average(seconds: sender.tag))
        }
    }
    
    @objc private func setInterval(_ sender: NSMenuItem) {
        let newInterval = sender.tag
        powerManager.setUpdateInterval(newInterval)
    }
    
    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }
} 
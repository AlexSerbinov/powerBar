import Foundation
import Combine

// MARK: - Display Mode
enum DisplayMode: Equatable {
    case instant
    case average(seconds: Int)
    
    var displayName: String {
        switch self {
        case .instant:
            return "Instant"
        case .average(let seconds):
            if seconds >= 60 {
                return "\(seconds / 60)min"
            } else {
                return "\(seconds)s"
            }
        }
    }
}

// MARK: - Power Reading
struct PowerReading {
    let allPower: Double
    let sysPower: Double
    let timestamp: Date
}

// MARK: - Power Manager
class PowerManager: ObservableObject {
    @Published var currentMetrics: MacMonMetrics?
    @Published var isRunning = false
    @Published var errorMessage: String?
    @Published var updateInterval: Int = 1000 // milliseconds
    @Published var displayMode: DisplayMode = .instant
    
    private var macmonProcess: Process?
    private var cancellables = Set<AnyCancellable>()
    
    // History tracking for averages
    private var powerHistory: [PowerReading] = []
    private let maxHistoryDuration: TimeInterval = 300 // 5 minutes max history
    
    // Available average periods
    let availableAveragePeriods = [5, 10, 30, 60] // seconds
    
    // Possible macmon locations
    private let macmonPaths = [
        "/opt/homebrew/bin/macmon",
        "/usr/local/bin/macmon",
        "/usr/bin/macmon"
    ]
    
    // MARK: - Lifecycle
    
    func startMonitoring() {
        guard !isRunning else { return }
        
        // Check if macmon is available
        guard let macmonPath = findMacMon() else {
            errorMessage = "macmon is not installed or not in PATH"
            return
        }
        
        setupMacMonProcess(macmonPath: macmonPath)
        startMacMonProcess()
    }
    
    func stopMonitoring() {
        guard isRunning else { return }
        
        macmonProcess?.terminate()
        macmonProcess = nil
        isRunning = false
        currentMetrics = nil
        errorMessage = nil
        powerHistory.removeAll()
    }
    
    func setUpdateInterval(_ interval: Int) {
        updateInterval = interval
        if isRunning {
            stopMonitoring()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startMonitoring()
            }
        }
    }
    
    func setDisplayMode(_ mode: DisplayMode) {
        displayMode = mode
    }
    
    // MARK: - Average Calculation
    
    private func cleanupOldReadings() {
        let cutoffTime = Date().addingTimeInterval(-maxHistoryDuration)
        powerHistory.removeAll { $0.timestamp < cutoffTime }
    }
    
    private func getAverageForPeriod(_ seconds: Int) -> (allPower: Double, sysPower: Double)? {
        guard !powerHistory.isEmpty else { return nil }
        
        let cutoffTime = Date().addingTimeInterval(-TimeInterval(seconds))
        let recentReadings = powerHistory.filter { $0.timestamp >= cutoffTime }
        
        guard !recentReadings.isEmpty else { return nil }
        
        let avgAllPower = recentReadings.map { $0.allPower }.reduce(0, +) / Double(recentReadings.count)
        let avgSysPower = recentReadings.map { $0.sysPower }.reduce(0, +) / Double(recentReadings.count)
        
        return (allPower: avgAllPower, sysPower: avgSysPower)
    }
    
    // MARK: - Private Methods
    
    private func findMacMon() -> String? {
        for path in macmonPaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        // Fallback: try which command
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["macmon"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                return path?.isEmpty == false ? path : nil
            }
        } catch {
            // which command failed
        }
        
        return nil
    }
    
    private func setupMacMonProcess(macmonPath: String) {
        macmonProcess = Process()
        macmonProcess?.executableURL = URL(fileURLWithPath: macmonPath)
        macmonProcess?.arguments = ["pipe", "--interval", "\(updateInterval)"]
        
        let pipe = Pipe()
        macmonProcess?.standardOutput = pipe
        macmonProcess?.standardError = pipe
        
        // Handle process termination
        macmonProcess?.terminationHandler = { [weak self] process in
            DispatchQueue.main.async {
                self?.isRunning = false
                if process.terminationStatus != 0 {
                    self?.errorMessage = "macmon process terminated unexpectedly"
                }
            }
        }
        
        // Handle output
        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            
            let output = String(data: data, encoding: .utf8) ?? ""
            self?.processOutput(output)
        }
    }
    
    private func startMacMonProcess() {
        do {
            try macmonProcess?.run()
            isRunning = true
            errorMessage = nil
        } catch {
            errorMessage = "Failed to start macmon: \(error.localizedDescription)"
        }
    }
    
    private func processOutput(_ output: String) {
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedLine.isEmpty else { continue }
            
            do {
                let data = trimmedLine.data(using: .utf8) ?? Data()
                let metrics = try JSONDecoder().decode(MacMonMetrics.self, from: data)
                
                DispatchQueue.main.async {
                    self.currentMetrics = metrics
                    
                    // Add to power history
                    let reading = PowerReading(
                        allPower: metrics.allPower,
                        sysPower: metrics.sysPower,
                        timestamp: Date()
                    )
                    self.powerHistory.append(reading)
                    self.cleanupOldReadings()
                }
            } catch {
                print("Failed to decode JSON: \(error)")
                // Don't update errorMessage for individual parsing failures
                // as they might be partial lines
            }
        }
    }
}

// MARK: - Error Handling Extension
extension PowerManager {
    var statusText: String {
        if errorMessage != nil {
            return "Error"
        } else if let metrics = currentMetrics {
            switch displayMode {
            case .instant:
                return metrics.formattedPower
            case .average(let seconds):
                if let average = getAverageForPeriod(seconds) {
                    return String(format: "%.1fW", average.sysPower)
                } else {
                    return metrics.formattedPower // Fallback to instant if no average available
                }
            }
        } else if isRunning {
            return "Loading..."
        } else {
            return "Stopped"
        }
    }
    
    var tooltipText: String {
        if let errorMessage = errorMessage {
            return "Error: \(errorMessage)"
        } else if let metrics = currentMetrics {
            switch displayMode {
            case .instant:
                return metrics.detailedBreakdown
            case .average(let seconds):
                if let average = getAverageForPeriod(seconds) {
                    let avgBreakdown = """
                    Average (\(displayMode.displayName)):
                    System: \(String(format: "%.1fW", average.sysPower))
                    Total: \(String(format: "%.1fW", average.allPower))
                    
                    Current:
                    \(metrics.detailedBreakdown)
                    """
                    return avgBreakdown
                } else {
                    return "Average (\(displayMode.displayName)): Collecting data...\n\n" + metrics.detailedBreakdown
                }
            }
        } else {
            return "PowerBar - macOS Power Monitor"
        }
    }
} 
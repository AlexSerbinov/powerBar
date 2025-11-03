import Foundation

// MARK: - Battery Service
class BatteryService {
    
    // MARK: - Public Methods
    
    static func getBatteryInfo() -> BatteryInfo? {
        print("BatteryService: Getting battery info from ioreg...")
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/ioreg")
        task.arguments = ["-a", "-r", "-n", "AppleSmartBattery"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            guard task.terminationStatus == 0 else {
                print("BatteryService: ioreg command failed with status \(task.terminationStatus)")
                return nil
            }
            
            return parseBatteryData(data)
            
        } catch {
            print("BatteryService: Failed to run ioreg command: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private static func parseBatteryData(_ data: Data) -> BatteryInfo? {
        do {
            // Parse the XML plist output from ioreg
            guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] else {
                print("BatteryService: Failed to parse plist - not an array of dictionaries")
                return nil
            }
            
            guard let batteryDict = plist.first else {
                print("BatteryService: No battery dictionary found in plist")
                return nil
            }
            
            // Extract the required fields
            let isCharging = batteryDict["IsCharging"] as? Bool ?? false
            let externalConnected = batteryDict["ExternalConnected"] as? Bool ?? false
            let currentCapacity = batteryDict["AppleRawCurrentCapacity"] as? Int ?? 0
            let voltage = batteryDict["Voltage"] as? Int ?? 0
            
            // Validate the data
            guard currentCapacity > 0, voltage > 0 else {
                print("BatteryService: Invalid battery data - capacity: \(currentCapacity), voltage: \(voltage)")
                return nil
            }
            
            let batteryInfo = BatteryInfo(
                isCharging: isCharging,
                externalConnected: externalConnected,
                currentCapacity: currentCapacity,
                voltage: voltage
            )
            
            print("BatteryService: Successfully parsed battery info")
            print(batteryInfo.debugDescription)
            
            return batteryInfo
            
        } catch {
            print("BatteryService: Failed to parse battery data: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    static func calculateRemainingTime(batteryInfo: BatteryInfo, averagePowerW: Double) -> TimeInterval? {
        guard batteryInfo.isOnBatteryPower else {
            print("BatteryService: Device is on external power, no time calculation needed")
            return nil
        }
        
        guard averagePowerW > 0.1 else {
            print("BatteryService: Average power too low (\(averagePowerW)W) for reliable calculation")
            return nil
        }
        
        let remainingTimeHours = batteryInfo.remainingEnergyWh / averagePowerW
        
        guard remainingTimeHours.isFinite && remainingTimeHours > 0 else {
            print("BatteryService: Invalid remaining time calculation: \(remainingTimeHours)")
            return nil
        }
        
        let remainingTimeSeconds = remainingTimeHours * 3600 // Convert to seconds
        
        print("BatteryService: Calculated remaining time: \(String(format: "%.2f", remainingTimeHours)) hours")
        
        return remainingTimeSeconds
    }
    
    static func formatRemainingTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
} 
import Foundation

// MARK: - Battery Info Model
struct BatteryInfo {
    let isCharging: Bool
    let externalConnected: Bool
    let currentCapacity: Int // в mAh
    let voltage: Int         // в mV
    
    // Calculated properties
    var remainingEnergyWh: Double {
        // Convert mAh to Ah, mV to V, then calculate Wh
        return (Double(currentCapacity) / 1000.0) * (Double(voltage) / 1000.0)
    }
    
    var isOnBatteryPower: Bool {
        return !externalConnected
    }
    
    // Debug description
    var debugDescription: String {
        return """
        BatteryInfo:
        - Charging: \(isCharging)
        - External Power: \(externalConnected)
        - Capacity: \(currentCapacity) mAh
        - Voltage: \(voltage) mV
        - Remaining Energy: \(String(format: "%.2f", remainingEnergyWh)) Wh
        """
    }
} 
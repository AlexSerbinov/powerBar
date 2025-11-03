import Foundation

// MARK: - MacMon JSON Response Model
struct MacMonMetrics: Codable {
    let allPower: Double
    let anePower: Double
    let cpuPower: Double
    let ecpuUsage: [Double]
    let gpuPower: Double
    let gpuRamPower: Double
    let gpuUsage: [Double]
    let memory: MemoryInfo
    let pcpuUsage: [Double]
    let ramPower: Double
    let sysPower: Double
    let temp: TemperatureInfo
    let timestamp: String
    
    private enum CodingKeys: String, CodingKey {
        case allPower = "all_power"
        case anePower = "ane_power"
        case cpuPower = "cpu_power"
        case ecpuUsage = "ecpu_usage"
        case gpuPower = "gpu_power"
        case gpuRamPower = "gpu_ram_power"
        case gpuUsage = "gpu_usage"
        case memory
        case pcpuUsage = "pcpu_usage"
        case ramPower = "ram_power"
        case sysPower = "sys_power"
        case temp
        case timestamp
    }
}

// MARK: - Memory Information
struct MemoryInfo: Codable {
    let ramTotal: Int64
    let ramUsage: Int64
    let swapTotal: Int64
    let swapUsage: Int64
    
    private enum CodingKeys: String, CodingKey {
        case ramTotal = "ram_total"
        case ramUsage = "ram_usage"
        case swapTotal = "swap_total"
        case swapUsage = "swap_usage"
    }
}

// MARK: - Temperature Information
struct TemperatureInfo: Codable {
    let cpuTempAvg: Double
    let gpuTempAvg: Double
    
    private enum CodingKeys: String, CodingKey {
        case cpuTempAvg = "cpu_temp_avg"
        case gpuTempAvg = "gpu_temp_avg"
    }
}

// MARK: - Convenience Extensions
extension MacMonMetrics {
    /// Formatted power consumption for menu bar display (using sys_power)
    var formattedPower: String {
        return String(format: "%.1fW", sysPower)
    }
    
    /// Detailed breakdown for tooltip or menu
        // Total: \(String(format: "%.1fW", allPower))
    var detailedBreakdown: String {
        return """
        System: \(String(format: "%.1fW", sysPower))
        CPU: \(String(format: "%.1fW", cpuPower))
        GPU: \(String(format: "%.1fW", gpuPower))
        ANE: \(String(format: "%.1fW", anePower))
        RAM: \(String(format: "%.1fW", ramPower))
        """
    }
} 
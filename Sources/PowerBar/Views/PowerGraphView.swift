import SwiftUI
import Charts

struct PowerGraphView: View {
    @ObservedObject var powerManager: PowerManager
    @State private var period: Int

    init(powerManager: PowerManager, initialPeriod: Int = 60) {
        self.powerManager = powerManager
        _period = State(initialValue: initialPeriod)
    }

    var body: some View {
        VStack {
            Picker("Period", selection: $period) {
                ForEach(powerManager.availableGraphPeriods, id: \.self) { value in
                    Text(friendlyName(for: value)).tag(value)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.horizontal, .top])

            Chart(data) { reading in
                LineMark(
                    x: .value("Time", reading.timestamp),
                    y: .value("Power", reading.sysPower)
                )
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
            .frame(width: 300, height: 200)
            .padding([.horizontal, .bottom])
        }
    }

    private var data: [PowerReading] {
        powerManager.readings(for: period)
    }

    private func friendlyName(for seconds: Int) -> String {
        switch seconds {
        case 60: return "1 min"
        case 600: return "10 min"
        case 3600: return "1 hr"
        case 21600: return "6 hr"
        default:
            return "\(seconds)s"
        }
    }
}

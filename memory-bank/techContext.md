# Технічний Контекст

## Платформа
- macOS 13.0+
- Swift 5.7+
- Xcode 14+

## Основні технології
- **Swift** - основна мова програмування
- **SwiftUI** - UI фреймворк
- **AppKit** - menu bar інтеграція
- **Foundation** - JSON парсинг і процеси
- **Combine** - reactive programming для settings updates

## Зовнішні залежності
- **macmon** - утиліта для отримання метрик споживання енергії
  - Команда: `macmon pipe`
  - Формат виводу: JSON (один об'єкт на рядок)
  - Інтервал оновлення: 1000ms (за замовчуванням)

## Архітектурні рішення
- Menu bar only додаток (LSUIElement = YES)
- Неперервний процес macmon pipe
- Асинхронне читання stdout
- JSON декодинг через Codable
- **Settings architecture** - централізоване управління налаштуваннями

## Обмеження
- Потребує встановленого macmon
- Працює тільки на macOS
- Залежить від доступності /usr/local/bin/macmon або шляху в PATH

## Налаштування розробки
- Target: macOS App
- Bundle Identifier: com.yourname.powerbar
- Deployment Target: macOS 13.0

---

## 🛠️ Технічні вимоги для системи налаштувань (19.01.2025)

### Додаткові технології
- **UserDefaults** - persistence налаштувань
- **NSWindow** - Settings window management
- **NSHostingController** - SwiftUI ↔ AppKit bridge
- **ServiceManagement** - auto-start at login functionality

### Settings Architecture Components

#### **Core Settings Types**
```swift
// Enums для типизованих налаштувань
enum MenuBarFormat: String, CaseIterable {
    case standard = "X.XW"           // "10.5W"
    case withSpaces = "X.X W"        // "10.5 W"  
    case withUnit = "X.X Watts"      // "10.5 Watts"
    case numberOnly = "X.X"          // "10.5"
}

enum FontSize: String, CaseIterable {
    case small = "Small"
    case medium = "Medium" 
    case large = "Large"
}

enum MetricType: String, CaseIterable {
    case sysPower = "sys_power"
    case allPower = "all_power"
    case cpuPower = "cpu_power"
}

enum TooltipLevel: String, CaseIterable {
    case minimal = "Minimal"
    case standard = "Standard"
    case detailed = "Detailed"
}

enum BatteryFormat: String, CaseIterable {
    case timeAndWh = "Time + Wh"
    case timeOnly = "Time Only"
    case whOnly = "Wh Only"
}
```

#### **Settings Persistence Strategy**
```swift
// UserDefaults keys
extension UserDefaults {
    // Display settings
    var menuBarFormat: MenuBarFormat { ... }
    var decimalPlaces: Int { ... }
    var fontSize: FontSize { ... }
    var primaryMetric: MetricType { ... }
    
    // Monitoring settings
    var autoStartAtLogin: Bool { ... }
    var historyDuration: TimeInterval { ... }
    var alertThresholds: [Double] { ... }
    
    // Battery settings  
    var batteryUpdateFrequency: TimeInterval { ... }
    var batteryDisplayFormat: BatteryFormat { ... }
    var lowBatteryAlerts: [Double] { ... }
    
    // Appearance settings
    var tooltipDetailLevel: TooltipLevel { ... }
    var colorCodingEnabled: Bool { ... }
    var menuAnimations: Bool { ... }
}
```

#### **Settings Window Technical Requirements**
- **Window Size**: 600x500 points (optimal for tabs)
- **Window Style**: Titled, closable, miniaturizable
- **Modality**: Non-modal (floating window)
- **Memory**: Lazy loading of tab content
- **Performance**: <100ms response time for setting changes

#### **Auto-start Implementation**
```swift
// ServiceManagement для auto-start
import ServiceManagement

func setAutoStart(_ enabled: Bool) {
    let identifier = "com.yourname.powerbar.launcher"
    if enabled {
        SMLoginItemSetEnabled(identifier as CFString, true)
    } else {
        SMLoginItemSetEnabled(identifier as CFString, false)
    }
}
```

#### **Live Preview Architecture**
```swift
// Settings зміни миттєво відображаються в menu bar
class SettingsManager: ObservableObject {
    @Published var menuBarFormat: MenuBarFormat = .standard {
        didSet {
            // Миттєво оновити menu bar display
            NotificationCenter.default.post(
                name: .menuBarFormatChanged, 
                object: menuBarFormat
            )
        }
    }
}
```

### Performance Considerations

#### **Settings Loading**
- **Startup time**: <50ms для завантаження всіх налаштувань
- **Memory usage**: <2MB для Settings window
- **Persistence**: Batch writes to UserDefaults
- **Validation**: Client-side validation для всіх inputs

#### **UI Responsiveness**  
- **Tab switching**: <16ms (60 FPS)
- **Setting changes**: Debounced updates (300ms)
- **Live preview**: <100ms delay
- **Window open/close**: <200ms animation

#### **Data Validation**
```swift
// Валідація налаштувань
struct SettingsValidator {
    static func validateDecimalPlaces(_ places: Int) -> Int {
        return max(0, min(3, places))
    }
    
    static func validateUpdateFrequency(_ frequency: TimeInterval) -> TimeInterval {
        return max(0.1, min(10.0, frequency))
    }
    
    static func validateHistoryDuration(_ duration: TimeInterval) -> TimeInterval {
        return max(300, min(86400, duration)) // 5min to 24h
    }
}
```

### Testing Infrastructure

#### **Unit Testing Requirements**
- **Settings persistence**: Тестування UserDefaults read/write
- **Validation logic**: Тестування всіх validation функцій  
- **Format functions**: Тестування string formatting
- **Default values**: Тестування initial state

#### **UI Testing Requirements**
- **Settings window**: Automated UI tests для всіх tabs
- **Live preview**: Тестування миттєвих змін
- **Validation feedback**: Тестування error states
- **Reset functionality**: Тестування reset to defaults

#### **Integration Testing**
- **Settings ↔ PowerManager**: Тестування setting changes propagation
- **Settings ↔ MenuBar**: Тестування UI updates
- **Settings ↔ Battery**: Тестування battery settings integration
- **Auto-start**: Тестування login item functionality

### Security & Privacy

#### **Data Storage**
- **UserDefaults only**: Ніяких файлів на диску
- **No network**: Всі налаштування локальні
- **No sensitive data**: Тільки UI preferences
- **Sandboxing**: Повна сумісність з App Store sandboxing

#### **Permissions**
- **Auto-start**: Потребує ServiceManagement entitlement
- **No additional permissions**: Всі інші функції працюють без дозволів
- **Privacy**: Ніякі особисті дані не збираються

---
*Оновлено: 19.01.2025 - ТЕХНІЧНІ ВИМОГИ ДЛЯ НАЛАШТУВАНЬ* 
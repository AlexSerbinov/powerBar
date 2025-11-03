# Системні Патерни

## Архітектура додатку

### 1. Menu Bar Integration
```
NSStatusItem -> Menu Bar Button
    ├── Title: Power consumption value
    ├── Tooltip: Detailed breakdown
    └── Menu: Additional options
```

### 2. Data Flow
```
macmon pipe → Process → JSON → Model → UI
```

### 3. Компоненти системи

#### PowerManager
- Відповідає за запуск і управління процесом macmon
- Читає stdout асинхронно
- Обробляє помилки процесу

#### MetricsModel
- Декодує JSON від macmon
- Зберігає поточні метрики
- Публікує зміни через @Published

#### MenuBarController
- Управляє NSStatusItem
- Оновлює відображення
- Обробляє користувацькі взаємодії

### 4. Патерни проєктування

#### Observer Pattern
- SwiftUI автоматично реагує на зміни в MetricsModel
- Combine framework для асинхронних операцій

#### Command Pattern
- Команди для запуску/зупинки процесу macmon
- Команди для обробки меню

#### State Management
- Централізоване зберігання стану в MetricsModel
- Reactive updates через SwiftUI

### 5. Error Handling
- Graceful degradation при недоступності macmon
- Retry logic для втраченого з'єднання
- User notifications для критичних помилок

---

## 🛠️ Архітектура системи налаштувань (19.01.2025)

### 6. Settings Architecture

#### Settings Data Flow
```
UserDefaults ↔ SettingsManager ↔ UI Components
                      ↓
              PowerManager/MenuBarController
                      ↓
                Menu Bar Display
```

#### Settings Manager Pattern
```swift
class SettingsManager: ObservableObject {
    // Published properties для reactive updates
    @Published var menuBarFormat: MenuBarFormat = .standard
    @Published var decimalPlaces: Int = 1
    @Published var primaryMetric: MetricType = .sysPower
    
    // UserDefaults persistence
    private let userDefaults = UserDefaults.standard
    
    // Settings categories
    var displaySettings: DisplaySettings { ... }
    var monitoringSettings: MonitoringSettings { ... }
    var batterySettings: BatterySettings { ... }
    var appearanceSettings: AppearanceSettings { ... }
}
```

#### Settings UI Architecture
```
SettingsWindow (NSWindow)
    ├── NSHostingController
    └── SettingsView (SwiftUI)
        ├── TabView
        │   ├── DisplaySettingsView
        │   ├── MonitoringSettingsView  
        │   ├── BatterySettingsView
        │   ├── AppearanceSettingsView
        │   └── AdvancedSettingsView
        └── SettingsToolbar
```

#### Integration Patterns

##### 1. **Reactive Settings Updates**
```swift
// Settings зміни автоматично оновлюють UI
settingsManager.$menuBarFormat
    .receive(on: DispatchQueue.main)
    .sink { [weak self] format in
        self?.updateMenuBarDisplay(format: format)
    }
    .store(in: &cancellables)
```

##### 2. **Settings Persistence Pattern**
```swift
// Автоматичне збереження при зміні
@Published var decimalPlaces: Int = 1 {
    didSet {
        userDefaults.set(decimalPlaces, forKey: "decimalPlaces")
    }
}
```

##### 3. **Settings Validation Pattern**
```swift
// Валідація значень перед застосуванням
func setDecimalPlaces(_ places: Int) {
    let validatedPlaces = max(0, min(3, places))
    self.decimalPlaces = validatedPlaces
}
```

#### Settings Categories Structure

##### **Display Settings**
- Контролюють відображення в menu bar
- Миттєво оновлюють UI без перезапуску
- Включають формат, точність, розмір шрифту

##### **Monitoring Settings**  
- Керують процесом моніторингу
- Можуть потребувати перезапуск macmon процесу
- Включають автостарт, історію, алерти

##### **Battery Settings**
- Контролюють батарейні функції
- Незалежні від основного моніторингу
- Включають частоту оновлень, формат відображення

##### **Appearance Settings**
- Візуальні налаштування інтерфейсу  
- Миттєво застосовуються
- Включають кольори, анімації, tooltip

##### **Advanced Settings**
- Професійні функції та діагностика
- Можуть впливати на продуктивність
- Включають експорт, shortcuts, debug

### 7. Settings Window Management

#### Window Lifecycle
```swift
class SettingsWindowController: NSWindowController {
    private var settingsManager: SettingsManager
    
    // Singleton pattern для налаштувань
    static var shared: SettingsWindowController?
    
    // Window показується як modal або floating
    func showSettings() {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
```

#### Settings Menu Integration
```swift
// В MenuBarController додається пункт Settings
let settingsItem = NSMenuItem(
    title: "Settings...", 
    action: #selector(showSettings), 
    keyEquivalent: ","
)
settingsItem.target = self
menu.addItem(settingsItem)
```

### 8. Settings Performance Patterns

#### **Lazy Loading**
- Налаштування завантажуються по потребі
- UI компоненти створюються динамічно
- Мінімальний impact на startup час

#### **Batch Updates**
- Множинні зміни налаштувань об'єднуються
- Уникнення частих перерахунків
- Debounced UI updates

#### **Memory Management**
- Settings window може закриватися без втрати стану
- Weak references для уникнення retain cycles
- Ефективне використання UserDefaults

### 9. Settings Testing Strategy

#### **Unit Testing**
```swift
// Тестування SettingsManager логіки
func testMenuBarFormatChange() {
    let settings = SettingsManager()
    settings.menuBarFormat = .withSpaces
    XCTAssertEqual(settings.formatPowerValue(10.5), "10.5 W")
}
```

#### **UI Testing**  
- Автоматизовані тести Settings window
- Перевірка live preview функціональності
- Validation тестування

#### **Integration Testing**
- Тестування Settings ↔ PowerManager інтеграції
- Перевірка persistence між сесіями
- Тестування reset to defaults 
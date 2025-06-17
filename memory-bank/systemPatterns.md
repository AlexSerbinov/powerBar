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
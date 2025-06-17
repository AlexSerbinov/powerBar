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

## Обмеження
- Потребує встановленого macmon
- Працює тільки на macOS
- Залежить від доступності /usr/local/bin/macmon або шляху в PATH

## Налаштування розробки
- Target: macOS App
- Bundle Identifier: com.yourname.powerbar
- Deployment Target: macOS 13.0 
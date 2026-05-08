# Площадка — iOS App

SwiftUI-приложение для бронирования футбольных полей.

## Требования

- Xcode 15+
- iOS 16+
- macOS 13+

## Подключение к Xcode

1. Открой Xcode → **File → New → Project**
2. Выбери **iOS → App**, нажми Next
3. Заполни:
   - Product Name: `Ploshchadka`
   - Bundle Identifier: `com.football.ploshchadka`
   - Interface: **SwiftUI**
   - Language: **Swift**
4. Выбери папку — укажи **эту папку** (`iOS/`), нажми Create
5. Xcode создаст проект. **Удали** `ContentView.swift`, который он создаст
6. Перетащи в проект папки `Models/`, `Network/`, `Store/`, `Views/` и файлы `PloshchadkaApp.swift`, `ContentView.swift`, `Info.plist` из папки `iOS/Ploshchadka/`
7. При перетаскивании выбери **"Copy items if needed"** и **"Create groups"**
8. В Xcode выдели проект → вкладка **Info** → убедись, что `Info.plist` подключён

## Настройка сервера

В файле `Network/APIClient.swift` измени `baseURL`:

```swift
// Симулятор (сервер на той же машине)
var baseURL = "http://localhost:8080/api"

// Реальное устройство (замени на IP вашего компьютера)
var baseURL = "http://192.168.1.100:8080/api"
```

Чтобы узнать IP Mac: **System Settings → Wi-Fi → Details → IP Address**

## Запуск бэкенда

```bash
# В корне проекта
mvn spring-boot:run

# Или с профилем prod (PostgreSQL)
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

## Функциональность по ролям

| Роль     | Что доступно |
|----------|-------------|
| Гость    | Просмотр полей |
| USER     | Просмотр + бронирование + список своих бронирований + отмена |
| OWNER    | Всё выше + управление своими полями (добавить/редактировать/активировать/деактивировать) + просмотр бронирований своих полей |
| ADMIN    | USER + просмотр всех бронирований |

## Структура проекта

```
iOS/Ploshchadka/
├── PloshchadkaApp.swift         # Точка входа
├── ContentView.swift            # Роутер Auth / Main
├── Info.plist                   # Разрешение HTTP для dev
│
├── Models/
│   ├── Field.swift              # Модель поля
│   ├── Booking.swift            # Модель бронирования
│   └── APIModels.swift          # Request/Response DTO
│
├── Network/
│   └── APIClient.swift          # HTTP-клиент (async/await)
│
├── Store/
│   └── AuthStore.swift          # Стейт аутентификации
│
└── Views/
    ├── Auth/
    │   ├── LoginView.swift
    │   └── RegisterView.swift
    ├── Fields/
    │   ├── FieldsListView.swift
    │   └── FieldDetailView.swift
    ├── Booking/
    │   ├── BookingFormView.swift
    │   └── MyBookingsView.swift
    ├── Owner/
    │   ├── OwnerDashboardView.swift
    │   └── FieldFormView.swift
    └── Shared/
        ├── MainTabView.swift
        ├── ProfileView.swift
        └── CommonViews.swift    # Переиспользуемые компоненты
```

# Football Booking System

Система бронирования спортивных площадок. Два параллельных клиента: iOS (этот разработчик) и Android (другой разработчик).

## Структура проекта

```
football-booking-system/
├── src/                        # Spring Boot бэкенд
│   └── main/
│       ├── java/com/football/booking/
│       └── resources/
│           ├── application.yml
│           ├── static/         # Веб-фронтенд (HTML/JS/CSS)
│           └── db/migration/   # Flyway SQL миграции
├── iOS/                        # iOS приложение (SwiftUI)
│   ├── Info.plist
│   ├── Ploshchadka.xcodeproj
│   └── Ploshchadka/
│       ├── Models/             # Field.swift, Booking.swift, APIModels.swift
│       ├── Network/            # APIClient.swift
│       ├── Store/              # AuthStore.swift (@Observable)
│       └── Views/
│           ├── Auth/           # LoginView, RegisterView
│           ├── Booking/        # BookingFormView, MyBookingsView
│           ├── Fields/         # FieldsListView, FieldDetailView
│           ├── Owner/          # OwnerDashboardView, FieldFormView
│           └── Shared/         # CommonViews, MainTabView, ProfileView
└── CLAUDE.md

```

## Бэкенд

- **Stack**: Spring Boot 3.2.3, Java 21, H2 (dev), PostgreSQL (prod), JWT, Flyway
- **Запуск**: `JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home mvn spring-boot:run`
- **API base**: `http://localhost:8080/api`
- **Порт**: 8080. Если занят: `lsof -ti:8080 | xargs kill -9`
- **Ответы**: пагинированные `Page<T>` с полем `content`

### Ключевые эндпоинты
```
POST /api/auth/register   - регистрация { username, email, password, role }
POST /api/auth/login      - вход { username, password } → { token, username, role }
GET  /api/fields          - список полей (Page<Field>)
GET  /api/fields/my       - поля владельца (требует OWNER токен)
POST /api/fields          - создать поле
PUT  /api/fields/{id}     - изменить поле
DELETE /api/fields/{id}   - деактивировать поле
PUT  /api/fields/{id}/activate - активировать поле
GET  /api/bookings/my     - мои бронирования
GET  /api/bookings/field/{id} - бронирования поля
POST /api/bookings        - создать бронь { fieldId, startTime, endTime }
PUT  /api/bookings/{id}/cancel - отменить бронь
```

### Роли пользователей
- `USER` — бронирует поля
- `OWNER` — создаёт и управляет полями
- `ADMIN` — полный доступ

## iOS приложение

- **Xcode**: 26 (Xcode 26.4.1), **Swift**: 6, **iOS target**: 26.4
- **Открыть**: `iOS/Ploshchadka.xcodeproj`
- **Запуск**: Cmd+R в Xcode, симулятор iPhone 17 Pro
- **Concurrency**: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- **Observable**: использует `@Observable` (не `ObservableObject`), `@Environment(AuthStore.self)` (не `@EnvironmentObject`)

### Дизайн-система "Stadium Calm"
Цвета (определены в `CommonViews.swift` через `Color.fb*`):
- `fbBg` = `#F6F7F2` — фон страниц
- `fbSurface` = `#FFFFFF` — карточки
- `fbPrimary` = `#1B6B2E` — тёмно-зелёный, основной
- `fbAccent` = `#F6B73C` — янтарный акцент
- `fbText` = `#172117`, `fbTextMuted` = `#667263`
- `fbDanger` = `#B83A3A`, `fbInfo` = `#256C8A`

### Ключевые компоненты (CommonViews.swift)
- `FieldPitchView` — питч-иллюстрация (зелёный градиент + разметка поля)
- `BrandMark` — логотип (зелёный квадрат с ⚽)
- `PitchStrip` — акцентная полоска внизу (зелёный + янтарный)
- `StatusBadge`, `FieldTypeBadge` — pill-бейджи с точкой
- `StatCard`, `ErrorBanner`, `SuccessBanner`, `PrimaryButton`
- `FormField`, `FormSecureField` — поля форм (определены в LoginView.swift)

### APIClient
```swift
// Запрос с ответом
let fields: [Field] = try await APIClient.shared.fetch("/fields")
// Запрос без ответа
try await APIClient.shared.send("/fields/\(id)", method: "DELETE")
// POST с телом
let booking: Booking = try await APIClient.shared.fetch("/bookings", method: "POST", body: request)
```
Ошибки — `APIError` (invalidURL, network, http, decoding, unauthorized).
**Важно**: все catch-блоки должны быть исчерпывающими (Swift 6).

## Веб-фронтенд (static/)

- `index.html` — список полей
- `login.html`, `register.html` — авторизация
- `book.html` — бронирование
- `bookings.html` — мои бронирования
- `owner.html` — кабинет владельца
- `js/api.js` — утилиты: `apiGet/apiPost/apiPut/apiDelete` + объект `api { get, post, put, delete }`

## Важные особенности

1. **Info.plist** лежит в `iOS/Info.plist` (НЕ внутри Ploshchadka/), `GENERATE_INFOPLIST_FILE = NO`
2. **Flyway**: только `flyway-core` в pom.xml (без `flyway-database-postgresql` — это Flyway 10+)
3. **Java**: система должна использовать Java 21, не 17
4. **Сессии Claude Code**: хранятся локально, не синхронизируются между машинами

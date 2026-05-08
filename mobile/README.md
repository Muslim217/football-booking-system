# 📱 FieldBooking — Mobile (KMP)

Мобильное приложение для бронирования спортивных площадок.
Построено на **Kotlin Multiplatform + Compose Multiplatform**.

## Стек

| Слой           | Технология                                |
|---------------|-------------------------------------------|
| UI            | Compose Multiplatform (Android + iOS)     |
| HTTP          | Ktor Client 3.x                           |
| DI            | Koin 4.x                                  |
| State         | ViewModel + StateFlow                     |
| Сериализация  | kotlinx.serialization                     |
| Хранение токенов | DataStore (Android) / NSUserDefaults (iOS) |
| Загрузка фото | Coil 3.x                                  |

## Структура

```
mobile/
├── shared/                    ← Общая логика (Android + iOS)
│   └── src/
│       ├── commonMain/
│       │   ├── api/           ← Ktor API клиент (Auth, Field, Booking, User)
│       │   ├── model/         ← Модели данных
│       │   ├── repository/    ← Репозитории
│       │   ├── storage/       ← TokenStorage интерфейс
│       │   ├── di/            ← Koin модули
│       │   └── util/          ← Result<T>
│       ├── androidMain/       ← DataStore реализация
│       └── iosMain/           ← NSUserDefaults реализация
│
├── composeApp/                ← UI (экраны, навигация, ViewModel)
│   └── src/
│       ├── commonMain/
│       │   ├── ui/
│       │   │   ├── screens/   ← Login, Register, FieldList, FieldDetail, Schedule, MyBookings, Profile
│       │   │   ├── components/ ← Общие компоненты
│       │   │   └── theme/     ← Material3 тема
│       │   ├── navigation/    ← NavGraph
│       │   └── viewmodel/     ← AuthVM, FieldVM, BookingVM, ProfileVM
│       ├── androidMain/       ← MainActivity, Application, DI
│       └── iosMain/           ← MainViewController, iOS DI
│
└── iosApp/                    ← Swift точка входа
```

## Экраны

| Экран         | Описание                                         |
|--------------|--------------------------------------------------|
| Login        | Вход через username + пароль, JWT                |
| Register     | Регистрация                                      |
| FieldList    | Список площадок с пагинацией, карточки с фото    |
| FieldDetail  | Детали площадки + выбор даты                     |
| Schedule     | Сетка почасовых слотов, выбор и бронирование     |
| MyBookings   | История броней, отмена                           |
| Profile      | Редактирование имени/телефона, выход             |

## Запуск

### Android
1. Открой `mobile/` как проект в Android Studio (Hedgehog+)
2. Убедись что backend запущен на `http://localhost:8080`
3. В `shared/di/SharedModules.kt` проверь `BASE_URL`:
   - Эмулятор: `http://10.0.2.2:8080`
   - Реальное устройство: `http://192.168.x.x:8080`
4. Run → `composeApp`

### iOS
1. Открой `mobile/` в Android Studio
2. Выполни `./gradlew :shared:assembleXCFramework`
3. Открой `iosApp/iosApp.xcodeproj` в Xcode
4. Run на симуляторе или устройстве

## API

Backend: `football-booking-system` (Spring Boot)  
Документация: `http://localhost:8080/swagger-ui.html`

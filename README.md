# ⚽ Football Booking System

REST API для системы бронирования футбольных полей.

## Технологии

- **Java 17**
- **Spring Boot 3.2.3**
- **Spring Security + JWT** — авторизация
- **Spring Data JPA** — работа с базой данных
- **PostgreSQL** — основная база данных (production)
- **H2** — встроенная база данных (dev)
- **Swagger / OpenAPI** — документация API
- **Lombok** — сокращение шаблонного кода
- **Maven** — система сборки

## Быстрый старт

### Запуск с H2 (dev-профиль)

Не требует установки базы данных:

```bash
mvn spring-boot:run
```

Приложение запустится на `http://localhost:8080`.

H2 Console доступна по адресу: `http://localhost:8080/h2-console`
- JDBC URL: `jdbc:h2:mem:footballdb`
- Username: `sa`
- Password: _(пусто)_

### Запуск с PostgreSQL (prod-профиль)

1. Создайте базу данных:
```sql
CREATE DATABASE footballdb;
```

2. Обновите настройки в `application.yml` (секция `prod`):
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/footballdb
    username: your_username
    password: your_password
```

3. Запустите приложение:
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

## API Документация

После запуска Swagger UI доступен по адресу:

👉 **http://localhost:8080/swagger-ui.html**

## API Эндпоинты

### Авторизация (`/api/auth`)

| Метод | URL | Описание | Доступ |
|-------|-----|----------|--------|
| POST | `/api/auth/register` | Регистрация | Все |
| POST | `/api/auth/login` | Вход | Все |

### Футбольные поля (`/api/fields`)

| Метод | URL | Описание | Доступ |
|-------|-----|----------|--------|
| GET | `/api/fields` | Все активные поля | Все |
| GET | `/api/fields/{id}` | Поле по ID | Все |
| POST | `/api/fields` | Создать поле | ADMIN |
| PUT | `/api/fields/{id}` | Обновить поле | ADMIN |
| DELETE | `/api/fields/{id}` | Деактивировать поле | ADMIN |

### Бронирования (`/api/bookings`)

| Метод | URL | Описание | Доступ |
|-------|-----|----------|--------|
| POST | `/api/bookings` | Создать бронирование | Авторизованные |
| GET | `/api/bookings/my` | Мои бронирования | Авторизованные |
| GET | `/api/bookings` | Все бронирования | ADMIN |
| GET | `/api/bookings/{id}` | Бронирование по ID | Владелец / ADMIN |
| PUT | `/api/bookings/{id}/cancel` | Отменить бронирование | Владелец / ADMIN |
| GET | `/api/bookings/field/{fieldId}` | Бронирования по полю | Все |

## Примеры запросов

### Регистрация

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "player1",
    "email": "player1@example.com",
    "password": "password123"
  }'
```

### Вход

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "player1",
    "password": "password123"
  }'
```

### Создание поля (ADMIN)

```bash
curl -X POST http://localhost:8080/api/fields \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "name": "Поле №1",
    "address": "ул. Спортивная, 10",
    "fieldType": "OUTDOOR",
    "pricePerHour": 3000.00,
    "description": "Открытое поле с натуральным газоном"
  }'
```

### Создание бронирования

```bash
curl -X POST http://localhost:8080/api/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "fieldId": 1,
    "startTime": "2026-03-15T18:00:00",
    "endTime": "2026-03-15T20:00:00"
  }'
```

## Структура проекта

```
src/main/java/com/football/booking/
├── config/          — Конфигурация (Security, Swagger)
├── controller/      — REST контроллеры
├── dto/
│   ├── request/     — DTO запросов
│   └── response/    — DTO ответов
├── entity/          — JPA сущности
├── enums/           — Перечисления (Role, FieldType, BookingStatus)
├── exception/       — Обработка ошибок
├── repository/      — JPA репозитории
├── security/        — JWT (провайдер, фильтр, UserDetailsService)
├── service/         — Бизнес-логика
└── FootballBookingApplication.java
```

## Роли

- **USER** — может бронировать поля и управлять своими бронированиями
- **ADMIN** — управление полями + доступ ко всем бронированиям

Для создания ADMIN-пользователя измените роль напрямую в базе данных:
```sql
UPDATE users SET role = 'ADMIN' WHERE username = 'your_username';
```

## Лицензия

MIT

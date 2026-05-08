-- V1: Начальная схема базы данных

CREATE TABLE IF NOT EXISTS users (
    id         BIGSERIAL PRIMARY KEY,
    username   VARCHAR(50)  NOT NULL UNIQUE,
    email      VARCHAR(100) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    role       VARCHAR(20)  NOT NULL DEFAULT 'USER',
    created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fields (
    id            BIGSERIAL PRIMARY KEY,
    name          VARCHAR(100)   NOT NULL,
    address       VARCHAR(255)   NOT NULL,
    field_type    VARCHAR(30)    NOT NULL,
    price_per_hour DECIMAL(10,2) NOT NULL,
    description   VARCHAR(1000),
    owner_id      BIGINT         NOT NULL REFERENCES users(id),
    is_active     BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP      NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS bookings (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT         NOT NULL REFERENCES users(id),
    field_id    BIGINT         NOT NULL REFERENCES fields(id),
    start_time  TIMESTAMP      NOT NULL,
    end_time    TIMESTAMP      NOT NULL,
    total_price DECIMAL(10,2)  NOT NULL,
    status      VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
    created_at  TIMESTAMP      NOT NULL DEFAULT NOW()
);

-- Индексы для производительности
CREATE INDEX IF NOT EXISTS idx_bookings_field_id    ON bookings(field_id);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id     ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_time_range  ON bookings(field_id, start_time, end_time);
CREATE INDEX IF NOT EXISTS idx_fields_owner_id      ON fields(owner_id);
CREATE INDEX IF NOT EXISTS idx_fields_is_active     ON fields(is_active);

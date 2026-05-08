-- V3: Расширение User (телефон, имя) и Field (новые типы, фото)

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS full_name  VARCHAR(100),
    ADD COLUMN IF NOT EXISTS phone      VARCHAR(20);

ALTER TABLE fields
    ADD COLUMN IF NOT EXISTS photo_url  VARCHAR(500),
    ADD COLUMN IF NOT EXISTS city       VARCHAR(100);

-- Расширяем BookingStatus: добавляем COMPLETED
-- (enum в коде тоже обновим)

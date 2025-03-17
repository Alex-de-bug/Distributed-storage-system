INSERT INTO rooms (room_name, floor_number, area_sqm) VALUES
    ('Гостиная', 1, 35.5),
    ('Кухня', 1, 18.2),
    ('Спальня', 2, 24.8),
    ('Ванная', 2, 12.5),
    ('Кабинет', 2, 16.0),
    ('Гараж', 0, 42.0);

INSERT INTO device_types (type_name, description, measurement_unit) VALUES
    ('Термометр', 'Измеряет температуру воздуха', '°C'),
    ('Гигрометр', 'Измеряет влажность воздуха', '%'),
    ('Электросчетчик', 'Измеряет потребление электроэнергии', 'кВт⋅ч'),
    ('Датчик CO2', 'Измеряет концентрацию углекислого газа', 'ppm'),
    ('Датчик движения', 'Фиксирует движение в помещении', 'boolean');

INSERT INTO devices (device_name, device_type_id, room_id, installation_date) VALUES
    ('Термометр гостиная', 1, 1, NOW() - INTERVAL '365 days'),
    ('Термометр кухня', 1, 2, NOW() - INTERVAL '365 days'),
    ('Термометр спальня', 1, 3, NOW() - INTERVAL '365 days'),
    ('Гигрометр гостиная', 2, 1, NOW() - INTERVAL '300 days'),
    ('Гигрометр спальня', 2, 3, NOW() - INTERVAL '300 days'),
    ('Электросчетчик', 3, 2, NOW() - INTERVAL '400 days'),
    ('Датчик CO2 гостиная', 4, 1, NOW() - INTERVAL '250 days'),
    ('Датчик CO2 спальня', 4, 3, NOW() - INTERVAL '250 days'),
    ('Датчик движения гостиная', 5, 1, NOW() - INTERVAL '200 days'),
    ('Датчик движения кухня', 5, 2, NOW() - INTERVAL '200 days');

INSERT INTO users (username, email, created_at) VALUES
    ('admin', 'admin@smarthome.com', NOW() - INTERVAL '500 days'),
    ('user1', 'user1@example.com', NOW() - INTERVAL '400 days'),
    ('user2', 'user2@example.com', NOW() - INTERVAL '300 days'),
    ('user3', 'user3@example.com', NOW() - INTERVAL '200 days');

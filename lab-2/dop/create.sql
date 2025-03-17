
CREATE DATABASE smart_home_monitoring;

CREATE TABLE rooms (
    room_id SERIAL PRIMARY KEY,
    room_name VARCHAR(50) NOT NULL,
    floor_number SMALLINT NOT NULL,
    area_sqm NUMERIC(6,2) NOT NULL
);

CREATE TABLE device_types (
    device_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    measurement_unit VARCHAR(20)
);

CREATE TABLE devices (
    device_id SERIAL PRIMARY KEY,
    device_name VARCHAR(100) NOT NULL,
    device_type_id INTEGER REFERENCES device_types(device_type_id),
    room_id INTEGER REFERENCES rooms(room_id),
    installation_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,

    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sensor_readings (
    reading_id BIGSERIAL PRIMARY KEY,
    device_id INTEGER REFERENCES devices(device_id),
    timestamp TIMESTAMPTZ NOT NULL,
    value NUMERIC(10,4) NOT NULL,
    battery_level SMALLINT,
    user_id INTEGER REFERENCES users(user_id)
);


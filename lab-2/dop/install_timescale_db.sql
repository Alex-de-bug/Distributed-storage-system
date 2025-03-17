CREATE EXTENSION IF NOT EXISTS timescaledb;

CREATE TABLE sensor_readings_ts (
    reading_id BIGSERIAL,
    device_id INTEGER REFERENCES devices(device_id),
    timestamp TIMESTAMPTZ NOT NULL,
    value NUMERIC(10,4) NOT NULL,
    battery_level SMALLINT,
    user_id INTEGER REFERENCES users(user_id)
);

SELECT create_hypertable('sensor_readings_ts', 'timestamp', 
                         chunk_time_interval => INTERVAL '1 day');

SELECT set_chunk_time_interval('sensor_readings_ts', INTERVAL '7 days');


-- Запрос 1: Среднесуточная температура по комнатам за последнюю неделю
CREATE OR REPLACE FUNCTION get_avg_daily_temperature() RETURNS TABLE (
    date_day DATE,
    room_name VARCHAR(50),
    avg_temperature NUMERIC(10,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        DATE_TRUNC('day', sr.timestamp)::DATE AS date_day,
        r.room_name,
        ROUND(AVG(sr.value)::NUMERIC, 2) AS avg_temperature
    FROM sensor_readings sr
    JOIN devices d ON sr.device_id = d.device_id
    JOIN rooms r ON d.room_id = r.room_id
    JOIN device_types dt ON d.device_type_id = dt.device_type_id
    WHERE 
        dt.type_name = 'Термометр' AND
        sr.timestamp >= NOW() - INTERVAL '7 days'
    GROUP BY date_day, r.room_name
    ORDER BY date_day, r.room_name;
END;
$$ LANGUAGE plpgsql;

-- Запрос 2: Почасовое потребление электроэнергии за последний месяц
CREATE OR REPLACE FUNCTION get_hourly_electricity_consumption() RETURNS TABLE (
    hour_timestamp TIMESTAMPTZ,
    consumption NUMERIC(10,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        DATE_TRUNC('hour', sr.timestamp) AS hour_timestamp,
        SUM(sr.value) AS consumption
    FROM sensor_readings sr
    JOIN devices d ON sr.device_id = d.device_id
    JOIN device_types dt ON d.device_type_id = dt.device_type_id
    WHERE 
        dt.type_name = 'Электросчетчик' AND
        sr.timestamp >= NOW() - INTERVAL '30 days'
    GROUP BY hour_timestamp
    ORDER BY hour_timestamp;
END;
$$ LANGUAGE plpgsql;

-- Запрос 3: Корреляция между температурой, влажностью и уровнем CO2
CREATE OR REPLACE FUNCTION get_environmental_correlation(room_id_param INTEGER) RETURNS TABLE (
    hour_timestamp TIMESTAMPTZ,
    avg_temperature NUMERIC(10,2),
    avg_humidity NUMERIC(10,2),
    avg_co2 NUMERIC(10,2)
) AS $$
BEGIN
    RETURN QUERY
    WITH temp_data AS (
        SELECT 
            DATE_TRUNC('hour', sr.timestamp) AS hour_timestamp,
            AVG(sr.value) AS temperature
        FROM sensor_readings sr
        JOIN devices d ON sr.device_id = d.device_id
        WHERE 
            d.device_type_id = 1 AND
            d.room_id = room_id_param AND
            sr.timestamp >= NOW() - INTERVAL '7 days'
        GROUP BY hour_timestamp
    ),
    humidity_data AS (
        SELECT 
            DATE_TRUNC('hour', sr.timestamp) AS hour_timestamp,
            AVG(sr.value) AS humidity
        FROM sensor_readings sr
        JOIN devices d ON sr.device_id = d.device_id
        WHERE 
            d.device_type_id = 2 AND
            d.room_id = room_id_param AND
            sr.timestamp >= NOW() - INTERVAL '7 days'
        GROUP BY hour_timestamp
    ),
    co2_data AS (
        SELECT 
            DATE_TRUNC('hour', sr.timestamp) AS hour_timestamp,
            AVG(sr.value) AS co2
        FROM sensor_readings sr
        JOIN devices d ON sr.device_id = d.device_id
        WHERE 
            d.device_type_id = 4 AND
            d.room_id = room_id_param AND
            sr.timestamp >= NOW() - INTERVAL '7 days'
        GROUP BY hour_timestamp
    )
    SELECT 
        t.hour_timestamp,
        ROUND(t.temperature::NUMERIC, 2) AS avg_temperature,
        ROUND(h.humidity::NUMERIC, 2) AS avg_humidity,
        ROUND(c.co2::NUMERIC, 2) AS avg_co2
    FROM temp_data t
    JOIN humidity_data h ON t.hour_timestamp = h.hour_timestamp
    JOIN co2_data c ON t.hour_timestamp = c.hour_timestamp
    ORDER BY t.hour_timestamp;
END;
$$ LANGUAGE plpgsql;

SELECT pg_stat_reset();

-- Среднесуточная температура 23.229 - 24.061 ms
EXPLAIN ANALYZE SELECT * FROM get_avg_daily_temperature();

-- Почасовое потребление электроэнергии 23.880 - 24.263 ms
EXPLAIN ANALYZE SELECT * FROM get_hourly_electricity_consumption();

-- Корреляция показаний между устройствами 27.506 - 25.466 ms
EXPLAIN ANALYZE SELECT * FROM get_environmental_correlation(2);

-- Прямой запрос к таблице с фильтрацией по времени 25.930 - 26.856 ms
EXPLAIN ANALYZE SELECT device_id, 
       DATE_TRUNC('hour', timestamp) AS hour, 
       AVG(value) AS avg_value
FROM sensor_readings
WHERE timestamp >= NOW() - INTERVAL '7 days'
GROUP BY device_id, hour
ORDER BY device_id, hour;

-- Запрос простенький 18.032 - 16.321 ms
EXPLAIN ANALYZE SELECT 
    device_id,
    timestamp,
    value
FROM sensor_readings
WHERE 
    device_id IN (1, 2, 3) AND
    timestamp >= NOW() - INTERVAL '7 day'
ORDER BY device_id, timestamp;

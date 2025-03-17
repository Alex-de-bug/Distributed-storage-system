SELECT pg_stat_reset();

-- Среднесуточная температура 10.273 - 9.159 ms
EXPLAIN ANALYZE SELECT * FROM get_avg_daily_temperature_ts();

-- Почасовое потребление электроэнергии 13.985 - 14.351 ms
EXPLAIN ANALYZE SELECT * FROM get_hourly_electricity_consumption_ts();

-- Корреляция показаний между устройствами 8.489 - 8.219 ms
EXPLAIN ANALYZE SELECT * FROM get_environmental_correlation_ts(2);

-- Прямой запрос с фильтрацией по времени 13.665 - 13.546 ms
EXPLAIN ANALYZE SELECT device_id, 
       time_bucket('1 hour', timestamp) AS hour, 
       AVG(value) AS avg_value
FROM sensor_readings_ts
WHERE timestamp >= NOW() - INTERVAL '7 days'
GROUP BY device_id, hour
ORDER BY device_id, hour;

-- Запрос простенький 5.244 - 4.234 ms
EXPLAIN ANALYZE SELECT 
    device_id,
    timestamp,
    value
FROM sensor_readings_ts
WHERE 
    device_id IN (1, 2, 3) AND
    timestamp >= NOW() - INTERVAL '7 day'
ORDER BY device_id, timestamp;

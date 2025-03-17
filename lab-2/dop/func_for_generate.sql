CREATE OR REPLACE FUNCTION generate_sensor_data(days_of_history INTEGER) RETURNS void AS $$ --100 дней +- 500к записей
DECLARE
    start_date TIMESTAMPTZ := NOW() - (days_of_history || ' days')::INTERVAL;
    curr_date TIMESTAMPTZ := start_date;
    device_rec RECORD;
    reading_value NUMERIC(10,4);
    battery INTEGER;
    admin_id INTEGER;
BEGIN
    SELECT user_id INTO admin_id FROM users WHERE username = 'admin';
    
    FOR device_rec IN SELECT device_id, device_type_id FROM devices LOOP
        curr_date := start_date;
        
        WHILE curr_date <= NOW() LOOP
            CASE device_rec.device_type_id
                WHEN 1 THEN -- Термометр
                    reading_value := 18.0 + 10.0 * random() + 5.0 * sin((extract(epoch from curr_date) / 86400.0) * 0.5);
                WHEN 2 THEN -- Гигрометр
                    reading_value := 40.0 + 30.0 * random() + 15.0 * sin((extract(epoch from curr_date) / 86400.0) * 0.3);
                WHEN 3 THEN -- Электросчетчик
                    reading_value := 0.1 + 0.5 * random() + 0.3 * sin((extract(epoch from curr_date) / 3600.0) * 0.2);
                WHEN 4 THEN -- Датчик CO2
                    reading_value := 400.0 + 600.0 * random() + 200.0 * sin((extract(epoch from curr_date) / 3600.0) * 0.1);
                WHEN 5 THEN -- Датчик движения
                    reading_value := round(random())::INTEGER;
                ELSE
                    reading_value := random() * 100.0;
            END CASE;

            battery := 50 + floor(random() * 50)::INTEGER;
            
            INSERT INTO sensor_readings (device_id, timestamp, value, battery_level, user_id)
            VALUES (device_rec.device_id, curr_date, reading_value, battery, admin_id);
            INSERT INTO sensor_readings_ts (device_id, timestamp, value, battery_level, user_id)
            VALUES (device_rec.device_id, curr_date, reading_value, battery, admin_id);
            
            IF device_rec.device_type_id IN (1, 2, 4) THEN
                curr_date := curr_date + INTERVAL '5 minutes';
            ELSIF device_rec.device_type_id = 3 THEN 
                curr_date := curr_date + INTERVAL '1 hour';
            ELSE 
                curr_date := curr_date + INTERVAL '1 minute';
            END IF;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

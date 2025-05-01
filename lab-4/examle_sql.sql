-- == Сессия клиента 1 ==

-- Создание первой таблицы (более двух столбцов)
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    hire_date DATE,
    department_id INTEGER
);

-- Создание второй таблицы
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE NOT NULL
);

-- Демонстрация внешнего ключа (связь между таблицами)
ALTER TABLE employees
ADD CONSTRAINT fk_department
FOREIGN KEY (department_id)
REFERENCES departments(department_id);

-- Начало первой транзакции
BEGIN;

-- Вставка первой строки во вторую таблицу (нужно сделать до вставки в первую из-за FK)
INSERT INTO departments (department_name) VALUES ('Engineering');

-- Вставка первой строки в первую таблицу
INSERT INTO employees (first_name, last_name, hire_date, department_id)
VALUES ('Alice', 'Smith', '2023-01-15', (SELECT department_id FROM departments WHERE department_name = 'Engineering'));

-- Проверка данных внутри транзакции (не обязательно, для демонстрации)
SELECT * FROM departments;
SELECT * FROM employees;

-- Завершение первой транзакции
COMMIT;

-- == Сессия клиента 2 ==
-- (Подключитесь в новом окне терминала или через другой клиент psql)
-- psql -h localhost -p 5432 -U user -d mydatabase

-- Начало второй транзакции
BEGIN;

-- Вставка второй строки во вторую таблицу
INSERT INTO departments (department_name) VALUES ('Sales');

-- Вставка второй строки в первую таблицу
INSERT INTO employees (first_name, last_name, hire_date, department_id)
VALUES ('Bob', 'Johnson', '2023-03-10', (SELECT department_id FROM departments WHERE department_name = 'Sales'));

-- Вставка третьей строки в первую таблицу (еще одна строка)
INSERT INTO employees (first_name, last_name, hire_date, department_id)
VALUES ('Charlie', 'Brown', '2022-11-20', (SELECT department_id FROM departments WHERE department_name = 'Engineering'));

-- Проверка данных внутри транзакции
SELECT * FROM departments WHERE department_name = 'Sales';
SELECT * FROM employees WHERE last_name = 'Johnson' OR last_name = 'Brown';

-- Завершение второй транзакции
COMMIT;


-- == Проверка данных после обеих транзакций (любая сессия) ==

SELECT * FROM departments ORDER BY department_id;

SELECT e.employee_id, e.first_name, e.last_name, d.department_name, e.hire_date
FROM employees e
JOIN departments d ON e.department_id = d.department_id
ORDER BY e.employee_id;

-- Пример обновления данных (еще одна операция записи)
UPDATE employees
SET last_name = 'Smith-Jones'
WHERE first_name = 'Alice';

-- Проверка обновления
SELECT * FROM employees WHERE first_name = 'Alice';

-- Пример удаления данных (еще одна операция записи)
-- Сначала создадим отдел и сотрудника для удаления
INSERT INTO departments (department_name) VALUES ('Temporary');
INSERT INTO employees (first_name, last_name, department_id) VALUES ('Delete', 'Me', (SELECT department_id FROM departments WHERE department_name = 'Temporary'));

-- Теперь удалим (сначала сотрудника из-за FK, потом отдел)
DELETE FROM employees WHERE first_name = 'Delete';
DELETE FROM departments WHERE department_name = 'Temporary';

-- Финальная проверка
SELECT * FROM departments ORDER BY department_id;
SELECT * FROM employees ORDER BY employee_id;





INSERT INTO departments (department_name) VALUES ('Marketing');

INSERT INTO employees (first_name, last_name, hire_date, department_id)
VALUES ('Grace', 'Hopper', NOW()::DATE, (SELECT department_id FROM departments WHERE department_name = 'Marketing'));



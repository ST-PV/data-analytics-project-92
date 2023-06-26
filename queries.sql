-- Шаг 4
SELECT COUNT(customers.customer_id) AS customers_count 		-- запрос, который считает общее количество покупателей
FROM customers;
-- Шаг 4
--------------------------------------------------------------------------------
-- Шаг 5, таблица 1 --- Начало
SELECT 
	DISTINCT (employees.first_name ||' '|| employees.last_name) AS name,
	COUNT(sales.quantity) AS oprations,			-- количество сделок
	ROUND(SUM(sales.quantity * products.price), 0) AS income  -- суммарная выручка каждого продавца за всё время
FROM sales
JOIN employees ON employees.employee_id = sales.sales_person_id
JOIN products ON products.product_id = sales.product_id
GROUP BY (employees.first_name ||' '|| employees.last_name)	-- группировка по "склееным" имени и фамилии
ORDER BY income DESC
LIMIT 10;  							-- выведены первые 10 продавцов т.к. по условию говорилось о десятке лучших продавцов
	
-- Шаг 5, таблица 1 --- Конец
-------------------------------------------------------------------------
-- Шаг 5, таблица 2 --- Начало
SELECT 
	(employees.first_name ||' '|| employees.last_name) AS name, 
	ROUND(AVG(sales.quantity * products.price), 0) AS average_income 
FROM sales
JOIN employees ON employees.employee_id = sales.sales_person_id
JOIN products ON products.product_id = sales.product_id
GROUP BY(employees.first_name ||' '|| employees.last_name)
HAVING 										-- задал отбор по сгруппированным значениям
	AVG(sales.quantity * products.price) < 					-- при помощи вложенной функции отобрал нужные значения
	(SELECT AVG(sales.quantity * products.price) FROM sales JOIN products ON products.product_id = sales.product_id)
ORDER BY average_income ASC;

-- Шаг 5, таблица 2 --- Конец
---------------------------------------------------------------------
-- Шаг 5, таблица 3 --- Начало
SELECT 
	(employees.first_name ||' '|| employees.last_name) AS name, 
	to_char(sales.sale_date, 'Day') AS weekday, 			-- представление дня недели в словесном формате
	ROUND(SUM(sales.quantity * products.price), 0) AS income
FROM sales
JOIN employees ON employees.employee_id = sales.sales_person_id
JOIN products ON products.product_id = sales.product_id
GROUP BY weekday, date_part ('isodow', sales.sale_date), (employees.first_name ||' '|| employees.last_name) -- из интересного тут только группировка по порядковому номеру дня недели
ORDER BY date_part ('isodow', sales.sale_date);

-- Шаг 5, таблица 3 --- Конец

-- Шаг 4
SELECT COUNT(customers.customer_id) AS customers_count 		-- запрос, который считает общее количество покупателей
FROM customers;
-- Шаг 4
--------------------------------------------------------------------------------
-- Шаг 5, таблица 1 --- Начало
SELECT 
	DISTINCT (employees.first_name ||' '|| employees.last_name) AS name,
	COUNT(sales.quantity) AS operations,			-- количество сделок
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
------------------------------------------------------------------
-- Шаг 6, таблица 1 -- Начало

SELECT
	CASE				       -- условия вывода возрастной группы
		WHEN customers.age BETWEEN 16 AND 25 WHEN '16-25'	
		WHEN customers.age BETWEEN 26 AND 40 WHEN '26-40'
		WHEN customers.age > 40 THEN '40+'
		END AS age_category,		-- условия вывода возрастной группы
	COUNT(customers.age)			-- подсчёт количества пользователей, которые распределятся по возрастным группам
FROM customers
GROUP BY age_category
ORDER BY age_category ASC;

-- Шаг 6, таблица 1 -- Конец
--------------------------------------------------------------------
-- Шаг 6, таблица 2	-- Начало

SELECT  
	TO_CHAR(sales.sale_date, 'YYYY-MM') as date,
	COUNT(customers.first_name||' '|| customers.last_name),
	SUM(sales.quantity * products.price)
FROM sales
JOIN customers ON customers.customer_id = sales.sales_person_id 
JOIN products ON products.product_id = sales.product_id 
GROUP BY date
ORDER BY date ASC;

-- Шаг 6, таблица 2	-- Конец
--------------------------------------------------------------------
-- Шаг 6, таблица 3	-- Начало

WITH sub AS (									-- отдельный подзапрос, в котором просто выводится из таблицы всё необходимое
	SELECT
	DISTINCT ON (customers.customer_id) customers.customer_id,  		-- а именно вывод уникальных id, отображение которых не нужно в основном выводе
	(customers.first_name ||' ' || customers.last_name) AS customer, 
	sales.sale_date,
	(employees.first_name ||' '|| employees.last_name) AS seller
	FROM sales

	JOIN customers ON customers.customer_id  = sales.customer_id 	
	JOIN products ON products.product_id = sales.product_id 		
	JOIN employees ON employees.employee_id = sales.sales_person_id
	WHERE products.price  = 0
)

SELECT  					-- из выше сформированной таблицы выводится требуемая информация
	customer, 
	sale_date, 
	seller 
FROM sub 
ORDER BY customer_id ASC;

-- Шаг 6, таблица 3	-Конец
--------------------------------------------------------------------

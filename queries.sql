SELECT COUNT(customers.customer_id) AS customers_count 
FROM customers;

-- Шаг 5, таблица 3 --- Начало
select 
	(employees.first_name ||' '|| employees.last_name) as name, 
	to_char(sales.sale_date, 'Day') AS weekday, -- представление дня недели в словесном формате
	ROUND(SUM(sales.quantity * products.price), 0) AS income
FROM sales
JOIN employees ON employees.employee_id = sales.sales_person_id
JOIN products ON products.product_id = sales.product_id
group by weekday, date_part ('isodow', sales.sale_date), (employees.first_name ||' '|| employees.last_name) -- из интересного тут только группировка по порядковому номеру дня недели
order by date_part ('isodow', sales.sale_date);

-- Шаг 5, таблица 3 --- Конец

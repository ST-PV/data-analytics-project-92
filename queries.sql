-- customers count START 
-- шаг 4
-- считает кол-во покупателей из таблицы customers

SELECT 
	COUNT(first_name || last_name) AS customers_count
FROM customers;

-- customers count END
---------------------------------------------------------------
-- top_10_total_income START
-- шаг 5.1
-- выбирает продавцов, кол-во их сделок, сумму выручки
-- TRUNC вместо ROUND чтобы отсечь значения после запятой без округления

SELECT
	first_name || ' ' || last_name AS name,
	COUNT(quantity) AS operations,
	TRUNC(SUM(quantity * price), 0) AS income
FROM sales 
JOIN employees ON sales.sales_person_id = employees.employee_id
JOIN products ON sales.product_id = products.product_id 
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- top_10_total_income END
---------------------------------------------------------------
-- lowest_average_income START
-- шаг 5.2
-- Информация о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.

SELECT
	first_name || ' ' || last_name AS name,
	ROUND(AVG(quantity * price), 0) AS average_income
FROM sales 
JOIN employees ON sales.sales_person_id = employees.employee_id
JOIN products ON sales.product_id = products.product_id 
GROUP BY 1
HAVING ROUND(AVG(quantity * price), 0) < 
	(
	SELECT ROUND(AVG(quantity * price), 0) 
	FROM sales JOIN products ON products.product_id = sales.product_id
	)
ORDER BY 2 ASC
;

-- lowest_average_income END
---------------------------------------------------------------
-- day_of_the_week_income START
-- шаг 5.3
-- информация о выручке по дням недели. Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку.


SELECT 
	(employees.first_name ||' '|| employees.last_name) AS name, 
	to_char(sales.sale_date, 'day') AS weekday, 			
	ROUND(SUM(sales.quantity * products.price), 0) AS income
FROM sales
JOIN employees ON employees.employee_id = sales.sales_person_id
JOIN products ON products.product_id = sales.product_id
GROUP BY weekday, date_part ('isodow', sales.sale_date), 1
ORDER BY date_part ('isodow', sales.sale_date)
;


-- day_of_the_week_income END
---------------------------------------------------------------
-- age_groups START
-- шаг 6.1
-- отчет c количествоv покупателей в разных возрастных группах

SELECT
	CASE
		WHEN age BETWEEN 16 AND 25 THEN '16-25'
		WHEN age BETWEEN 26 AND 40 THEN '26-40'
		WHEN age > 40 THEN'40+'
	END AS age_category,
	COUNT(age) AS count
FROM customers
GROUP BY age_category
ORDER BY age_category
;


-- age_groups END
---------------------------------------------------------------
-- customers_by_month START
-- шаг 6.2
-- в отчете данные по дате, количеству уникальных покупателей и выручке, которую они принесли

SELECT
	TO_CHAR(sale_date, 'YYYY-MM') AS date,
	COUNT(DISTINCT(customers.first_name||' '|| customers.last_name)) AS total_customers,
	TRUNC(SUM(price * quantity), 0) AS income
FROM sales
JOIN customers ON customers.customer_id = sales.customer_id 
JOIN products ON products.product_id = sales.product_id  
GROUP BY date
ORDER BY date
;

-- customers_by_month END
---------------------------------------------------------------
-- special_offer START
-- шаг 6.3
-- отчет о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)

SELECT
	DISTINCT ON ((customers.first_name ||' ' || customers.last_name)) 
	(customers.first_name ||' ' || customers.last_name) AS customer,
	MIN(sales.sale_date) AS sale_date,
	(employees.first_name ||' '|| employees.last_name) AS seller
FROM sales
JOIN customers ON customers.customer_id = sales.customer_id 	
JOIN products ON products.product_id = sales.product_id 		
JOIN employees ON employees.employee_id = sales.sales_person_id
WHERE products.price = 0
GROUP BY 1, 3
;


-- special_offer END
---------------------------------------------------------------

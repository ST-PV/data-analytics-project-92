-- Использовался SQLFluff Online 
---------------------------------------------------------------
-- customers count START 
-- шаг 4
-- считает кол-во покупателей из таблицы customers

SELECT COUNT(first_name || last_name) AS customers_count
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
INNER JOIN employees ON sales.sales_person_id = employees.employee_id
INNER JOIN products ON sales.product_id = products.product_id
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
FROM sales AS s
INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY 1
HAVING
    ROUND(AVG(quantity * price), 0)
    < (
        SELECT ROUND(AVG(quantity * price), 0)
        FROM sales AS s INNER JOIN products AS p ON s.product_id = p.product_id
    )
ORDER BY 2 ASC;

-- lowest_average_income END
---------------------------------------------------------------
-- day_of_the_week_income START
-- шаг 5.3
-- информация о выручке по дням недели. Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку.


SELECT 
	(e.first_name ||' '|| e.last_name) AS name, 
	to_char(s.sale_date, 'day') AS weekday, 			
	ROUND(SUM(s.quantity * p.price), 0) AS income
FROM sales s
JOIN employees e ON e.employee_id = s.sales_person_id
JOIN products p ON p.product_id = s.product_id
GROUP BY weekday, date_part ('isodow', s.sale_date), 1
ORDER BY date_part ('isodow', s.sale_date)
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
        WHEN age > 40 THEN '40+'
    END AS age_category,
    COUNT(age) AS count
FROM customers
GROUP BY age_category
ORDER BY age_category;


-- age_groups END
---------------------------------------------------------------
-- customers_by_month START
-- шаг 6.2
-- в отчете данные по дате, количеству уникальных покупателей и выручке, которую они принесли

SELECT
    TO_CHAR(sale_date, 'YYYY-MM') AS date,
    COUNT(DISTINCT c.first_name || ' ' || c.last_name) AS total_customers,
    TRUNC(SUM(price * quantity), 0) AS income
FROM sales AS s
INNER JOIN customers AS c ON s.customer_id = c.customer_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY date
ORDER BY date;

-- customers_by_month END
---------------------------------------------------------------
-- special_offer START
-- шаг 6.3
-- отчет о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)

SELECT DISTINCT ON ((c.first_name || ' ' || c.last_name))
    (c.first_name || ' ' || c.last_name) AS customer,
    MIN(s.sale_date) AS sale_date,
    (e.first_name || ' ' || e.last_name) AS seller
FROM sales AS s
INNER JOIN customers AS c ON s.customer_id = c.customer_id
INNER JOIN products AS p ON s.product_id = p.product_id
INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
WHERE products.price = 0
GROUP BY 1, 3;


-- special_offer END
---------------------------------------------------------------

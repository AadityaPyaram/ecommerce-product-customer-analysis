-- Active: 1789920515628@@127.0.0.1@3306@ecommerce


-- BUSINESS QUESTIONS

-- What is the overall sales performance of the business?

-- total orders -
SELECT COUNT(order_id) FROM customer_behavior; -- 17,049 orders
-- total customers
SELECT COUNT(DISTINCT customer_id) FROM customer_behavior; -- 5000 customers
-- quantity sold
SELECT SUM(quantity) FROM customer_behavior; -- 51,341 products including multiple quantities sold
-- total_sales
SELECT SUM(total_amount) FROM customer_behavior; -- 21779052.59 in sales

-- average order value
SELECT SUM(total_amount)/COUNT(*) FROM customer_behavior; -- ~1277.439


-- Which product categories contribute the most to sales?

WITH category_sales AS(
SELECT product_category, SUM(total_amount) AS total_revenue FROM customer_behavior
GROUP BY product_category)
SELECT product_category, total_revenue,
RANK() OVER(ORDER BY total_revenue DESC)
FROM category_sales;
-- Electronics, Home&Garden and Sports
-- Electronics is about 48% of revenue, so there's concentration risk.

-- Which cities generate the most sales?

SELECT * FROM customer_behavior
LIMIT 10;

WITH CTE AS (SELECT city, SUM(total_amount) AS total_revenue FROM customer_behavior
GROUP BY city)
SELECT city, total_revenue,
RANK() OVER(ORDER BY total_revenue DESC)
FROM CTE;
-- istanbul, ankara, izmir are the cities that generate most sales
-- Istanbul alone is about 26% of sales.

-- How does sales performance change month over month?
SELECT * FROM customer_behavior
LIMIT 10;

WITH CTE AS(SELECT *,
LAG(x.monthly_sales) OVER(ORDER BY x.`year`, x.month_num) AS prev_month_sales
FROM
(SELECT MONTHNAME(`date`) AS `month`, MONTH(`date`) AS month_num, YEAR(`date`) AS `year`, SUM(total_amount) AS monthly_sales
FROM customer_behavior
GROUP BY MONTHNAME(`date`), MONTH(`date`), YEAR(`date`))x)
SELECT *,
((monthly_sales - prev_month_sales)/prev_month_sales)*100 AS MoM
FROM CTE;
-- strongest months - July and December 2023
-- weakest months - Feburaru 2024


-- How does order volume change over time?

SELECT x.month, x.`year`, x.total_orders, x.prev_total_orders, ((x.total_orders - x.prev_total_orders)/x.prev_total_orders)*100 AS MoM FROM
(WITH CTE AS
(SELECT MONTHNAME(`date`) AS `month`, MONTH(`date`) AS month_num, YEAR(`date`) AS `year`, COUNT(*) AS total_orders
FROM customer_behavior
GROUP BY MONTHNAME(`date`), MONTH(`date`), YEAR(`date`))
SELECT `month`, `year`, total_orders,
LAG(total_orders) OVER(ORDER BY `year`, month_num) AS prev_total_orders
FROM CTE)x;
-- order volume drops drastically from May to June in 2023 and from January to Feburary in 2024, then increases from June to July and in November to December in 2023



-- Do returning customers generate more value?

SELECT is_returning_customer, SUM(total_amount) AS total_sales FROM customer_behavior
GROUP BY is_returning_customer;

SELECT is_returning_customer, SUM(total_amount)/COUNT(*) AS AOV FROM customer_behavior
GROUP BY is_returning_customer;

SELECT is_returning_customer, AVG(quantity) FROM customer_behavior
GROUP BY is_returning_customer;

SELECT is_returning_customer, COUNT(*) AS total_orders FROM customer_behavior
GROUP BY is_returning_customer;
-- both returning and non returning customers purchase 3 units per order
-- the AOV is approximately same with non returning customers a little bit higher
-- the total amount of sales is far more for returning customers - 1,91,90,720.46 than for non returning customers - 23,88,332.13
-- the total number of orders of returning customers is 15,039 while of non returning it is 2010
-- Returning customers generate substantially more total revenue because they account for far more orders, but their average order value is slightly lower than that of non-returning customers.
-- Returning customers make up about 88% of orders and revenue, so retention matters more than acquisition.


-- Who are the highest-value customers?
WITH CTE AS(
SELECT x.customer_id, x.total_sales, x.total_orders,
RANK() OVER(ORDER BY x.total_sales DESC, x.total_orders DESC) AS `rank`, MAX(x.total_sales) OVER() AS max_sales
FROM
(SELECT customer_id,SUM(total_amount) AS total_sales, COUNT(*) AS total_orders FROM customer_behavior
GROUP BY customer_id) x)
SELECT * FROM `CTE`
WHERE `rank` BETWEEN 1 AND 10
ORDER BY total_sales DESC;
--  highest value customers are CUST_01573, 00197, 03795, 00154, 04219

-- How frequently do customers purchase? And is sales affected much because of high frequency purchasing groups?

WITH CTE2 AS(
SELECT x.customer_id, x.total_orders,x.total_sales,
CASE 
    WHEN x.total_orders >= 7 THEN 'high_frequency_purchase_group'
    WHEN x.total_orders >= 4 THEN 'moderate_frequency_purchase_group' 
    ELSE 'low_frequency_purchase_group'
END AS purchase_freq_group
FROM
(SELECT customer_id, COUNT(*) AS total_orders, SUM(total_amount) AS total_sales FROM customer_behavior
GROUP BY customer_id)x)
SELECT purchase_freq_group, SUM(total_sales) AS total_sales_of_group FROM CTE2
GROUP BY purchase_freq_group
ORDER BY total_sales_of_group DESC;
-- surprisingly, low frequency purchase group contribute the most to sales
-- but to keep in mind, low-frequency group can generate more total revenue simply because it contains many more customers.


-- Which categories rely most heavily on discounts?

WITH category_discount AS (
    SELECT
        product_category,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS total_sales,
        SUM(discount_amount) AS total_discount,
        SUM(unit_price * quantity) AS gross_sales
    FROM customer_behavior
    GROUP BY product_category
)
SELECT
    product_category,
    total_orders,
    total_sales,
    total_discount,
    ROUND(
        (total_discount / NULLIF(gross_sales, 0)) * 100,
        2
    ) AS discount_rate_pct
FROM category_discount
ORDER BY discount_rate_pct DESC;
-- Discount intensity is fairly similar across all categories, ranging from about 4.78% to 5.38%. Food and Beauty have the highest discount rates, while Books has the lowest.

-- Which products/categories have high sales but relatively low quantity, and vice versa?
WITH category_performance AS (
    SELECT
        product_category,
        SUM(total_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(
            SUM(total_amount) / NULLIF(SUM(quantity), 0),
            2
        ) AS sales_per_unit
    FROM customer_behavior
    GROUP BY product_category
)
SELECT
    product_category,
    total_sales,
    total_quantity,
    sales_per_unit,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank,
    RANK() OVER (ORDER BY total_quantity DESC) AS quantity_rank
FROM category_performance
ORDER BY sales_rank;
-- Electronics and Home & Garden generate very high sales despite relatively low quantities, indicating much higher revenue per unit. Sports generates the highest quantity but ranks only third in total sales, while Books has the second-highest quantity but the lowest sales because of its low revenue per unit.


-- Does delivery time affect customer ratings?

SELECT * FROM customer_behavior
LIMIT 10;

SELECT x.delivery_rate, AVG(x.customer_rating) AS avg_rating
FROM
(SELECT *,
CASE 
    WHEN delivery_time_days >= 20 THEN 'extremely-late-delivery'
    WHEN delivery_time_days >= 12 THEN 'very-late-delivery'
    WHEN delivery_time_days >= 6 THEN 'late-delivery'
    ELSE  'fast-delivery'
END AS delivery_rate
FROM customer_behavior)x
GROUP BY x.delivery_rate
ORDER BY avg_rating DESC;
-- Customer ratings tend to decline as delivery time increases, particularly for very late and extremely late deliveries.


-- Which cities have the best sales and worst delivery performance?
SELECT city, AVG(delivery_time_days) AS avg_delivery_time, AVG(customer_rating) AS avg_rating, SUM(total_amount) AS total_sales  FROM customer_behavior
GROUP BY city
ORDER BY total_sales DESC;
-- Istanbul and Ankara generate the highest sales, while Ankara has slightly slower-than-average delivery performance.


-- Does longer session duration correspond to higher-value purchases?

SELECT MAX(session_duration_minutes) FROM customer_behavior;
SELECT MIN(session_duration_minutes) FROM customer_behavior;

SELECT session_duration_range, COUNT(*) AS total_orders, AVG(x.total_amount) AS avg_sales, COUNT(DISTINCT customer_id) AS total_customers
FROM
(SELECT *,
CASE 
    WHEN session_duration_minutes >= 14 THEN 'high'
    WHEN session_duration_minutes >= 7 THEN 'low'
    ELSE 'very-low'
END AS session_duration_range
FROM customer_behavior)x
GROUP BY session_duration_range;
-- there is no positive relationship evident from these bands, but more the session duration more the total number of orders
-- high session duration - 10,969 total orders
-- low - 6,016
-- very-low - 64

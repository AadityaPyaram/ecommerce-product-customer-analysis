-- Active: 1789920515628@@127.0.0.1@3306@ecommerce

SELECT * FROM customer_behavior
LIMIT 10;

SELECT COUNT(*) AS total_rows,COUNT(DISTINCT order_id) AS order_id FROM customer_behavior;
-- 1 row = 1 order
-- each row has unique order_id
-- this is our primary key

-- checking for NULLs
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(order_id) = '' OR order_id IS NULL;

ALTER TABLE customer_behavior
MODIFY order_id VARCHAR(255) PRIMARY KEY;

DESC customer_behavior;

-- customer_id
-- since 1 row = 1 order, 1 customer can place many orders, so this column won't be unique
-- NULLs
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(customer_id) = '' OR customer_id IS NULL;

-- validation
SELECT customer_id FROM customer_behavior
WHERE customer_id NOT REGEXP '^CUST_[0-9]{5}$';

CREATE INDEX idx_customer_id ON customer_behavior(customer_id);


-- date
-- checking for invalid values
SELECT `date` FROM customer_behavior
WHERE `date` NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';
-- it's a valid col
-- one more validation
SELECT `date` FROM customer_behavior
WHERE STR_TO_DATE(`date`, '%Y-%m-%d') IS NULL;
-- this is a completely valid column

UPDATE customer_behavior
SET `date` = STR_TO_DATE(`date`, '%Y-%m-%d');

ALTER TABLE customer_behavior
MODIFY `date` DATE;

DESC customer_behavior;

-- checking for NULLs
SELECT COUNT(*) FROM customer_behavior
WHERE `date` IS NULL;


-- age
-- validating
SELECT age FROM customer_behavior
WHERE age NOT REGEXP '^[0-9]{2}$';

-- NULLs
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(age) = '' OR age IS NULL;

ALTER TABLE customer_behavior
MODIFY age INT NOT NULL;

-- another validation
SELECT MIN(age) FROM customer_behavior;
SELECT MAX(age) FROM customer_behavior

ALTER TABLE customer_behavior
MODIFY customer_id VARCHAR(255) NOT NULL;

ALTER TABLE customer_behavior
MODIFY `date` DATE NOT NULL;

DESC customer_behavior;

-- gender
SELECT COUNT(DISTINCT gender) FROM customer_behavior;
SELECT DISTINCT gender FROM customer_behavior; -- male, female, other

SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(gender) = '' OR gender IS NULL;

UPDATE customer_behavior
SET gender = CASE
                WHEN gender = 'Male' THEN 'M'
                WHEN gender = 'Female' THEN 'F'
                ELSE 'O'
                END;

ALTER TABLE customer_behavior
MODIFY gender CHAR(1) NOT NULL;

DESC customer_behavior;

-- city
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(city) = '' OR city IS NULL;

SELECT COUNT(DISTINCT city) FROM customer_behavior;
SELECT COUNT(DISTINCT LOWER(city)) FROM customer_behavior;
-- 10 different cities
-- no case inconsistencies

UPDATE customer_behavior
SET city = LOWER(city);

ALTER TABLE customer_behavior
MODIFY city VARCHAR(100) NOT NULL;

DESC customer_behavior;

-- product_category
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(product_category) ='' OR product_category IS NULL;

SELECT COUNT(DISTINCT product_category) FROM customer_behavior;
-- 8 different product categories

ALTER TABLE customer_behavior
MODIFY product_category VARCHAR(255) NOT NULL;

-- unit price
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(unit_price) = '' OR unit_price IS NULL;

ALTER TABLE customer_behavior
MODIFY unit_price DECIMAL(10,2) NOT NULL;

-- validation
SELECT COUNT(*) FROM customer_behavior
WHERE unit_price <= 0.00;
-- no anomalies 

DESC customer_behavior;

-- quantity
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(quantity) = '' OR quantity IS NULL;
-- no null values

ALTER TABLE customer_behavior
MODIFY quantity INT NOT NULL;

-- validation
SELECT COUNT(*) FROM customer_behavior
WHERE quantity <= 0;
-- no anomalies

-- discount amount
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(discount_amount) = '' OR discount_amount IS NULL;

ALTER TABLE customer_behavior
MODIFY discount_amount DECIMAL(10,2) NOT NULL;

DESC customer_behavior;

-- validation
SELECT COUNT(*) FROM customer_behavior
WHERE discount_amount < 0.00;
-- no anomalies

-- total_amount
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(total_amount) ='' OR total_amount IS NULL;

ALTER TABLE customer_behavior
MODIFY total_amount DECIMAL(10,2) NOT NULL;

-- validation
SELECT COUNT(*) FROM customer_behavior
WHERE total_amount != unit_price*quantity-discount_amount;
-- no anomalies

-- payment method
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(payment_method) = '';
-- no NULLs

SELECT COUNT(DISTINCT payment_method) FROM customer_behavior;
-- 5 different types of payment methods
SELECT DISTINCT payment_method FROM customer_behavior; -- Digital Walled, Credit Card, Bank Transfer, Debit Card, Cash on Delivery

UPDATE customer_behavior
SET payment_method = LOWER(payment_method);

ALTER TABLE customer_behavior
MODIFY payment_method VARCHAR(100) NOT NULL;

DESC customer_behavior;

-- device_type
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(device_type) = '';
-- no NULLs

SELECT COUNT(DISTINCT device_type) FROM customer_behavior;
-- 3 types of devices
SELECT DISTINCT device_type FROM customer_behavior; -- Mobile, Desktop, Tablet

UPDATE customer_behavior
SET device_type = LOWER(device_type);

ALTER TABLE customer_behavior
MODIFY device_type VARCHAR(100) NOT NULL;

DESC customer_behavior;

-- session_duration_minutes
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(session_duration_minutes) = '';
-- no NULL values

SELECT COUNT(*) FROM customer_behavior
WHERE session_duration_minutes NOT REGEXP '[0-9]{2}|[0-9]{3}|[0-9]{1}'; -- no anomalies

ALTER TABLE customer_behavior
MODIFY session_duration_minutes INT NOT NULL;

DESC customer_behavior;

-- pages_viewed
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(pages_viewed) ='';
-- no NULLs

-- validation
SELECT COUNT(*) FROM customer_behavior
WHERE pages_viewed NOT REGEXP '[0-9]{1}|[0-9]{2}|[0-9]{3}';
-- no anomalies

ALTER TABLE customer_behavior
MODIFY pages_viewed INT NOT NULL;

DESC customer_behavior;

-- is_returning_customer
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(is_returning_customer) = '';
-- no NULL values

-- validation
SELECT DISTINCT is_returning_customer FROM customer_behavior;
-- no invalid values present

UPDATE customer_behavior
SET is_returning_customer = CASE 
    WHEN is_returning_customer = 'True' THEN TRUE 
    ELSE  FALSE
END;

ALTER TABLE customer_behavior
MODIFY is_returning_customer BOOLEAN NOT NULL;

DESC customer_behavior;

-- delivery time days
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(delivery_time_days) = '';
-- no NULLs

SELECT COUNT(*) FROM customer_behavior
WHERE delivery_time_days NOT REGEXP '[0-9]{1}|[0-9]{2}';
-- no anomailes

ALTER TABLE customer_behavior
MODIFY delivery_time_days INT NOT NULL;

DESC customer_behavior;

-- customer_rating
SELECT COUNT(*) FROM customer_behavior
WHERE TRIM(customer_rating) = '';
-- no NULLs

SELECT COUNT(*) FROM customer_behavior
WHERE customer_rating NOT REGEXP '^[0-9]{1}$';
-- no anomalies

ALTER TABLE customer_behavior
MODIFY customer_rating INT NOT NULL;

-- validation
SELECT MIN(customer_rating) FROM customer_behavior;
SELECT MAX(customer_rating) FROM customer_behavior;

DESC customer_behavior;

-- validating no. of rows 
SELECT COUNT(*) FROM customer_behavior; -- no change

-- no duplicate rows present as we have a primary key
-- with that we have completed data cleaning.
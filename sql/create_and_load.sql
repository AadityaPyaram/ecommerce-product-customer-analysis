CREATE DATABASE ecommerce;

USE ecommerce;

CREATE TABLE customer_behavior(
    order_id VARCHAR(255),
    customer_id VARCHAR(255),
    `date` VARCHAR(255),
    age VARCHAR(255),
    gender VARCHAR(255),
    city VARCHAR(255),
    product_category VARCHAR(255),
    unit_price VARCHAR(255),
    quantity VARCHAR(255),
    discount_amount VARCHAR(255),
    total_amount VARCHAR(255),
    payment_method VARCHAR(255),
    device_type VARCHAR(255),
    session_duration_minutes VARCHAR(255),
    pages_viewed VARCHAR(255),
    is_returning_customer VARCHAR(255),
    delivery_time_days VARCHAR(255),
    customer_rating VARCHAR(255)
);

LOAD DATA LOCAL INFILE 'C:/Users/hp/Desktop/e-commerce/ecommerce_customer_behavior_dataset_v2.csv'
INTO TABLE customer_behavior
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
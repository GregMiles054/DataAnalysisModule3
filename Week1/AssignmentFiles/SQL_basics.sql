-- =========================================================
-- BASICS PRACTICE
-- Instructions: Answer each prompt by writing a SELECT query
-- directly below it. Keep your work; you'll submit this file.
-- =========================================================

-- Q1) List all products (show product name and price), sorted by price descending.
USE coffeshop_db;

SELECT name, price FROM products
ORDER BY price desc;

-- Q2) Show all customers who live in the city of 'Lihue'.
USE coffeshop_db;

SELECT first_name, last_name 
FROM customers WHERE CITY = "Lihue";

-- Q3) Return the first 5 orders by earliest order_datetime (order_id, order_datetime).
USE coffeshop_db;

SELECT order_id, order_datetime 
FROM orders LIMIT 5;

-- Q4) Find all products with the word 'Latte' in the name.
USE coffeshop_db;

SELECT * 
FROM products WHERE name = 'Latte';

-- Q5) Show distinct payment methods used in the dataset.
USE coffeshop_db;

SELECT DISTINCT payment_method 
FROM orders;

-- Q6) For each store, list its name and city/state (one row per store).
USE coffeshop_db;

SELECT name, city, state 
FROM stores;

-- Q7) From orders, show order_id, status, and a computed column total_items
--     that counts how many items are in each order.
USE coffeshop_db;

SELECT order_id, status, COUNT(*) AS total_items
FROM orders
GROUP BY order_id, status;

-- Q8) Show orders placed on '2025-09-04' (any time that day).
USE coffeshop_db;

SELECT *
FROM orders
WHERE order_datetime >= '2025-09-04'
  AND order_datetime < '2025-09-05';
  
-- Q9) Return the top 3 most expensive products (price, name).
USE coffeeshop_db;

SELECT name, price
FROM products
ORDER BY price desc LIMIT 3;

-- Q10) Show customer full names as a single column 'customer_name'
--      in the format "Last, First".
USE coffeeshop_db;

SELECT CONCAT (last_name,' ', first_name) AS customer_name
FROM customers


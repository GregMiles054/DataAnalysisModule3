-- =========================================================
-- JOINS & RELATIONSHIPS PRACTICE
-- =========================================================

-- Q1) Join products to categories: list product_name, category_name, price.
USE coffeeshop_db;

SELECT
	products.product_id AS product_name,
    products.name AS category_name,
    products.price
FROM products
INNER JOIN categories
ON products.category_id = categories.category_id;  

-- Q2) For each order item, show: order_id, order_datetime, store_name,
--     product_name, quantity, line_total (= quantity * products.price).
--     Sort by order_datetime, then order_id.
USE coffeeshop_db;

SELECT
    o.order_id,
    o.order_datetime,
    s.name AS store_name,
    p.name AS product_name,
    oi.quantity,
    (oi.quantity * p.price) AS line_total
FROM orders o
INNER JOIN stores s
    ON o.store_id = s.store_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
ORDER BY o.order_datetime, o.order_id;	

-- Q3) Customer order history (PAID only):
--     For each order, show customer_name, store_name, order_datetime,
--     order_total (= SUM(quantity * products.price) per order).
USE coffeeshop_db;

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    s.name AS store_name,
    o.order_datetime,
    SUM(oi.quantity * p.price) AS order_total
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN stores s
    ON o.store_id = s.store_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'paid'
GROUP BY
    o.order_id,
    customer_name,
    store_name,
    o.order_datetime
ORDER BY o.order_datetime;

-- Q4) Left join to find customers who have never placed an order.
--     Return first_name, last_name, city, state.
USE coffeeshop_db;

SELECT
    c.first_name,
    c.last_name,
    c.city,
    c.state
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id 
       AND o.status = 'paid'
WHERE o.order_id IS NULL;

-- Q5) For each store, list the top-selling product by units (PAID only).
--     Return store_name, product_name, total_units.
--     Hint: Use a window function (ROW_NUMBER PARTITION BY store) or a correlated subquery.
USE coffeeshop_db;

SELECT
    s.name AS store_name,
    p.name,
    SUM(oi.quantity) AS total_units
FROM stores s
INNER JOIN orders o
    ON s.store_id = o.store_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'paid'
GROUP BY s.store_id, p.product_id
HAVING SUM(oi.quantity) = (
    SELECT MAX(total_units)
    FROM (
        SELECT SUM(oi2.quantity) AS total_units
        FROM orders o2
        INNER JOIN order_items oi2
            ON o2.order_id = oi2.order_id
        WHERE o2.store_id = s.store_id
          AND o2.status = 'paid'
        GROUP BY oi2.product_id
    ) AS sub
);

-- Q6) Inventory check: show rows where on_hand < 12 in any store.
--     Return store_name, product_name, on_hand.
USE coffeeshop_db;

SELECT 
	s.name AS store_name,
    p.name AS product_name,
    i.on_hand AS on_hand
FROM stores s
INNER JOIN inventory i
	ON i.store_id = s.store_id
INNER JOIN products p
	ON i.product_id = p.product_id
WHERE i.on_hand < 12;

-- Q7) Manager roster: list each store's manager_name and hire_date.
--     (Assume title = 'Manager').
USE coffeeshop_db;

SELECT
	s.name AS store_name,
	CONCAT(e.first_name, ' ', e.last_name) AS manager_name,
    hire_date AS hire_date
FROM employees e
INNER JOIN stores s
	ON e.store_id = s.store_id
    WHERE e.title = 'Manager';

-- Q8) Using a subquery/CTE: list products whose total PAID revenue is above
--     the average PAID product revenue. Return product_name, total_revenue.
USE coffeeshop_db;

SELECT
    p.name AS product_name,
    SUM(oi.quantity * p.price) AS total_revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY p.product_id
HAVING SUM(oi.quantity * p.price) > (
    SELECT AVG(total_revenue)
    FROM (
        SELECT SUM(oi2.quantity * p2.price) AS total_revenue
        FROM products p2
        INNER JOIN order_items oi2
            ON p2.product_id = oi2.product_id
        INNER JOIN orders o2
            ON oi2.order_id = o2.order_id
        WHERE o2.status = 'paid'
        GROUP BY p2.product_id
    ) AS revenue_per_product
);

-- Q9) Churn-ish check: list customers with their last PAID order date.
--     If they have no PAID orders, show NULL.
--     Hint: Put the status filter in the LEFT JOIN's ON clause to preserve non-buyer rows.

USE coffeeshop_db;

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    MAX(o.order_datetime) AS last_paid_order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
       AND o.status = 'paid'
GROUP BY c.customer_id, c.first_name, c.last_name;

-- Q10) Product mix report (PAID only):
--     For each store and category, show total units and total revenue (= SUM(quantity * products.price)).

USE coffeeshop_db;

SELECT
    s.name AS store_name,
    p.category_id AS category,
    SUM(oi.quantity) AS total_units,
    SUM(oi.quantity * p.price) AS total_revenue
FROM stores s
INNER JOIN orders o
    ON s.store_id = o.store_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'paid'
GROUP BY s.store_id, p.category_id
ORDER BY s.name, p.category_id;


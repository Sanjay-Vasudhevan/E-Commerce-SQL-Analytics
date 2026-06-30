-- ==================================================================
-- E-COMMERCE SALES & CUSTOMER ANALYTICS IN REPOSITORY ENGINE
-- FULL PROJECT SOURCE CODE
-- ==================================================================

-- ------------------------------------------------------------------
-- PART 1: DATABASE & SCHEMA DEFINITION
-- ------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50),
    signup_date DATE NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    payment_method VARCHAR(50),
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- ------------------------------------------------------------------
-- PART 2: DYNAMIC TRANSITIONAL DATA SEEDING
-- ------------------------------------------------------------------
INSERT INTO customers (customer_id, name, email, city, state, signup_date) VALUES
(1, 'Amit Sharma', 'amit.sharma@email.com', 'Mumbai', 'Maharashtra', '2025-01-15'),
(2, 'Priya Nair', 'priya.nair@email.com', 'Bangalore', 'Karnataka', '2025-02-10'),
(3, 'Rohan Das', 'rohan.das@email.com', 'Kolkata', 'West Bengal', '2025-03-05'),
(4, 'Sneha Reddy', 'sneha.reddy@email.com', 'Hyderabad', 'Telangana', '2025-03-22'),
(5, 'Vikram Singh', 'vikram.singh@email.com', 'Delhi', 'Delhi', '2025-04-12');

INSERT INTO products (product_id, product_name, category, price, stock) VALUES
(101, 'iPhone 15', 'Electronics', 79999.00, 50),
(102, 'Sony WH-1000XM4', 'Electronics', 19999.00, 30),
(103, 'Running Shoes', 'Footwear', 4499.00, 100),
(104, 'Leather Wallet', 'Accessories', 1299.00, 200),
(105, 'Coffee Maker', 'Appliances', 5999.00, 25);

INSERT INTO orders (order_id, customer_id, order_date, payment_method, status) VALUES
(1001, 1, '2025-05-01', 'Credit Card', 'Delivered'),
(1002, 2, '2025-05-03', 'UPI', 'Delivered'),
(1003, 1, '2025-05-10', 'UPI', 'Delivered'),
(1004, 3, '2025-05-15', 'Credit Card', 'Shipped'),
(1005, 4, '2025-05-20', 'Net Banking', 'Delivered'),
(1006, 2, '2025-06-02', 'UPI', 'Delivered'),
(1007, 5, '2025-06-15', 'COD', 'Cancelled'),
(1008, 1, '2025-06-20', 'Credit Card', 'Delivered');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price) VALUES
(5001, 1001, 101, 1, 79999.00),
(5002, 1001, 104, 2, 1299.00),
(5003, 1002, 102, 1, 19999.00),
(5004, 1003, 103, 1, 4499.00),
(5005, 1004, 105, 1, 5999.00),
(5006, 1005, 102, 1, 19999.00),
(5007, 1006, 101, 1, 79999.00),
(5008, 1007, 103, 2, 4499.00),
(5009, 1008, 104, 1, 1299.00);

-- ------------------------------------------------------------------
-- PART 3: ADVANCED ANALYTICAL ENGINE QUERIES
-- ------------------------------------------------------------------

-- Query 1: Gross Revenue Metric Matrix
SELECT COUNT(DISTINCT order_id) AS total_orders, SUM(quantity * price) AS total_revenue FROM order_items;

-- Query 2: Segment Demand Matrix Breakdown
SELECT p.category, SUM(oi.quantity) AS total_units_sold, SUM(oi.quantity * oi.price) AS total_revenue
FROM order_items oi JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category ORDER BY total_revenue DESC;

-- Query 3: Top Value Consumer Lifecycle Spending
SELECT c.name, c.city, SUM(oi.quantity * oi.price) AS total_spent
FROM customers c JOIN orders o ON c.customer_id = o.customer_id JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name, c.city ORDER BY total_spent DESC LIMIT 3;

-- Query 4: Customer Lifetime Value (CLV) Cohort Ranking
WITH CustomerSpending AS (
    SELECT c.customer_id, c.name, SUM(oi.quantity * oi.price) AS total_spent
    FROM customers c JOIN orders o ON c.customer_id = o.customer_id JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'Cancelled' GROUP BY c.customer_id, c.name
)
SELECT customer_id, name, total_spent, DENSE_RANK() OVER (ORDER BY total_spent DESC) AS customer_rank FROM CustomerSpending;

-- Query 5: Cumulative Revenue Trajectory Window
WITH MonthlySales AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month, SUM(oi.quantity * oi.price) AS monthly_revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'Cancelled' GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT sales_month, monthly_revenue, SUM(monthly_revenue) OVER (ORDER BY sales_month) AS running_total_revenue FROM MonthlySales;

-- Query 6: Month-on-Month Performance Vectors (LAG Scaling)
WITH MonthlySales AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month, SUM(oi.quantity * oi.price) AS revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'Cancelled' GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT sales_month, revenue, LAG(revenue, 1) OVER (ORDER BY sales_month) AS previous_month_revenue,
       ROUND(((revenue - LAG(revenue, 1) OVER (ORDER BY sales_month)) / LAG(revenue, 1) OVER (ORDER BY sales_month)) * 100, 2) AS mom_growth_pct
FROM MonthlySales;

-- Query 7: Production Aggregation Architecture Abstraction View
CREATE OR REPLACE VIEW business_performance_summary AS
SELECT o.order_id, o.order_date, c.name AS customer_name, c.city, p.product_name, p.category, (oi.quantity * oi.price) AS item_total_revenue, o.status
FROM orders o JOIN customers c ON o.customer_id = c.customer_id JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id;

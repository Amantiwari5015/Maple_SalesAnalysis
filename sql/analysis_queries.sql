-- Maple & Co. 2025 sales analysis
-- Table: orders (02_Cleaned/orders_cleaned.csv loaded into SQLite)
-- Revenue and profit use Delivered orders only.

-- Q1: Total revenue, profit and main KPIs
SELECT
    ROUND(SUM(revenue), 2)                       AS total_revenue,
    ROUND(SUM(profit), 2)                        AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(revenue), 1) AS profit_margin_pct,
    COUNT(*)                                     AS total_orders,
    ROUND(SUM(revenue) / COUNT(*), 2)            AS avg_order_value
FROM orders
WHERE order_status = 'Delivered';

-- Q2: Monthly revenue trend
SELECT month, month_name,
       ROUND(SUM(revenue), 2) AS revenue,
       COUNT(*)               AS orders
FROM orders
WHERE order_status = 'Delivered'
GROUP BY month, month_name
ORDER BY month;

-- Q3a: Profit and margin by category
SELECT category,
       ROUND(SUM(revenue), 2)                       AS revenue,
       ROUND(SUM(profit), 2)                        AS profit,
       ROUND(SUM(profit) * 100.0 / SUM(revenue), 1) AS margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY category
ORDER BY profit DESC;

-- Q3b: Top 10 products by profit
SELECT product_name, category,
       ROUND(SUM(profit), 2) AS profit
FROM orders
WHERE order_status = 'Delivered'
GROUP BY product_name, category
ORDER BY profit DESC
LIMIT 10;

-- Q4: Performance by sales channel
SELECT sales_channel,
       COUNT(*)                          AS orders,
       ROUND(SUM(revenue), 2)            AS revenue,
       ROUND(SUM(profit), 2)             AS profit,
       ROUND(SUM(revenue) / COUNT(*), 2) AS avg_order_value
FROM orders
WHERE order_status = 'Delivered'
GROUP BY sales_channel
ORDER BY revenue DESC;

-- Q5: Performance by region
SELECT region,
       COUNT(*)               AS orders,
       ROUND(SUM(revenue), 2) AS revenue,
       ROUND(SUM(profit), 2)  AS profit
FROM orders
WHERE order_status = 'Delivered'
GROUP BY region
ORDER BY revenue DESC;

-- Q6: Return rate by category (cancelled orders excluded)
SELECT category,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders,
       ROUND(SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END) * 100.0
             / COUNT(*), 1) AS return_rate_pct
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY category
ORDER BY return_rate_pct DESC;

-- Q7: Impact of discounts
SELECT discount_pct,
       COUNT(*)                                     AS orders,
       ROUND(AVG(revenue), 2)                       AS avg_order_value,
       ROUND(SUM(profit) * 100.0 / SUM(revenue), 1) AS margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY discount_pct
ORDER BY discount_pct;

-- Q8: Repeat customers
WITH customer_orders AS (
    SELECT customer_id, COUNT(*) AS num_orders
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT COUNT(*) AS total_customers,
       SUM(CASE WHEN num_orders >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(SUM(CASE WHEN num_orders >= 2 THEN 1 ELSE 0 END) * 100.0
             / COUNT(*), 1) AS repeat_customer_pct
FROM customer_orders;

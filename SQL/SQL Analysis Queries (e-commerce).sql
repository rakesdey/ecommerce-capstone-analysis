-- No.1
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_item_price,
    ROUND(100.0 * COUNT(*) FILTER (WHERE o.order_status = 'delivered') / COUNT(*), 2) AS delivery_success_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;



-- No.02
SELECT 
    p.product_category_name_en AS category,
    c.customer_state AS state,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue,
    COUNT(DISTINCT oi.order_id) AS num_orders
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name_en, c.customer_state
ORDER BY revenue DESC
LIMIT 15;




-- No.03
SELECT 
    CASE 
        WHEN o.delivery_delay_days IS NULL THEN 'Not Delivered'
        WHEN o.delivery_delay_days <= -7 THEN 'Very Early (7+ days)'
        WHEN o.delivery_delay_days < 0 THEN 'Early'
        WHEN o.delivery_delay_days = 0 THEN 'On Time'
        WHEN o.delivery_delay_days <= 7 THEN 'Late (1-7 days)'
        ELSE 'Very Late (7+ days)'
    END AS delivery_bucket,
    COUNT(*) AS num_orders,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score
FROM orders o
LEFT JOIN reviews r ON o.order_id = r.order_id
GROUP BY delivery_bucket
ORDER BY avg_review_score DESC;



-- No.04
WITH customer_order_counts AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS num_orders
    FROM orders
    GROUP BY customer_id
)
SELECT 
    CASE WHEN num_orders = 1 THEN 'One-time buyer' ELSE 'Repeat buyer' END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers
FROM customer_order_counts
GROUP BY customer_type;



-- No.05
SELECT 
    s.seller_id,
    s.seller_state,
    COUNT(*) AS total_orders,
    ROUND(100.0 * COUNT(*) FILTER (WHERE o.delivery_delay_days > 0) / COUNT(*), 2) AS late_delivery_pct
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_state
HAVING COUNT(*) >= 20
ORDER BY late_delivery_pct DESC
LIMIT 10;



-- No.06
SELECT 
    payment_type,
    COUNT(*) AS num_payments,
    ROUND(AVG(payment_installments)::numeric, 1) AS avg_installments,
    ROUND(SUM(payment_value)::numeric, 2) AS total_value
FROM payments
GROUP BY payment_type
ORDER BY total_value DESC;







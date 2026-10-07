SELECT
    c.region,
    COALESCE(SUM(o.sales), 0) AS total_sales
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.region
ORDER BY c.region;
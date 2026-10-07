SELECT
    c.region,
    CASE
        WHEN o.sales > 1000 THEN 'high-value'
        ELSE 'low-value'
    END AS order_group,
    COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.region,
    CASE
        WHEN o.sales > 1000 THEN 'high-value'
        ELSE 'low-value'
    END
ORDER BY
    c.region,
    order_group;
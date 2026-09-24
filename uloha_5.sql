SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(o.sales), 0) AS total_sales
FROM products p
LEFT JOIN orders o
    ON p.product_id = o.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    p.product_name;
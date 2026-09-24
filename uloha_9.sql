SELECT
    p.sub_category,
    ROUND(AVG(o.discount) * 100, 2) AS avg_discount
FROM products p
JOIN orders o
    ON p.product_id = o.product_id
GROUP BY p.sub_category;
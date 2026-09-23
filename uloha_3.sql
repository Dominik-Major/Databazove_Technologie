SELECT o.order_id, c.customer_name, p.category, o.sales FROM orders o 
INNER JOIN customers c ON c.customer_id = o.customer_id
INNER JOIN products p ON p.product_id = o.product_id;
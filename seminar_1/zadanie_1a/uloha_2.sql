-- Active: 1790273724970@@127.0.0.1@5432@superstore
SELECT o.order_id, o.sales, c.customer_name FROM orders o 
INNER JOIN customers c ON c.customer_id = o.customer_id
where sales > 500;
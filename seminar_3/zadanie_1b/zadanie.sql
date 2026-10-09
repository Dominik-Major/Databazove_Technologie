-- Active: 1790273724970@@127.0.0.1@5432@datacraftinglab_db
WITH daily_sales AS (
    SELECT 
        sale_date, 
        SUM(total_amount) AS total_daily_sales
    FROM flourmills_sales
    GROUP BY sale_date
)
SELECT 
    sale_date, 
    total_daily_sales
FROM daily_sales
WHERE total_daily_sales > 3000000
ORDER BY total_daily_sales DESC;

WITH category_sales AS (
    SELECT 
        product_category, 
        SUM(total_amount) AS total_category_sales
    FROM flourmills_sales
    GROUP BY product_category
)
SELECT 
    product_category, 
    total_category_sales
FROM category_sales
ORDER BY total_category_sales DESC;

WITH product_sales AS (
    SELECT 
        product_category,
        product_name,
        SUM(total_amount) AS total_product_sales
    FROM flourmills_sales
    GROUP BY product_category, product_name
),
ranked_products AS (
    SELECT 
        product_category,
        product_name,
        total_product_sales,
        RANK() OVER (
            PARTITION BY product_category 
            ORDER BY total_product_sales DESC
        ) AS category_rank
    FROM product_sales
)
SELECT 
    product_category,
    product_name,
    total_product_sales,
    category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY product_category ASC, category_rank ASC;

WITH customer_revenue AS (
    SELECT 
        customer_type,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY customer_type
),
revenue_share AS (
    SELECT 
        customer_type,
        revenue,
        SUM(revenue) OVER () AS total_revenue,
        ROUND((revenue / SUM(revenue) OVER ()) * 100, 2) AS revenue_percentage
    FROM customer_revenue
)
SELECT 
    customer_type,
    revenue,
    total_revenue,
    revenue_percentage
FROM revenue_share
ORDER BY revenue DESC;

WITH latest_customer_purchases AS (
    SELECT 
        customer_id,
        product_name,
        sale_date,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY sale_date DESC
        ) AS rn
    FROM flourmills_sales   
)
SELECT 
    customer_id,
    product_name,
    sale_date,
    total_amount
FROM latest_customer_purchases
WHERE rn = 1
ORDER BY customer_id ASC;

WITH RECURSIVE date_range AS (
    SELECT 
        MIN(sale_date) AS min_date,
        MAX(sale_date) AS max_date
    FROM flourmills_sales
),
calendar_days AS (
    SELECT 
        min_date AS sale_date,
        max_date
    FROM date_range
    
    UNION ALL
    
    SELECT 
        (sale_date + INTERVAL '1 day')::date,
        max_date
    FROM calendar_days
    WHERE sale_date < max_date
)
SELECT 
    sale_date
FROM calendar_days
ORDER BY sale_date ASC;



WITH RECURSIVE 
monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', sale_date) AS month,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
ranked_months AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY month) AS rn,
        month,
        revenue
    FROM monthly_sales
),
cumulative_sales AS (
    -- Anchor query: začína prvým mesiacom (rn = 1)
    SELECT 
        rn,
        month,
        revenue,
        revenue AS cumulative_revenue
    FROM ranked_months
    WHERE rn = 1

    UNION ALL

    SELECT 
        rm.rn,
        rm.month,
        rm.revenue,
        cs.cumulative_revenue + rm.revenue AS cumulative_revenue
    FROM cumulative_sales cs
    JOIN ranked_months rm ON rm.rn = cs.rn + 1
    WHERE cs.cumulative_revenue < 500000000
)
SELECT 
    rn,
    month,
    revenue,
    cumulative_revenue
FROM cumulative_sales;
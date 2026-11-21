\set ON_ERROR_STOP on
\encoding UTF8

BEGIN;
CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE IF NOT EXISTS gold.dim_category (
    categoryid INT PRIMARY KEY,
    categoryname TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS gold.dim_supplier (
    supplierid INT PRIMARY KEY,
    suppliername TEXT,
    contactname TEXT,
    address TEXT,
    city TEXT,
    postalcode TEXT,
    country TEXT,
    phone TEXT
);

CREATE TABLE IF NOT EXISTS gold.dim_customer (
    customerid INT PRIMARY KEY,
    customername TEXT,
    contactname TEXT,
    address TEXT,
    city TEXT,
    postalcode TEXT,
    country TEXT
);

CREATE TABLE IF NOT EXISTS gold.dim_employee (
    employeeid INT PRIMARY KEY,
    lastname TEXT,
    firstname TEXT,
    birthdate TIMESTAMP,
    photo TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS gold.dim_shipper (
    shipperid INT PRIMARY KEY,
    shippername TEXT,
    phone TEXT
);

CREATE TABLE IF NOT EXISTS gold.dim_product (
    productid INT PRIMARY KEY,
    productname TEXT,
    supplierid INT NOT NULL REFERENCES gold.dim_supplier(supplierid),
    categoryid INT NOT NULL REFERENCES gold.dim_category(categoryid),
    unit TEXT,
    price NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS gold.dim_date (
    date_id INT PRIMARY KEY,
    order_date DATE NOT NULL UNIQUE,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name TEXT NOT NULL,
    week INT NOT NULL,
    month_name TEXT NOT NULL,
    quarter INT NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.fact_order (
    orderdetailid INT PRIMARY KEY,
    orderid INT NOT NULL,
    customerid INT NOT NULL REFERENCES gold.dim_customer(customerid),
    employeeid INT NOT NULL REFERENCES gold.dim_employee(employeeid),
    productid INT NOT NULL REFERENCES gold.dim_product(productid),
    shipperid INT NOT NULL REFERENCES gold.dim_shipper(shipperid),
    date_id INT NOT NULL REFERENCES gold.dim_date(date_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    total_amount NUMERIC(18,2) NOT NULL,
    line_count INT NOT NULL CHECK (line_count = 1)
);

CREATE INDEX IF NOT EXISTS idx_fact_order_orderid ON gold.fact_order (orderid);
CREATE INDEX IF NOT EXISTS idx_fact_order_customerid ON gold.fact_order (customerid);
CREATE INDEX IF NOT EXISTS idx_fact_order_employeeid ON gold.fact_order (employeeid);
CREATE INDEX IF NOT EXISTS idx_fact_order_productid ON gold.fact_order (productid);
CREATE INDEX IF NOT EXISTS idx_fact_order_shipperid ON gold.fact_order (shipperid);
CREATE INDEX IF NOT EXISTS idx_fact_order_date_id ON gold.fact_order (date_id);

TRUNCATE gold.fact_order, gold.dim_product, gold.dim_category,
    gold.dim_supplier, gold.dim_customer, gold.dim_employee,
    gold.dim_shipper, gold.dim_date;

INSERT INTO gold.dim_category (categoryid, categoryname, description)
SELECT categoryid, categoryname, description
FROM silver.stg_categories;

INSERT INTO gold.dim_supplier (supplierid, suppliername, contactname, address, city, postalcode, country, phone)
SELECT supplierid, suppliername, contactname, address, city, postalcode, country, phone
FROM silver.stg_suppliers;

INSERT INTO gold.dim_customer (customerid, customername, contactname, address, city, postalcode, country)
SELECT customerid, customername, contactname, address, city, postalcode, country
FROM silver.stg_customers;

INSERT INTO gold.dim_employee (employeeid, lastname, firstname, birthdate, photo, notes)
SELECT employeeid, lastname, firstname, birthdate, photo, notes
FROM silver.stg_employees;

INSERT INTO gold.dim_shipper (shipperid, shippername, phone)
SELECT shipperid, shippername, phone
FROM silver.stg_shippers;

INSERT INTO gold.dim_product (productid, productname, supplierid, categoryid, unit, price)
SELECT productid, productname, supplierid, categoryid, unit, price
FROM silver.stg_products;

INSERT INTO gold.dim_date (date_id, order_date, day, month, year,
    day_of_week, day_name, week, month_name, quarter)
SELECT TO_CHAR(d, 'YYYYMMDD')::INT, d,
    EXTRACT(DAY FROM d)::INT, EXTRACT(MONTH FROM d)::INT,
    EXTRACT(YEAR FROM d)::INT, EXTRACT(ISODOW FROM d)::INT,
    TO_CHAR(d, 'FMDay'), EXTRACT(WEEK FROM d)::INT,
    TO_CHAR(d, 'FMMonth'), EXTRACT(QUARTER FROM d)::INT
FROM (
    SELECT DISTINCT orderdate::DATE AS d FROM silver.stg_orders
    ) dates;

INSERT INTO gold.fact_order (orderdetailid, orderid, customerid,
    employeeid, productid, shipperid, date_id, quantity,
    unit_price, total_amount, line_count)
SELECT od.orderdetailid, od.orderid, o.customerid, o.employeeid,
    od.productid, o.shipperid, TO_CHAR(o.orderdate, 'YYYYMMDD')::INT,
    od.quantity, p.price, od.quantity * p.price, 1
FROM silver.stg_orderdetails od
LEFT JOIN silver.stg_orders o ON o.orderid = od.orderid
LEFT JOIN silver.stg_products p ON p.productid = od.productid;

DO $$
BEGIN
    IF (SELECT COUNT(*) FROM gold.fact_order) <>
       (SELECT COUNT(*) FROM silver.stg_orderdetails) THEN
        RAISE EXCEPTION 'Fact row count mismatch';
    END IF;
END $$;

COMMIT;

-- Kontrola Gold vrstvy

SELECT 'dim_category' AS table_name, COUNT(*) AS row_count
FROM gold.dim_category
UNION ALL
SELECT 'dim_supplier', COUNT(*) FROM gold.dim_supplier
UNION ALL
SELECT 'dim_product', COUNT(*) FROM gold.dim_product
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM gold.dim_customer
UNION ALL
SELECT 'dim_employee', COUNT(*) FROM gold.dim_employee
UNION ALL
SELECT 'dim_shipper', COUNT(*) FROM gold.dim_shipper
UNION ALL
SELECT 'dim_date', COUNT(*) FROM gold.dim_date
UNION ALL
SELECT 'fact_order', COUNT(*) FROM gold.fact_order;
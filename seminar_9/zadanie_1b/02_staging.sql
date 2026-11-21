\set ON_ERROR_STOP on
\encoding UTF8

BEGIN;
CREATE SCHEMA IF NOT EXISTS silver;

CREATE OR REPLACE VIEW silver.stg_categories AS
    SELECT categoryid, categoryname, description
    FROM bronze.categories;

CREATE OR REPLACE VIEW silver.stg_customers AS
    SELECT customerid, customername, contactname, address, city, postalcode, country
    FROM bronze.customers;

CREATE OR REPLACE VIEW silver.stg_employees AS
    SELECT employeeid, lastname, firstname, birthdate, photo, notes
    FROM bronze.employees;

CREATE OR REPLACE VIEW silver.stg_orderdetails AS
    SELECT orderdetailid, orderid, productid, quantity
    FROM bronze.orderdetails;

CREATE OR REPLACE VIEW silver.stg_orders AS
    SELECT orderid, customerid, employeeid, orderdate, shipperid
    FROM bronze.orders;

CREATE OR REPLACE VIEW silver.stg_products AS
    SELECT productid, productname, supplierid, categoryid, unit, price
    FROM bronze.products;

CREATE OR REPLACE VIEW silver.stg_shippers AS
    SELECT shipperid, shippername, phone
    FROM bronze.shippers;

CREATE OR REPLACE VIEW silver.stg_suppliers AS
    SELECT supplierid, suppliername, contactname, address, city, postalcode, country, phone
    FROM bronze.suppliers;

COMMIT;
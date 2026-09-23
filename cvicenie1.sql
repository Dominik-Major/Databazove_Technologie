-- Active: 1790162497761@@127.0.0.1@5432@superstore
-- Active: 1790162497761@@127.0.0.1@5432@Northwind


CREATE DATABASE superstore;

CREATE Table customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(20),
    segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);

CREATE Table products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100)
);

CREATE Table orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES customers(customer_id),
    product_id VARCHAR(20) REFERENCES products(product_id),
    order_date DATE,
    ship_date DATE,
    sales NUMERIC(10,2),
    quantity INT,
    discount NUMERIC(10,2),
    profit NUMERIC(10,2)
);
CREATE TABLE public.dim_category (
    category_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id INTEGER NOT NULL UNIQUE,
    category_name VARCHAR(25) NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE public.dim_supplier (
    supplier_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_id INTEGER NOT NULL UNIQUE,
    supplier_name VARCHAR(50) NOT NULL,
    contact_name VARCHAR(50),
    city VARCHAR(20),
    country VARCHAR(15)
);

CREATE TABLE public.dim_product (
    product_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE,
    product_name VARCHAR(50) NOT NULL,
    unit VARCHAR(25),
    current_price NUMERIC(12,2),
    category_key INTEGER REFERENCES public.dim_category(category_key),
    supplier_key INTEGER REFERENCES public.dim_supplier(supplier_key)
);

CREATE TABLE public.dim_customer (
    customer_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER NOT NULL UNIQUE,
    customer_name VARCHAR(50) NOT NULL,
    contact_name VARCHAR(50),
    city VARCHAR(20),
    country VARCHAR(15)
);

CREATE TABLE public.dim_employee (
    employee_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id INTEGER NOT NULL UNIQUE,
    first_name VARCHAR(15),
    last_name VARCHAR(15),
    birth_date DATE
);

CREATE TABLE public.dim_shipper (
    shipper_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipper_id INTEGER NOT NULL UNIQUE,
    shipper_name VARCHAR(25) NOT NULL,
    phone VARCHAR(15)
);

CREATE TABLE public.dim_date (
    date_key INTEGER PRIMARY KEY,  -- format YYYYMMDD, napr. 20261104
    full_date DATE NOT NULL UNIQUE,
    day_of_month SMALLINT NOT NULL,
    month_number SMALLINT NOT NULL,
    quarter_number SMALLINT NOT NULL,
    year_number INTEGER NOT NULL
);

CREATE TABLE public.fact_sales (
    sales_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_detail_id INTEGER NOT NULL UNIQUE,
    order_id INTEGER NOT NULL,  -- degenerovana dimenzia (cislo objednavky)
    customer_key INTEGER NOT NULL REFERENCES public.dim_customer(customer_key),
    employee_key INTEGER REFERENCES public.dim_employee(employee_key),
    shipper_key INTEGER REFERENCES public.dim_shipper(shipper_key),
    product_key INTEGER NOT NULL REFERENCES public.dim_product(product_key),
    date_key INTEGER NOT NULL REFERENCES public.dim_date(date_key),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    sales_amount NUMERIC(14,2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);

CREATE INDEX idx_fact_sales_customer ON public.fact_sales(customer_key);
CREATE INDEX idx_fact_sales_employee ON public.fact_sales(employee_key);
CREATE INDEX idx_fact_sales_shipper ON public.fact_sales(shipper_key);
CREATE INDEX idx_fact_sales_product ON public.fact_sales(product_key);
CREATE INDEX idx_fact_sales_date ON public.fact_sales(date_key);
CREATE INDEX idx_product_category ON public.dim_product(category_key);
CREATE INDEX idx_product_supplier ON public.dim_product(supplier_key);
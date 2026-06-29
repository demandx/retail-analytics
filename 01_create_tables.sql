-- ============================================================
-- RETAIL SALES & CUSTOMER ANALYTICS
-- Schema: Table Definitions
-- Author: Tauseef Ahmad Khan
-- ============================================================

CREATE DATABASE retail_analytics;
USE retail_analytics;

-- Customers Table
CREATE TABLE customers (
    customer_id     INT PRIMARY KEY AUTO_INCREMENT,
    customer_name   VARCHAR(100),
    email           VARCHAR(100),
    phone           VARCHAR(20),
    city            VARCHAR(50),
    region          VARCHAR(50),
    signup_date     DATE,
    segment         VARCHAR(30)
);

-- Products Table
CREATE TABLE products (
    product_id      INT PRIMARY KEY AUTO_INCREMENT,
    product_name    VARCHAR(150),
    category        VARCHAR(50),
    sub_category    VARCHAR(50),
    unit_price      DECIMAL(10,2),
    cost_price      DECIMAL(10,2)
);

-- Orders Table
CREATE TABLE orders (
    order_id        INT PRIMARY KEY AUTO_INCREMENT,
    customer_id     INT,
    order_date      DATE,
    delivery_date   DATE,
    region          VARCHAR(50),
    status          VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items Table
CREATE TABLE order_items (
    item_id         INT PRIMARY KEY AUTO_INCREMENT,
    order_id        INT,
    product_id      INT,
    quantity        INT,
    unit_price      DECIMAL(10,2),
    discount        DECIMAL(5,2) DEFAULT 0,
    FOREIGN KEY (order_id)    REFERENCES orders(order_id),
    FOREIGN KEY (product_id)  REFERENCES products(product_id)
);

-- Sales Funnel Table
CREATE TABLE sales_funnel (
    lead_id         INT PRIMARY KEY AUTO_INCREMENT,
    lead_date       DATE,
    stage           VARCHAR(30),
    region          VARCHAR(50),
    converted       BOOLEAN DEFAULT FALSE
);

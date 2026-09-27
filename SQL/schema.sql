USE ecommerce_dw;

CREATE TABLE dim_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

SHOW TABLES;


CREATE TABLE dim_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(150),
    product_category_name_english VARCHAR(150),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g DECIMAL(10,2),
    product_length_cm DECIMAL(10,2),
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2)
);

CREATE TABLE dim_sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

SHOW TABLES;

CREATE TABLE fact_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    delivery_days DECIMAL(10,2),
    is_late BOOLEAN,

    FOREIGN KEY (customer_id)
        REFERENCES dim_customers(customer_id)
);

SHOW TABLES;


CREATE TABLE fact_order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    item_total DECIMAL(10,2),

    PRIMARY KEY (order_id, order_item_id),

    FOREIGN KEY (order_id)
        REFERENCES fact_orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES dim_products(product_id),

    FOREIGN KEY (seller_id)
        REFERENCES dim_sellers(seller_id)
);

SHOW TABLES;

CREATE TABLE fact_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2),

    FOREIGN KEY (order_id)
        REFERENCES fact_orders(order_id)
);

CREATE TABLE fact_reviews (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,

    FOREIGN KEY (order_id)
        REFERENCES fact_orders(order_id)
);

SHOW TABLES;



DROP TABLE fact_reviews;

CREATE TABLE fact_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,

    PRIMARY KEY (review_id, order_id),

    FOREIGN KEY (order_id)
        REFERENCES fact_orders(order_id)
);


SELECT COUNT(*) AS invalid_orders
FROM fact_orders o
LEFT JOIN dim_customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


SELECT COUNT(*) AS invalid_order_items
FROM fact_order_items oi
LEFT JOIN fact_orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


SELECT COUNT(*) AS invalid_products
FROM fact_order_items oi
LEFT JOIN dim_products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


SELECT COUNT(*) AS invalid_sellers
FROM fact_order_items oi
LEFT JOIN dim_sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


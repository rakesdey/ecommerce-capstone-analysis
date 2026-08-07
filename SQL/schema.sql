
CREATE TABLE customers (
    customer_id           VARCHAR(50) PRIMARY KEY,
    customer_unique_id    VARCHAR(50),
    customer_city         VARCHAR(100),
    customer_state        VARCHAR(5)
);

CREATE TABLE sellers (
    seller_id       VARCHAR(50) PRIMARY KEY,
    seller_city     VARCHAR(100),
    seller_state    VARCHAR(5)
);

CREATE TABLE products (
    product_id                  VARCHAR(50) PRIMARY KEY,
    product_category_name       VARCHAR(100),
    product_category_name_en    VARCHAR(100)
);

CREATE TABLE orders (
    order_id                        VARCHAR(50) PRIMARY KEY,
    customer_id                     VARCHAR(50) REFERENCES customers(customer_id),
    order_status                    VARCHAR(20),
    order_purchase_timestamp        TIMESTAMP,
    order_approved_at               TIMESTAMP,
    order_delivered_carrier_date    TIMESTAMP,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP,
    delivery_delay_days             INT
);

CREATE TABLE order_items (
    order_id             VARCHAR(50) REFERENCES orders(order_id),
    order_item_id         INT,
    product_id            VARCHAR(50) REFERENCES products(product_id),
    seller_id              VARCHAR(50) REFERENCES sellers(seller_id),
    price                   NUMERIC(10,2),
    freight_value            NUMERIC(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE payments (
    order_id                VARCHAR(50) REFERENCES orders(order_id),
    payment_sequential       INT,
    payment_type              VARCHAR(30),
    payment_installments       INT,
    payment_value                NUMERIC(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE reviews (
    review_id             VARCHAR(50),
    order_id               VARCHAR(50) REFERENCES orders(order_id),
    review_score             INT,
    review_comment_title      TEXT,
    review_comment_message    TEXT,
    review_creation_date       TIMESTAMP,
    review_answer_timestamp     TIMESTAMP,
    PRIMARY KEY (review_id, order_id)
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_purchase_timestamp);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_order_items_seller ON order_items(seller_id);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_reviews_order ON reviews(order_id);

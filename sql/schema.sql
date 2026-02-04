SELECT * FROM retail_db.shopping_behavior_updated;

/*créer la table client */
USE retail_db;
CREATE TABLE dim_customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_code INT,
    age INT,
    gender VARCHAR(10),
    subscription_status VARCHAR(20),
    previous_purchases INT,
    frequency VARCHAR(50)
);

/*créer la table product */

Use retail_db ; 
	create Table dim_product (
       product_id INT AUTO_INCREMENT PRIMARY KEY, 
       product_name VARCHAR(50) ,
       category VARCHAR(100) , 
       size VARCHAR(50) ,
       color varchar(50), 
	   season VARCHAR(50)
);

/*créer la table locationn */

Use retail_db ; 
CREATE TABLE IF NOT EXISTS dim_locationn (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    city VARCHAR(100)
);

/*créer la table fact_sales */
Use retail_db ; 
CREATE TABLE IF NOT EXISTS fact_sales (
    sales_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    location_id INT,
    amount_usd DECIMAL(10,2),
    review_rating DECIMAL(3,2),
    discount_applied VARCHAR(10),
    promo_code_used VARCHAR(10),
    payment_method VARCHAR(50),
    shipping_type VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (location_id) REFERENCES dim_locationn(location_id)
);

-- aliemantation dim_customer 
INSERT INTO dim_customer (
    customer_code, age, gender, subscription_status, previous_purchases, frequency
)
SELECT DISTINCT
    `Customer ID`,
    Age,
    Gender,
    `Subscription Status`,
    `Previous Purchases`,
    `Frequency of Purchases`
FROM retail_db.shopping_behavior_updated;

-- aliementation dim product 
INSERT INTO dim_product (
    product_name, category, size, color, season
)
SELECT DISTINCT
    `Item Purchased`,
    Category,
    Size,
    Color,
    Season
FROM retail_db.shopping_behavior_updated;


-- aliementation dim_location 
INSERT INTO dim_locationn (city)
SELECT DISTINCT Location
FROM retail_db.shopping_behavior_updated;

-- aliementation fact_sales
INSERT INTO fact_sales (
    customer_id, product_id, location_id,
    amount_usd, review_rating,
    discount_applied, promo_code_used,
    payment_method, shipping_type
)
SELECT
    c.customer_id,
    p.product_id,
    l.location_id,
    s.`Purchase Amount (USD)`,
    s.`Review Rating`,
    s.`Discount Applied`,
    s.`Promo Code Used`,
    s.`Payment Method`,
    s.`Shipping Type`
FROM retail_db.shopping_behavior_updated s
JOIN dim_customer c
    ON s.`Customer ID` = c.customer_code
JOIN dim_product p
    ON s.`Item Purchased` = p.product_name
   AND s.Category = p.category
-- on ignore Size, Color, Season au début pour insérer
JOIN dim_locationn l
    ON s.Location = l.city;

   
SHOW CREATE TABLE fact_sales;
ALTER TABLE fact_sales
DROP FOREIGN KEY fact_sales_ibfk_3;
DROP TABLE dim_location;
        
-- vue avec tous les informations des ventes 
CREATE OR REPLACE VIEW sales_view AS
SELECT 
    f.sales_id,
    c.customer_code, c.age, c.gender, c.subscription_status,
    p.product_name, p.category, p.size, p.color, p.season,
    l.city,
    f.amount_usd, f.review_rating, f.discount_applied, f.promo_code_used,
    f.payment_method, f.shipping_type
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_locationn l ON f.location_id = l.location_id;


SHOW DATABASES;
USE retail_db;
SHOW TABLES;

SHOW VARIABLES LIKE 'port';


CREATE TABLE ml_customer_features AS
SELECT
    customer_code,

    -- Infos client
    MAX(age) AS age,
    MAX(gender) AS gender,
    MAX(city) AS city,

    -- Comportement d'achat
    SUM(amount_usd) AS total_spent,
    AVG(amount_usd) AS avg_spent,
    COUNT(sales_id) AS total_orders,

    -- Satisfaction
    AVG(review_rating) AS avg_review_rating,

    -- Promotions
    AVG(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) AS discount_rate,
    AVG(CASE WHEN promo_code_used = 'Yes' THEN 1 ELSE 0 END) AS promo_rate,

    -- Diversité d'achat
    COUNT(DISTINCT category) AS category_diversity,
    COUNT(DISTINCT payment_method) AS payment_method_diversity,

    -- TARGET : abonnement
    MAX(
        CASE 
            WHEN subscription_status = 'Subscribed' THEN 1
            ELSE 0
        END
    ) AS subscribed

FROM sales_view
GROUP BY customer_code;





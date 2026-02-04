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


SELECT customer_code , COUNT(*) 
FROM dim_customer
group by customer_code 
HAVING count(*) > 1;


-- verification des doublons dans la table product 

SELECT product_name , category , COUNT(*)
FROM dim_product 
group by product_name , category 
HAVING count(*) >1 ; 


-- verification des valeurs manquantes dans la table de fait 

SELECT *
FROM fact_sales 
WHERE customer_id IS NULL 
      OR product_id IS NULL 
      OR location_id IS NULL;

      
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


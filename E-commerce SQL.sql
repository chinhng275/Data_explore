--  Customer purchase trend Year-On-Year
SELECT
month AS month_no,
CASE 
WHEN a.month='1' THEN 'Jan' 
WHEN a.month='2' THEN 'Feb'
WHEN a.month='3' THEN 'Mar'
WHEN a.month='4' THEN 'Apr'
WHEN a.month='5' THEN 'May'
WHEN a.month='6' THEN 'Jun'
WHEN a.month='7' THEN 'Jul'
WHEN a.month='8' THEN 'Aug'
WHEN a.month='9' THEN 'Sep'
WHEN a.month='10' THEN 'Oct'
WHEN a.month='11' THEN 'Nov'
WHEN a.month='12' THEN 'Dec'
ELSE to_char(a.month,'999') END AS month,
SUM(CASE WHEN a.year= '2016' THEN 1 ELSE 0 END) AS Year2016,
SUM(CASE WHEN a.year= '2017' THEN 1 ELSE 0 END) AS Year2017,
SUM(CASE WHEN a.year= '2018' THEN 1 ELSE 0 END) AS Year2018
FROM
(SELECT 
customer_id,
order_id,
order_delivered_customer_date,
order_status,
date_part('year',order_delivered_customer_date) AS Year,
date_part('month',order_delivered_customer_date) AS month
FROM orders
WHERE order_status= 'delivered' and order_delivered_customer_date is not null
GROUP BY customer_id,order_id,order_delivered_customer_date,order_status
ORDER BY order_delivered_customer_date ASC) a
GROUP BY month
ORDER BY month_no ASC

-- Average order values of customers
SELECT
raw_data.customer_unique_id,
COUNT(raw_data.order_id) AS Total_Orders_By_Customers,
AVG(raw_data.payment_value) AS Total_Payment_By_Customers,
raw_data.customer_city,
raw_data.customer_state

FROM (SELECT
delivery_details.customer_unique_id,
delivery_details.customer_id,
delivery_details.order_id,
delivery_details.customer_city,
delivery_details.customer_state,
delivery_details.order_status,
delivery_details.order_delivered_customer_date,
payment_details.payment_value

FROM (SELECT
c.customer_unique_id,
c.customer_id,
o.order_id,
c.customer_city,
c.customer_state,
o.order_status,
o.order_delivered_customer_date
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY 1,2,3,4,5,6,7
ORDER BY 1,2,3 ASC) delivery_details

JOIN (SELECT
o.customer_id,
o.order_id,
o.order_status,
o.order_delivered_customer_date,
p.payment_value

FROM orders o
JOIN order_payments p
ON o.order_id=p.order_id
GROUP BY 1,2,3,4,5) payment_details
ON delivery_details.customer_id=payment_details.customer_id
and delivery_details.order_id=payment_details.order_id 
and delivery_details.order_status=payment_details.order_status
and delivery_details.order_delivered_customer_date=payment_details.order_delivered_customer_date
GROUP BY 1,2,3,4,5,6,7,8
ORDER BY 1,2,3,4,5,6,7,8 ASC
) raw_data
WHERE raw_data.order_status='delivered'
GROUP BY 1,4,5
ORDER BY 1

-- Top 10 Cities with highest revenue FROM 2016 to 2018

WITH raw_data AS (
SELECT DISTINCT
c.customer_id,
o.order_id,
p.payment_value,
o.order_status
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_payments p
ON p.order_id = o.order_id
WHERE o.order_status = 'delivered')


SELECT
customer_city,
customer_state,
COUNT(DISTINCT raw.order_id) as Total_orders,
SUM(raw.payment_value) AS Total_payments
FROM customers c
JOIN raw_data raw
ON c.customer_id = raw.customer_id
GROUP BY 1,2
ORDER BY 4 DESC
LIMIT 10

-- Ver2

SELECT 
result.customer_city,
result.customer_state,
result.Total_Orders_By_Customers AS Total_Orders,
result.Total_Payment_By_Customers AS Total_Customers_Payment
FROM (
SELECT
raw_data.customer_city,
raw_data.customer_state,
COUNT(distinct raw_data.order_id) AS Total_Orders_By_Customers,
SUM(raw_data.payment_value) AS Total_Payment_By_Customers
FROM (

SELECT
delivery_details.customer_unique_id,
delivery_details.customer_id,
delivery_details.order_id,
delivery_details.customer_city,
delivery_details.customer_state,
delivery_details.order_status,
delivery_details.order_delivered_customer_date,
payment_details.payment_value
FROM
(SELECT
c.customer_unique_id,
c.customer_id,
o.order_id,
c.customer_city,
c.customer_state,
o.order_status,
o.order_delivered_customer_date
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY 1,2,3,4,5,6,7
ORDER BY 1,2,3 ASC) delivery_details

JOIN (SELECT
o.customer_id,
o.order_id,
o.order_status,
o.order_delivered_customer_date,
p.payment_value

FROM orders o
JOIN order_payments p
ON o.order_id=p.order_id
GROUP BY 1,2,3,4,5) payment_details
ON delivery_details.customer_id=payment_details.customer_id
and delivery_details.order_id=payment_details.order_id 
and delivery_details.order_status=payment_details.order_status
and delivery_details.order_delivered_customer_date=payment_details.order_delivered_customer_date
GROUP BY 1,2,3,4,5,6,7,8
ORDER BY 1,2,3,4,5,6,7,8 ASC
) raw_data
WHERE raw_data.order_status='delivered'
GROUP BY 1,2
ORDER BY 1,2 desc
) result

GROUP BY 1,2,3,4
ORDER BY 4 desc
limit 10

-- State wise revenue table between 2016 to 2018
SELECT
result.year AS Year,
MAX(result.SP) AS SP,
MAX(result.SC) AS SC,
MAX(result.MG) AS MG,
MAX(result.PR) AS PR,
MAX(result.RJ) AS RJ,
MAX(result.RS) AS RS,
MAX(result.PA) AS PA,
MAX(result.GO) AS GO,
MAX(result.ES) AS ES,
MAX(result.BA) AS BA,
MAX(result.MA) AS MA,
MAX(result.MS) AS MS,
MAX(result.CE) AS CE,
MAX(result.DF) AS DF,
MAX(result.RN) AS RN,
MAX(result.PE) AS PE,
MAX(result.MT) AS MT,
MAX(result.AM) AS AM,
MAX(result.AP) AS AP,
MAX(result.AL) AS AL,
MAX(result.RO) AS RO,
MAX(result.PB) AS PB,
MAX(result.TOs) AS TOs,
MAX(result.PI) AS PI,
MAX(result.AC) AS AC,
MAX(result.SE) AS SE,
MAX(result.RR) AS RR
FROM (
SELECT 
date_part('year',raw.order_delivered_customer_date) AS Year,
raw.customer_city,
raw.customer_state,
CASE WHEN raw.customer_state='SP' THEN SUM(raw.payment_value) ELSE 0 END AS SP,
CASE WHEN raw.customer_state='SC' THEN SUM(raw.payment_value) ELSE 0 END AS SC,
CASE WHEN raw.customer_state='MG' THEN SUM(raw.payment_value) ELSE 0 END AS MG,
CASE WHEN raw.customer_state='PR' THEN SUM(raw.payment_value) ELSE 0 END AS PR,
CASE WHEN raw.customer_state='RJ' THEN SUM(raw.payment_value) ELSE 0 END AS RJ,
CASE WHEN raw.customer_state='RS' THEN SUM(raw.payment_value) ELSE 0 END AS RS,
CASE WHEN raw.customer_state='PA' THEN SUM(raw.payment_value) ELSE 0 END AS PA,
CASE WHEN raw.customer_state='GO' THEN SUM(raw.payment_value) ELSE 0 END AS GO,
CASE WHEN raw.customer_state='ES' THEN SUM(raw.payment_value) ELSE 0 END AS ES,
CASE WHEN raw.customer_state='BA' THEN SUM(raw.payment_value) ELSE 0 END AS BA,
CASE WHEN raw.customer_state='MA' THEN SUM(raw.payment_value) ELSE 0 END AS MA,
CASE WHEN raw.customer_state='MS' THEN SUM(raw.payment_value) ELSE 0 END AS MS,
CASE WHEN raw.customer_state='CE' THEN SUM(raw.payment_value) ELSE 0 END AS CE,
CASE WHEN raw.customer_state='DF' THEN SUM(raw.payment_value) ELSE 0 END AS DF,
CASE WHEN raw.customer_state='RN' THEN SUM(raw.payment_value) ELSE 0 END AS RN,
CASE WHEN raw.customer_state='PE' THEN SUM(raw.payment_value) ELSE 0 END AS PE,
CASE WHEN raw.customer_state='MT' THEN SUM(raw.payment_value) ELSE 0 END AS MT,
CASE WHEN raw.customer_state='AM' THEN SUM(raw.payment_value) ELSE 0 END AS AM,
CASE WHEN raw.customer_state='AP' THEN SUM(raw.payment_value) ELSE 0 END AS AP,
CASE WHEN raw.customer_state='AL' THEN SUM(raw.payment_value) ELSE 0 END AS AL,
CASE WHEN raw.customer_state='RO' THEN SUM(raw.payment_value) ELSE 0 END AS RO,
CASE WHEN raw.customer_state='PB' THEN SUM(raw.payment_value) ELSE 0 END AS PB,
CASE WHEN raw.customer_state='TO' THEN SUM(raw.payment_value) ELSE 0 END AS TOs,
CASE WHEN raw.customer_state='PI' THEN SUM(raw.payment_value) ELSE 0 END AS PI,
CASE WHEN raw.customer_state='AC' THEN SUM(raw.payment_value) ELSE 0 END AS AC,
CASE WHEN raw.customer_state='SE' THEN SUM(raw.payment_value) ELSE 0 END AS SE,
CASE WHEN raw.customer_state='RR' THEN SUM(raw.payment_value) ELSE 0 END AS RR
FROM 
(SELECT
delivery_details.customer_unique_id,
delivery_details.customer_id,
delivery_details.order_id,
delivery_details.customer_city,
delivery_details.customer_state,
delivery_details.order_status,
delivery_details.order_delivered_customer_date,
payment_details.payment_value
FROM
(SELECT
c.customer_unique_id,
c.customer_id,
o.order_id,
c.customer_city,
c.customer_state,
o.order_status,
o.order_delivered_customer_date
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY 1,2,3,4,5,6,7
ORDER BY 1,2,3 ASC) delivery_details

JOIN (SELECT
o.customer_id,
o.order_id,
o.order_status,
o.order_delivered_customer_date,
p.payment_value

FROM orders o
JOIN order_payments p
ON o.order_id=p.order_id
GROUP BY 1,2,3,4,5) payment_details
ON delivery_details.customer_id=payment_details.customer_id
and delivery_details.order_id=payment_details.order_id 
and delivery_details.order_status=payment_details.order_status
and delivery_details.order_delivered_customer_date=payment_details.order_delivered_customer_date
GROUP BY 1,2,3,4,5,6,7,8
ORDER BY 1,2,3,4,5,6,7,8 ASC) raw
GROUP BY 1,2,3
ORDER BY 1,2,3 ASC) result
GROUP BY 1
ORDER BY 1 ASC

-- Delivery Success Rate across state
SELECT
c.customer_state,
date_part('year',o.order_delivered_customer_date) AS Year,
COUNT(distinct c.customer_city) AS Total_Cities_Delivered,
COUNT(c.customer_unique_id) AS Total_Customers,
SUM(CASE WHEN o.order_status='delivered' THEN 1 ELSE 0 END) AS Delivered,
SUM(CASE WHEN o.order_status!='delivered' THEN 1 ELSE 0 END) AS Not_Delivered,
100-100*round(round(SUM(CASE WHEN o.order_status!='delivered' THEN 1 ELSE 0 END),4)/round(COUNT(o.order_status),4),4) AS Delivery_Success_Rate,
100*round(round(SUM(CASE WHEN o.order_status!='delivered' THEN 1 ELSE 0 END),4)/round(COUNT(o.order_status),4),4) AS Delivery_Failure_Rate
FROM customers c
JOIN orders o ON o.customer_id=c.customer_id
WHERE date_part('year',o.order_delivered_customer_date) IS NOT NULL
GROUP BY c.customer_state,date_part('year',o.order_delivered_customer_date)
ORDER BY c.customer_state,date_part('year',o.order_delivered_customer_date) ASC

-- Extract payment value in a day and month
SELECT
date_trunc('day',o.order_purchase_timestamp) AS date_purchase,
SUM(p.payment_value) AS total_value,
COUNT(p.order_id) AS total_order
FROM orders o
LEFT JOIN order_payments p
ON o.order_id = p.order_id
GROUP BY 1
ORDER BY 1 ASC

WITH raw AS(
SELECT
date_trunc('day',o.order_purchase_timestamp) AS date_purchase,
SUM(p.payment_value) AS total_value,
COUNT(p.order_id) AS total_order
FROM orders o
LEFT JOIN order_payments p
ON o.order_id = p.order_id
GROUP BY 1
ORDER BY 1 ASC)

SELECT *
FROM raw
WHERE total_value IS NOT NULL

SELECT
date_trunc('month',o.order_purchase_timestamp) AS date_purchase,
SUM(p.payment_value) AS total_value,
COUNT(p.order_id) AS total_order
FROM orders o
LEFT JOIN order_payments p
ON o.order_id = p.order_id
GROUP BY 1
ORDER BY 1 ASC


-- Average review score by month
SELECT
date_trunc('month',o.order_purchase_timestamp) AS date_purchase,
AVG(r.review_score) AS average_score
FROM orders o
LEFT JOIN order_reviews r
ON o.order_id = r.order_id
GROUP BY 1
ORDER BY 1 ASC

-- Customer only use boleto payment_type
WITH raw AS
(SELECT DISTINCT
c.customer_unique_id
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
LEFT JOIN order_payments p
ON p.order_id = o.order_id
WHERE p.payment_type = 'boleto')

,raw2 AS
(SELECT DISTINCT
c.customer_unique_id
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
LEFT JOIN order_payments p
ON p.order_id = o.order_id
WHERE p.payment_type <> 'boleto')

SELECT *
FROM raw
WHERE NOT EXISTS (SELECT * FROM raw2 WHERE raw.customer_unique_id = raw2.customer_unique_id)

-- Top average review score by category
SELECT
c.product_category_name_english,
AVG(r.review_score) AS average_score
FROM product_category_name_translatiON c
JOIN products p
ON c.product_category_name = p.product_category_name
JOIN order_items i
ON p.product_id = i.product_id
JOIN order_reviews r
ON i.order_id = r.order_id
GROUP BY 1
ORDER BY 2 DESC

-- TOP payment_value by category 
SELECT
p2.product_category_name_english,
SUM(o.payment_value) AS total_value
FROM products p
LEFT JOIN order_items i
ON i.product_id = p.product_id
LEFT JOIN order_payments o
ON i.order_id = o.order_id
LEFT JOIN product_category_name_translatiON p2
ON p.product_category_name = p2.product_category_name
GROUP BY 1
ORDER BY 2 DESC


-- Seller sold the most product and number of product
SELECT 
o.product_id,
o.seller_id,
pc.product_category_name_english,
s.seller_zip_code_prefix,
s.seller_city,
s.seller_state,
COUNT (DISTINCT o.order_id) AS number_order
FROM order_items o
JOIN products p
ON o.product_id = p.product_id
JOIN product_category_name_translation pc
ON p.product_category_name = pc.product_category_name
JOIN sellers s
ON o.seller_id = s.seller_id
GROUP BY 1,2,3,4,5,6
ORDER BY 7 DESC
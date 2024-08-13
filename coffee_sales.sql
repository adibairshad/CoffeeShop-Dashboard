-- creating the database
CREATE DATABASE coffe_sales_db;
   
-- Checking the data type
DESCRIBE coffee_shop_sales;
   
-- Changing data types:
   
UPDATE coffee_shop_sales 
SET 
    transaction_date = STR_TO_DATE(transaction_date, '%m/%d/%Y');
   
-- changing data type
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;
   
-- changing transaction_time from text to time
UPDATE coffee_shop_sales 
SET 
    transaction_date = STR_TO_DATE(transaction_time, '%H:%i:%s');
   
-- changing data type
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

-- renaming column
ALTER TABLE coffee_shop_sales
CHANGE COLUMN
ï»¿transaction_id transaction_id int;

-- looking for null values
SELECT * FROM coffee_shop_sales
WHERE transaction_id IS NULL;

-- --KPI--

-- SALES ANALYSIS

-- Total sale
SELECT ROUND(SUM(transaction_qty * unit_price),2) AS total_sale
FROM coffee_shop_sales;

-- Total sale for specific month say june
SELECT ROUND(SUM(transaction_qty * unit_price),2) AS total_sale
FROM coffee_shop_sales
WHERE
MONTH(transaction_date) = 6; -- june month

-- Total sale in list of month
SELECT ROUND(SUM(transaction_qty * unit_price),2) AS total_sale
FROM coffee_shop_sales
WHERE
MONTH(transaction_date) IN (1,2,3); -- jan,feb,march

-- percentage change in sale over month 
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
    (ROUND(SUM(unit_price * transaction_qty)) - 
    LAG(ROUND(SUM(unit_price * transaction_qty)), 1) OVER (ORDER BY MONTH(transaction_date))) /
    LAG(ROUND(SUM(unit_price * transaction_qty)), 1) OVER (ORDER BY MONTH(transaction_date)) * 100 AS pct_sale_change
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- APRIL,MAY
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
-- sale difference
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
    (ROUND(SUM(unit_price * transaction_qty)) - 
    LAG(ROUND(SUM(unit_price * transaction_qty)), 1) OVER (ORDER BY MONTH(transaction_date))) AS sale_diff
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- APRIL,MAY
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

-- ORDER ANALYSIS

-- Total order
SELECT COUNT(transaction_id)
FROM coffee_shop_sales;

-- percent change in the number of orders over month
SELECT
	    MONTH(transaction_date) AS month,
        COUNT(transaction_id) AS total_sale,
        ((COUNT(transaction_id) - LAG(COUNT(transaction_id),1) OVER (ORDER BY MONTH(transaction_date)))/
	    LAG(COUNT(transaction_id),1) OVER (ORDER BY MONTH(transaction_date))) * 100 AS pct_order_change
FROM  
    coffee_shop_sales
WHERE
    MONTH(transaction_date) IN (4,5) -- April,May
GROUP BY
    MONTH(transaction_date)
ORDER BY
    MONTH(transaction_date);

 -- Difference order by months
 SELECT
	    MONTH(transaction_date) AS month,
        COUNT(transaction_id) AS total_sale,
        COUNT(transaction_id) - LAG(COUNT(transaction_id),1) OVER (ORDER BY MONTH(transaction_date))
	FROM  
    coffee_shop_sales
WHERE
    MONTH(transaction_date) IN (3,4) -- March,April
GROUP BY
    MONTH(transaction_date)
ORDER BY
    MONTH(transaction_date);

-- QUANTITY SOLD ANALYSIS

-- Total quantity sold 
SELECT 
    SUM(transaction_qty) AS total_qty_sold
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5;

-- Percent change in quatity sold over month
SELECT 
     MONTH(transaction_date) AS Month,
     SUM(transaction_qty) AS total_qty_sold,
     ((SUM(transaction_qty) - LAG(SUM(transaction_qty),1) OVER (ORDER BY MONTH(transaction_date)))/
     LAG(SUM(transaction_qty),1) OVER (ORDER BY MONTH(transaction_date))) * 100 AS pct_change_qty
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (5,6)
GROUP BY
MONTH(transaction_date);

-- Difference qty by months
SELECT 
     MONTH(transaction_date) AS Month,
     SUM(transaction_qty) AS total_qty_sold,
	SUM(transaction_qty) - LAG(SUM(transaction_qty),1) OVER (ORDER BY MONTH(transaction_date))
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (5,6)
GROUP BY
MONTH(transaction_date);

-- SALES ANALYSIS BY WEEKEND AND WEEKDAYS IN A MONTH
SELECT 
    CASE
        WHEN WEEKDAY(transaction_date) IN (1 , 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sale
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 3
GROUP BY day_type;

-- SALES ANALYSIS BY STORE LOCATION
SELECT 
    store_location,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sale
FROM
    coffee_shop_sales
GROUP BY store_location
ORDER BY total_sale;

-- AVERAGE SALE ANALYSIS
SELECT 
    AVG(total_sale) AS avg_sales
FROM
    (SELECT 
        ROUND(SUM(transaction_qty * unit_price), 2) AS total_sale
    FROM
        coffee_shop_sales
        WHERE MONTH(transaction_date) = 4
        GROUP BY transaction_date ) AS inner_query;
        
 -- DAILY SLES       
SELECT 
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sale
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 4
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date);

-- COMPARING DAILY SALES WITH AVERGAE SALES
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS sale_status,
    total_sales 
FROM
    (SELECT
        DAY(transaction_date) AS day_of_month,
        ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales,
        ROUND(AVG(SUM(transaction_qty * unit_price)) OVER (), 2) AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE
        MONTH(transaction_date) = 5
    GROUP BY
        DAY(transaction_date)
    ) AS sales_data
ORDER BY 
    day_of_month;

-- SALE BY PRODUCT ANALYSIS
SELECT 
    product_category,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales
FROM
    coffee_shop_sales
GROUP BY product_category
ORDER BY total_sales DESC;

-- TOP 10 SELLING PRODUCTS
SELECT 
    product_type,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales
FROM
    coffee_shop_sales
GROUP BY product_type
ORDER BY total_sales DESC
LIMIT 10;

-- PEAK SELLING HOURS
SELECT 
    HOUR(transaction_time) AS time,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales
FROM
    coffee_shop_sales
GROUP BY HOUR(transaction_time)
ORDER BY total_sales DESC;

-- TOTAL SALES BY WEEKNAME
SELECT 
CASE 
WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
ELSE 'Sunday' 
END AS day_of_week,
ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales
FROM coffee_shop_sales
GROUP BY day_of_week;
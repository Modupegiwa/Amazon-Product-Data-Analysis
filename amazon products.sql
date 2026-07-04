--CREATE TABLE
DROP TABLE IF EXISTS amazon_sales;

CREATE TABLE amazon_sales (
    product_id TEXT,
    product_name TEXT,
    category TEXT,
    discounted_price TEXT,
    actual_price TEXT,
    discount_percentage TEXT,
    rating TEXT,
    rating_count TEXT,
    about_product TEXT,
    user_id TEXT,
    user_name TEXT,
    review_id TEXT,         -- Changed from VARCHAR(50) to TEXT to handle combined IDs
    review_title TEXT,
    review_content TEXT,
    img_link TEXT,
    product_link TEXT
);

--IMPORT CSV FILE
COPY amazon_sales 
FROM 'C:\Users\Public\Documents\amazon.csv' 
WITH (
    FORMAT CSV, 
    HEADER TRUE, 
    DELIMITER ',', 
    QUOTE '"', 
    ESCAPE '"', 
    ENCODING 'UTF8'
);

--EXPLORE THE DATA
--Check Rows
SELECT * 
FROM amazon_sales
LIMIT 10;

--Count Rows
SELECT COUNT(*)
FROM amazon_sales;

--DATA CLEANING
--Clean and convert prices (removing currency symbol and commas)
UPDATE amazon_sales 
SET 
    discounted_price = REGEXP_REPLACE(discounted_price, '[^0-9.]', '', 'g'),
    actual_price = REGEXP_REPLACE(actual_price, '[^0-9.]', '', 'g');

--Clean discount percentage (removing % sign)
UPDATE amazon_sales 
SET discount_percentage = REGEXP_REPLACE(discount_percentage, '[^0-9.]', '', 'g');

--Clean ratings (handling potential dirty data or 'null' strings)
UPDATE amazon_sales SET rating = '0' WHERE rating NOT SIMILAR TO '[0-9.]+';
UPDATE amazon_sales SET rating_count = REGEXP_REPLACE(rating_count, '[^0-9]', '', 'g');

--Drop Columns
ALTER TABLE amazon_sales DROP COLUMN img_link;
ALTER TABLE amazon_sales DROP COLUMN product_link;
ALTER TABLE amazon_sales DROP COLUMN user_name;
ALTER TABLE amazon_sales DROP COLUMN user_id; 
ALTER TABLE amazon_sales DROP COLUMN review_id;     
ALTER TABLE amazon_sales DROP COLUMN review_title; 
ALTER TABLE amazon_sales DROP COLUMN review_content;
ALTER TABLE amazon_sales DROP COLUMN about_product;
ALTER TABLE amazon_sales DROP COLUMN category;

--Alter column types to numeric for analysis
ALTER TABLE amazon_sales 
    ALTER COLUMN discounted_price TYPE NUMERIC USING discounted_price::NUMERIC,
    ALTER COLUMN actual_price TYPE NUMERIC USING actual_price::NUMERIC,
    ALTER COLUMN discount_percentage TYPE NUMERIC USING discount_percentage::NUMERIC,
    ALTER COLUMN rating TYPE NUMERIC USING rating::NUMERIC,
    ALTER COLUMN rating_count TYPE INTEGER USING rating_count::INTEGER;

-- Create two new columns for categories
ALTER TABLE amazon_sales 
ADD COLUMN main_category TEXT,
ADD COLUMN sub_category TEXT;

-- Extract the first and last items
UPDATE amazon_sales
SET 
    -- Convert string to a list and grab the 1st element
    main_category = (regexp_split_to_array(category, '\|'))[1],
    
    -- Convert string to a list and grab the last element using array_length
    sub_category = (regexp_split_to_array(category, '\|'))[array_length(regexp_split_to_array(category, '\|'), 1)];

--Split characters
-- Step 1: Add clean spaces around any ampersands (&) for both columns
UPDATE amazon_sales
SET 
    main_category = REPLACE(main_category, '&', ' & '),
    sub_category = REPLACE(sub_category, '&', ' & ');

-- Step 2: Fix stuck words like 'LapDesks' -> 'Lap Desks'
UPDATE amazon_sales
SET 
    main_category = REGEXP_REPLACE(main_category, '([a-z])([A-Z])', '\1 \2', 'g'),
    sub_category = REGEXP_REPLACE(sub_category, '([a-z])([A-Z])', '\1 \2', 'g');

-- Step 3: Clean up any double spaces and trim the outer edges in one go
UPDATE amazon_sales
SET 
    -- This shrinks multiple spaces to one, then immediately trims the edges
    main_category = TRIM(REGEXP_REPLACE(main_category, '\s+', ' ', 'g')),
    sub_category  = TRIM(REGEXP_REPLACE(sub_category, '\s+', ' ', 'g'));

--Check Rows
SELECT * 
FROM amazon_sales
LIMIT 10;

--EXPLORATORY DATA ANALYSIS
--Total Products
SELECT COUNT(DISTINCT product_id)
FROM amazon_sales;

--Number of Categories
SELECT COUNT(DISTINCT main_category)
FROM amazon_sales;

--Products per category
SELECT main_category, COUNT(*) AS products
FROM amazon_sales
GROUP BY main_category
ORDER BY products DESC;

--Average Ratings per category
SELECT ROUND(avg(rating), 2) AS average_rating, main_category
FROM amazon_sales
GROUP BY main_category
ORDER BY average_rating DESC;

--ALTER TABLE amazon_sales 
    --ALTER COLUMN discount_percentage TYPE NUMERIC USING discount_percentage::NUMERIC*100;

--Average Discount per category
SELECT ROUND(avg(discount_percentage), 2) AS average_discount, main_category
FROM amazon_sales
GROUP BY main_category
ORDER BY average_discount DESC;

--Total Savings
SELECT 
SUM(actual_price - discounted_price) AS total_savings 
FROM amazon_sales;

--Category with the highest customer engagement
SELECT main_category, SUM(rating_count) AS customer_enagagement
FROM amazon_sales
GROUP BY main_category
ORDER BY customer_enagagement DESC;

--Product Summary View
CREATE VIEW v_product_summary AS
SELECT 
    product_id,
    product_name,
    main_category,
    sub_category,
    actual_price,
    discounted_price,
    (actual_price - discounted_price) AS savings,
    discount_percentage,
    rating,
    rating_count
FROM amazon_sales;

--Review Summary View
CREATE VIEW v_review_summary AS
SELECT 
    product_id,
    product_name,
    main_category,
    rating,
    rating_count,
    CASE 
        WHEN rating >= 4.5 THEN 'Top Tier (4.5+)'
        WHEN rating >= 4.0 AND rating < 4.5 THEN 'Strong (4.0-4.4)'
        WHEN rating >= 3.0 AND rating < 4.0 THEN 'Average (3.0-3.9)'
        ELSE 'Underperforming (<3.0)'
    END AS product_tier
FROM amazon_sales
WHERE rating_count > 100; -- Filters out low-sample flukes

--Executive Summary View
CREATE OR REPLACE VIEW v_executive_summary AS
SELECT 
    main_category,
    COUNT(DISTINCT product_id) AS total_products,
    ROUND(AVG(discounted_price), 2) AS avg_discounted_price,
	ROUND(AVG(actual_price), 2) AS avg_price,
    ROUND(AVG(discount_percentage), 2) AS avg_discount_percent,
    ROUND(AVG(rating), 2) AS avg_rating,
    SUM(rating_count) AS total_reviews
FROM amazon_sales
GROUP BY main_category;
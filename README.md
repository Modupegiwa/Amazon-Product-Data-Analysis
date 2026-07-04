# Amazon-Product-Data-Analysis

## Project Overview
This project focuses on the end-to-end extraction, cleaning, and visualization of the Amazon Sales Dataset obtained from Kaggle. The dataset contains execution-ready data capturing e-commerce attributes, customer ratings, pricing metrics, and text reviews for over 1,400 products.

Using a robust data pipeline consisting of PostgreSQL (pgAdmin 4) for advanced data cleaning/transformation and Power BI for dynamic reporting, this project maps consumer behavior, identifies category dominance, and evaluates the role of aggressive discounting strategies in modern e-commerce.

## Dataset Description
The database initially consists of 16 raw fields capturing product profiles, customer identification, and granular reviews. To streamline performance and focus on business intelligence, structural changes were made to the core fields.

It consists of 1,465 unique products characterized by the following features:

1. product_id: Unique identifier for each product.

2. product_name: Complete descriptive text string of the item.

3. category: The categorical hierarchy of the product (split during ETL into main parent and sub-categories).

4. actual_price: The original retail value (formatted back to currency representation).

5. discounted_price: The finalized market selling price after markdowns.

6.discount_percentage: The fractional markdown rate applied to the product.

7. rating: The average customer satisfaction score (ranging from 0.0 to 5.0).

8. rating_count: The total number of customers who voted or wrote reviews for the item.

9. about_product: The deep textual description outlining product capabilities.

10. review_id: Combined list of unique text keys identifying verified user evaluations.

11. review_title & review_content: Short headers and extended written consumer feedback strings.

12. product_tier: A dynamically calculated segment field classification (Budget, Mid-Range, Premium) based on retail pricing thresholds.

(Note: Meta-attributes like img_link, product_link, and user_name were explicitly dropped during database optimization to eliminate technical bloat.)

## Summary of Findings
Through programmatic database querying and interactive dashboard data visualization, the following core business insights were discovered:

1. The Prevalence of Visual Anchor Pricing
The average discount rate across the entire catalog sits at an incredibly high 47.7%. This reveals that e-commerce sellers rely heavily on psychological "anchor pricing"—maintaining an artificially high actual_price while listing items at near-permanent markdowns to manipulate buyer urgency and increase checkout conversions.

2. Category Dominance & Inventory Clutter
Inventory distribution is heavily dominated by two sectors: Electronics and Computers & Accessories.

Electronics leads the ecosystem with the highest catalog headcount (over 500+ products).

Computers & Accessories sits tightly as the second largest structural category (approaching 400 products).

Niche markets such as Office Products, Home Improvement, and Musical Instruments compose very minor structural fractions of the total inventory layout.

3. Customer Engagement Concentrations
Consumer interaction is not evenly spread; it matches inventory density. Out of a massive global pool of 26.8 Million Total Customer Reviews, the Electronics category commands the overwhelming lion's share of buyer engagement, yielding an average of 57.80K review interactions per item. By comparison, Computers & Accessories records a lower concentration of 20.39K interactions.

4. Correlation Between Ratings, Tiers, and Stock Mobility
The overall average customer sentiment across the platform is highly positive, maintaining an Average Rating of 4.1 out of 5.0.

High-performing accessories (such as the Amazon Basics Wireless Mouse and specialized MFi Certified USB-C Fast Charging Cables) consistently secure flawless 5.0 star rankings with minor variance.

The analysis shows an inverse relationship between product performance and discount intensity on clearance stock: items carrying subpar consumer ratings or lower volume tiers feature heavily spiked markdowns (climbing all the way up to 94.0% in specific clearing sub-categories) as sellers aggressively drop prices to push low-performing stock out of distribution centers.

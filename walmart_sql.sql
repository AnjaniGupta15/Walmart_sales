SELECT * FROM walmart;
SELECT COUNT(*) FROM walmart;
SELECT 
 payment_method , 
 count(*)
from walmart
Group By payment_method ;

SELECT COUNT(DISTINCT Branch) FROM walmart;

SELECT MAX(quantity) from walmart;
SELECT MIN(quantity) from walmart;


-- BUSINESS PROBLEMS

-- Q1 find diff payment method and no of transaction, no of qty sold.
SELECT 
 payment_method , 
 count(*) as no_of_payment,
 SUM(quantity) as no_qty_sold
from walmart
Group By payment_method ;

-- Q2 Identify the highest rated catgory in each branch, displaying the branch , category avg rating

SELECT *
from 
( SELECT
 Branch, 
 category ,AVG(rating) as avg_rating ,
 Rank() OVER (PARTITION BY Branch ORDER BY AVG(rating) DESC) as ranking 
from walmart 
GROUP BY Branch, category
)AS temp_table
WHERE ranking =1;

-- Q3 Identify the busiest day for each branch based on no of transaction

SELECT *
FROM 
(SELECT Branch ,
   DAYNAME( Str_TO_DATE(date, "%d/%m/%y")) as day_name 
   , COUNT(*) as no_transaction,
   RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) as ranking from walmart
   GROUP BY Branch , day_name
  ) AS temp2
  WHERE ranking =1;
  
  -- Q4 Calculate total quantity of items sold per payment methods , list payment method and total _quantity.
  SELECT 
 payment_method , 
 SUM(quantity) as no_qty_sold
 from walmart
Group By payment_method;
 
 -- Q5: Determine the average, minimum, and maximum rating of categories for each city
SELECT city ,category , MIN(rating) as min_rating, 
MAX(rating) as max_rating ,AVG(rating) as avg_rating
from walmart 
GROUP BY  city ,category;


-- Q6: Calculate the total profit for each category
SELECT 
    category, SUM(total) as total_revenue,
    SUM(total * profit_margin) AS profit
FROM walmart
GROUP BY category
ORDER BY profit DESC;

-- Q7: Determine the most common payment method for each branch
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE ranking = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

   


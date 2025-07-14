create database Final_Project;
use Final_Project;
select * from walmart_sales;
ALTER TABLE walmart_sales
CHANGE `Invoice ID` invoice_id VARCHAR(255);
ALTER TABLE walmart_sales
CHANGE `Customer type` Customer_type VARCHAR(255);
ALTER TABLE walmart_sales
CHANGE `Product line` Product_line VARCHAR(255);
ALTER TABLE walmart_sales
CHANGE `Unit price` Unit_price VARCHAR(255);
ALTER TABLE walmart_sales
CHANGE `Tax 5%` Tax_5 VARCHAR(255);
ALTER TABLE walmart_sales
CHANGE `gross margin percentage` gross_margin VARCHAR(255);
ALTER TABLE walmart_sales
CHANGE `gross income` gross_income VARCHAR(255);
ALTER TABLE walmart_sales
CHANGE `Customer ID` Customer_ID VARCHAR(255);
ALTER TABLE walmart_sales
ADD COLUMN New_Date DATE;
UPDATE walmart_sales
SET New_Date = STR_TO_DATE(Date, '%d-%m-%Y');
ALTER TABLE walmart_sales DROP COLUMN date;

-- Task 1: Identifying the Top Branch by Sales Growth Rate (6 Marks) Walmart wants to identify which branch has exhibited the highest sales growth over time. Analyze the total sales for each branch and compare the growth rate across months to find the top performer. identifying top branch by total_sales.
select branch,monthname(new_date) as months ,round(sum(total), 2) as total_sale from walmart_sales group by branch,months order by branch,FIELD(months, 'January', 'February', 'March');

-- Task 2: Finding the Most Profitable Product Line for Each Branch (6 Marks) Walmart needs to determine which product line contributes the highest profit to each branch.The profit margin should be calculated based on the difference between the gross income and cost of goods sold.
create temporary table profit_ranks as
SELECT Branch,Product_line,ROUND(SUM(gross_income), 2) AS total_profit,
RANK() OVER (PARTITION BY Branch ORDER BY SUM(gross_income) dESC) AS rank_profit FROM walmart_sales GROUP BY Branch, Product_line;
select Branch,Product_line,total_profit from profit_ranks where rank_profit = 1;

-- Task 3: Analyzing Customer Segmentation Based on Spending (6 Marks) Walmart wants to segment customers based on their average spending behavior. Classify customers into three tiers: High, Medium, and Low spenders based on their total purchase amounts.
select customer_id,round(avg(total),2) as avg_spending,
case
when avg(total)>=320 then "High"
when avg(total) >= 300 and avg(total)<=320 then "Medium"
else "low"
end as spending_behavior
from walmart_sales group by customer_id;

-- Task 4: Detecting Anomalies in Sales Transactions (6 Marks) Walmart suspects that some transactions have unusually high or low sales compared to the average for the product line. Identify these anomalies.
with ProductLineAvg as 
(select Product_line,avg(Total) as avg_total from walmart_sales group by Product_line)
select w.Invoice_id,w.Branch,w.Product_line,w.Total,a.avg_total from walmart_sales w
join ProductLineAvg a
on w.Product_line = a.Product_line
where w.Total > a.avg_total * 1.5  
or w.Total < a.avg_total * 0.5  
order by w.Total desc;

-- Task 5: Most Popular Payment Method by City (6 Marks) Walmart needs to determine the most popular payment method in each city to tailor marketing strategies.
create temporary table task_5 as
select city,payment,count(payment) as count_payment,rank() over (partition by city order by count(payment) desc) as rank_payment
from walmart_sales group by city,payment;
select city,payment,count_payment from task_5 where rank_payment=1;

-- Task 6: Monthly Sales Distribution by Gender (6 Marks) Walmart wants to understand the sales distribution between male and female customers on a monthly basis.
select gender,monthname(new_date) as months,round(sum(total),2) as total_sales from walmart_sales group by gender,months order by FIELD(months, 'January', 'February', 'March');

-- Task 7: Best Product Line by Customer Type (6 Marks) Walmart wants to know which product lines are preferred by different customer types(Member vs. Normal).
create temporary table task_7 as 
select customer_type,Product_Line,count(Product_Line) as total_line,rank() 
over(partition by customer_type order by count(Product_Line) desc) as
rnk from walmart_sales group by customer_type,Product_Line;

select customer_type,Product_Line,total_line from task_7 where rnk = 1;

-- Task 8: Identifying Repeat Customers (6 Marks) Walmart needs to identify customers who made repeat purchases within a specific time frame (e.g., within 30 days).
select w1.customer_id, COUNT(distinct w1.invoice_id) AS purchase_count from walmart_sales AS w1
join walmart_sales as w2
on w1.customer_id = w2.customer_id
and w1.invoice_id <> w2.invoice_id
and DATEDIFF(w2.new_Date, w1.new_Date) between 1 and 30
group by w1.customer_id
having purchase_count > 1
order by purchase_count desc;

-- Task 9: Finding Top 5 Customers by Sales Volume (6 Marks) Walmart wants to reward its top 5 customers who have generated the most sales Revenue.
select customer_id,round(sum(total),2) as total_sales from walmart_sales group by customer_id order by total_sales desc limit 5;

-- Task 10: Analyzing Sales Trends by Day of the Week (6 Marks) Walmart wants to analyze the sales patterns to determine which day of the week brings the highest sales.
select DAYNAME(new_date) as day_of_week,round(sum(total),2) as total_sales from walmart_sales group by day_of_week order by total_sales desc;
-- Creating Database Structure --

create database fnp_sales_data;

use fnp_sales_data;
drop table customers;
create table customers(
	customer_id varchar(5) primary key,
    customer_name varchar(50) not null,
    city varchar(50) not null,
    contact_number varchar(15) not null,
    email_id varchar(100) not null,
    gender varchar(10) not null,
    address varchar(200) not null
);

create table products(
	product_id int primary key,
    product_name varchar(50) not null,
    category varchar(50) not null,
    price float not null,
    occasion varchar(30) not null
);

create table orders(
	order_id int primary key,
    customer_id varchar(5) not null,
    product_id int not null,
    quantity int not null,
    order_date varchar(15) not null,
    order_time time not null,
    delivery_date varchar(15) not null,
    delivery_time time not null
);

-- Quering the tables

select * from customers;

select * from products;

select * from orders;

-- Transforming Data
alter table orders add column order_date_2 date after order_date;
update orders set order_date_2 = str_to_date(order_date, "%d-%m-%Y");
alter table  orders drop column order_date;
alter table orders rename column order_date_2 to order_date;

alter table orders add column delivery_date_2 date after delivery_date;
update orders set delivery_date_2 = str_to_date(delivery_date, "%d-%m-%Y");
alter table  orders drop column delivery_date;
alter table orders rename column delivery_date_2 to delivery_date;

-- Calculating Total Amount for Every Orders in Orders Table
select * from orders join products on products.product_id = orders.product_id;

SELECT 
	orders.order_id as 'Order ID',
    products.product_name as 'Product Name',
    products.price as 'Product Price',
    orders.quantity as ' Order Quantity',
    products.price * orders.quantity as 'Total Amount'
FROM
    products
        JOIN
    orders ON products.product_id = orders.product_id;

-- Data Processing
alter table orders add column total_amount float;
update orders join products on orders.product_id = products.product_id
set orders.total_amount = products.price * orders.quantity; 

-- Answers to find

-- Q1. Find the total revenue generated across all the products.
select sum(total_amount) as 'Total Revenue generated across all the products' from orders;

-- Q2. Find the average customers spending on products.

select round(avg(total_amount),2) as "average customers spending on products"
 from orders;
    
-- Q3. Calculate the average time taken in days for orders to deliver.

select round(AVG(DATEDIFF(delivery_date, order_date)),2) AS 'Avg delivery time in days'
FROM
    orders;

-- Q4. Find the total revenue by morning, afternoon and evening.

select 
 case
	when hour(delivery_time) < 12 then 'Morning'
    when hour(delivery_time) < 17 then 'Afternoon'
    else 'Evening'
	
end as 'Time of Day'
from orders;

select 
 case
	when hour(delivery_time) < 12 then 'Morning'
    when hour(delivery_time) < 17 then 'Afternoon'
    else 'Evening'
	
end as `Time of Day`,
	sum(total_amount) as "Total  Revenue"
from orders
group by `time of day`;

-- Q5. Find the number of orders placed by morning, afternoon and evening.

select 
 case
	when hour(delivery_time) < 12 then 'Morning'
    when hour(delivery_time) < 17 then 'Afternoon'
    else 'Evening'
	
end as `Time of Day`,
	count(order_id) as "number of orders placed by morning, afternoon and evening"
from orders
group by `time of day`;

    
-- Q6. List total revenue generated month by month.

SELECT 
    MONTH(delivery_date) AS 'Month Number',
    MONTHNAME(delivery_date) AS 'Month Name',
    SUM(total_amount) AS 'total Revenue'
FROM
    orders
GROUP BY `Month Name` , `Month Number`
ORDER BY `Month Number`;

SELECT 
    MONTHNAME(delivery_date) AS 'Month Name',
    SUM(total_amount) AS 'total Revenue'
FROM
    orders
GROUP BY MONTH(delivery_date) , MONTHNAME(delivery_date)
ORDER BY MONTH(delivery_date);

-- Q7. List total number of orders places day by day.

SELECT 
    
    weekday(order_date) as 'day number',
    DAYNAME(order_date) AS 'DAY Name',
    count(order_id) AS 'total number of orders placed'
FROM
    orders
GROUP BY  DAYNAME(order_date), weekday(order_date)
order by weekday(order_date) ;



-- 7.2 Total Revenue by weekday and weekday.

SELECT 
    *,
    DAYNAME(delivery_date) as 'Day Name',
    weekday(delivery_date) as 'Day Number',
    CASE
        WHEN WEEKDAY(delivery_date) BETWEEN 0 AND 4 THEN 'Weekday'
        ELSE 'Weekend'
    END AS 'Weekday / Weekend'
FROM
    orders;
    
    
SELECT 
    CASE
        WHEN WEEKDAY(delivery_date) BETWEEN 0 AND 4 THEN 'Weekday'
        ELSE 'Weekend'
    END AS 'Day Status',
    SUM(total_amount) AS 'Total Revenue'
FROM
    orders
GROUP BY `Day Status`;
    

select * from products;
-- Q8. Calculate which product categories gave what revenue.

select * from orders join products on orders.product_id = products.product_id;

SELECT 
    products.category AS 'Product Category',
    SUM(orders.total_amount) AS 'Total REvenue'
FROM
    orders
        JOIN
    products ON orders.product_id = products.product_id
GROUP BY products.category;

-- Q9. Determine which 10 pr5oducts are giving the most revenue.
SELECT 
	products.product_name as 'Product Name',
    
    SUM(orders.total_amount) AS 'Total REvenue'
FROM
    orders
        JOIN
    products ON orders.product_id = products.product_id
GROUP BY products.product_name order by SUM(orders.total_amount) desc limit 10;


-- Q10. List which 10 cities are placing the highest number of orders.

SELECT 
	customers.city as 'City Name',
    
    count(orders.order_id) AS '10 cities are placing the highest number of orders'
FROM
    orders
        JOIN
    customers ON orders.customer_id = customers.customer_id
GROUP BY `City Name` order by count(orders.order_id) desc limit 10;


select * from customers;
select * from orders;
select * from products;

-- Q11. Compare the total revenue generated from different occasions.
SELECT 
	products.occasion as 'occasion',
    
    SUM(orders.total_amount) AS 'Total REvenue'
FROM
    orders
        JOIN
    products ON orders.product_id = products.product_id
GROUP BY products.occasion order by SUM(orders.total_amount) desc limit 10;

-- Q12. Find out top 5 products of every occasion.
SELECT 
	products.occasion as 'occasion',
    
    SUM(orders.total_amount) AS 'Total REvenue'
FROM
    orders
        JOIN
    products ON orders.product_id = products.product_id
GROUP BY products.occasion order by SUM(orders.total_amount) desc limit 5;


-- Q13. Find out top 5 products among different categories.

SELECT 
	products.category as 'category',
    
    SUM(orders.total_amount) AS 'Total REvenue'
FROM
    orders
        JOIN
    products ON orders.product_id = products.product_id
GROUP BY products.category order by SUM(orders.total_amount) desc limit 5;
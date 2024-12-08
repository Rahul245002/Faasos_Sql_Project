drop table if exists driver;
create database fasos;
show databases;

use fasos;
show tables;
CREATE TABLE driver(driver_id integer,reg_date date);

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'2021-01-01'),
(2,'2021-03-01'),
(3,'2021-08-01'),
(4,'2021-01-15');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60));

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24));

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1, 1, '2021-01-01 18:15:34', '20km', '32 minutes', ''),
(2, 1, '2021-01-01 19:10:54', '20km', '27 minutes', ''),
(3, 1, '2021-01-03 00:12:37', '13.4km', '20 mins', 'NaN'),
(4, 2, '2021-01-04 13:53:03', '23.4', '40', 'NaN'),
(5, 3, '2021-01-08 21:10:57', '10', '15', 'NaN'),
(6, 3, NULL, NULL, NULL, 'Cancellation'),
(7, 2, '2021-01-08 21:30:45', '25km', '25mins', NULL),
(8, 2, '2021-01-10 00:15:02', '23.4 km', '15 minute', NULL),
(9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
(10, 1, '2021-01-11 18:50:20', '10km', '10minutes', NULL);


drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1, 101, 1, '', '', '2021-01-01 18:05:02'),
(2, 101, 1, '', '', '2021-01-01 19:00:52'),
(3, 102, 1, '', '', '2021-01-02 23:51:23'),
(3, 102, 2, '', 'NaN', '2021-01-02 23:51:23'),
(4, 103, 1, '4', '', '2021-01-04 13:23:46'),
(4, 103, 1, '4', '', '2021-01-04 13:23:46'),
(4, 103, 2, '4', '', '2021-01-04 13:23:46'),
(5, 104, 1, NULL, '1', '2021-01-08 21:00:29'),
(6, 101, 2, NULL, NULL, '2021-01-08 21:03:13'),
(7, 105, 2, NULL, '1', '2021-01-08 21:20:29'),
(8, 102, 1, NULL, NULL, '2021-01-09 23:54:33'),
(9, 103, 1, '4', '1,5', '2021-01-10 11:22:59'),
(10, 104, 1, NULL, NULL, '2021-01-11 18:34:49'),
(10, 104, 1, '2,6', '1,4', '2021-01-11 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

-- How many Rolls were orderd?

SELECT 
    *
FROM
    customer_orders;

SELECT 
    COUNT(roll_id) as total_rolls_order
FROM
    customer_orders;

-- How many unique customer orders were made?

SELECT 
    COUNT(DISTINCT (Customer_id)) AS unique_customer
FROM
    customer_orders;

-- How many successful orders were delivered by each driver ?

SELECT 
    driver_id,
    COUNT(DISTINCT (driver_id)) AS successfully_delivered
FROM
    driver_order
WHERE
    pickup_time IS NOT NULL
GROUP BY driver_id;


-- How many of each type of rolls was Delivered?
SELECT 
    a.roll_name, COUNT(a.roll_id)
FROM
    (SELECT 
        driver_order.order_id,
            customer_orders.roll_id,
            rolls.roll_name
    FROM
        customer_orders
    JOIN driver_order ON customer_orders.order_id = driver_order.order_id
    JOIN rolls ON customer_orders.roll_id = rolls.roll_id
    WHERE
        driver_order.pickup_time IS NOT NULL) a
GROUP BY a.roll_name;

-- How many veg and non_veg rolls were orders by each customer?

select * from customer_orders;
select *  from rolls;

SELECT 
    a.cust_id, a.roll_name, COUNT(a.roll_id) as roll_order
FROM
    (SELECT 
        customer_orders.roll_id,
            rolls.roll_name,
            customer_orders.customer_id AS cust_id
    FROM
        customer_orders
    JOIN rolls ON customer_orders.roll_id = rolls.roll_id) a
GROUP BY a.roll_name , a.cust_id;


-- what was the maximum number of rolls delivered in single order?

SELECT 
    a.order_id, a.date, COUNT(a.order_id) AS max_delivered_order
FROM
    (SELECT 
        customer_orders.order_id, customer_orders.order_date AS date
    FROM
        customer_orders
    JOIN driver_order ON customer_orders.order_id = driver_order.order_id
    WHERE
        driver_order.pickup_time IS NOT NULL) a
GROUP BY a.order_id , a.date
ORDER BY max_delivered_order DESC
LIMIT 1;

-- for each customer, how many delivered roll had at least 1 change and how many had no changes?

select * from customer_orders;
select * from driver_order;

with temp_cust_order(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)as
(
select order_id,customer_id,roll_id,
case when not_include_items is null or not_include_items='' then '0' else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included = '' or extra_items_included ='NaN' or extra_items_included = 'Null' then '0'
else extra_items_included end as new_extra_items_included,
order_date from customer_orders
),
temp_driver_order(order_id, driver_id, pickup_time, distance, duration, new_cancellation) AS (
    SELECT
        order_id,
        driver_id,
        CASE 
            WHEN pickup_time IS NULL THEN '0' 
            ELSE pickup_time 
        END AS new_pickup_time,
        CASE 
            WHEN distance IS NULL THEN '0' 
            ELSE distance 
        END AS new_distance,
        CASE 
            WHEN duration IS NULL THEN '0' 
            ELSE duration 
        END AS new_duration,
        CASE 
            WHEN cancellation= 'Customer Cancellation' OR cancellation = 'Cancellation' THEN '0'
            ELSE 1
        END AS new_cancellation
    FROM driver_order
)

select a.customer_id,a.change_no_change,count(a.order_id) as total_count
from
(
select *, case when not_include_items = '0' and extra_items_included = '0' then 'no change' else 'change' end as change_no_change
from temp_cust_order where order_id in (
SELECT order_id from temp_driver_order where new_cancellation !=0))a
group by a.customer_id,a.change_no_change;


-- How many rolls were delivered that had both exclusion and extra?

SELECT 
    *
FROM
    customer_orders;
SELECT 
    *
FROM
    driver_order;

with temp_cust_order(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) as
(
select order_id,customer_id,roll_id,
case when not_include_items is null or not_include_items = '' then '0' else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included = 'NaN'or extra_items_included='' 
then '0' else extra_items_included end as new_extra_item_included,
order_date from customer_orders

),
temp_driver_order(order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(
select order_id,driver_id,
case when pickup_time is null  then '0' else pickup_time end as new_pickup_time,
case when distance is null  then '0' else distance end as distance,
case when duration is null then '0' else duration end as new_duration,
case when cancellation is null or cancellation='' or cancellation='NaN' then '1' else 0 end as new_cancellation
from driver_order
)
select a.customer_id,a.roll_id,count(a.mutually) as total_count
from
(select *, case when not_include_items !='0' and extra_items_included !='0' then 1 else 0 end as mutually from temp_cust_order where order_id in(
select order_id from temp_driver_order where new_cancellation !=0))a where mutually !=0 group by a.roll_id, a.customer_id;


-- what was the total no of rolls ordered for each hour of the day?

select * from customer_orders;

SELECT 
    a.hour, COUNT(a.roll_id) as total_roll_order
FROM
    (SELECT 
        *,
            CONCAT(HOUR(order_date), '-', HOUR(order_date) + 1) AS hour
    FROM
        customer_orders) a
GROUP BY a.hour;

-- what was the number of orders for each day of the week?

select * from customer_orders;

SELECT 
    a.dy, count(distinct(a.order_id)) AS total_order
FROM
    (SELECT 
        *, DAYNAME(order_date) AS dy
    FROM
        customer_orders) a
GROUP BY dy
ORDER BY total_order DESC;


-- what was the average time in minutes it took for each driver to arrive at the fasoos HQ to pickup the order?

select * from customer_orders;
select * from driver_order;

SELECT 
    a.driver_id, ROUND(AVG(time_diff), 2) AS avg_min
FROM
    (SELECT 
        customer_orders.order_date,
            driver_order.driver_id,
            driver_order.pickup_time,
            TIMESTAMPDIFF(MINUTE, customer_orders.order_date, driver_order.pickup_time) AS time_diff
    FROM
        customer_orders
    JOIN driver_order ON customer_orders.order_id = driver_order.order_id
    WHERE
        driver_order.pickup_time IS NOT NULL) a
GROUP BY a.driver_id;

-- is there any relationship between the number of rolls and how long the order take to prepare?

select * from customer_orders;
select * from driver_order;

SELECT 
    a.order_id,
    COUNT(a.roll_id) AS roll_count,
    ROUND(SUM(time_diff) / COUNT(roll_id), 2) AS time_taken
FROM
    (SELECT 
        customer_orders.order_date,
            customer_orders.roll_id,
            customer_orders.order_id,
            driver_order.pickup_time,
            TIMESTAMPDIFF(MINUTE, customer_orders.order_date, driver_order.pickup_time) AS time_diff
    FROM
        customer_orders
    JOIN driver_order ON customer_orders.order_id = driver_order.order_id
    WHERE
        driver_order.pickup_time IS NOT NULL) a
GROUP BY a.order_id;

-- what is the avg distance travelled for each customer?

select * from driver_order;

SELECT 
    a.customer_id, ROUND(AVG(a.distance), 2) AS avg_dist
FROM
    (SELECT 
        customer_orders.customer_id, driver_order.distance
    FROM
        customer_orders
    INNER JOIN driver_order ON customer_orders.order_id = driver_order.order_id
    WHERE
        distance IS NOT NULL) a
GROUP BY a.customer_id
ORDER BY avg_dist DESC;

-- what was the difference between the longest an shortest delivery time for all orders?
   
   
   SELECT 
    c.max_duration - c.min_duration AS diff_between_longest_shortest_time
FROM
    (SELECT 
        MAX(avg_duration) AS max_duration,
            MIN(avg_duration) AS min_duration
    FROM
        (SELECT 
        a.order_id, AVG(a.cleaned_duration) AS avg_duration
    FROM
        (SELECT 
        customer_orders.order_id,
            driver_order.duration,
            TRIM(LOWER(REPLACE(REPLACE(REPLACE(REPLACE(driver_order.duration, 'mins', ''), 'minute', ''), 'minutes', ''), 's', ''))) AS cleaned_duration
    FROM
        customer_orders
    INNER JOIN driver_order ON customer_orders.order_id = driver_order.order_id
    WHERE
        driver_order.duration IS NOT NULL) a
    GROUP BY a.order_id
    ORDER BY avg_duration DESC) b) c;
    
    -- what was the avg speed for each driver for each delivery and do you notice any trend for these values?
    
    select * from customer_orders;
    select * from driver_order;
    
    SELECT 
    a.driver_id, ROUND(AVG(a.distance / a.duration), 2) AS speed
FROM
    (SELECT 
        driver_id, distance, duration
    FROM
        driver_order
    WHERE
        distance OR duration IS NOT NULL) a
GROUP BY a.driver_id;

-- what is the successful delivery percentage for each driver?

select * from driver_order;

select b.driver_id, b.cnt/b.cd*100 as percentage_of_successful_delivery
from
(select a.driver_id, count(a.driver_id) as cd,sum(a.cancellation) as cnt
from
(with temp_driver_table(order_id,driver_id,pickup_time,distance,duration,cancellation) as 
(
select order_id,driver_id,
case when pickup_time is null then 0 else pickup_time end as new_pickup_time,
case when distance is null then 0 else distance end as new_distance,
case when duration is null then 0 else duration end as new_duration,
case when cancellation is null or cancellation = 'NaN' or cancellation = '' then 1 else 0 end as new_cancellation
from driver_order
)
select * from temp_driver_table)a
group by driver_id)b;
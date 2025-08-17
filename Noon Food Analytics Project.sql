--1. Find top 3 outlets by cuisine type without using limit or top function
with cte as 
	(select Cuisine, Restaurant_id,
	count(*) as number_of_orders
	from orders
	group by Cuisine, Restaurant_id)
select * from
	(select  *,
	row_number() over(partition by cuisine order by number_of_orders desc) as rn
	from cte) a
where rn <= 3


--2. Find the daily new customer count from the launch date (everyday how many new customers are we acquired)
with cte as
	(select Customer_code, 
	cast(min(Placed_at) as date) as first_order_date
	from orders
	group by Customer_code)
select first_order_date,
count(*) as number_of_new_customers
from cte
group by first_order_date
order by first_order_date
;


--3. count all the users who were acquired in Jan 2024 and only placed one order in Jan and did not place any other order
select Customer_code, 
count(*) as number_of_orders
from orders
where month(Placed_at) = 1 and year(Placed_at) = 2024
	  and Customer_code not in (select distinct Customer_code
								from orders
								where not (month(Placed_at) = 1 and year(Placed_at) = 2024))
group by Customer_code
having count(*) = 1;


--4. list ALL the customers with no order in the last 7 days but were acquired one month ago with their first order on promo
with cte as
	(select Customer_code,
	min(placed_at) as first_order_date,
	max(placed_at) as latest_order_date
	from orders
	group by Customer_code)
select c.*, o.Promo_code_Name as first_order_promo_code 
from cte c
inner join orders o on c.Customer_code = o.Customer_code and c.first_order_date = o.Placed_at
where latest_order_date < dateadd(day, -7, getdate())
	  and first_order_date < dateadd(month, -1, getdate())
	  and Promo_code_Name is not null;


--5. Growth team is planning to create a trigger that will target customers after their every third order with a 
--personalized communication and they have asked you to create a query for this
with cte as
	(select *,
	row_number() over(partition by customer_code order by placed_at) as order_number
	from orders)
select * from cte
where order_number%3 = 0 and cast(placed_at as date) = cast(getdate() as date) 
;


--6. list customers who placed more than 1 order and all their orders on a promo only.
select Customer_code, 
count(*) as number_of_orders,
count(Promo_code_Name) as promo_only 
from orders
group by Customer_code
having count(*) > 1 and count(*) = count(Promo_code_Name)
;


--7. what percent of customers were organically acquired in Jan 2024 (placed their first order without promo)
with cte as
	(select *,
	row_number() over(partition by Customer_code order by Placed_at) as rn
	from orders
	where month(placed_at) = 1)
select count(case when rn = 1 and Promo_code_Name is null then customer_code end)*100.0/count(distinct Customer_code) as organically_acquired_customers 
from cte
;

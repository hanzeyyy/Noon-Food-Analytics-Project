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

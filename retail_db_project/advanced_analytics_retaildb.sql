/*lets start the power up with pivot table*/

create extension tablefunc 

select o.order_date ,o.order_status, count(1) 
from orders o 
group by order_date, order_status 
order by order_date, order_status 
limit 18


select * from crosstab(
	'select order_date, order_status, count(1) as order_count
	from orders 
	group by order_date, order_status',
	'select distinct order_status 
		from orders 
		order by 1') as (
		order_date DATE, 
		"canceled" INT, 
		"closed" INT,
		"complete" INT,
		"on_hold" INT, 
		"payment_review" INT, 
		"pending" INT,
		"pending_payment" INT,
		"processing" INT,
		"suspected_fraud" INT
		)
		
/*Earnestly getting into analytics*/
		
/*
* Aggregate Functions (`sum`, `min`, `max`, `avg`)

* Window Functions (`lead`, `lag`, `first_value`, `last_value`)

* Rank Functions (`rank`, `dense_rank`, `row_number` etc)

* There will moving cumulative and filtering functions

* For all the functions when used as part of Analytic or Windowing
functions we use `OVER` clause.

* For aggregate functions we typically use `PARTITION BY`

* For global ranking and windowing functions we can use `ORDER BY sort_column` and for ranking and windowing with in a partition or group we can use `PARTITION BY partition_column ORDER BY sort_column`.

* Here is how the syntax will look like.
  * Aggregate - `func() OVER (PARTITION BY partition_column)`
  * Global Rank - `func() OVER (ORDER BY sort_column DESC)`
  * Rank in a partition - `func() OVER (PARTITION BY partition_column ORDER BY sort_column DESC)`
* We can also get cumulative or moving metrics by adding `ROWS BETWEEN` clause. We will see details later.
*/
		
create table daily_revenue
as
select o.order_date , 
round(sum(oi.order_item_subtotal)::numeric,2) as revenue
from order_items oi join orders o 
on o.order_id = oi.order_item_order_id 
where o.order_status in ('complete','closed')
group by o.order_date 

select *
from daily_revenue 
limit 5

create table daily_product_revenue
as
select o.order_date , oi.order_item_product_id , 
round(sum(oi.order_item_subtotal)::numeric ,2) as product_revenue
from order_items oi join orders o 
on o.order_id = oi.order_item_order_id 
join products p 
on p.product_id = oi.order_item_product_id 
where o.order_status in ('complete','closed')
group by oi.order_item_product_id , o.order_date 

select *
from daily_product_revenue 
order by order_date, product_revenue DESC
limit 6

/*Note from here on the hrdb is being used ...*/

select e.department_id , sum(e.salary) as dept_expense
from employees e 
group by e.department_id 
order by e.department_id 

/*The raw data is gone. How to keep the raw data and then group it??*/
select e2.employee_id , e2.department_id , e2.salary ,
ae.dept_expense, ae.dept_avg
from employees e2 join(
	select e.department_id , sum(e.salary) as dept_expense, 
		round(avg(e.salary)::numeric, 2) as dept_avg
	from employees e 
	group by e.department_id 
) ae
on e2.department_id = ae.department_id
order by e2.department_id , e2.salary
limit 5

/*see how simple it is using partition and over clause*/

select e.employee_id , e.department_id ,e.salary, 
sum(e.salary) over(
	partition by e.department_id 	
	) as dept_exp,
avg(e.salary) over(
	partition by e.department_id 
	) as dept_avg
from employees e 

select
	e.employee_id ,
	e.salary,
	sum(e.salary) over(
	partition by e.department_id 	
	) as dept_exp,
	avg(e.salary) over(
	partition by e.department_id 
	) as dept_avg,
	e.salary / sum(e.salary) over(partition by e.department_id) as pct_exp
from
	employees e


select e.employee_id ,e.department_id , e.salary,
	min(e.salary) over(
		partition by e.department_id 
	) as min_salary,
	max(e.salary) over(
		partition by e.department_id 
	) as max_salary,
	count(e.salary) over(
		partition by e.department_id 
	) as count_sal
from employees e 
order by e.salary 

/*Now jumping to retail_db again*/

select order_date, product_revenue, 
	sum(product_revenue) over(
		partition by order_date
	) as daily_revenue,
	avg(product_revenue) over(
		partition by order_date
	) as avg_daily
from daily_product_revenue 
order by order_date, daily_revenue

select *
from daily_product_revenue  

select t.*, 
	round(sum(t.revenue) over ( 
		order by t.order_date
		rows between 2 preceding and current row
	) ,2) as moving_3day_sum, 
	round(sum(t.revenue) over (
		order by t.order_date
		rows between 2 preceding and 2 following 
	), 2) as moving_4day_sum,
	round(avg(t.revenue) over ( 
		order by t.order_date
		rows between 2 preceding and current row 
	), 2) as moving_3day_avg
from daily_revenue t
order by t.order_date
limit 10

/*starting with the windowing function that involves lead, lag, first and last value*/

select t.*, 
	lead(t.order_date) over (order by t.order_date desc) as prior_date,
	lead(t.revenue) over (order by t.order_date desc) as prior_revenue,
	lag(t.order_date) over (order by t.order_date) as lag_date,
	lag(t.revenue) over (order by t.order_date) as lag_revenue
from daily_revenue t
order by t.order_date 
limit 10

select t.*, 
	lead(t.order_date, 5) over (order by t.order_date desc) as prior_date,
	lead(t.revenue, 5) over (order by t.order_date desc) as prior_revenue
from daily_revenue t
order by t.order_date desc
limit 10

select t.*, 
	lead(t.order_date, 5) over (order by t.order_date desc) as prior_date,
	lead(t.revenue, 5,0.0) over (order by t.order_date desc) as prior_revenue
from daily_revenue t
order by t.order_date
limit 10

select t.*, 
	first_value(t.order_item_product_id) over ( 
		partition by t.order_date order by t.product_revenue
	) as firstPdtId,
	first_value (t.product_revenue) over ( 
		partition by t.order_date order by t.product_revenue desc
		
	) as first_revenue,
	max(t.product_revenue) over ( 
		partition by order_date
	) as max_revenue
from daily_product_revenue t
	
SELECT t.*,
    last_value(order_item_product_id) OVER (
        PARTITION BY order_date ORDER BY product_revenue    
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
    ) last_product_id,
    max(product_revenue) OVER (
        PARTITION BY order_date
    ) last_revenue
FROM daily_product_revenue AS t
ORDER BY order_date, product_revenue DESC
LIMIT 30


/*that is the end of aggregate function and starting the cumulative function*/
/*We are moving the hrdb again*/

select e.employee_id , e.salary ,e.department_id ,
	sum(e.salary) over ( 
		partition by e.department_id 
		order by e.salary 
		rows between unbounded preceding and current row 
	) as sum_sal_expense
from employees e 
order by e.department_id , e.salary desc
limit 10

/*If we have to assign ranks globally, we just need to specify ORDER BY

* If we have to assign ranks with in a key then we need to specify PARTITION BY and then ORDER BY.
* By default ORDER BY will sort the data in ascending order. We can change the order by passing DESC after order by.
* We have 3 main functions to assign ranks - 
	* rank, 
	* dense_rank and 
	* row_number.*/


select rank() over ( 
		partition by dpr.order_date 
		order by dpr.product_revenue desc
	) as rvn_rank, 
	dpr.order_date , dpr.product_revenue, 
	to_char(dpr.order_date,'mm-dd') as order_day
from daily_product_revenue dpr 
offset 200

/*FJWGSO is the reason CTE, CTAS, subqueries and views play a major
role in querying the database. The execution flow has select at the 
last, so aliases created in select will not be available from W & G 
ops.*/

/*using cte with rank()*/
with rank_revenue 
as (
	select rank() over ( 
		partition by dpr.order_date 
		order by dpr.product_revenue desc
	) as rvn_rank, 
	dpr.order_date , dpr.product_revenue, 
	to_char(dpr.order_date,'mm-dd') as order_day
	from daily_product_revenue dpr
) 
select rvn_rank, order_day from rank_revenue 
where rvn_rank <= 5

/*using ctas */
create table rank_revenue_ctas
as 
select rank() over ( 
		partition by dpr.order_date 
		order by dpr.product_revenue desc
	) as rvn_rank, 
	dpr.order_date , dpr.product_revenue, 
	to_char(dpr.order_date,'mm-dd') as order_day
	from daily_product_revenue dpr 

select * 
from rank_revenue_ctas 
where order_day = '07-26'
limit 5

/*using the temp view*/
create or replace view rank_revenue_view 
as 
select rank() over ( 
		partition by dpr.order_date 
		order by dpr.product_revenue desc
	) as rvn_rank, 
	dpr.order_date , dpr.product_revenue, 
	to_char(dpr.order_date,'mm-dd') as order_day
	from daily_product_revenue dpr

select * 
from rank_revenue_view 
limit 5

/*following wont work as */

SELECT t.*,
    dense_rank() OVER (
      PARTITION BY order_date
      ORDER BY product_revenue DESC
    ) AS drnk
  FROM daily_product_revenue t
  where drnk <=5 

/***********using subquery*********/
  
SELECT * FROM (
  SELECT t.*,
    dense_rank() OVER (
      PARTITION BY order_date
      ORDER BY product_revenue DESC
    ) AS drnk
  FROM daily_product_revenue t
) q
WHERE q.drnk <= 5
ORDER BY q.order_date, q.product_revenue DESC
LIMIT 10


/***********************8*/

/*moving over to hrdb for additional examples*/

/*ctrl + 9 is the short cut to change the data source in dbeaver*/

/*using order by for the global sorting*/
select e.employee_id , e.department_id , e.salary 
from employees e 
order by e.department_id , e.salary 

select e.department_id , e.employee_id,
	rank () over (
		partition by e.department_id 
		order by e.salary 
	) as salary_rnk
from employees e 

select e.department_id , e.employee_id,
	dense_rank () over (
		partition by e.department_id 
		order by e.salary 
	) as salary_rnk
from employees e 

/*apt example to understand the diff between rank, dense_rank and row_number*/

select e.employee_id, e.salary,
	rank () over ( 
		order by e.salary 
	) as simple_rank,
	dense_rank () over (
		order by e.salary
	) as dense_ranker,
	row_number () over ( 
		order by e.salary
	) as rower
from employees e 

/*notice the simple ranking gives the ranks considering the ordinal position
in the entire list*/

/** We can use either of the functions to generate ranks 
 * when the rank field does not have duplicates.
* When rank field have duplicates then row_number should not be used 
* as it generate unique number for each record with in the partition.
* **rank** will skip the ranks in between if multiple people get the 
* same rank while **dense_rank** continue with the next number.*/

/*move to retail_db data source*/

select dpr.order_item_product_id , 
	to_char(dpr.order_date, 'yy-mm-dd') as order_day,
	rank () over ( 
		partition by dpr.order_date  
		order by dpr.product_revenue 
	) as ranker,
	dense_rank () over ( 
		partition by dpr.order_date  
		order by dpr.product_revenue 
	) as dense_ranker,
	row_number  () over ( 
		partition by dpr.order_date  
		order by dpr.product_revenue 
	) as rower
from daily_product_revenue dpr 
where to_char(dpr.order_date, 'yy-mm-dd')='13-07-26'
limit 5

/*when filtering remember the below execution flow*/

/* FJWGSO
 * FROM ==> 
 * JOIN or OUTER JOIN with ON ==> 
 * WHERE ==>
 * GROUP BY and optionally HAVING =>
 * SELECT ==>
 * ORDER BY
*/

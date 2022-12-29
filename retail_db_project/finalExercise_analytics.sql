/*The file is the final ItVersity sql exercise on Analytics*/

/*the database hrdb will be used

* Get all the employees who is making more than 
average salary with in each department.
* Get cumulative salary for one of the department 
along with department name.
* Get top 3 paid employees with in each 
department by salary (use dense_rank)
* Get top 3 products sold in the 
month of 2014 January by revenue.
* Get top 3 products in each category sold in the 
month of 2014 January by revenue.*/

/*REMEMBER ==> FJWGSO*/

/*query 1 : using subquery*/

select q.department_id, q.dept_avg, e2.employee_id , e2.salary  from (
select avg(e.salary) as dept_avg, e.department_id
from employees e 
group by e.department_id 
order by dept_avg
) q join employees e2 
on e2.department_id = q.department_id
where e2.salary > q.dept_avg
order by q.department_id desc

/*query 1 : using cte*/

with dept_avg_table 
as ( 
	select avg(e.salary) as dept_avg, e.department_id
	from employees e 
	group by e.department_id 
	order by dept_avg
) select dat.dept_avg, dat.department_id, e2.employee_id , e2.salary
from dept_avg_table dat join employees e2
on dat.department_id = e2.department_id 
where e2.salary > dat.dept_avg
order by e2.department_id , e2.salary desc
 /*follow the requirement exactly*/

/*query 1 : using over clause and cte*/

with dept_avg_over_clause 
as (
select e.employee_id , e.department_id ,e.salary , 
	avg(e.salary) over ( 
		partition by department_id 
	) as dept_avg_salary 
from employees e 
) select daoc.employee_id, daoc.department_id, daoc.salary, 
	daoc.dept_avg_salary
from dept_avg_over_clause daoc
where daoc.salary > daoc.dept_avg_salary
order by daoc.department_id desc

/*below query is support for checking*/
select e.employee_id , e.department_id ,e.salary , 
	avg(e.salary) over ( 
		partition by department_id 
		order by e.salary desc
	) as dept_avg_salary 
from employees e 

/*query 2: getting the cumulative salary of one department*/

/*this is equal to group by*/
select e.employee_id , e.department_id ,e.salary ,
	sum(e.salary) over ( 
		partition by e.department_id 
	) as cumulative_salary
from employees e  

/*rows between current and following works*/
select e.employee_id ,e.salary ,d.department_name, 
	sum(e.salary) over ( 
		partition by e.department_id 
		rows between current row and unbounded following  
	) as cummulative_real
from employees e join departments d 
on d.department_id = e.department_id
where d.department_name in ('Finance','IT')
order by d.department_name , e.salary 

/*take a look at how the values have been cumulated... */
select e.employee_id , e.department_id , e.salary ,
	sum(e.salary) over ( 
		partition by e.department_id 
		rows between unbounded preceding and current row
	) as cummulative_real
from employees e 
where e.department_id = 30

/*query 3: top three employees based on salary*/

select e.employee_id , e.department_id , e.salary ,
	dense_rank () over(
		partition by e.department_id 
		order by e.salary desc
	) as salary_dense_rank
from employees e 

/*getting only the top 3 requires using additional table*/

create table employee_rank 
as
select e.employee_id , e.department_id , e.salary ,
	dense_rank () over(
		partition by e.department_id 
		order by e.salary desc
	) as salary_dense_rank
from employees e 

select er.employee_id, er.department_id, er.salary_dense_rank
from employee_rank er
where er.salary_dense_rank <=3

/*next 2 queries will involve retail_db, switch the data source*/

/*query 4: top 3 products sold in Jan 2014*/

/*following query is partitioning on each day of the month*/

with jan_pdt_rank
as (
select o.order_date , oi.order_item_product_id , oi.order_item_subtotal ,
	dense_rank() over (
		partition by o.order_date
		order by oi.order_item_subtotal 
	) as pdt_rank
from order_items oi join orders o 
on oi.order_item_order_id = o.order_id 
where to_char(o.order_date,'yyyy-mm') = '2014-01'
) select distinct jpr.order_item_product_id, jpr.pdt_rank
from jan_pdt_rank jpr 
where jpr.pdt_rank <= 3
order by jpr.pdt_rank desc


with jan_pdt_rank
as (
select o.order_date , oi.order_item_product_id , oi.order_item_subtotal ,
	dense_rank() over (
		partition by to_char(o.order_date, 'yyyy-mm')
		order by oi.order_item_subtotal 
	) as pdt_rank
from order_items oi join orders o 
on oi.order_item_order_id = o.order_id 
where to_char(o.order_date,'yyyy-mm') = '2014-01'
) select distinct jpr.order_item_product_id, jpr.pdt_rank,
from jan_pdt_rank jpr 
where jpr.pdt_rank <= 3
order by jpr.pdt_rank desc

/*supporting query*/

select dense_rank() over (
		partition by to_char(o.order_date, 'yyyy-mm')
		order by oi.order_item_subtotal 
	) as pdt_rank, o.order_date , oi.order_item_product_id , 
		oi.order_item_subtotal
from order_items oi join orders o 
on oi.order_item_order_id = o.order_id 
where to_char(o.order_date,'yyyy-mm') = '2014-01'
order by pdt_rank 

/*need to check the solution for this query*/

select distinct oi.order_item_product_id, 
	dense_rank () over ( 
		order by oi.order_item_subtotal 
	) as sub_rank
from order_items oi join orders o 
on oi.order_item_order_id = o.order_id 
where to_char(o.order_date,'yyyy-mm') = '2014-01'
order by sub_rank

/*query 5 : top 3 products sold in each category in jan'14*/

/*lets get the players to the arena in month of jan'14*/

select o.order_date , oi.order_item_product_id , p.product_category_id ,
oi.order_item_subtotal 
from order_items oi join orders o 
on o.order_id = oi.order_item_order_id 
join products p on p.product_id = oi.order_item_product_id 
where to_char(o.order_date, 'yyyy-mm') = '2014-01' 

/*apply global group by */

select p.product_category_id , p.product_id , 
	sum(oi.order_item_subtotal) as pdt_cat_sum 
from order_items oi join orders o 
on o.order_id = oi.order_item_order_id 
join products p on p.product_id = oi.order_item_product_id 
where to_char(o.order_date, 'yyyy-mm') = '2014-01' 
group by p.product_category_id , p.product_id 
order by p.product_id, pdt_cat_sum

/*apply dense_rank on that group by: using cte*/

with pdt_categ_table
as (
	select p.product_category_id , p.product_id , 
		sum(oi.order_item_subtotal) as pdt_cat_sum 
	from order_items oi join orders o 
	on o.order_id = oi.order_item_order_id 
	join products p on p.product_id = oi.order_item_product_id 
	where to_char(o.order_date, 'yyyy-mm') = '2014-01' 
	group by p.product_category_id , p.product_id 
	order by p.product_id, pdt_cat_sum
) select product_category_id, product_id, 
	dense_rank () over ( 
		order by pdt_cat_sum
	) as dense_ranker
from pdt_categ_table
where product_category_id = 18
order by dense_ranker 

select count(1) as dept_cat_count, c.category_department_id  
from categories c 
group by c.category_department_id

select max(p.product_id), min(p.product_id), p.product_category_id,
	count(1) as num_pdt
from products p  
group by p.product_category_id 

select max(p.product_category_id) over(partition by c.category_department_id ) as first_pid,
min(p.product_category_id) over(partition by c.category_department_id) as last_pid
from products p join categories c 
on c.category_id  = p.product_category_id
order by c.category_department_id 

/*the solution*/

with trial_table
as (	
	SELECT p.product_id, p.product_name,
             round(sum(oi.order_item_subtotal)::numeric ,2) AS revenue
    FROM orders o JOIN order_items oi
            ON o.order_id = oi.order_item_order_id
        JOIN products p
            ON oi.order_item_product_id = p.product_id
    WHERE o.order_status IN ('complete','closed') AND to_char(order_date,'yyyy-MM-dd') LIKE '2014-01%'
    GROUP BY p.product_id, p.product_name
    ORDER BY revenue desc
) select * ,
	dense_rank () over (order by revenue desc) as drnk
from trial_table
	
with temp_table
as(
 SELECT  cat.category_id,cat.category_name, P.product_id,p.product_name,
    round(sum(oi.order_item_subtotal::numeric),2) AS revenue
    FROM orders o 
    JOIN order_items oi
        ON o.order_id = oi.order_item_order_id
    JOIN products p
        ON  p.product_id = oi.order_item_product_id
    JOIN categories cat 
        ON cat.category_id = p.product_category_id
    WHERE o.order_status IN ('complete' , 'closed')
    AND to_char(order_date, 'yyyy-MM-dd') LIKE '2014-01%'
    AND cat.category_name IN ('Cardio Equipment','Strength Training')
    GROUP BY cat.category_id,cat.category_department_id,cat.category_name,p.product_id
    ORDER BY cat.category_id
) select *, 
	dense_rank () over (partition by category_id order by revenue desc) as pdt_rnk
from temp_table

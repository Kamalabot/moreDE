/*views will be explored here*/

/*We cannot directly update data in tables via views when the 
 * view is defined with joins. Even operations such as 
 * `GROUP BY` or `ORDER BY` etc will make views not updatable by default.*/

/*In this script we will see 4 
 * create or repalace view view_name
 * with named-query as (also called CTEs)
 * subquery created on the fly using select... from ... as sub-query
 * create table as select (CTAS)*/

/*after the multiple ways of creating tables and views are mastered, 
then we move into advanced querying and dml */

create or replace view myKordr
as
select o.* 
from orders o 

/*thats a bummer, the views don't show popup....*/
select my.order_status, my.order_id
from mykordr my 

update mykordr 
set order_status=lower(order_status)

/*changing the column params in the views changes the parent table also....*/ 
select * from orders o limit 5


create or replace view oi_products
as
select distinct oi.order_item_product_id, 
	oi.order_item_product_price, p.product_category_id,
	p.product_name 
from order_items oi join products p 
on p.product_id = oi.order_item_product_id 

/*the views can be built with ease..Depending on the tasks 
 * that you are trying to accomplish.*/

select * from oi_products limit 5
/*build the view and view it*/


/*You explore the dataset and then see if it will be useful*/
select c.category_id, oip.order_item_product_price, c.category_name 
from oi_products oip join categories c 
on c.category_id = oip.product_category_id

/*what will be the max, min & average price of products inside the category*/
select c.category_name, max(oip.order_item_product_price) as max_price, 
min(oip.order_item_product_price) as min_price, 
round(avg(oip.order_item_product_price)::numeric ,2) as avg_price
from oi_products oip join categories c 
on c.category_id = oip.product_category_id
group by c.category_name 
order by avg_price desc 

analyse orders

explain select * from orders o 

explain
select
	*
from
	order_items oi
where
	order_item_product_id = 25
	
explain analyse 
select
	*
from
	order_items oi
where
	order_item_product_id = 25

/*starting named queries*/
with order_oi_nq as(	
	select *
	from orders o join order_items oi 
	on oi.order_item_order_id = o.order_id 
	) select order_status , order_item_product_id 
		from order_oi_nq
	
/*select *  from order_oi_nq */ /*will throw error*/
		
create or replace view view_from_nq
as 
with order_oi_nq as(	
	select *
	from orders o join order_items oi 
	on oi.order_item_order_id = o.order_id 
	) select order_status , order_item_product_id, order_customer_id, 
		order_item_order_id
		from order_oi_nq 

/*The views can be created on top of the named queries, which will 
work when queried seperately*/

select * from view_from_nq 

SELECT * FROM order_items oi
WHERE oi.order_item_order_id 
    NOT IN (
        SELECT order_id FROM orders o
        WHERE o.order_id = oi.order_item_order_id
    )

SELECT count(1) FROM order_items oi
WHERE oi.order_item_order_id 
    IN (
        SELECT order_id FROM orders o
        WHERE o.order_id = oi.order_item_order_id
    )
 
/*The below query has been pulled out of the above in query... for analysis*/    
 SELECT order_id FROM orders o
 WHERE o.order_id = oi.order_item_order_id

/*seems like IN and EXISTS clause are like filters*/
 
SELECT * FROM (
    SELECT nq.*,
        dense_rank() OVER (
            PARTITION BY order_date
            ORDER BY revenue DESC
        ) AS drnk
    FROM (
        SELECT o.order_date,
            oi.order_item_product_id,
            round(sum(oi.order_item_subtotal)::numeric, 2) AS revenue
        FROM orders o 
            JOIN order_items oi
                ON o.order_id = oi.order_item_order_id
        WHERE o.order_status IN ('complete', 'closed')
        GROUP BY o.order_date, oi.order_item_product_id
    ) nq
) nq1
WHERE drnk <= 5
ORDER BY order_date, revenue DESC
LIMIT 20 

select o.order_status 
from orders o 
limit 5

/*below query will have no data, since the order_status has been lowercased*/

SELECT o.order_date,
            oi.order_item_product_id,
            round(sum(oi.order_item_subtotal)::numeric, 2) AS revenue
        FROM orders o 
            JOIN order_items oi
                ON o.order_id = oi.order_item_order_id
        WHERE o.order_status IN ('COMPLETE', 'CLOSED')
        GROUP BY o.order_date, oi.order_item_product_id
 
/*Something very interesting is gonna surface, that is CTAS. Before that 
 * I did some side exploration into jq tool... */

drop table backup_orders

/*note these CTAS tables don't get replaced*/

create table backup_orders
as
select o.order_id ,
	to_char(o.order_date,'yyyy')::int as order_year,
	to_char(o.order_date, 'mm')::int as order_month,
	to_char(o.order_date, 'dd')::int as order_day
from orders o 

select *
from backup_orders 
limit 5

/*one way to create really empty table*/

create table order_empty
as
select * from order_items oi where 1 = 2

select * from order_empty

drop table if exists order_empty

drop table if exists backup_orders







 
        
/*We are gonna see some serious analytics fu with this script*/

/*I was confused with numeric / int then realised that numeric & decimal types 
can store rational numbers while the int and bigint can store only 
whole number*/

create table customers_orders_mnth_metrics(
	customer_id INT,
	order_month char(7),
	order_count int,
	order_revenue FLOAT
)

alter table customers_orders_mnth_metrics 
	add primary key (order_month, customer_id)

/*below is the table that has monthly revenue details*/	
	
select o.order_customer_id,
	to_char(o.order_date,'yyyy-MM') as order_month,
	count(1) as order_count,
	round(sum(order_item_subtotal)::numeric,2) as order_revenue
from orders o join order_items oi 
on o.order_id = oi.order_item_order_id 
group by o.order_customer_id , to_char(o.order_date,'yyyy-MM')
order by order_month, order_count desc

explain select count(1) 
from orders o join order_items oi 
on o.order_id = oi.order_item_order_id 

/*That will show how expensive the join can be. i still need to 
 * learn reading the explain analyze output*/

insert into customers_orders_mnth_metrics 
select o.order_customer_id,
	to_char(o.order_date,'yyyy-MM') as order_month,
	count(1) as order_count,
	round(sum(order_item_subtotal)::numeric,2) as order_revenue
from orders o join order_items oi 
on o.order_id = oi.order_item_order_id 
group by o.order_customer_id , to_char(o.order_date,'yyyy-MM')
order by order_month, order_count desc

explain analyse select * from customers_orders_mnth_metrics

select distinct order_month from customers_orders_mnth_metrics

/*There is all the months inside the above table...*/


select * from customers_orders_mnth_metrics 
where order_month = '2013-08'
order by customer_id

explain analyse select * from customers_orders_mnth_metrics 
where order_month = '2013-08'

UPDATE customers_orders_mnth_metrics comd
SET 
    (order_count, order_revenue) = (
        SELECT count(1),
            round(sum(order_item_subtotal)::numeric, 2)
        FROM orders o 
            JOIN order_items oi
                ON o.order_id = oi.order_item_order_id
        WHERE o.order_customer_id = comd.customer_id
            AND to_char(o.order_date, 'yyyy-MM') = comd.order_month
            AND to_char(o.order_date, 'yyyy-MM') = '2013-08'
            AND comd.order_month = '2013-08'
        GROUP BY o.order_customer_id,
            to_char(o.order_date, 'yyyy-MM')
    )
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.order_customer_id = comd.customer_id
        AND to_char(o.order_date, 'yyyy-MM') = comd.order_month
        AND to_char(o.order_date, 'yyyy-MM') = '2013-08'
) AND comd.order_month = '2013-08'

explain analyse select * from customers_orders_mnth_metrics 
where order_month='2013-08'
order by order_month, customer_id

/*
Even though the statements can be executed in any order, updating first and then inserting perform better in most of the cases (as update have to deal with lesser number of records with this approach)
*/

/*
We can also take care of merge or upsert using INSERT with ON CONFLICT (columns) DO UPDATE.
*/

/*
Postgres does not have either MERGE or UPSERT as part of the SQL syntax
*/









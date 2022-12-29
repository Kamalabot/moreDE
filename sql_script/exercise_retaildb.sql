
select count(1) as customer_order_count, c.customer_id , c.customer_fname ,
c.customer_lname 
from order_items oi join
orders o on oi.order_item_order_id = o.order_id 
join customers c 
on c.customer_id = o.order_customer_id 
where to_char(o.order_date,'yyyy-MM')='2014-05'
group by c.customer_id , c.customer_fname , c.customer_lname 

select c.* 
from order_items oi join
orders o on oi.order_item_order_id = o.order_id 
join customers c 
on c.customer_id = o.order_customer_id 
where to_char(o.order_date,'yyyy-MM')='2014-05'

select order_customer_id 
from orders 
where to_char(order_date,'yyyy-MM') = '2014-01'  
order by order_customer_id 

select count(1) from(
select  distinct order_customer_id 
from orders 
where to_char(order_date,'yyyy-MM') = '2014-01'  

) q

select count(1) from(
select distinct o.order_customer_id , c.*
from orders o 
join customers c 
on c.customer_id =o.order_customer_id 
where to_char(o.order_date,'yyyy-MM') = '2014-01' 
) q

select  c.customer_id , c.customer_fname, order_item_subtotal  from (
select o.order_customer_id, o.order_status, o.order_id  
from orders o
where to_char(order_date,'yyyy-MM') = '2014-01' and 
(order_status='COMPLETE' or order_status='CLOSED')
order by order_customer_id 
) query right join customers c 
on query.order_customer_id = c.customer_id
join order_items oi 
on oi.order_item_order_id = query.order_id
order by order_item_subtotal desc

select  c.customer_id , c.customer_fname, sum(oi.order_item_subtotal) as revenue from (
	select o.order_customer_id, o.order_status, o.order_id  
	from orders o
	where to_char(order_date,'yyyy-MM') = '2014-01' and 
	(order_status='COMPLETE' or order_status='CLOSED')
	order by order_customer_id 
) query right join customers c 
on query.order_customer_id = c.customer_id
join order_items oi 
on oi.order_item_order_id = query.order_id
group by c.customer_id , c.customer_fname 
order by revenue desc

select  c.category_id  , c.category_name , 
	sum(order_item_subtotal) as revenue 
		from (
		select o.order_status, o.order_id, oi.order_item_product_id ,
		oi.order_item_subtotal
		from orders o join
		order_items oi on oi.order_item_order_id = o.order_id
		where to_char(order_date,'yyyy-MM') = '2014-01' and 
		(order_status='COMPLETE' or order_status='CLOSED') 
	) query right join products p 
on p.product_id = query.order_item_product_id
join categories c 
on c.category_id  = p.product_category_id 
group by c.category_id , c.category_name 

select count(p.product_name) as pdt_count, d.department_name 
from products p 
join categories c 
on p.product_category_id = c.category_id 
join departments d 
on d.department_id = c.category_name 
group by d.department_name 







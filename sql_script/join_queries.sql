#This script contains the advanced queries

select * from orders o limit 5;

select * from order_items oi limit 5;

select * from departments d limit 5;

select * from customers c limit 5;

#get all the data

select o.*, oi.* from
order_items oi join 
orders o on 
oi.order_item_order_id = o.order_id
limit 5;

select * from products p limit 10

select o.order_id, o.order_date, oi.order_item_product_id, oi.order_item_subtotal,
p.product_name, p.product_price from
order_items oi join orders o 
on oi.order_item_order_id = o.order_id 
join products p 
on oi.order_item_product_id = p.product_id 
limit 5

select o.order_id, o.order_date, oi.order_item_product_id, oi.order_item_subtotal,
p.product_name, p.product_price from
order_items oi join orders o 
on oi.order_item_order_id = o.order_id 
join products p 
on oi.order_item_product_id = p.product_id 
offset 500 limit 50

select o.order_id, o.order_status, oi.order_item_subtotal
from order_items oi join 
orders o on o.order_id = oi.order_item_id  
limit 5

select count(*) from order_items oi  

select count(*) from orders o 

select count(*)
from order_items oi join 
orders o on o.order_id = oi.order_item_id  
limit 5 

#above query returns only 68,883

select count(*)
from order_items oi left join
orders o on o.order_id = oi.order_item_id 

select count(*)
from order_items oi left inner join  # there cannot be out left / right inner
orders o on o.order_id = oi.order_item_id 

select oi.order_item_id, o.order_status	 
from order_items oi left join
orders o on o.order_id = oi.order_item_id 

select oi.order_item_id, o.order_status, oi.order_item_quantity	,oi.order_item_product_id  
from order_items oi left join
orders o on o.order_id = oi.order_item_id 
where o.order_status is null 
limit 5

select count(*)
from order_items oi right join
orders o on o.order_id = oi.order_item_id 

#get order_id, date, status, revenue for all order_items

select o.order_id, o.order_date, o.order_status,oi.order_item_subtotal, oi.order_item_id  
from order_items oi join
orders o on 
o.order_id =oi.order_item_order_id 
limit 5

select o.order_id, o.order_date, o.order_status,oi.order_item_subtotal, oi.order_item_id  
from order_items oi join
orders o on 
o.order_id =oi.order_item_order_id 
where o.order_status = 'COMPLETE' or o.order_status ='CLOSED'
limit 5

select o.order_id, o.order_date , o.order_status,oi.order_item_subtotal, oi.order_item_id  
from order_items oi join
orders o on 
o.order_id =oi.order_item_order_id 
where  to_char(o.order_date, 'yyyy/MM') = '2014/01' and (o.order_status = 'COMPLETE' or o.order_status ='CLOSED')
limit 5





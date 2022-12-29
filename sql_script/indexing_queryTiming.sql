select * 
from orders o join order_items oi 
on o.order_id = oi.order_item_order_id 
limit 5

select * 
from orders o join order_items oi 
on o.order_id = oi.order_item_order_id 
where oi.order_item_order_id = 100

select * 
from orders o join order_items oi 
on o.order_id = oi.order_item_order_id 
where oi.order_item_order_id = 1200

create index order_items_oid_index
on order_items(order_item_order_id)

/*Creating index got the results in less than 1sec, that is 560 ~ 660 msec*/

select * from pg_catalog.pg_indexes pi2 
where schemaname = 'public'
and tablename ='orders'

select * from pg_catalog.pg_indexes pi2 
where schemaname = 'public'
and tablename ='order_items'

select tc.table_name , tc.constraint_name, tc.constraint_type  
from information_schema.table_constraints tc join pg_catalog.pg_indexes pi2 
on tc.constraint_name = pi2.indexname 
where tc.table_catalog  = 'retail_db'
and tc.constraint_type in ('PRIMARY KEY','UNIQUE')




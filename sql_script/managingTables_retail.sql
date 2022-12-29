/*This script will manage the various database objects*/

/*finding the max of the surrogate key*/


select max(o.order_id) as max_order_id,
	max(oi.order_item_id) as max_oi_id,
	max(p.product_id) as max_pid,
	max(c.customer_id) as max_cid,
	max(c2.category_id) as max_catid,
	max(d.department_id) as max_did
from order_items oi 
join orders o 
on o.order_id = oi.order_item_order_id 
join products p 
on p.product_id = oi.order_item_product_id 
join customers c 
on c.customer_id = o.order_customer_id 
join categories c2 
on c2.category_id = p.product_category_id 
join departments d 
on d.department_id = c2.category_department_id

select o.order_id,oi.order_item_id,p.product_id,
	c.customer_id,c2.category_id,d.department_id
from order_items oi 
join orders o 
on o.order_id = oi.order_item_order_id 
join products p 
on p.product_id = oi.order_item_product_id 
join customers c 
on c.customer_id = o.order_customer_id 
join categories c2 
on c2.category_id = p.product_category_id 
join departments d 
on d.department_id = c2.category_department_id
order by o.order_id desc, oi.order_item_order_id desc, 
p.product_id desc, c.customer_id desc, c2.category_id desc, 
d.department_id desc
limit 1

select p.product_id 
from products p 
order by p.product_id DESC
limit 1

select tc.table_catalog ,tc.table_name ,tc.constraint_type,
pi2.indexname 
from information_schema.table_constraints tc 
join pg_catalog.pg_indexes pi2 
on pi2.indexname =tc.constraint_name 
where tc.table_name is in ('orders', 'order_items','customers','department','categories')


select s.sequence_name , s.sequence_catalog , s.sequence_schema
from information_schema."sequences" s 

select t.table_name , t.table_schema , t.table_type 
from information_schema."tables" t 

/*The max value taken with other columns screwed the number*/
/*the start value is wrong*/

drop sequence if exists orders_order_id_seq cascade

drop sequence if exists order_items_order_items_order_id_seq cascade

drop sequence if exists products_product_id_seq cascade 

drop sequence if exists categories_category_id_seq cascade 

drop sequence if exists department_department_id_seq cascade

drop sequence if exists customers_customer_id_seq cascade

/*following sequence creation is completely wrong....*/

/*create sequence orders_order_id_seq
	start with 68883
	minvalue 1
	maxvalue 68883
	increment by 1

create sequence order_items_order_items_order_id_seq
	start with 1
	minvalue 1
	maxvalue 172198
	increment by 1
	
create sequence customers_customer_id_seq
	start with 1
	minvalue 1
	maxvalue 12435
	increment by 1
	
create sequence categories_category_id_seq
	start with 1
	minvalue 1
	maxvalue 48
	increment 1
	
create sequence department_department_id_seq
	start with 1
	minvalue 1
	maxvalue 7
	increment by 1
		
create sequence products_product_id_seq
	start with 1
	minvalue 1
	maxvalue 1073*/

create sequence orders_order_id_seq
	start with 68884
	increment by 1

create sequence order_items_order_items_order_id_seq
	start with 172199
	increment by 1
	
create sequence customers_customer_id_seq
	start with 12436
	increment by 1
	
create sequence categories_category_id_seq
	maxvalue 59
	increment 1
	
create sequence department_department_id_seq
	start with 8
	increment by 1
		
create sequence products_product_id_seq
	start with 1346
	increment 1

alter sequence orders_order_id_seq
	owned by orders.order_id
	
select nextval('orders_order_id_seq')

ALTER TABLE orders 
    ALTER COLUMN order_id 
    SET DEFAULT nextval('orders_order_id_seq')

select currval('orders_order_id_seq')


alter sequence order_items_order_items_order_id_seq
	owned by order_items.order_item_order_id 
 
	
alter table order_items  
	alter column order_item_order_id
	set default nextval('order_items_order_items_order_id_seq') 
	
alter sequence products_product_id_seq
	owned by products.product_id 

	
alter table products 
	alter column product_id
	set default nextval('products_product_id_seq') 	
	
alter sequence department_department_id_seq
	owned by departments.department_id 
	
alter table departments 
	alter column department_id
	set default nextval('department_department_id_seq') 
	
alter sequence categories_category_id_seq
	owned by categories.category_id 
	
alter table categories 
	alter column category_id
	set default nextval('categories_category_id_seq') 

alter table user_logins 
	add foreign key (user_login_id)
	references users(user_id)
	
alter table orders 
	add foreign key (order_customer_id)
	references customers(customer_id)
	
alter table order_items 
	add foreign key (order_item_order_id)
	references orders(order_id)
	
alter table order_items 
	add foreign key (order_item_product_id)
	references products(product_id)
	
alter table products  
	add foreign key(product_category_id)
	references categories(category_id)
	
/*the above command is not expected to work_*/
	
select * from products p 
where product_category_id is null 
limit 5

alter table products 
	alter column product_category_id
		drop not null
		
/*the above command did not drop any columns... but what did it do*/
UPDATE products SET product_category_id=null
WHERE product_category_id=59

alter table products  
	add foreign key(product_category_id)
	references categories(category_id)
	
/*the below query checks the output*/	
select distinct c.category_id , p.product_category_id 
from categories c left outer join products p 
on c.category_id = p.product_category_id 
order by c.category_id desc		

ALTER TABLE categories ALTER COLUMN category_department_id DROP NOT NULL;

update categories set category_department_id=null 
where category_department_id=8

select d.* from departments d 
where d.department_id = 7

select d.department_id , c.category_department_id 
from departments d left outer join categories c 
on d.department_id = c.category_department_id
limit 5

alter table categories 
	add foreign key(category_department_id)
	references departments(department_id)
	
/*there was additional fkey so removinvg*/	
alter table orders
	drop constraint orders_order_customer_id_fkey1
	
select *
from information_schema."sequences" s 	

select tc.constraint_name , tc.constraint_catalog, tc.table_name
from information_schema.table_constraints tc 
where tc.table_name = 'categories'

select tc.constraint_name , tc.constraint_catalog, tc.table_name
from information_schema.table_constraints tc 
where tc.table_name = 'orders'
	
select c.table_catalog , c.table_name , c.column_name 
from information_schema."columns" c 
where c.table_name = 'orders'

select c.table_catalog , c.table_name , c.column_name, c.is_identity  
from information_schema."columns" c 
where c.table_name = 'order_items'


	
	
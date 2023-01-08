This series of queries is based on the diagram available at  
//run/media/solverbot/repoA/gitFolders/botoPersonal/script_exercise/retail_db_drawing

//order_items_table

select COUNT(*) as item_count, order_item_order_id  
from order_items
group by order_item_order_id 
order by item_count desc

select SUM(order_item_quantity) as order_qty, order_item_order_id
from order_items 
group by order_item_order_id 
order by order_qty

select * from order_items oi 
limit 5

//query 1
select SUM(order_item_quantity) as total_qty
from order_items 

//query 2

select SUM(order_item_subtotal) as total_sales
from order_items oi 

//query 3

select SUM(order_item_subtotal) as order_subtotal, 
order_item_order_id 
from order_items oi 
group by order_item_order_id
order by order_subtotal desc

//sub-query 3-0
select count(*) as order_count, order_item_order_id 
from order_items oi 
group by order_item_order_id 
order by order_count DESC

//query 4

select sum(order_item_subtotal) as item_subtotal,
sum(order_item_quantity) as item_quantity,
order_item_id
from order_items oi 
group by order_item_id 
order by item_subtotal, item_quantity desc 

//query 5

select count(*) product_count, order_item_product_id 
from order_items oi 
group by order_item_product_id 
order by product_count desc

//query 6

select sum(order_item_product_price) as product_sales, 
count(order_item_product_id ) as product_count, 
order_item_product_id, avg(order_item_product_price)

from order_items oi 

group by order_item_product_id 

order by product_sales desc

### Starting the orders table analysis ###
# I can guess the order_id will be unique. 
//query 1

select count(*) as day_count, order_date,
extract (day from order_date) as day
from orders o 
group by order_date 
order by day_count desc 

//sub query 1-0

select count(*) as dow_count,
extract (day from order_date) as day
from orders 
group by day 
order by dow_count desc

//query 2

select count(*) as status_count, order_status
from orders o 
group by order_status 
order by status_count desc

//query 2-0

select  order_status, count(*) as day_status, 
extract (day from order_date) as dow
from orders 
group by order_status, dow 
order by day_status, dow desc

// query 3

select order_customer_id, count(*) as customer_order_count
from orders 
group by order_customer_id 
order by customer_order_count desc

/*
Additional questions:
1) How much each customer has spent? 
2) Which category and item_id the customer is choosing frequently? 
3) which date there is maximum sales
4) which type of order status is having highest value 
5) Linking the product details, category detais, customer details , department details in the above table
*/

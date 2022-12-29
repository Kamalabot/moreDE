/*get total number of orders*/

select
	count(1) as number_of_orders
from
	orders o 

select
	order_item_order_id ,
	sum(order_item_subtotal) as order_revenue
from
	order_items oi
group by
	order_item_order_id
order by
	order_revenue desc
limit 5

select
	count(1) as status_count
from
	orders o
where
	order_status = 'COMPLETE'
	or order_status = 'CLOSED'

select
	count(1) as completed_count
from
	orders o
where
	order_status = 'COMPLETE'

select
	count(1) as closed_count
from
	orders o
where
	order_status = 'CLOSED'

select
	count(1) as status_count,
	order_status
from
	orders o
where
	order_status = 'CLOSED'
	or order_status = 'COMPLETE'
group by
	order_status
order by
	order_status 

select
	sum(order_item_subtotal) as order_total,
	order_item_order_id
from
	order_items oi
group by
	order_item_order_id
where
	sum(order_item_subtotal) > 1500

select
	sum(order_item_subtotal) as order_total,
	order_item_order_id
from
	order_items oi
group by
	order_item_order_id
having
	sum(order_item_subtotal) > 1500

select
	sum(oi.order_item_subtotal) as order_id_revenue,
	oi.order_item_order_id,
	o.order_status ,
	o.order_date
from
	order_items oi
join
orders o on
	oi.order_item_order_id = o.order_id
group by
	oi.order_item_order_id,
	o.order_status ,
	o.order_date  

select
	sum(oi.order_item_product_price * oi.order_item_quantity) as product_revn,
	oi.order_item_product_id,
	p.product_name ,
	o.order_date
from
	order_items oi
join products p 
on
	oi.order_item_product_id = p.product_id
join orders o 
on
	oi.order_item_order_id = o.order_id
group by
	oi.order_item_product_id,
	p.product_name ,
	o.order_date
limit 5

select
	sum(oi.order_item_product_price * oi.order_item_quantity) as product_revn,
	oi.order_item_product_id,
	p.product_name ,
	o.order_date
from
	order_items oi
join products p 
on
	oi.order_item_product_id = p.product_id
join orders o 
on
	oi.order_item_order_id = o.order_id
group by
	oi.order_item_product_id,
	p.product_name ,
	o.order_date
having
	sum(oi.order_item_product_price * oi.order_item_quantity) > 500
limit 5

select
	sum(oi.order_item_product_price * oi.order_item_quantity :: numeric) as product_revn,
	oi.order_item_product_id,
	p.product_name ,
	o.order_date
from
	order_items oi
join products p 
on
	oi.order_item_product_id = p.product_id
join orders o 
on
	oi.order_item_order_id = o.order_id
group by
	oi.order_item_product_id,
	p.product_name ,
	o.order_date
having
	sum(oi.order_item_product_price * oi.order_item_quantity) > 500
limit 5

select
	c.customer_fname ,
	c.customer_city ,
	o.order_date ,
	oi.order_item_subtotal ,
	oi.order_item_product_id ,
	p.product_name ,
	o.order_status
from
	order_items oi
join orders o 
on
	o.order_id = oi.order_item_order_id
join products p 
on
	oi.order_item_product_id = p.product_id
join customers c 
on
	c.customer_id = o.order_customer_id
where
	o.order_status = 'COMPLETE'

with c_s as (
	select
		c.customer_fname ,
		c.customer_city ,
		o.order_date ,
		oi.order_item_subtotal ,
		oi.order_item_product_id ,
		p.product_name ,
		o.order_status
	from
		order_items oi
	join orders o 
on
		o.order_id = oi.order_item_order_id
	join products p 
on
		oi.order_item_product_id = p.product_id
	join customers c 
on
		c.customer_id = o.order_customer_id
	where
		o.order_status = 'COMPLETE')
select
	c_s.customer_fname,
	c_s.order_date,
	sum(c_s.order_item_subtotal) as customer_sales
from
	c_s
group by
	c_s.customer_fname,
	c_s.order_date
order by
	order_date,
	customer_sales desc

select
	count(1)
from
	(
	select
		o.order_date,
		oi.order_item_product_id,
		p.product_name,
		round(sum(oi.order_item_subtotal::numeric), 2) as product_revenue
	from
		orders o
	join order_items oi
            on
		o.order_id = oi.order_item_order_id
	join products p
            on
		p.product_id = oi.order_item_product_id
	where
		o.order_status in ('COMPLETE', 'CLOSED')
	group by
		o.order_date,
		oi.order_item_product_id,
		p.product_name
) q

select
	o.order_date,
	oi.order_item_product_id,
	p.product_name,
	round(sum(oi.order_item_subtotal::numeric), 2) as product_revenue
from
	orders o
join order_items oi
            on
	o.order_id = oi.order_item_order_id
join products p
            on
	p.product_id = oi.order_item_product_id
where
	o.order_status in ('COMPLETE', 'CLOSED')
group by
	o.order_date,
	oi.order_item_product_id,
	p.product_name

	
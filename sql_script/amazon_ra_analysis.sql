/*This script will move on to create analysis 
 * and populate the data in the table for the dashboard.
 * Idea is to use the json format of the data instead of 
 * querying the database.
 * */

SELECT * 
FROM cleaned_data
limit 5

/*The delivery_id is unique, as there is no more than one with same id*/

/*
THE QUERY WAS TO CHECK UNIQUENESS
select cd.id, min(cd.deliverypersonage) as age ,
round(avg(cd.deliverypersonratings)::numeric,2) as ratings, 
count(cd.id) as delivery_done
from cleaned_data cd 
group by cd.id 
order by delivery_done desc
*/

create table if not exists delivery_agent_ratings
as
select cd.delivery_person_id, round(avg(cd.deliverypersonage)::numeric,0) as age ,
round(avg(cd.deliverypersonratings)::numeric,2) as avg_ratings, 
round(max(cd.deliverypersonratings)::numeric,2) as max_ratings, 
round(min(cd.deliverypersonratings)::numeric,2) as min_ratings, 
count(cd.id) as delivery_done
from cleaned_data cd 
group by cd.delivery_person_id 
order by delivery_done desc

select *
from delivery_agent_ratings dar 
limit 5

select cd.order_date ,cd.delivery_person_id , cd.deliverypersonage , cd.deliverypersonratings,
	cd.vehicle_condition , cd.type_of_vehicle 
from cleaned_data cd 
where cd.delivery_person_id = 'COIMBRES13DEL01'
order by cd.order_date 

/*The age, ratings, vehicle condition and type of vehicles all change 
even though the id is same*/

select cd.order_date ,cd.delivery_person_id, round(avg(cd.deliverypersonage)::numeric,0) as age ,
round(avg(cd.deliverypersonratings)::numeric,2) as avg_ratings, 
count(cd.id) as delivery_done
from cleaned_data cd 
group by cd.delivery_person_id, cd.order_date  
having cd.delivery_person_id = 'COIMBRES13DEL01'
order by cd.order_date desc

/*Order date and deliveries*/

create table if not exists order_date_count
as
select cd.order_date , count(cd.id) as order_count
from cleaned_data cd 
group by cd.order_date 

select * from order_date_count limit 5

create table if not exists order_type_count
as
select cd.type_of_order, count(cd.id) as type_count
from cleaned_data cd 
group by cd.type_of_order 

/*Road weather, road, order_type conditions on given day*/
select cd.order_date , cd.weather ,cd.road_traffic_density, 
	cd.type_of_order , cd.type_of_vehicle , cd."name" 
from cleaned_data cd 
where cd.order_date ='2022-04-06'

/*The order quantity is more in metropolitan*/
select coalesce(cd.city,'other') as city , count(cd.id) as order_per_city
from cleaned_data cd 
group by cd.city 
order by order_per_city

/*The order quantity is mostly drinks, while the meal is the least*/

create table if not exists order_type_location_count
as
select cd.type_of_order , coalesce(cd.city,'other') as city , 
	count(cd.id) as type_count
from cleaned_data cd 
group by cd.type_of_order, cd.city  
order by type_count desc

/*Getting at the city name in the delivery_person_id*/

create table if not exists city_delivery_counts
as
select count(cd.delivery_person_id) as city_count , 
		coalesce(split_part(cd.delivery_person_id,'RE',1),'RANCHI') as city_name
from cleaned_data cd 
group by coalesce(split_part(cd.delivery_person_id,'RE',1),'RANCHI')
order by city_count desc

create table if not exists city_date_deliveries
as
select cd.order_date ,count(cd.delivery_person_id) as city_count , 
		coalesce(split_part(cd.delivery_person_id,'RE',1),'RANCHI') as city_name
from cleaned_data cd 
group by coalesce(split_part(cd.delivery_person_id,'RE',1),'RANCHI'), cd.order_date 
order by cd.order_date desc

select cdc.*
from city_delivery_counts cdc 
limit 5

with partitioned_del_counts
as(select dense_rank () over (partition by cdd.city_name
						order by cdd.order_date) as count_rank,
	cdd.order_date, cdd.city_count,cdd.city_name 		
from city_date_deliveries cdd 
order by cdd.city_name)
select order_date, city_count, city_name 
from partitioned_del_counts
where count_rank <= 3

select *
from city_date_deliveries cdd 
order by cdd.order_date , cdd.city_name 

select cd.time_ordered , cd.order_date, 
		split_part(cd.time_ordered::varchar,':',1) as hour_ordered,
		count(cd.id) 
		over (partition by split_part(cd.time_ordered::varchar,':',1))
		as total_orders_hour
from cleaned_data cd 

create table if not exists order_date_hour
as
select cd.order_date, 
		split_part(cd.time_ordered::varchar,':',1) as hour_ordered,
		count(cd.id) as total_orders_hour
from cleaned_data cd 
group by cd.order_date, split_part(cd.time_ordered::varchar,':',1)

select * from order_date_hour odh 

select cd.order_date ,
	count(cd.id) over (partition by cd.order_date) as orders_today,
	cd.delivery_person_id , 
	coalesce(split_part(cd.delivery_person_id,'RE',1),'RANCHI') as city_name,
	count(cd.id) 
	over (partition by 
			coalesce(split_part(cd.delivery_person_id,'RE',1),'RANCHI'),
					cd.order_date) 
	as city_orders_today,
	cd.deliverypersonage::int , 
	avg(round(cd.deliverypersonage,1)) 
	over(partition by cd.delivery_person_id) 
	as avg_age_in_id,
	round(cd.deliverypersonratings,1) as deliveryperson_rating ,
	max(round(cd.deliverypersonratings,1)) 
	over(partition by cd.delivery_person_id) 
	as max_ratings_in_id,
	count(cd.id) 
	over (partition by cd.delivery_person_id, cd.order_date) as delivered_today
from cleaned_data cd 



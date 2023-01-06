/*This script will build the company progress database with the necessary 
 * tables to build the dashboards
 */ */

create table if not exists amazon_encoded(ID varchar primary key unique,Delivery_person_ID varchar unique,
Type_of_Vehicle varchar,
DeliveryPersonAge numeric,
DeliveryPersonRatings numeric,
TypeOfVehicle numeric,
DeliveryPersonID numeric,
Restaurant_latitude numeric,
Restaurant_longitude numeric,
Delivery_location_latitude numeric,
Delivery_location_longitude numeric,
Order_Date numeric,
Weather_idx numeric,Road_traffic_density_idx numeric,
Type_of_order_idx numeric,
multiple_deliveries_idx numeric,IntervalPickup numeric)

drop table if exists amazon_encoded 

drop table if exists cleaned_raw_data

create table if not exists cleaned_raw_data(ID varchar primary key unique,
Delivery_person_ID varchar,
DeliveryPersonAge numeric,
DeliveryPersonRatings numeric,
Restaurant_latitude numeric,
Restaurant_longitude numeric,
Delivery_location_latitude numeric,
Delivery_location_longitude numeric,
Order_Date date,
Time_ordered varchar, 
time_order_picked varchar,
Weather varchar,Road_traffic_density varchar,
vehicle_condition numeric,
Type_of_order varchar,
Type_of_Vehicle varchar,
multiple_deliveries numeric,Festival Boolean,
city varchar, name varchar)


drop table if exists cleaned_data

create table if not exists cleaned_data(ID varchar primary key unique,
Delivery_person_ID varchar,
DeliveryPersonAge numeric,
DeliveryPersonRatings numeric,
Restaurant_latitude numeric,
Restaurant_longitude numeric,
Delivery_location_latitude numeric,
Delivery_location_longitude numeric,
Order_Date date,
Weather varchar,Road_traffic_density varchar,
vehicle_condition numeric,
Type_of_order varchar,
Type_of_Vehicle varchar,
multiple_deliveries numeric,Festival Boolean,
city varchar, name varchar,
Time_ordered time, 
time_order_picked time)

/*The below query fails, because all the conditions of the time is not checked.*/

insert into cleaned_data (ID ,Delivery_person_ID,DeliveryPersonAge ,DeliveryPersonRatings,
		Restaurant_latitude,Restaurant_longitude ,Delivery_location_latitude,
		Delivery_location_longitude,Order_Date,Weather,Road_traffic_density,
		vehicle_condition,Type_of_order,Type_of_Vehicle,
		multiple_deliveries,Festival,city, name, Time_ordered, time_order_picked)
select crd.ID ,crd.Delivery_person_ID,crd.DeliveryPersonAge ,crd.DeliveryPersonRatings,
		crd.Restaurant_latitude,crd.Restaurant_longitude ,crd.Delivery_location_latitude,
		crd.Delivery_location_longitude,crd.Order_Date,Weather,crd.Road_traffic_density,
		crd.vehicle_condition,crd.Type_of_order,crd.Type_of_Vehicle,
		crd.multiple_deliveries,crd.Festival,crd.city, crd.name,
		case when split_part(crd.Time_ordered, ':',2)::int = 60
			then concat((split_part(crd.Time_ordered, ':',1)::int + 1)::varchar,':00')::time
			else crd.Time_ordered::time
			end as time_ordered,
		case when split_part(crd.time_order_picked, ':',2)::int = 60
			then concat((split_part(crd.time_order_picked, ':',1)::int + 1)::varchar,':00')::time
			else crd.time_order_picked::time
			end as time_ordered_picked
from cleaned_raw_data crd


select crd.Time_ordered, crd.time_order_picked
from cleaned_raw_data crd 
limit 35


/*The below query is the trial run*/

select crd.ID ,crd.Delivery_person_ID,crd.DeliveryPersonAge ,crd.DeliveryPersonRatings,
		crd.Restaurant_latitude,crd.Restaurant_longitude ,crd.Delivery_location_latitude,
		crd.Delivery_location_longitude,crd.Order_Date,Weather,crd.Road_traffic_density,
		crd.vehicle_condition,crd.Type_of_order,crd.Type_of_Vehicle,
		crd.multiple_deliveries,crd.Festival,crd.city, crd.name,
case when split_part(crd.Time_ordered, ':',1)::int = 23 and split_part(crd.Time_ordered, ':',2)::int = 60
			then '00:00'::time
			when split_part(crd.Time_ordered, ':',1)::int = 0 and split_part(crd.Time_ordered, ':',2)::int = 60
			then '01:00'::time
			when split_part(crd.Time_ordered, ':',2)::int = 60 and split_part(crd.Time_ordered, ':',1)::int != 23
			then concat((split_part(crd.Time_ordered, ':',1)::int + 1)::varchar,':00')::time
			when split_part(crd.Time_ordered, ':',1)::int = 24 and split_part(crd.Time_ordered, ':',2)::int != 60
			then concat('00:',(split_part(crd.Time_ordered, ':',2)))::time
			else crd.Time_ordered::time
			end as time_ordered,
			case when split_part(crd.time_order_picked, ':',1)::int = 23 and split_part(crd.time_order_picked, ':',2)::int = 60
			then '00:00'::time
			when split_part(crd.time_order_picked, ':',1)::int = 0 and split_part(crd.time_order_picked, ':',2)::int = 60
			then '01:00'::time
			when split_part(crd.time_order_picked, ':',2)::int = 60 and split_part(crd.time_order_picked, ':',1)::int != 23
			then concat((split_part(crd.time_order_picked, ':',1)::int + 1)::varchar,':00')::time
			when split_part(crd.time_order_picked, ':',1)::int = 24 and split_part(crd.time_order_picked, ':',2)::int != 60
			then concat('00:',(split_part(crd.time_order_picked, ':',2)))::time
			else crd.time_order_picked::time
			end as time_order_picked
from cleaned_raw_data crd



insert into cleaned_data (ID ,Delivery_person_ID,DeliveryPersonAge ,DeliveryPersonRatings,
		Restaurant_latitude,Restaurant_longitude ,Delivery_location_latitude,
		Delivery_location_longitude,Order_Date,Weather,Road_traffic_density,
		vehicle_condition,Type_of_order,Type_of_Vehicle,
		multiple_deliveries,Festival,city, name, Time_ordered, time_order_picked)
select crd.ID ,crd.Delivery_person_ID,crd.DeliveryPersonAge ,crd.DeliveryPersonRatings,
		crd.Restaurant_latitude,crd.Restaurant_longitude ,crd.Delivery_location_latitude,
		crd.Delivery_location_longitude,crd.Order_Date,Weather,crd.Road_traffic_density,
		crd.vehicle_condition,crd.Type_of_order,crd.Type_of_Vehicle,
		crd.multiple_deliveries,crd.Festival,crd.city, crd.name,
case when split_part(crd.Time_ordered, ':',1)::int = 23 and split_part(crd.Time_ordered, ':',2)::int = 60
			then '00:00'::time
			when split_part(crd.Time_ordered, ':',1)::int = 0 and split_part(crd.Time_ordered, ':',2)::int = 60
			then '01:00'::time
			when split_part(crd.Time_ordered, ':',2)::int = 60 and split_part(crd.Time_ordered, ':',1)::int != 23
			then concat((split_part(crd.Time_ordered, ':',1)::int + 1)::varchar,':00')::time
			when split_part(crd.Time_ordered, ':',1)::int = 24 and split_part(crd.Time_ordered, ':',2)::int != 60
			then concat('00:',(split_part(crd.Time_ordered, ':',2)))::time
			else crd.Time_ordered::time
			end as time_ordered,
			case when split_part(crd.time_order_picked, ':',1)::int = 23 and split_part(crd.time_order_picked, ':',2)::int = 60
			then '00:00'::time
			when split_part(crd.time_order_picked, ':',1)::int = 0 and split_part(crd.time_order_picked, ':',2)::int = 60
			then '01:00'::time
			when split_part(crd.time_order_picked, ':',2)::int = 60 and split_part(crd.time_order_picked, ':',1)::int != 23
			then concat((split_part(crd.time_order_picked, ':',1)::int + 1)::varchar,':00')::time
			when split_part(crd.time_order_picked, ':',1)::int = 24 and split_part(crd.time_order_picked, ':',2)::int != 60
			then concat('00:',(split_part(crd.time_order_picked, ':',2)))::time
			else crd.time_order_picked::time
			end as time_order_picked
from cleaned_raw_data crd

SELECT to_timestamp('23:6]0', 'HH24:MI'); 





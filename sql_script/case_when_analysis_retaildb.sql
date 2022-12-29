/*This will be the exercise solution file for the pre-defined functions
using the retail_db*/


select distinct O.order_status 
from orders o 


select count(1) as order_count,
	case when o.order_status = 'COMPLETE' or O.order_status = 'CLOSED'
		then 'COMPLETED'
	when O.order_status = 'PENDING' or 
		O.order_status = 'PROCESSING' or 
		O.order_status = 'PENDING_PAYMENT' 
		then 'PROCESSING'
	when O.order_status = 'PAYMENT_REVIEW' or O.order_status = 'SUSPECTED_FRAUD'
		then 'REVIEWING'
	else 'HANGED ORDER' 
	end as consolidated_status
from orders o 
group by consolidated_status
order by order_count desc

drop table if exists users cascade

/*checking if the users relationship exists*/
select u.user_id , u.user_firstname 
from users u 

create table users(
	user_id serial primary key,
	user_unique_id varchar,
	user_firstname varchar, 
	user_lastname varchar,
	user_mail varchar,
	user_gender varchar,
	user_phone_no varchar,
	user_dob date,
	created_ts timestamp
)

insert into users (
    user_firstname, user_lastname, user_mail, user_gender, 
    user_unique_id, user_phone_no, user_dob, created_ts
) VALUES
    ('Giuseppe', 'Bode', 'gbode0@imgur.com', 'M', '88833-8759', 
     '+86 (764) 443-1967', '1973-05-31', '2018-04-15 12:13:38'),
    ('Lexy', 'Gisbey', 'lgisbey1@mail.ru', 'F', '262501-029', 
     '+86 (751) 160-3742', '2003-05-31', '2020-12-29 06:44:09'),
    ('Karel', 'Claringbold', 'kclaringbold2@yale.edu', 'F', '391-33-2823', 
     '+62 (445) 471-2682', '1985-11-28', '2018-11-19 00:04:08'),
    ('Marv', 'Tanswill', 'mtanswill3@dedecms.com', 'F', '1195413-80', 
     '+62 (497) 736-6802', '1998-05-24', '2018-11-19 16:29:43'),
    ('Gertie', 'Espinoza', 'gespinoza4@nationalgeographic.com', 'M', '471-24-6869', 
     '+249 (687) 506-2960', '1997-10-30', '2020-01-25 21:31:10'),
    ('Saleem', 'Danneil', 'sdanneil5@guardian.co.uk', 'F', '192374-933', 
     '+63 (810) 321-0331', '1992-03-08', '2020-11-07 19:01:14'),
    ('Rickert', 'O''Shiels', 'roshiels6@wikispaces.com', 'M', '749-27-47-52', 
     '+86 (184) 759-3933', '1972-11-01', '2018-03-20 10:53:24'),
    ('Cybil', 'Lissimore', 'clissimore7@pinterest.com', 'M', '461-75-4198', 
     '+54 (613) 939-6976', '1978-03-03', '2019-12-09 14:08:30'),
    ('Melita', 'Rimington', 'mrimington8@mozilla.org', 'F', '892-36-676-2', 
     '+48 (322) 829-8638', '1995-12-15', '2018-04-03 04:21:33'),
    ('Benetta', 'Nana', 'bnana9@google.com', 'M', '197-54-1646', 
     '+420 (934) 611-0020', '1971-12-07', '2018-10-17 21:02:51'),
    ('Gregorius', 'Gullane', 'ggullanea@prnewswire.com', 'F', '232-55-52-58', 
     '+62 (780) 859-1578', '1973-09-18', '2020-01-14 23:38:53'),
    ('Una', 'Glayzer', 'uglayzerb@pinterest.com', 'M', '898-84-336-6', 
     '+380 (840) 437-3981', '1983-05-26', '2019-09-17 03:24:21'),
    ('Jamie', 'Vosper', 'jvosperc@umich.edu', 'M', '247-95-68-44', 
     '+81 (205) 723-1942', '1972-03-18', '2020-07-23 16:39:33'),
    ('Calley', 'Tilson', 'ctilsond@issuu.com', 'F', '415-48-894-3', 
     '+229 (698) 777-4904', '1987-06-12', '2020-06-05 12:10:50'),
    ('Peadar', 'Gregorowicz', 'pgregorowicze@omniture.com', 'M', '403-39-5-869', 
     '+7 (267) 853-3262', '1996-09-21', '2018-05-29 23:51:31'),
    ('Jeanie', 'Webling', 'jweblingf@booking.com', 'F', '399-83-05-03', 
     '+351 (684) 413-0550', '1994-12-27', '2018-02-09 01:31:11'),
    ('Yankee', 'Jelf', 'yjelfg@wufoo.com', 'F', '607-99-0411', 
     '+1 (864) 112-7432', '1988-11-13', '2019-09-16 16:09:12'),
    ('Blair', 'Aumerle', 'baumerleh@toplist.cz', 'F', '430-01-578-5', 
     '+7 (393) 232-1860', '1979-11-09', '2018-10-28 19:25:35'),
    ('Pavlov', 'Steljes', 'psteljesi@macromedia.com', 'F', '571-09-6181', 
     '+598 (877) 881-3236', '1991-06-24', '2020-09-18 05:34:31'),
    ('Darn', 'Hadeke', 'dhadekej@last.fm', 'M', '478-32-02-87', 
     '+370 (347) 110-4270', '1984-09-04', '2018-02-10 12:56:00'),
    ('Wendell', 'Spanton', 'wspantonk@de.vu', 'F', null, 
     '+84 (301) 762-1316', '1973-07-24', '2018-01-30 01:20:11'),
    ('Carlo', 'Yearby', 'cyearbyl@comcast.net', 'F', null, 
     '+55 (288) 623-4067', '1974-11-11', '2018-06-24 03:18:40'),
    ('Sheila', 'Evitts', 'sevittsm@webmd.com', null, '830-40-5287',
     null, '1977-03-01', '2020-07-20 09:59:41'),
    ('Sianna', 'Lowdham', 'slowdhamn@stanford.edu', null, '778-0845', 
     null, '1985-12-23', '2018-06-29 02:42:49'),
    ('Phylys', 'Aslie', 'paslieo@qq.com', 'M', '368-44-4478', 
     '+86 (765) 152-8654', '1984-03-22', '2019-10-01 01:34:28')

/*re-checking if the users relationship exists*/
select u.user_id , u.user_firstname 
from users u 

/*question 1*/
select to_char(u.created_ts ,'yyyy') as created_year, count(1) as usr_cnt
from users u 
group by created_year
order by usr_cnt desc

/*question 2*/
select u.user_id , u.user_dob, u.user_mail ,
/*	extract ('DAY' from u.user_dob) as users_day,*/
/*	extract ('dow' from u.user_dob) as users_dow,*/
/*	date_trunc('DAY',u.user_dob::date) as date_trunc,*/
	initcap(to_char(u.user_dob, 'day')) as users_dob_day,
	to_char(u.user_dob, 'month') as month_ob
from users u 
where to_char(u.user_dob, 'mon') = 'jun'

/*question 3*/
select u.user_id , u.user_firstname, u.user_mail , 
	extract ('YEAR' from u.created_ts) as ceated_year
from users u 
where extract ('YEAR' from u.created_ts) = 2019

/*question 4*/

select count(u.user_gender) as gender_count, 
	case when u.user_gender = 'M' then 'Male'
	when u.user_gender = 'F' then 'Female'
	when u.user_gender is NULL then 'Not Specified'
	end as user_exp_gender
from users u
group by user_exp_gender
order by gender_count

select distinct q.user_exp_gender from (
select case when u.user_gender = 'M' then 'Male'
	when u.user_gender = 'F' then 'Female'
	when u.user_gender is null then 'Not Specified'
	end as user_exp_gender
from users u) as q

select u.user_unique_id, u.user_id, 
	replace(u.user_unique_id,'-','') as clean_id,
	case when length(replace(u.user_unique_id,'-','')) < 9 then 'not valid'
	when  u.user_unique_id is null then 'not specified'
	else substring(replace(u.user_unique_id,'-',''), '....$') 
	end as user_unique_id_last4
from users u

/*question 6*/

select
	count(u.user_phone_no) as country_count,
	replace(split_part(u.user_phone_no, '(', 1),'+','')::numeric  as countryCode
from
	users u
group by
	countryCode
order by 
	countryCode

/*question 7*/
	
select count(1) as miss_counter, q.order_cheker from (
select oi.order_item_quantity * oi.order_item_product_price as order_subtotal,
	case when oi.order_item_subtotal != oi.order_item_quantity * oi.order_item_product_price then 'found'
	else 'okay'
	end as order_cheker
from order_items oi  
) as q
group by q.order_cheker
	
/*There will be a lot of orders raising found flags...*/

select count(1) as miss_counter, q.order_cheker from (
select oi.order_item_quantity * oi.order_item_product_price as order_subtotal,
	case when oi.order_item_subtotal != oi.order_item_quantity * oi.order_item_product_price then 'found'
	else 'okay'
	end as order_cheker
from order_items oi  
) as q
group by q.order_cheker

/*the key is how the round function is implemented*/

select q.* from (
select oi.order_item_quantity * oi.order_item_product_price as order_subtotal,
	case when oi.order_item_subtotal != round(oi.order_item_quantity * oi.order_item_product_price::numeric ,2) then 'found'
	else 'okay'
	end as order_cheker,
	oi.order_item_subtotal 
from order_items oi 
) as q
where q.order_cheker = 'found'

select count(1) as order_day, q.day_type from (
select o.order_date, 
	case when to_char(o.order_date, 'day')  in ('saturday','sunday') then 'weekend'
	else 'weekday'
	end as day_type
from order_items oi join 
orders o on o.order_id = oi.order_item_order_id
) as q
group by q.day_type

/*There is something very specific in to_char usage, check it*/
select count(1) as order_day, q.day_type from (
select o.order_date, to_char(o.order_date, 'Dy') as week_days,
	case when to_char(o.order_date, 'Dy') in ('Sat','Sun') then 'weekend'
	else 'weekday'
	end as day_type
from order_items oi join 
orders o on o.order_id = oi.order_item_order_id
where to_char(o.order_date,'yyyy-mm') = '2014-02'
) as q
group by q.day_type


/*This script file will query the tables in test database
 * with intention to do the followinw
 * Create a Analysis process oriented data model
 * Understand multiple un-related tables and try to merge them
 * Use the various Pre-defined function like String, Date, Numeric functions
 * Come up with Numeric solutions for the charting requiresments in the real world
 * use the queries to make charts in the front end 
 */*/
 
 /*following process to be used*
  * Use the from statement first 
  * implement all possible pdfs on the datasets
  * try the null values handling
  * implement atleast one case and when query
  * do the exercise example on the dataset*/
 
/*starting with aid_data*/

/*query-1 : general select*/ 
select
	ad.aiddata_id ,
	ad.donor ,
	ad."year" ,
	ad.recipient ,
	ad.coalesced_purpose_name
from
	aid_data ad

/*query-2 : implementing string concat */
	
select concat(upper(ad.donor),'=>',lower(ad.recipient)) as direction 
from aid_data ad 
limit 5

/*query-3 : implementing translate*/

select translate(ad.coalesced_purpose_name, '/', '_') as translated_purpose,
recipient ,donor ,year
from aid_data ad 

/*query-4: implementing replace + translate */

select replace(ad.coalesced_purpose_name, ' ', '_') as replaced_purpose,
	translate (ad.coalesced_purpose_name, ' /', '_') as translated_purpose
from aid_data ad 

/*query -5 : thinking of reversing names*/

select reverse(ad.donor) as reversed_donor, reverse(ad.recipient) as reversed_rep  
from aid_data ad 

select
	length(ad.donor) as donor_length,
	length(ad.recipient) as recipLength,
	length(ad.coalesced_purpose_name) as purpose_length,
	ad.coalesced_purpose_name, 
	ad.donor ,
	ad.recipient
from aid_data ad 
where
	length(ad.donor) > 5
order by purpose_length DESC

/*select clause has to come before from, where clause doesn't work on alias*/
	
select
	distinct ad.coalesced_purpose_name ,
	length(ad.coalesced_purpose_name) as name_len
from
	aid_data ad 
order by name_len desc 

select substring(ad.coalesced_purpose_name, 0,25) as purpose_stub 
from aid_data ad 

select distinct substring(ad.coalesced_purpose_name from 25) as form_25,
	length(substring(ad.coalesced_purpose_name from 25)) as length_25
from aid_data ad 
order by length_25 desc

select substring(ad.coalesced_purpose_name from '....$') as dollar_sub,
	ad.coalesced_purpose_name 
from aid_data ad 
limit 5

select substring(ad.coalesced_purpose_name from '^....') as start_dollar 
from aid_data ad 
limit 5

/*notice the above symbols use regex symbols*/

select distinct substring(ad.coalesced_purpose_name from 25) as form_25,
	length(substring(ad.coalesced_purpose_name from 25)) as length_25
from aid_data ad 
where from_25 contains 'does not fit'
order by length_25 desc

/*learn about contains */

select split_part(ad.coalesced_purpose_name, ' ', 2) as split_2nd,
	split_part(ad.coalesced_purpose_name, ' ', 3) as split_3rd,
	split_part(ad.coalesced_purpose_name, ' ', 5) as split_5th,
	length(split_part(ad.coalesced_purpose_name, ' ', 5)) as length_5th,
	ad.coalesced_purpose_name 
from aid_data ad 
order by length_5th desc

select distinct length(split_part(ad.coalesced_purpose_name, ' ', 5)) as length_5th,
	ad.coalesced_purpose_name 
from aid_data ad 
order by length_5th desc

select
	ad.donor ,
	right(ad.donor, 2) as donor_right,
	ad.recipient,
	left(ad.recipient, 5) as donor_left
from
	aid_data ad 

/*till now the left, right, substring, split, reverse, length 
 * replace, translate and concat has been covered. Work on trim (l & r), pad (l * r),  */
	
select position (',' in ad.coalesced_purpose_name) as comma_pos,
	position ('/' in ad.coalesced_purpose_name) as slash_pos,
	strpos(ad.coalesced_purpose_name, ' ') as space_pos, 
	ad.coalesced_purpose_name 
from aid_data ad 

select ltrim(ad.donor, 'd'), ad.donor  
from aid_data ad 

/*the above will do nothing as there are no spaces... try a diff string*/

select rtrim(ad.donor, 'i'), ad.donor  
from aid_data ad 

select replace (ad.donor, ' ', '')  as no_spaced, ad.donor
from aid_data ad 

select lpad(ad.donor,15, 'ee') as ee_donr, ad.donor 
from aid_data ad 
limit 5

select rpad(ad.donor,15, 'ee') as ee_donr, ad.donor 
from aid_data ad
where ad.recipient  = 'India'
limit 5

SELECT lpad(709::varchar, 5, '0') AS result

SELECT concat_ws('__', year, lpad(month::varchar, 2, '0'),
              lpad(myDate::varchar, 2, '0')) AS order_date
FROM
    (SELECT 2013 AS year, 7 AS month, 25 AS myDate) q

/*Starting to work on date*/
/*The aid_data has only year. in such cases need to ways to generate 
random date data*/
  
select ad."year"   
from aid_data ad

select concat (ad.aiddata_id::varchar,' days')
from aid_data ad 

select current_date + interval '10 days'
from aid_data ad 

/*using the concat option with interval doesn't work*/
select
	current_date + interval concat (ad.aiddata_id::varchar,' days') as new_date,
	ad.year
from
	aid_data ad

/*using the column to store the concats and then using doesn't work*/
select
	ad.year,
	concat (ad.aiddata_id,
	' days') as days
from
	aid_data ad
order by ad.year
	
	
select random()*10::float as ten_rand

drop sequence if exists random_month_seq

drop sequence if exists random_day_seq


create sequence if not exists random_month_seq
start with 1
increment 1

create sequence if not exists random_day_seq
start with 1
increment 1


select ad."year", 
	nextval('random_day_seq') % 31 as day,
	nextval('random_month_seq') % 12 as month,
	concat ((nextval('random_day_seq') % 31)::varchar, '-', 
			(nextval('random_month_seq') % 12)::varchar,'-',
			ad.year)
from aid_data ad 

select ad.year % 12
from aid_data ad 

select round (avg(ad.commitment_amount_usd_constant)) as abs_avg, ad.donor 
from aid_data ad 
group by ad.donor
order by abs_avg desc 

select round(avg(ad.commitment_amount_usd_constant)) as round_recip, ad.recipient 
from aid_data ad 
group by ad.recipient 
order by round_recip desc

select ad."year" , sum(ad.commitment_amount_usd_constant) as yearly_donation
from aid_data ad 
group by ad."year" 
order by yearly_donation

select min(s.yearly_donation), max(s.yearly_donation), 
sum(s.yearly_donation), avg(s.yearly_donation) from (
	select ad."year" , sum(ad.commitment_amount_usd_constant) as yearly_donation
	from aid_data ad 
	group by ad."year" 
	order by yearly_donation desc
	) s

select to_char('2021-05-21'::date, 'dd')::int as day

select cast('0.00336' as float) as flo_rs

select '0.0625'::float as cast_flo

/*cast and :: are used intercangeable*/


/*try type casting the created date, there will out of range errors*/
select ad."year", 
	nextval('random_day_seq') % 31 as day,
	nextval('random_month_seq') % 12 as month,
	concat ((nextval('random_month_seq') % 11)::varchar, '-', 
			(nextval('random_day_seq') % 30)::varchar,'-',
			ad.year) as conca_date
from aid_data ad 

select 1 + null as result
/*will return null*/

select coalesce (1+null, 115, 168, 526)
/*will return 115. the other numbers don't matter*/

select coalesce (115, 168, 526)
/*will return 115. the other numbers don't matter*/

select nullif (0,1)

select nullif (0,null)

select nullif (1,null)

drop table sales

create table sales(
	sale_id serial primary key,
	sale_price numeric,
	quantity numeric
)

insert into
	sales(sale_price, quantity) 
values
	(1000,10),
(1500,6),
(57,null),
(700,5),
(65,null)

select s.sale_id, s.sale_price, s.quantity
from sales s

select s.sale_id, s.sale_price,
	coalesce ((s.quantity * s.sale_price), 0) as sale_revenue
from sales s 

select sum(q.sale_revenue) as tot_revenue from (
	select s.sale_id, s.sale_price,
		coalesce ((s.quantity * s.sale_price), 0) as sale_revenue
	from sales s 
) q

/*in place of simple coalesce complicated case when can be used*/


select s.sale_id, 
	case when s.sale_price is not null
		then s.sale_price * s.quantity
	else 0
	end as total_sale
from sales s

select ad.donor, ad.recipient, 
	case when ad.commitment_amount_usd_constant < 500000
		then 'stingy'
	when ad.commitment_amount_usd_constant > 500001 and ad.commitment_amount_usd_constant < 1000000
		then 'committed'
	when ad.commitment_amount_usd_constant > 1000001 and ad.commitment_amount_usd_constant < 5000000
		then 'generous'
	else 'be careful...'
	end as type_donor
from aid_data ad 
 



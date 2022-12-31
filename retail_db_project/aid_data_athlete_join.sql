/*Trying the join between aid_data and athletes data in same database*/

/*starting with the aid_data table*/

select ad.year, ad.donor ,ad.recipient , ad.commitment_amount_usd_constant,
	ad.coalesced_purpose_code , ad.coalesced_purpose_name 
from aid_data ad
limit 5

select count(*)
from aid_data ad 

/*The country names in aid data is full names*/

select a.*
from athletes a 
limit 5

select count(*)
from athletes a 

/*while the nationality in athletes is abbreviations. Need the table that contains the expansions
 * Bringing in the world indicator data that I have in another script.*/

create table primary_country(country_code varchar primary key unique, 
								country_name varchar)
								
/*the below command is for local execution*/
COPY primary_country FROM '/run/media/solverbot/repoA/gitFolders/rilldash/dimension_country.csv' DELIMITER ',' CSV HEADER;

/*bringing in the 3rd table for getting the country names to codes*/

select *
from primary_country pc
limit 5

/*problem statement: 
create a fact table that contains the donors, recievers, donation given, athletes from the donor countries and their medals*/

/*idea 1: connect the pc and a */

select pc.country_name, a.*  
from athletes a join primary_country pc 
on a.nationality = pc.country_code 
limit 5

/*idea 2: connect the pc with ad on donor only*/

select ad."year" , ad.donor, pc.country_code,ad .commitment_amount_usd_constant, ad.coalesced_purpose_code ,ad.coalesced_purpose_name  
from aid_data ad join primary_country pc 
on pc.country_name  = ad.donor 
limit 5

/*idea 3: connect the pc with ad on recipient only */

select ad."year" , ad.recipient , pc.country_code ,ad .commitment_amount_usd_constant, ad.coalesced_purpose_code ,ad.coalesced_purpose_name  
from aid_data ad join primary_country pc 
on pc.country_name  = ad.recipient  
limit 5

/*create with clause chain with aid table ideas first
 * The tables in with still needs to be joined at the end. 
 * */
with 
donor_table as (
select ad."year" , ad.donor, pc.country_code,ad .commitment_amount_usd_constant, ad.coalesced_purpose_code ,ad.coalesced_purpose_name
from aid_data ad join primary_country pc 
on pc.country_name  = ad.donor 
),
athlete_code as(
select pc.country_name, a.nationality ,a."name" ,a.sex ,a.date_of_birth 
from athletes a join primary_country pc 
on a.nationality = pc.country_code 
) select dt.*, ac.*
from donor_table dt join athlete_code ac 
on dt.country_code = ac.nationality
limit 5

/*I did not realize important aspect. Time. 
The aid data is multi year data. Athelete is a snapshot*/

select count(*) as yearly_count,
	ad."year" 
from aid_data ad 
group by ad."year" 
order by ad.year

/*if the athelete data is joined directly on the aid_data, then there will be total */

select round(avg(yearly_count)::numeric,1) as avg_txn, max(yearly_count) as max_yr_txn
from (
select count(*) as yearly_count,
	ad."year" 
from aid_data ad 
group by ad."year" 
order by ad.year
) q

/*The transactions in aid data is between two countries. each country will have its own set 
of athletes, their medals. There will be massive duplication of data. */

/*when bringing the tables together, important questions to ask are 
 * 1) What is the desired outcome or answer the final table should answer? To find the correlation of donor country's athletes profeciency and that countries generosity. 
 * 2) Whether any of the tables have time component? Yes, the aid data has time component in the form of years
 * 3) Which categorical information can be safely aggregated/ filtered and still answer the 1st question? Year can be filtered to most recent year. The total_donation matters, so
 * the recipients, the cause for which it was given can be aggregated into a total.
 * 4) Whether seperate tables with its indices and constraints are required before joining? Will find out  
 * */

/*lets start with aid_data of last year 2013, as decided above get only the aid_donated by each donor*/

select ad.donor, sum(ad.commitment_amount_usd_constant) as aid_donated
from aid_data ad 
where ad."year" = 2013
group by ad.donor 

/*next we bring in the glue table that provides the country code*/

with 
aid_temp as(
	select ad.donor, sum(ad.commitment_amount_usd_constant) as aid_donated
	from aid_data ad 
	where ad."year" = 2013
	group by ad.donor 
)
select ac.donor, pc.country_code ,ac.aid_donated
from aid_temp ac join primary_country pc 
on ac.donor = pc.country_name 

/*Now we have snapshot on which the athlete data can be joined*/

with 
athlete_code as (
select pc.country_name, a.*  
from athletes a join primary_country pc 
on a.nationality = pc.country_code 
),
aid_country as(
	select ad.donor, sum(ad.commitment_amount_usd_constant) as aid_donated
	from aid_data ad 
	where ad."year" = 2012
	group by ad.donor 
)
select atc.name, atc.sport, atc.gold, atc.silver, atc.bronze, atc.nationality, ac.donor, ac.aid_donated
from athlete_code atc join primary_country pc2  
on pc2.country_code = atc.nationality
join aid_country ac 
on ac.donor = pc2.country_name 

/*The tables have been successfull glued together. It took 35 ~ 39ms to get the data
 * lets do some sanity checks on the data.
 * How many athletes are from united states?
 */*/
 
 with 
athlete_code as (
select pc.country_name, a.*  
from athletes a join primary_country pc 
on a.nationality = pc.country_code 
),
aid_country as(
	select ad.donor, sum(ad.commitment_amount_usd_constant) as aid_donated
	from aid_data ad 
	where ad."year" = 2012
	group by ad.donor 
)
select count(1)
from athlete_code atc join primary_country pc2  
on pc2.country_code = atc.nationality
join aid_country ac 
on ac.donor = pc2.country_name 
where ac.donor = 'United States'

select count(1)
from athletes a  
where a.nationality = 'USA'

/*Note the check is done using the nationality code. That way the join and the final calculation 
can be validated. We can think about building the tables and check the benefit of query time*/

select pc.country_name, a.*  
from athletes a, primary_country pc 
where a.nationality = pc.country_code 

/*lets create the athlete_with primary_country reference table first*/


create table athletes_pc (
	athlete_id serial primary key,
	name varchar, 
	nationality varchar references primary_country(country_code),
	nation varchar,
	sex varchar, 
	date_of_birth date,
	height numeric,
	weight numeric, 
	sport varchar, 
	gold int,
	silver int,
	bronze int
)

insert into athletes_pc (name, nationality, nation, sex, date_of_birth,height,weight,sport,gold,silver,bronze)
select a."name" ,a.nationality ,pc.country_name ,a.sex ,a.date_of_birth ,a.height ,a.weight ,a.sport ,a.gold ,a.silver ,a.bronze 
from athletes a join primary_country pc 
on a.nationality = pc.country_code 

select count(1)
from athletes_pc a  
where a.nationality = 'USA'

select count(1)
from athletes_pc a  
where a.nation = 'United States'

create table aid_agg_2013(
	d_id serial primary key,
	aid_donor varchar references primary_country(country_name),
	donor_code varchar,
	donated_amount numeric
	)
	
insert into aid_agg_2013 (aid_donor, donor_code, donated_amount)
select q.donor, pic.country_code ,q.aid_donated
from (
	select aa.donor, sum(aa.commitment_amount_usd_constant) as aid_donated
	from aid_data aa  
	where aa."year" = 2012
	group by aa.donor
)q join primary_country pic  
on q.donor = pic.country_name 

select count(*) from aid_agg_2013 	
/*returns 25*/	
	
select count(*)
from (
select aa.donor, sum(aa.commitment_amount_usd_constant) as aid_donated
from aid_data aa  
where aa."year" = 2012
group by aa.donor	
	)q
	
/*returns 26. which is the correct answer.*/

from aid_agg_2013 
	
	
	


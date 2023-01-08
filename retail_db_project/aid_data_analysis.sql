/*starting with the aid_data table*/


select ad.year, ad.donor ,ad.recipient , ad.commitment_amount_usd_constant,
	ad.coalesced_purpose_code , ad.coalesced_purpose_name 
from aid_data ad
limit 5

/*query 1: who are the top 5 donors*/

select sum(ad.commitment_amount_usd_constant) as donated_amount, 
	ad.donor , count(1) as times_donated
from aid_data ad 
group by ad.donor 
order by donated_amount desc 
limit 5

select sum(ad.commitment_amount_usd_constant) as recieved_amount,
	ad.recipient, count(1) as times_recieved 
from aid_data ad 
group by ad.recipient 
order by recieved_amount desc
limit 5

select round(avg(ad.commitment_amount_usd_constant)::numeric, 2) as avg_reciept, ad.recipient 
from aid_data ad 
group by ad.recipient 
order by avg_reciept desc 
limit 5

select round(avg(ad.commitment_amount_usd_constant)::numeric, 2) as avg_donor, ad.donor  
from aid_data ad 
group by ad.donor  
order by avg_donor desc 
limit 5
/*
 * Chart type : bar 
 * Insight provided : The order of magnitude difference between 1st and 2nd place
 * The number of times recieved can give a different insight
 */

select ad."year" , 
sum(ad.commitment_amount_usd_constant) as yearly_donations,
count(1) as Total_txn
from aid_data ad 
group by ad."year" 
order by ad."year"

/*
 * chart type: time series of donations and transactions
 * Insights : There can be ups and downs in the donations
 * */

select ad."year" ,ad.donor ,sum(ad.commitment_amount_usd_constant) as yrly_don_per_donor,
count(1) as times_donated
from aid_data ad 
where ad.donor = 'Japan'
group by ad."year" , ad.donor 
order by ad."year" 

/*
 * chart : multiple line charts for each of the countries
 * or it could be bar charts that can move as per the year change
 * */

drop view if exists top_last_donor

drop view if exists top_last_recipt

create or replace view top_last_donor
as
select distinct  "year", donor,
	max(commitment_amount_usd_constant) as max_donation,
	min(commitment_amount_usd_constant) as min_donation
from aid_data ad 
group by ad."year" , ad.donor 

create or replace view top_last_recipt
as
select distinct  "year", recipient ,
	max(commitment_amount_usd_constant) as max_recipt,
	min(commitment_amount_usd_constant) as min_recipt
from aid_data ad 
group by ad."year" , ad.recipient 

select * from top_last_recipt order by "year"

select * from top_last_donor order by "year"
/*
 *The two tables can be joined on the recipient, donor and 
 * get top reciept and top donation columns.
 * 
 * Challenge the data spans multiple years. This opens up 
 * only option of filtering the tables based on year and 
 * then joining them. 
 * 
 * below is trial of the same
 * */


with 
donor_1973 as (
	select *
	from top_last_donor
	where "year" = 1973
)
,
receptor_1973 as (
	select *
	from top_last_recipt 
	where "year" = 1973
) select da.donor, da.max_donation, ra.max_recipt
from donor_1973 da left outer join receptor_1973 ra
on da.donor = ra.recipient

/*
 * Query worked, but there is no trace of India? How come.
 * In the below query checking the 
 * */
select *
from top_last_recipt 
where "year" = 1973 and recipient = 'India'


with 
donor_1980 as (
	select *
	from top_last_donor
	where "year" = 1980
)
,
receptor_1980 as (
	select *
	from top_last_recipt 
	where "year" = 1980
) select da.donor, ra.recipient, da.max_donation, ra.max_recipt
from donor_1980 da full outer join receptor_1980 ra
on da.donor = ra.recipient

/*Right outer and Full outer join in this case give same result*/

with 
donor_1980 as (
	select *
	from top_last_donor
	where "year" = 1980
)
,
receptor_1980 as (
	select *
	from top_last_recipt 
	where "year" = 1980
) select da.donor, ra.recipient, da.max_donation, ra.max_recipt, 
from donor_1980 da right outer join receptor_1980 ra
on da.donor = ra.recipient


with 
donor_1980 as (
	select *
	from top_last_donor
	where "year" = 1980
)
,
receptor_1980 as (
	select *
	from top_last_recipt 
	where "year" = 1980
) select da.donor, ra.recipient, da.max_donation, ra.max_recipt
from donor_1980 da right outer join receptor_1980 ra
on da.donor = ra.recipient
where da.max_donation is null and ra.max_recipt is not null 


/*
 * chart : opposed bar chart could be a great visualisation 
 * Insight: In year 1980, how did the recipient and donors give and take
 * */


/*
 * How to get the above data for all the years?
 * Need to find a way for that.
 * */

select distinct ad.coalesced_purpose_code
from aid_data ad 
order by ad.coalesced_purpose_code 

/*
 * There are 250 different purpose codes
 * Remember 	
 * */

select ad."year" , ad.coalesced_purpose_code , count(1) as counting_prpus
from aid_data ad 
group by ad."year" , ad.coalesced_purpose_code 
order by ad."year" 

/*
 * What are the top 3 purposes based on the count for each year
 * */

/*stage 2 query*/

select dense_rank () 
		over (
			partition by q.year
			order by q.counting_prpus desc
			) as rnk_p,
q.year, q.coalesced_purpose_code
from (
	select ad."year" , ad.coalesced_purpose_code , count(1) as counting_prpus
	from aid_data ad 
	group by ad."year" , ad.coalesced_purpose_code 
	order by ad."year" 
	) q

/*stage 3 : nested query*/
select q1.rnk_p, q1.year, q1.coalesced_purpose_code, q1.counting_prpus
from (
	select dense_rank () 
			over (
				partition by q.year
				order by q.counting_prpus desc
				) as rnk_p,
	q.year, q.coalesced_purpose_code, q.counting_prpus
	from (
		select ad."year" , ad.coalesced_purpose_code , count(1) as counting_prpus
		from aid_data ad 
		group by ad."year" , ad.coalesced_purpose_code 
		order by ad."year" 
	) q
)q1 
where q1.rnk_p < 5

/*
 * In the above query, I see 2 purpose at rank 3 in year 1974. Which seems 
 * erroneous. So checking with rank() function.
 * stage 3: with rank()*/

select q1.rnk_p, q1.year, q1.coalesced_purpose_code, q1.counting_prpus
from (
	select rank () 
			over (
				partition by q.year
				order by q.counting_prpus desc
				) as rnk_p,
	q.year, q.coalesced_purpose_code, q.counting_prpus
	from (
		select ad."year" , ad.coalesced_purpose_code , count(1) as counting_prpus
		from aid_data ad 
		group by ad."year" , ad.coalesced_purpose_code 
		order by ad."year" 
	) q
)q1 
where q1.rnk_p < 5

/*
 * The rank and dense_rank are giving different results for sure. 
 * But the rank numbers are same if multiple counts are same.  
 * Also the partition is now clarified
 * */

/*Ranking of donors based on their yearly donation*/

select q1.rnk_p, q1.year, q1.donor, q1.donation
from (
	select rank () 
			over (
				partition by q.year
				order by q.donation desc
				) as rnk_p,
	q.year, q.donor, q.donation
	from (
		select ad."year" , ad.donor , sum(ad.commitment_amount_usd_constant) as donation
		from aid_data ad 
		group by ad."year" , ad.donor 
		order by ad."year" 
	) q
)q1 
where q1.rnk_p < 5

/*Running the cumulative calculation of the yearly donation
 * This will end with full accumated value by 2013
 * */

select year, 
	sum(donation) over (
						order by year
						rows between unbounded preceding and current row
						) as cumulative_donation,
	donation
from (
	select ad."year" , sum(ad.commitment_amount_usd_constant) as donation 
	from aid_data ad 
	group by ad."year" 
) q

/*
 *Try the same calculation in the opposite direction 
 *use CTE instead of subquery
 */*/
 
with cumulative_donation
as (
	select ad."year" , sum(ad.commitment_amount_usd_constant) as donation 
	from aid_data ad 
	group by ad."year" 
)  select year, 
	sum(donation) over (
						order by year
						rows between current row and unbounded following 
						) as cumulative_donation,
	donation
from cumulative_donation
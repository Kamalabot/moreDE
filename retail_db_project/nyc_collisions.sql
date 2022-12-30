/*Script will look at nyc collisions from the analytics perspective
 * Will push towards brushing up PD functions, CTE, subquery and CTAS concepts.
 * Finally push towards full analytics using the over clause 
 */*/
 
 select n."date", n."time", n.borough, n.cause, n.zip,
 	n.injured, n.killed
 from nyccollision n 

 create table nyc_anulled
 as
 select n."date", n."time", case when n.borough is null then 'unknown'
 							else n.borough 
 							end as borough, 
 		n.cause, case when n.zip is null then 0
 				 else n.zip 
 				 end as zip,
 	n.injured, n.killed
 from nyccollision n 
 
/*lesson learnt, the case when ... then ... needs to confirm with type of the column*/
 
/* extracting days, months, hours for more analysis*/
create table nyc_analytics
as
select to_char(nanull."date", 'Day') as inc_day, to_char(nanull."date", 'Month') as inc_month, 
	to_char(nanull."date",'yyyy') as inc_year, 
	to_char(nanull."time", 'hh') as inc_hour,
	nanull.cause, nanull.zip,nanull."date",
 	nanull.injured, nanull.killed,nanull.borough
 from nyc_anulled nanull
 
 /*We have following categories to work with
  * 1) Year
  * 2) Month
  * 3) Day
  * 4) hour
  * 5) Cause
  * 6) Zip
  * 7) Borough
  * 
  * The two facts are injured and killed. 
  * */
 
/* Think what the NY mayor will need to see in the dashboard?*/
 
/*query 1 : Which borough has more collisions recently? */
 
/*try it with group by */
 
select na.date, na.borough, 
	sum(na.injured) as total_injured,
	max(na.injured) as max_injured,
	sum(na.killed) as total_killed,
	max(na.killed) as max_killed
from nyc_analytics na
group by na.date, na.borough
order by na.date desc

select na.date, 
	sum(na.injured) as total_injured,
	max(na.injured) as max_injured,
	sum(na.killed) as total_killed,
	max(na.killed) as max_killed
from nyc_analytics na
group by na.date
order by na.date
 
/*try it with over clause. The values will be repeating unlike the group clause above*/
/*The below clause can be used if you want to plot the max,min,avg along with the data*/
select na.date, na.borough, na.zip,na.injured,na.killed,
	sum(na.injured) over (partition by na.date) as total_injured,
	max(na.injured) over (partition by na.date) as max_injured,
	max(na.killed) over (partition by na.date) as max_killed
from nyc_analytics na
order by na.date

/*What will happen when I partition over both date and borough*/
/*Don't know what use ==> DKWITU*/ 
select na.date, na.borough, na.zip,na.injured,na.killed,
	sum(na.injured) over (partition by na.date, na.borough) as total_injured,
	max(na.injured) over (partition by na.date, na.borough) as max_injured,
	max(na.killed) over (partition by na.date, na.borough) as max_killed
from nyc_analytics na
order by na.date 

/*Let me partition it seperately*/
/*similar to above, here two different features are used*/ 
select na.date, na.borough, na.zip,na.injured,na.killed,
	sum(na.injured) over (partition by na.date) as total_injured,
	max(na.injured) over (partition by na.date) as max_injured,
	max(na.killed) over (partition by na.date) as max_killed,
	sum(na.injured) over (partition by na.borough) as total_b_injured,
	max(na.injured) over (partition by na.borough) as max_b_injured,
	max(na.killed) over (partition by na.borough) as max_b_killed
from nyc_analytics na
order by na.date

/*moving average of total injured over 3 days*/
/*check the output, you will find the result totally different from your expectations*/
select q.date, q.borough, 
	avg(q.total_injured) over(
		partition by q.date
		order by q.total_injured
		rows between 2 preceding and current row
	) as mov_3_avg, q.total_injured, q.max_injured
from (
select na.date, na.borough, 
	sum(na.injured) as total_injured,
	max(na.injured) as max_injured,
	sum(na.killed) as total_killed,
	max(na.killed) as max_killed
from nyc_analytics na
group by na.date, na.borough
)q

/*Looking at the result of this query will provide some perspective. 
 * It is not what we will look for in 3 day moving avg
 * The series has to be reversed.
 * Note, there is no partitioning at all 
 * */
select q.date, 
	avg(q.total_injured) over(
		rows between current row and 2 following  
	) as mov_3_avg, q.total_injured, q.max_injured
from (
select na.date, 
	sum(na.injured) as total_injured,
	max(na.injured) as max_injured,
	sum(na.killed) as total_killed,
	max(na.killed) as max_killed
from nyc_analytics na
group by na.date
)q

/* This is a valid 3 day moving avg.
 * Note, there is no partitioning at all 
 * */
select q.date, 
	round(avg(q.total_injured) over(
		rows between 2 preceding and current row 
	)::numeric, 1) as mov_3_avg, 
	q.total_injured, q.max_injured
from (
select na.date, 
	sum(na.injured) as total_injured,
	max(na.injured) as max_injured,
	sum(na.killed) as total_killed,
	max(na.killed) as max_killed
from nyc_analytics na
group by na.date
)q

/* Now we can try something with partitioning.
 * Lets bring in boroughs and just order over them.
 * If there is additional rows data in the partition,
 * then rows between , preceding and unbounded will work 
 * only inside them. 
 * */
select q.date, 
	round(avg(q.total_injured) over(
		partition by q.date
		order by q.borough desc
		rows between 1 preceding and current row 
	)::numeric, 1) as cum_avg, 
	q.borough, q.total_injured, q.max_injured
from (
select na.date, na.borough,
	sum(na.injured) as total_injured,
	max(na.injured) as max_injured,
	sum(na.killed) as total_killed,
	max(na.killed) as max_killed
from nyc_analytics na
group by na.date, na.borough
)q
order by q.date

/*query 2: practice lead and lag on the dates and injuries
 * you have to use order by in the over clause
 * */

select q.date, q.total_injured,
	lead(q.total_injured) over (order by q.date) as next_day_total,
	lag(q.total_injured) over (order by q.date) as prev_day_total
from (
select na.date, na.borough,
	sum(na.injured) as total_injured,
	max(na.injured) as max_injured,
	sum(na.killed) as total_killed,
	max(na.killed) as max_killed
from nyc_analytics na
group by na.date, na.borough
)q
order by q.date
 
/*query 2: Which is the top 2 boroughs in injuries every day*/
/*Remember to include the brackets for the with cte*/
with borough_rank
as (
select dense_rank() over(partition by q.date order by q.borough) as brnk,
	q.date,q.total_injured,q.borough
from (
select na.date, na.borough,
	sum(na.injured) as total_injured,
	max(na.injured) as max_injured,
	sum(na.killed) as total_killed,
	max(na.killed) as max_killed
from nyc_analytics na
group by na.date, na.borough
)q
order by q.date
)
select date, total_injured,borough, brnk
from borough_rank
where brnk <= 2 
 
/*This script will work on queries to create
 * dash boards. Dashboards must answer certain question that will help the 
 * operators, business or production. This script will have the following template
 */*/
 
/* question 1 : what are the entities we are talking about*/
 
 select distinct m.model  
 from machines m
 order by m.model 
 
 /*ans-1 : 4 models of machines*/

 select count(1) as model_count, m.model  
 from machines m
 group by m.model
 order by m.model desc
 
 /*ans-2 : The count of machines based each model in shop floor*/

 /*Idea 1: Dash will have details of the machines on right pane
  * Left pane will contain the model types
  * Each model type will contain
  * 	- Avg Age (question 3)
  * 	- Number of Machines (question 3)
  * 	- top error type (question 4)
  * 	- top failure type (question 5)
  * Right pane will contain the time series chart for each of the 
  * machines under a particular model type. Each of the machines 
  * will contain the following details
  * 	- Machine Id
  * 	- Machine age
  * 	- Time line chart with count of error / fails / maintenances 
  * 	in months, (query 7 takes care of it, just a slight change)
  * 	days. (query 6 with cte do the needful)
  * Right pane also has option to track the individual machines performance which 
  * contains the line chart of daily, (query 8)
  * monthly average (query 9) 
  * values of the vibes, rotation, pressure, voltage 
  * The individual graphs will include the max, avg and min values of respective
  * parameters 
  * */
 select t.
 from telemetry t
 
/*question 3 - what is the avg age of each model*/
 
 select m.model , round(avg(m.age), 1) as avg_age, count(1) as machine_qty
 from machines m 
group by m.model
 order by m.model
 
 /*question 4 - what is the top error type by count for each model*/
 
 select q.err_rank, q.model, q.errorid, q.err_count from 
 (
	 with 
	 model_error_count as (
		 select count(1) as err_count, e.errorid, m.model  
		 from errors e join machines m
		 on m.machine_id = e.machineid
		 group by e.errorid, m.model
		 order by e.errorid, err_count desc
	 ) select rank() over(partition by model order by err_count desc) as err_rank, err_count, 
		 errorid, model
		 from model_error_count
) q 
where q.err_rank <= 1

/*question 5 - what is the top fail type by count for each model*/
 
 select q.fail_rank, q.model, q.failure, q.fail_count from 
 (
	 with 
	 model_fail_count as (
		 select count(1) as fail_count, f.failure , m.model  
		 from failures f join machines m
		 on m.machine_id = f.machine_id
		 group by f.failure, m.model
		 order by f.failure, fail_count desc
	 ) select rank() over(partition by model order by fail_count desc) as fail_rank, 
	 fail_count, failure, model
		 from model_fail_count
) q 
where q.fail_rank <= 1

/*next question is split between multiple smaller queries*/

/* question 6- What is the count of machine fails every day*/

select count(e.error_line_id) as err_count, m.machine_id,
to_char(e.datetime, 'mm-dd-yy') as day_id
from errors e join machines m 
on e.machineid = m.machine_id 
group by to_char(e.datetime, 'mm-dd-yy'), m.machine_id 
order by day_id , m.machine_id

/*trying query 6 with over clause*/

select count(e.error_line_id) over (partition by m.machine_id, 
									to_char(e.datetime,'dd-mm-yy')
									) as err_count,
		to_char(e.datetime,'dd-mm-yy') as day_id , e.machineid , m.model 
from errors e join machines m 
on e.machineid = m.machine_id 
order by day_id

/*extending the query 6 include the other parameters*/
/*the below query is unable to partition multiple datetime, across similar looking day_id*/
select count(e.error_line_id) over (partition by e.machineid, 
									to_char(e.datetime,'dd-mm-yy')
									) as err_count,
		count(f.failure_id) over (partition by f.machine_id , 
									to_char(f.datetime,'dd-mm-yy')
									) as fail_count,
		count(mc.maintenance_id) over (partition by mc.machine_id , 
									to_char(mc.datetime,'dd-mm-yy')
									) as maint_count,
		to_char(e.datetime,'dd-mm-yy') as day_id , m.machine_id  , m.model 
from errors e join machines m 
on e.machineid = m.machine_id 
join failures f 
on f.machine_id = m.machine_id 
join maint_comp mc 
on mc.machine_id = m.machine_id 
order by day_id

/*query 6 with the answer*/

with err_count as
( select count(e.error_line_id) over (partition by m.machine_id, 
									to_char(e.datetime,'dd-mm-yy')
									) as err_cnt,
		to_char(e.datetime,'dd-mm-yy') as day_id , e.machineid , m.model 
from errors e join machines m 
on e.machineid = m.machine_id 
order by day_id
),
fail_count as 
( select count(f.failure_id) over (partition by m.machine_id, 
									to_char(f.datetime ,'dd-mm-yy')
									) as fail_cnt,
		to_char(f.datetime,'dd-mm-yy') as day_id , f.machine_id , m.model 
from failures f  join machines m 
on f.machine_id  = m.machine_id 
order by day_id
),
maint_count as 
( select count(mc.maintenance_id) over (partition by m.machine_id, 
									to_char(mc.datetime ,'dd-mm-yy')
									) as maint_cnt,
		to_char(mc.datetime ,'dd-mm-yy') as day_id , mc.machine_id , m.model 
from maint_comp mc join machines m 
on mc.machine_id  = m.machine_id 
order by day_id
) select m2.day_id, m2.maint_cnt, f2.fail_cnt, e2.err_cnt, m2.machine_id
from maint_count m2 join fail_count f2
on m2.machine_id = f2. machine_id
join err_count e2
on m2.machine_id = e2.machineid
order by m2.day_id 

/*query 7 : extending the query 6 for monthly calculation*/

with err_count as
( select count(e.error_line_id) over (partition by m.machine_id, 
									to_char(e.datetime,'mm-yy')
									) as err_cnt,
		to_char(e.datetime,'mm-yy') as month_id , e.machineid , m.model 
from errors e join machines m 
on e.machineid = m.machine_id 
order by month_id
),
fail_count as 
( select count(f.failure_id) over (partition by m.machine_id, 
									to_char(f.datetime ,'mm-yy')
									) as fail_cnt,
		to_char(f.datetime,'mm-yy') as month_id , f.machine_id , m.model 
from failures f  join machines m 
on f.machine_id  = m.machine_id 
order by month_id
),
maint_count as 
( select count(mc.maintenance_id) over (partition by m.machine_id, 
									to_char(mc.datetime ,'mm-yy')
									) as maint_cnt,
		to_char(mc.datetime ,'mm-yy') as month_id , mc.machine_id , m.model 
from maint_comp mc join machines m 
on mc.machine_id  = m.machine_id 
order by month_id
) select m2.month_id, m2.maint_cnt, f2.fail_cnt, e2.err_cnt, m2.machine_id
from maint_count m2 join fail_count f2
on m2.machine_id = f2. machine_id
join err_count e2
on m2.machine_id = e2.machineid
order by m2.month_id 

/*query 8 : query the vibes on hourly basis (doesn't work)*/ 

select avg(q.volt) over (partition by q.machine_id,q.day_id
						rows between unbounded preceding and current row 
						) as vibes_daily,
		q.machine_id , day_id
from (		
	select to_char(t.datetime ,'dd-mm-yy') as day_id, t.volt, t.machine_id  
	from telemetry t 
) q

/*query 8: works and gives the daily avg data for telemetry paramters*/

select avg(t.volt) as daily_volt, to_char(t.datetime ,'dd-mm-yyyy') as day_id, t.machine_id,
		avg(t.rotate) as daily_rotate, avg(t.pressure) as daily_pressure, 
		avg(t.vibration) as daily_vibration
from telemetry t 
group by to_char(t.datetime ,'dd-mm-yyyy'), t.machine_id 
order by day_id
limit 20

/*supporting query to check the to_char*/
select t.datetime , t.volt, t.machine_id, to_char(t.datetime, 'dd-mm-yyyy') as day_id,
to_char(t.datetime, 'hh') as hr_id
from telemetry t 
limit 100

/*query 8: works and gives the monthly avg data for telemetry paramters*/

select avg(t.volt) as daily_volt, to_char(t.datetime ,'mm-yyyy') as month_id, t.machine_id,
		avg(t.rotate) as daily_rotate, avg(t.pressure) as daily_pressure, 
		avg(t.vibration) as daily_vibration
from telemetry t 
group by to_char(t.datetime ,'mm-yyyy'), t.machine_id 
order by month_id
limit 120

/*query 10: gets the max, min, and avg value of each machine_id*/ 

select min(t.volt) as min_volt, avg(t.volt) as avg_volt, max(t.volt) as max_volt, 
	min(t.rotate) as min_rotation, avg(t.rotate) as avg_rotation, max(t.rotate) as max_rotation, 
	min(t.pressure) as min_pressure, avg(t.pressure) as avg_pressure, max(t.pressure) as max_pressure, 
	min(t.vibration) as min_vibes, avg(t.vibration) as avg_vibes,max(t.vibration) as max_vibes,
	t.machine_id 
from telemetry t 
group by t.machine_id 
order by t.machine_id 

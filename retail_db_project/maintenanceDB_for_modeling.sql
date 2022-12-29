/*This script will work on queries to get the 
 * data ready for modeling in the environment of choice.
 */ 

/*What can we predict?
 * In this case, Failures and errors seem to be important
 * In fact the errors could and the components could be leveraged to 
 * predict failures
 * */


select t.machine_id , t.volt ,t.rotate, t.pressure ,t.vibration ,
e.errorid ,f.failure , mc.comp , m."age", m.model 
from telemetry t join errors e 
on t.machine_id = e.machineid 
join failures f 
on t.machine_id = f.machine_id 
join maint_comp mc 
on t.machine_id = mc.machine_id 
join machines m 
on t.machine_id = m.machine_id 

/*
 * The errorid, model and the comp type are categorical. The can be modified using
 * the algorithms in the libraries like pyspark. On the 2nd thought, may be there 
 * is no need to use pyspark algo. The sql substring can do the trick and extract the 
 * last number from the various categorical columns. 
 * The age is a number so no change 
 * required there. 
 * Coming to the target, the failure component. The model has to come out with a 
 * categorical value, which will be mapped back to components that may fail in the 
 * future. 
 */*/
 
 create table failure_pred_data
 as
 select t.machine_id::int , t.volt ,t.rotate, t.pressure ,t.vibration ,
substring(e.errorid, '.$')::int as error_cat ,substring(f.failure,'.$')::int as failuer_cat , 
substring(mc.comp, '.$')::int as component_cat, m."age", 
substring(m.model, '.$')::int as model_cat
from telemetry t join errors e 
on t.machine_id = e.machineid 
join failures f 
on t.machine_id = f.machine_id 
join maint_comp mc 
on t.machine_id = mc.machine_id 
join machines m 
on t.machine_id = m.machine_id 
limit 5

/*the above method of joining with the machine_id is not the correct way for 
modeling*/


 select t.datetime , e.datetime ,t.machine_id::int , t.volt ,t.rotate, t.pressure ,t.vibration ,
substring(e.errorid, '.$')::int as error_cat 
from telemetry t right outer join errors e 
on t.datetime  = e.datetime  
order by t.datetime, t.machine_id 
limit 500

select t.datetime , e.datetime, e.machineid , t.machine_id 
from telemetry t left outer join errors e 
on t.datetime  = e.datetime
where e.datetime  is not null 
order by t.datetime 


/*joining on the date time confuses the algorithm, and 
 * copies the data from error id into wrong locations 
 */*/

/*Trying to take it slow*/ 
 
select  t.machine_id , m.machine_id 
from telemetry t join machines m 
on t.machine_id = m.machine_id 

/*The above join has no duplicates. The machine ids has copied themselves
to the rows where they are referred in telemetry table*/

select t.datetime , f.datetime , f.machine_id , t.machine_id 
from telemetry t left outer join failures f 
on t.datetime = f.datetime

/*46,000 additional rows are getting added. Seems to be 
wrong*/

select count(*)
from telemetry t 

select count(*)
from failures f 

/*note the below query has no else clause in the case when*/

select t.datetime , case when f.datetime is null then 0 end as datetime ,
case when f.machine_id is null then t.machine_id end as machine_id, t.machine_id,  
case when f.failure is null then 0 end as failure
from telemetry t left outer join failures f 
on t.datetime = f.datetime and t.machine_id = f.machine_id 
left outer join maint_comp mc
on t.datetime = mc.datetime and t.machine_id = mc.machine_id 
left outer join errors e 
on t.datetime = e.datetime and t.machine_id = e.machineid 
join machines m 
on t.machine_id = m.machine_id 

/*query that implements case when with else clause*/

select t.datetime , case 
					when f.datetime is null 
					then current_date 
					else f.datetime  
					end as datetime ,
					case 
					when f.machine_id is null 
					then 0
					else f.machine_id 
					end as machine_id, 
					t.machine_id,  
					case when f.failure is null 
					then 0
					else substring(f.failure, '.$')::numeric 
					end as failure
from telemetry t left outer join failures f 
on t.datetime = f.datetime and t.machine_id = f.machine_id 
left outer join maint_comp mc
on t.datetime = mc.datetime and t.machine_id = mc.machine_id 
left outer join errors e 
on t.datetime = e.datetime and t.machine_id = e.machineid 
join machines m 
on t.machine_id = m.machine_id 

/*supporting queries*/

select count(*)
from telemetry t left outer join maint_comp mc
on t.datetime = mc.datetime and t.machine_id = mc.machine_id 

select count(*)
from telemetry t left outer join errors e 
on t.datetime = e.datetime and t.machine_id = e.machineid 


/*I can proceed by creating a table using the CTAS format. then I want to attach 
the keys back to child tables, and create star schema. */

/*schema is created by the foreign key in fact table referencing the dimension table. 
The constrain forces the fact table to have correct data for furhter analysis.*/


create table fact_telemetry (
	machine_line_id INT, error_line_id INT, maintenance_line_id INT, 
	failure_line_id INT, telemetry_line_id int, failure varchar, maint_component varchar,
	error_id varchar , machine_model varchar, machine_age INT 
)

/*The above table will require the foreign keys to be assigned, 
 * and then the data will be filled. This will ensure the table will 
 * hold the correct mapped data.
 * */

alter table fact_telemetry 
	add foreign key(machine_line_id)
		references machines(machine_id)

alter table fact_telemetry 
	add foreign key(error_line_id)
		references errors(error_line_id)
		
alter table fact_telemetry  
	add foreign key(maintenance_line_id)
	references maint_comp(maintenance_id)
	
alter table fact_telemetry 
	add foreign key(failure_line_id)
		references failures(failure_id)

alter table fact_telemetry 
	add foreign key(telemetry_line_id)
		references telemetry(telemetry_id)
		
/*foreign key is a constraint. when you create duplicates of it, then drop 
constraint. In this case, following key was duplicated */
alter table fact_telemetry 
	drop constraint fact_telemetry_failure_line_id_fkey1

/*The frame has been create, now filling it with data from multiple tables*/	
	
insert into fact_telemetry (machine_line_id, error_line_id, maintenance_line_id, 
	failure_line_id, telemetry_line_id, failure, maint_component,
	error_id, machine_model, machine_age)	
select m.machine_id , e.error_line_id , mc.maintenance_id , f.failure_id , t.telemetry_id,
	f.failure ,mc.comp, e.errorid, m.model, m."age" 
from telemetry t left outer join failures f 
on t.datetime = f.datetime and t.machine_id = f.machine_id 
left outer join maint_comp mc
on t.datetime = mc.datetime and t.machine_id = mc.machine_id 
left outer join errors e 
on t.datetime = e.datetime and t.machine_id = e.machineid 
join machines m 
on t.machine_id = m.machine_id 

select * 
from fact_telemetry f
order by f.telemetry_line_id
limit 5
#drop table failures;

create table failures(failure_ID SERIAL primary key, datetime TIMESTAMP, 
						machine_id INTEGER, failure VARCHAR(10))

create table machines(machine_id INTEGER primary key, model VARCHAR, age INTEGER)

create table errors(error_line_id SERIAL primary key, datetime TIMESTAMP, machine_id INTEGER, 
					error_id VARCHAR)
					
create table telemetry(telemetry_id SERIAL primary key, datetime TIMESTAMP, machine_id INTEGER,
					volt real, rotate real, pressure real, vibration real)
					
create table maint_comp(maintenance_id SERIAL primary key, datetime TIMESTAMP, machine_id INTEGER,
						comp VARCHAR(10))
						
COPY machines(machine_id, model, age) FROM 'machines.csv' CSV HEADER DELIMITER ',';

COPY maint_comp(datetime, machine_id, comp) FROM 'maint.csv' CSV HEADER DELIMITER ',';

COPY telemetry(datetime, machine_id, volt, rotate, pressure, vibration) FROM 'telemetry.csv' CSV HEADER DELIMITER ',';


## Starting BY querying the errors TABLE

//query 1

select count(*) 
FROM errors

// query 2

select datetime, count (3) as daily_errors
from errors e 
group by datetime 
order by daily_errors desc

// sub query 2-0

select to_char (datetime, 'yyyy/MM/dd') as observe_date, errorid, 
machineid 
from errors e 

// sub query 2-1

select count(1) as daily_error_types, errorid,
to_char (datetime, 'yyyy/MM/dd') as observe_date
from errors e 
group by observe_date, errorid 
order by observe_date, errorid

// sub query 2-2
select count(1) as daily_error_types,
to_char (datetime, 'yyyy/MM/dd') as observe_date
from errors e 
group by observe_date
order by daily_error_types desc

// sub query 2-3
select count(1) as hour_wise_error,
to_char (datetime, 'hh') as observe_hour
from errors e 
group by observe_hour
order by hour_wise_error desc

// query 3

select errorid, count(3) as error_count
from errors e 
group by errorid
order by error_count desc 


// query 4 

select machineid, count(4) as machine_id_error_count
from errors e 
group by machineid 
order by machine_id_error_count desc

// sub query 4-0

select machineid, count(4) as machine_daily_error,
to_char(datetime, 'yy/MM/dd') as obse_dt
from errors e 
group by obse_dt, machineid 
order by machineid,machine_daily_error desc

## Starting the query for failures table 

select * from failures f 

select count(*) from failures f 

// query 1

select machine_id, count(4) as machine_daily_fails,
to_char(datetime, 'yy/MM/dd') as obse_dt
from failures f  
group by obse_dt, machine_id 
order by machine_id,machine_daily_fails desc

// query 2

select machine_id, count(4) as machine_fails
from failures f  
group by machine_id 
order by machine_fails desc

// query 3

select failure, count(4) as comp_failures
from failures f 
group by failure 
order by comp_failures desc

// query 4

select count(failure) daily_failure, extract (doy from datetime) as dayoyear
from failures f 
group by dayoyear 
order by daily_failure desc

### starting analysis of machines

select * from machines

// query 1

select model , count(age) as model_count
from machines m 
group by model 
order by model_count desc

// query 2

select avg(age) as avg_age 
from machines m 

// query 3

select round(avg(age),1) as avg_age, model
from machines m 
group by model 
order by avg_age desc

// query 4

select count(*) as grp_age, age
from machines m 
group by age 
order by age desc

### starting on the maint_comp table 

select * from maint_comp mc 

select count(*) from maint_comp mc 

// query 1

select count(1) as day_maintenance, 
to_char(datetime, 'yy/MM/dd') as day_work
from maint_comp mc 
group by day_work
order by day_maintenance DESC

// query 2

select count(*) as per_mc, machine_id
from maint_comp mc 
group by machine_id 
order by per_mc desc

// query 3

select count(*) as per_comp, comp 
from maint_comp mc 
group by comp 
order by per_comp desc

### starting to work on the telemetry

select * from telemetry t 

// query 1

select count(*) obs_count, machine_id
from telemetry t 
group by machine_id 
order by obs_count desc

select 8761 / 24 as number_of_days

// query 2

select max(rotate) as max_rotation, min(rotate) as minimum_rotation, 
to_char(datetime,'yy/mm/dd') as date, machine_id  
from telemetry t 
group by date, machine_id 
order by max_rotation 

// query 2-0
select max(rotate) as max_rotation, min(rotate) as minimum_rotation, 
to_char(datetime,'yy/mm/dd') as date, machine_id  
from telemetry t 
group by date, machine_id
having machine_id = 89
order by date 

### starting the composite queries


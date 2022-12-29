/*This script will explore all tables of maintenance database
 * and try to come out with
 * Insights
 * Datasets for visualisation
 * Datasets for machine learning processes
 */*/
 
/* stage 1 : familiarising tables*/
 
 select * 
 from errors e 
 
 select distinct e.errorid  
 from errors e 
 order by e.errorid 

 select count(1) as err_count, e.errorid 
 from errors e 
 group by e.errorid
 order by e.errorid 
 
 select count(1) as day_count, e.datetime
 from errors e
 group by e.datetime 
 order by e.datetime
 
 select count(1) as day_count, to_char(e.datetime, 'yyyy-MM-dd')
 from errors e
 group by to_char(e.datetime, 'yyyy-MM-dd')
 order by to_char(e.datetime, 'yyyy-MM-dd')
 
select count(1) as day_count, to_char(e.datetime, 'hh')
from errors e
group by to_char(e.datetime, 'hh')
order by to_char(e.datetime, 'hh')

 /*
  * errors table is about 5 different errors
  * errors are logged based on the errors raised 
  * date_time is logged as timestamp, from which the days extracted
  */*/
  
 select * 
 from failures f  
 
 select distinct f.failure 
 from failures f
 order by f.failure 

 select count(1) as fail_count, f.failure  
 from failures f
 group by f.failure
 order by f.failure
 
 select count(1) as day_count, f.datetime
 from failures f
 group by f.datetime 
 order by f.datetime
 
 select count(1) as day_count, to_char(f.datetime, 'yyyy-MM-dd')
 from failures f
 group by to_char(f.datetime, 'yyyy-MM-dd')
 order by to_char(f.datetime, 'yyyy-MM-dd')
 
select count(1) as day_count, to_char(f.datetime, 'hh')
from failures f 
group by to_char(f.datetime, 'hh')
order by to_char(f.datetime, 'hh')

/*
 * The failures are concentrated on 3rd and 6th hour of ops, 
 * with the 06 hour registering 97.578% fails
 * */

 select *
 from maint_comp mc

 select distinct mc.comp  
 from maint_comp mc
 order by mc.comp 

 select count(1) as maint_count, mc.comp  
 from maint_comp mc
 group by mc.comp
 order by mc.comp
 
 select count(1) as day_count, mc.datetime
 from maint_comp mc
 group by mc.datetime 
 order by mc.datetime
 
 select count(1) as day_count, to_char(mc.datetime, 'yyyy-MM-dd')
 from maint_comp mc
 group by to_char(mc.datetime, 'yyyy-MM-dd')
 order by to_char(mc.datetime, 'yyyy-MM-dd')
 
select count(1) as day_count, to_char(mc.datetime, 'hh')
from maint_comp mc 
group by to_char(mc.datetime, 'hh')
order by to_char(mc.datetime, 'hh')

/* 
 * Why all the maintenance is done at 06 hrs? 
 * Maintenance is taken up every fortnightly 
 * Average of the daily_count of maintenance can give insights
 * */


 select * 
 from machines m
 
 select distinct m.model  
 from machines m
 order by m.model 

 select count(1) as model_count, m.model  
 from machines m
 group by m.model
 order by m.model desc
 
 select count(1) as mc_count, m.age
 from machines m
 group by m.age  
 order by m.age desc
 
/*
 * The machines' model and age count can provide 
 * connectivity between the error/ failures table 
 * for composite analysis with joins
 * */

select *
from telemetry t 

select count(1) as telemetryCount, t.machine_id 
from telemetry t 
group by t.machine_id 
order by telemetryCount

select distinct t.machine_id 
from telemetry t 
order by t.machine_id desc

select min(t.volt) as min_volt, avg(t.volt) as avg_volt, max(t.volt) as max_volt, 
	min(t.rotate) as min_rotation, avg(t.rotate) as avg_rotation, max(t.rotate) as max_rotation, 
	min(t.pressure) as min_pressure, avg(t.pressure) as avg_pressure, max(t.pressure) as max_pressure, 
	min(t.vibration) as min_vibes, avg(t.vibration) as avg_vibes,max(t.vibration) as max_vibes,
	t.machine_id 
from telemetry t 
group by t.machine_id 
order by t.machine_id 

/*
 * The baseline has been established. The analysis can be further built 
 * from here, to find the areas of improvements and preventive maintenances
 * extend it to classification and regression models
 * */






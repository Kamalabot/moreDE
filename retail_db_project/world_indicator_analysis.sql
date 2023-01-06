/*This script will hold the analytics part of the 
 * world indicators table
 */*/
 
 select pc.country_code, pc.country_name
 from primary_country pc 
 limit 5
 
 select pi2.indicator_code, pi2.indicator_name
 from primary_indicator pi2  
 limit 5
 
select pc.country_name ,pi2.indicator_name  
from fact_data fd join primary_country pc 
on pc.country_code = fd.country_code 
join primary_indicator pi2 
on pi2.indicator_code = fd.indicator_code 
where pi2.indicator_name ~ 'female'st ba
limit 200


select pc.country_name , pi2.indicator_name, round(fd.year2011,1) as year2011,
	round(fd.year2012,1) as year2012, round(fd.year2013,1) as year2013,
	round(fd.year2014,1) as year2014,round(fd.year2015,1) as year2015,
	fd.year2016,fd.year2017,fd.year2018 ,fd.year2019, fd.year2020,
	fd.year2021 
from fact_data fd join primary_country pc 
on pc.country_code = fd.country_code 
join primary_indicator pi2 
on pi2.indicator_code = fd.indicator_code 
where pi2.indicator_name ~ 'telephone' and pc.country_name ~ 'Africa Eastern'



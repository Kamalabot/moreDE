/*Doing the analysis of glass door salary dataset*/

/*found that there were no data in the database
 * Understood the issue was with varchar length, and 
 * completely different column names.
 * */
select * 
from gd_salary_data_cleaned gsdc 

select *
from gd_eda_data ged 


select count(*) 
from glassdoor_jobs gj  

/*The glassdoor_jobs table has all the 956 rows of data*/

/*The following query can be a good candidate for bar graph showing various 
roles for which there is opening.*/

create table if not exists openings_per_title
as
select split_part(gj."Job Title",'-',1) as job_title, count(gj.job_id) as title_count
from glassdoor_jobs gj 
group by split_part(gj."Job Title",'-',1)
order by title_count desc

select *
from openings_per_title opt 

/*initially I was thinking of grouping and counting based 
on the company name. */

/*select split_part(REGEXP_REPLACE(opc."Company Name", '\n', '_', 'g'),
					'_',1)
from openings_per_company opc */

drop table if exists opening_per_company

create table if not exists openings_per_company
as
select split_part(REGEXP_REPLACE(gsdc."Company Name", '\n', '_', 'g'),
					'_',1) as company_name, 
		count(gsdc."Job Title") as count_per_company
from gd_salary_data_cleaned gsdc 
group by gsdc."Company Name" 
order by count_per_company desc

select *
from openings_per_company opc 

/*then I felt grouping for the location would be better choice
 * and a good candidate for Mercator plot of USA
 * */

create table if not exists openings_per_location
as
select split_part(gsdc."Location",',',1) as location_city, 
	split_part(gsdc."Location",',',2) as state, 
	count(gsdc."Job Title") as opening_location
from gd_salary_data_cleaned gsdc 
group by split_part(gsdc."Location",',',1), split_part(gsdc."Location",',',2) 
order by opening_location desc

select *
from openings_per_location opl 

/*The max / avg age extracted seems to have errors...*/

select gsdc.sector , round(avg(gsdc.age)::numeric,1) as sector_avg_age, 
		round(avg(gsdc.avg_salary)::numeric,1) as sector_avg_salary  
from gd_salary_data_cleaned gsdc  
group by gsdc.sector 

select gsdc.sector , max(gsdc.age) as sectorMax_age, 
		max(gsdc.avg_salary) as sectorMax_salary  
from gd_salary_data_cleaned gsdc  
group by gsdc.sector 

select gsdc.sector ,gsdc.age, 
	gsdc.avg_salary  
from gd_salary_data_cleaned gsdc  
where gsdc.sector = 'Finance'

select count(ged."Job Title") as python_reqd , 
		case when ged.python_yn = 1 then 'yes'
		else 'no' end as python_yn
from gd_eda_data ged 
group by ged.python_yn 

select count(ged."Job Title") as excel_reqd , 
		case when ged.excel = 1 then 'yes'
		else 'no' end as excel_yn  
from gd_eda_data ged 
group by ged.excel 


select count(ged."Job Title") as aws_reqd,  
		case when ged.aws = 1 then 'yes'
		else 'no' end as aws_yn
from gd_eda_data ged 
group by ged.aws

select count(ged."Job Title") as r_reqd , 
		case when ged.r_yn = 1 then 'yes'
		else 'no' end as r_yn  
from gd_eda_data ged 
group by ged.r_yn 

select count(ged."Job Title") as spark_reqd, 
		case when ged.spark = 1 then 'yes'
		else 'no' end as spark_yn 
from gd_eda_data ged 
group by ged.spark 


select count(ged.sector) as reqd_seniority, ged.seniority  
from gd_eda_data ged 
group by ged.seniority 

create table if not exists tools_required
as
with 
py_req as (select count(ged."Job Title") as python_reqd , 
		case when ged.python_yn = 1 then 'yes'
		else 'no' end as python_yn
		from gd_eda_data ged 
		group by ged.python_yn),
exl_req as (select count(ged."Job Title") as excel_reqd , 
		case when ged.excel = 1 then 'yes'
		else 'no' end as excel_yn  
from gd_eda_data ged 
group by ged.excel), 
aws_req as (select count(ged."Job Title") as aws_reqd,  
		case when ged.aws = 1 then 'yes'
		else 'no' end as aws_yn
from gd_eda_data ged 
group by ged.aws),
r_req as(select count(ged."Job Title") as r_reqd , 
		case when ged.r_yn = 1 then 'yes'
		else 'no' end as r_yn  
from gd_eda_data ged 
group by ged.r_yn), 
spark_req as(select count(ged."Job Title") as spark_reqd, 
		case when ged.spark = 1 then 'yes'
		else 'no' end as spark_yn 
from gd_eda_data ged 
group by ged.spark)
select er.excel_yn as requirement, er.excel_reqd, ar.aws_reqd, 
		rr.r_reqd, sr.spark_reqd, pr.python_reqd
from exl_req er join aws_req ar 
on er.excel_yn = ar.aws_yn
join r_req rr on er.excel_yn = rr.r_yn
join spark_req sr on er.excel_yn = sr.spark_yn
join py_req pr on er.excel_yn = pr.python_yn

select *
from tools_required 

create table if not exists salary_quote_count
as
with 
max_sal_count as (select count(1) as per_salary, concat(gsdc.max_salary,'K') as max_salary 
from gd_salary_data_cleaned gsdc 
group by gsdc.max_salary 
order by per_salary desc),
min_sal_count as (select count(1) as per_salary, concat(gsdc.min_salary,'K') as min_salary  
from gd_salary_data_cleaned gsdc 
group by gsdc.min_salary 
order by per_salary desc)
select ms.min_salary as salary_quoted, ms.per_salary as min_salary_count,
	mx.per_salary as max_salary_count
from min_sal_count ms join max_sal_count mx
on ms.min_salary = mx.max_salary
order by split_part(ms.min_salary,'K',1)::int desc 




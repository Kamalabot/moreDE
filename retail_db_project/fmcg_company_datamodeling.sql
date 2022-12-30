/*
 * Objective is to bring the management table and fmcg_india table together
 * Remember FJWGSO rule, always start with FROM. Think about the ways to apply constraints 
 * on the table, not on the data.
 */*/
 
 select cmi.id,cmi."name" ,cmi.designation ,cmi.company 
 from company_management_india cmi 
 where cmi.company ~ 'hindustan'
 
/* lets begin by making company table and executive_name table */
 
 drop table executives cascade
 
 drop table indian_companies cascade
 
 create table executives(
 	exe_id serial primary key unique,
 	exe_name varchar unique
 )
 
 create table indian_companies(
 	comp_id serial primary key unique,
 	company_name varchar unique
 )
 
/*There are 471 companies. They are not having any gaps in their names*/

 insert into indian_companies(company_name)
 select distinct cmi.company
 from company_management_india cmi 
 
/*There are 3609 executives*/
 
 insert into executives(exe_name)
 select distinct cmi."name"
 from company_management_india cmi 
 where cmi.name is not null
 
 select e.*
 from executives e 
 limit 5
 
 select ic.*
 from indian_companies ic  
 limit 5
 
/* lets build the company_management_india table again*/
 
 drop table new_exec_company_table
 
 create table new_exec_company_table(
 	id serial primary key,
 	designation varchar,
 	comp_name VARCHAR references indian_companies(company_name),
 	exe_name VARCHAR references executives(exe_name)
 )
 
insert into new_exec_company_table (exe_name,designation,comp_name) 
select cmi."name" , cmi.designation , cmi.company  
 from company_management_india cmi
 
/*Testing the newly created table */ 
select nect.designation , nect.comp_name ,nect.exe_name  
from new_exec_company_table nect
where nect.comp_name ~ 'hindustanuni'
 
/*starting to work on the fmcg company. There is only 43 company data here*/

create table distinct_fmcg_company( 
	sec_code int primary key,
	company_name varchar unique
)

insert into distinct_fmcg_company (sec_code,company_name)
select distinct f.securitycode::int as sec_code, split_part(replace(lower(f.companyname),' ',''),'.',1)  as company_name  
from fmcgindia f 

select count(1)
from distinct_fmcg_company dfc 

/*lets immediately join with the new_exec and see*/

select nect.designation,tc.company_name, tc.sec_code  
from new_exec_company_table nect join distinct_fmcg_company tc 
on tc.company_name ~ nect.comp_name 

/*even though the company names are matching they are not outputting data
 * when using the = for joining.
 * when the ~ was used for joining the tables came together. 
 * The data is not perfect, as it was inner join
 * Only 27 fmcg companies are reflecting, out of 43 companies in the fmcg_india dataset.
 * */

drop table fmcgindia_executives 

create table fmcgindia_executives(
	fmcg_exe_id serial primary key,
	designation varchar,
	company_name varchar references distinct_fmcg_company(company_name),
	bse_sec_code INT references distinct_fmcg_company(sec_code)
)

insert into fmcgindia_executives (designation, company_name,bse_sec_code)
select nect.designation,tc.company_name, tc.sec_code 
from new_exec_company_table nect join trial_company tc 
on tc.company_name ~ nect.comp_name 

select count(1)
from ( 
	select distinct fe.company_name 
	from fmcgindia_executives fe 
)q

/*What problem have we solved 1st?
 * Not so fast. No problem has been solved. 
 * */
/*We have got the sec_code for the fmcg companies inside the company management table along with the 
executives and their designations.*/


select distinct dfc.company_name
 from company_management_india cmi left outer join distinct_fmcg_company dfc  
 on dfc.company_name ~ cmi.company 
 
 select count(1)
 from (
 	select distinct dfc.company_name 
from company_management_india cmi left outer join distinct_fmcg_company dfc  
 on dfc.company_name ~ cmi.company 
 )q
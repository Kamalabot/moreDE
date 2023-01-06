/*This script will build the company progress database with the necessary 
 * tables to build the dashboards
 */ */
 
 create table if not exists company_made_progress (id bigint,
 			Date date,Locations varchar,
 			Sales_reps varchar,Product varchar,Price numeric,
 			cost numeric,Qty numeric,Total_Sales numeric,
 			cogs numeric,Profit numeric,Balance numeric,
 			Targets numeric,Payment numeric) 
 			
/*The table is inserted from external database*/
 			 
copy company_made_progress from '/home/kali/gitFolder/company_made_progress.csv' csv header delimiter ',';                         

/*The above command did not work due to permission issues. The same has been 
circumvented with directly copying the file*/

select *
from company_made_progress 
limit 5

/*Lets start creating the tables necessary for each of the dashboard features*/

select to_char(cmp."date" ,'Month') as month,
		sum(cmp.total_sales) as monthly_sales,
		sum(cmp.cogs) as monthly_cogs,
		sum(cmp.profit) as monthly_profit,
		sum(cmp.qty) as monthly_qty,
		sum(cmp.payment) as monthly_payment,
		round(sum(cmp.targets)::numeric, 2) as monthly_target
from company_made_progress cmp 
group by to_char(cmp."date" ,'Month') 

drop table if exists monthly_data;

create table monthly_data(month varchar primary key	unique,
		monthly_sales integer,
		monthly_cogs integer,
		monthly_profit integer,
		monthly_qty integer, 
		monthly_payment integer,
		monthly_target numeric )

/*Sending data into the table...*/
		
insert into monthly_data (month,
		monthly_sales,
		monthly_cogs,
		monthly_profit,
		monthly_qty, 
		monthly_payment,
		monthly_target)
select to_char(cmp."date" ,'Month') as month,
		sum(cmp.total_sales) as monthly_sales,
		sum(cmp.cogs) as monthly_cogs,
		sum(cmp.profit) as monthly_profit,
		sum(cmp.qty) as monthly_qty,
		sum(cmp.payment) as monthly_payment,
		round(sum(cmp.targets)::numeric, 2) as monthly_target
from company_made_progress cmp 
group by to_char(cmp."date" ,'Month')

/*Checking the data*/
select *
from monthly_data 


/*Creating data for the sales reps to have reference for the reps*/

select cmp.sales_reps ,
		sum(cmp.total_sales) as monthly_sales,
		sum(cmp.cogs) as monthly_cogs,
		sum(cmp.profit) as monthly_profit,
		sum(cmp.qty) as monthly_qty,
		sum(cmp.payment) as monthly_payment,
		round(sum(cmp.targets)::numeric, 2) as monthly_target
from company_made_progress cmp 
group by cmp.sales_reps 


drop table if exists salesreps_data; 

create table salesreps_data(sales_reps varchar primary key unique,
		reps_sales integer,
		reps_cogs integer,
		reps_profit integer,
		reps_qty integer, 
		reps_payment integer,
		reps_target numeric )

insert into salesreps_data (sales_reps,
		reps_sales,
		reps_cogs,
		reps_profit,
		reps_qty, 
		reps_payment,
		reps_target)
select 	cmp.sales_reps,
		sum(cmp.total_sales),
		sum(cmp.cogs),
		sum(cmp.profit),
		sum(cmp.qty),
		sum(cmp.payment),
		round(sum(cmp.targets)::numeric, 2)
from company_made_progress cmp 
group by cmp.sales_reps 

/*Creating the data for the monthly data grouped by sales_reps */

create table reps_monthly(sales_reps varchar references salesreps_data(sales_reps),
		month varchar references monthly_data(month),
		reps_sales integer,
		reps_cogs integer,
		reps_profit integer,
		reps_qty integer, 
		reps_payment integer,
		reps_target numeric)

/*This insertion will have 48 rows. 4 reps and 12 months for each reps.
 * The names and months are referenced to parent tables. They cannot be outside 
 * the format in the parent tables */		
insert into reps_monthly (sales_reps,
		month,
		reps_sales,
		reps_cogs,
		reps_profit,
		reps_qty, 
		reps_payment,
		reps_target)
select cmp.sales_reps, 
		to_char(cmp."date" ,'Month'),
		sum(cmp.total_sales),
		sum(cmp.cogs),
		sum(cmp.profit),
		sum(cmp.qty),
		sum(cmp.payment),
		round(sum(cmp.targets)::numeric, 2)
from company_made_progress cmp 
group by to_char(cmp."date" ,'Month'), cmp.sales_reps 

/*Creating data for the products to have reference for the products*/

select cmp.product ,
		sum(cmp.total_sales) as monthly_sales,
		sum(cmp.cogs) as monthly_cogs,
		sum(cmp.profit) as monthly_profit,
		sum(cmp.qty) as monthly_qty,
		sum(cmp.payment) as monthly_payment,
		round(sum(cmp.targets)::numeric, 2) as monthly_target
from company_made_progress cmp 
group by cmp.product  


drop table if exists product_data; 

create table product_data(products varchar primary key unique,
		product_sales integer,
		product_cogs integer,
		product_profit integer,
		product_qty integer, 
		product_payment integer,
		product_target numeric )

/*There will be 16 inserts in this tables*/		
insert into product_data (products,
		product_sales,
		product_cogs,
		product_profit,
		product_qty, 
		product_payment,
		product_target)
select 	cmp.product ,
		sum(cmp.total_sales),
		sum(cmp.cogs),
		sum(cmp.profit),
		sum(cmp.qty),
		sum(cmp.payment),
		round(sum(cmp.targets)::numeric, 2)
from company_made_progress cmp 
group by cmp.product 

/*There will be 191 inserts.. some months all the products are not sold*/
create table product_monthly(
		products varchar references product_data(products),
		month varchar references monthly_data("month"),
		product_sales integer,
		product_cogs integer,
		product_profit integer,
		product_qty integer, 
		product_payment integer,
		product_target numeric )
		

insert into product_monthly(products,
		month,
		product_sales,
		product_cogs,
		product_profit,
		product_qty, 
		product_payment,
		product_target)
select 	cmp.product,
		to_char(cmp."date" ,'Month'),
		sum(cmp.total_sales),
		sum(cmp.cogs),
		sum(cmp.profit),
		sum(cmp.qty),
		sum(cmp.payment),
		round(sum(cmp.targets)::numeric, 2)
from company_made_progress cmp 
group by cmp.product,to_char(cmp."date" ,'Month')


/*Creating data for the locations to have reference for the location_monthly*/

select cmp.locations ,
		sum(cmp.total_sales) as location_sales,
		sum(cmp.cogs) as location_cogs,
		sum(cmp.profit) as location_profit,
		sum(cmp.qty) as location_qty,
		sum(cmp.payment) as location_payment,
		round(sum(cmp.targets)::numeric, 2) as location_target
from company_made_progress cmp 
group by cmp.locations 


drop table if exists location_data; 

create table location_data(location varchar primary key unique,
		location_sales integer,
		location_cogs integer,
		location_profit integer,
		location_qty integer, 
		location_payment integer,
		location_target numeric )

/*There will be 11 inserts in this tables*/		
insert into location_data (location,
		location_sales,
		location_cogs,
		location_profit,
		location_qty, 
		location_payment,
		location_target)
select 	cmp.locations,
		sum(cmp.total_sales),
		sum(cmp.cogs),
		sum(cmp.profit),
		sum(cmp.qty),
		sum(cmp.payment),
		round(sum(cmp.targets)::numeric, 2)
from company_made_progress cmp 
group by cmp.locations 


create table location_monthly(
		location varchar references location_data(location),
		month varchar references monthly_data("month"),
		location_sales integer,
		location_cogs integer,
		location_profit integer,
		location_qty integer, 
		location_payment integer,
		location_target numeric )
		

/*There are total 132 inserts*/		
insert into location_monthly(location,
		month,
		location_sales,
		location_cogs,
		location_profit,
		location_qty, 
		location_payment,
		location_target)
select 	cmp.locations,
		to_char(cmp."date" ,'Month'),
		sum(cmp.total_sales),
		sum(cmp.cogs),
		sum(cmp.profit),
		sum(cmp.qty),
		sum(cmp.payment),
		round(sum(cmp.targets)::numeric, 2)
from company_made_progress cmp 
group by cmp.locations,to_char(cmp."date" ,'Month')

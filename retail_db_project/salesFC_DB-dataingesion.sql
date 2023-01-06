/*Creating tables and ingesting the data 
 * from sales forecasting competition and 
 * then generating the data model*/

/*The creating TABLE step IS done AFTER the datasets are loaded in-memory database or 
 * temporary database. Since the data has been throughly checked using Pyspark 
 * environment, that step is skipped. The data store is shown below.*/


/*/run/media/solverbot/repoA/gitFolders/moreDE/store_sales_data_analysis*/
 
/* stage 1 : Creating tables*/

/*table 0: date series */
/*+-------------------+-------------------+--------------------+
|           max_date|           min_date|           diff_date|
+-------------------+-------------------+--------------------+
|2017-08-01 00:00:00|2013-01-01 00:00:00|INTERVAL '1673 00...|
+-------------------+-------------------+--------------------+*/


     
/*DECLARE @startDate date = CAST('2013-04-01' AS date),
    @endDate date = CAST(GETDATE() AS date);

SELECT DATEADD(day, number - 1, @startDate) AS [Date]
FROM (
    SELECT ROW_NUMBER() OVER (
        ORDER BY n.object_id
        )
    FROM sys.all_objects n
    ) S(number)
WHERE number <= DATEDIFF(day, @startDate, @endDate) + 1;

**/

drop table if exists date_spine cascade;

create table date_spine(
	date_series date primary key unique
)
     
insert into date_spine(date_series)
SELECT date_trunc('day', dd):: date
FROM generate_series
        ( '2012-01-01'::timestamp 
        , '2017-12-26'::timestamp
        , '1 day'::interval) dd;

select * from date_spine limit 2
       
       
/*Table 1: Oil price data*/

drop table if exists oil_table;

CREATE TABLE IF NOT EXISTS oil_table(
	day_date date,
	dcoilwtico numeric
)

copy oil_table from '/run/media/solverbot/repoA/gitFolders/moreDE/store_sales_data_analysis/oil.csv' csv header delimiter ',';

/*The oil_table has dates missing so creating new oil_table*/

drop table if exists full_oil_table cascade;

create table if not exists full_oil_table(
	day_date date references date_spine(date_series),
	dcoilwtico numeric
)

insert into full_oil_table (day_date, dcoilwtico)
select ds.date_series, coalesce(ot.dcoilwtico,0) as dcoilwtico
from oil_table ot right join date_spine ds 
on ds.date_series = ot.day_date

select * from full_oil_table limit 5

/*table 2: Holiday List table*/

drop table if exists holiday_table;

create table holiday_table(
	day_date date references date_spine(date_series), 
	holiday_type VARCHAR, 
	holiday_locale VARCHAR, 
	holiday_localename VARCHAR,
	description VARCHAR, 
	transferred BOOLEAN
	)

copy holiday_table from '/run/media/solverbot/repoA/gitFolders/moreDE/store_sales_data_analysis/holidays_events.csv' csv header delimiter ',';

select ht.* from holiday_table ht limit 5

/*join_table1: holidays and oil data*/

drop table if exists full_oil_holiday_table;

create table if not exists full_oil_holiday_table(
	oil_id serial primary key,
	day_date date references date_spine(date_series), 
	holiday_type VARCHAR, 
	holiday_locale VARCHAR,
	holiday_localename VARCHAR,
	dcoilwtico numeric,
	description varchar,
	transferred boolean
)

insert into full_oil_holiday_table(day_date, holiday_type, holiday_locale,
		holiday_localename, dcoilwtico, description, transferred) 
select fot.day_date, coalesce(ht.holiday_type,'working') as holiday_type, 
		coalesce(ht.holiday_locale,'National') as holiday_locale,
        coalesce(ht.holiday_localename,'National') as holiday_localename,
        fot.dcoilwtico, ht.description , ht.transferred 
from full_oil_table fot left join holiday_table ht 
on fot.day_date = ht.day_date

/*table 3: Store numbers*/

drop if table exists stores_table;

create table if not exists stores_table(
	store_nbr int primary key unique,
	city varchar,
	state varchar,
	type varchar(1),
	cluster int
)

copy stores_table from '/run/media/solverbot/repoA/gitFolders/moreDE/store_sales_data_analysis/stores.csv' csv header delimiter ',';

select *
from stores_table 
limit 5;

/*table 4: train table*/

drop table if exists train_table;

create table if not exists train_table(
	id int primary key unique, 
	day_date date references date_spine(date_series),
    store_nbr int references stores_table(store_nbr),
    family varchar,
    sales numeric, 
    onpromotion int
)

copy train_table from '/run/media/solverbot/repoA/gitFolders/moreDE/store_sales_data_analysis/train.csv' csv header delimiter ',';

select * from train_table limit 5

/*Referencing the date column to date_spine changed the format automatically */

/*Table 5: Transaction tables*/

drop table if exists transaction_table;

create table if not exists transaction_table(
	txn_date date references date_spine(date_series),
   	store_nbr INT references stores_table(store_nbr),
   	transactions INT
)

copy transaction_table from '/run/media/solverbot/repoA/gitFolders/moreDE/store_sales_data_analysis/transactions.csv' csv header delimiter ',';

/*Lets begin the joining process of train, txn and stores table*/

drop table if exists fact_table

create table if not exists fact_table(
	ftt_id bigserial primary key,
	oil_id int references full_oil_holiday_table(oil_id),
	train_id int references train_table(id),
	day_date date references date_spine(date_series), 
	store_nbr int references stores_table(store_nbr) 
)


select foht.oil_id, tt.id, tt.day_date,tt.store_nbr
FROM train_table tt JOIN stores_table st
on tt.store_nbr = st.store_nbr
LEFT JOIN full_oil_holiday_table foht
on foht.day_date = tt.day_date

/*note the above includes the holiday details also.*/

select foht.oil_id, tt.id, tt.day_date,tt.store_nbr,
tt."family",st."type",st.city, coalesce(tt.sales,0) as sales, 
coalesce(txt.transactions,0) as transactions 
FROM train_table tt JOIN stores_table st
on tt.store_nbr = st.store_nbr 
LEFT JOIN full_oil_holiday_table foht
on foht.day_date = tt.day_date
left join transaction_table txt
on txt.txn_date = tt.day_date 
and txt.store_nbr = tt.store_nbr 

/*Send the data in batches*/


insert into fact_table(oil_id,train_id,day_date, store_nbr)
select foht.oil_id, tt.id, tt.day_date,tt.store_nbr
FROM train_table tt JOIN stores_table st
on tt.store_nbr = st.store_nbr 
LEFT JOIN full_oil_holiday_table foht
on foht.day_date = tt.day_date
left join transaction_table txt
on txt.txn_date = tt.day_date 
and txt.store_nbr = tt.store_nbr
offset 1555510 limit 500000


select count(*) from fact_table ft 


create table if not exists unref_fact_table(
	ftt_id bigserial primary key,
	oil_id int,
	train_id int,
	day_date date, 
	store_nbr int 
)

/*Foreign column on the child table has to be indexed, if that column 
 * is going to be used for joining the tables. That is the case with 
 * all the id columns here*/

insert into unref_fact_table(oil_id,train_id,day_date, store_nbr)
select foht.oil_id, tt.id, tt.day_date,tt.store_nbr
FROM train_table tt JOIN stores_table st
on tt.store_nbr = st.store_nbr 
LEFT JOIN full_oil_holiday_table foht
on foht.day_date = tt.day_date
left join transaction_table txt
on txt.txn_date = tt.day_date 
and txt.store_nbr = tt.store_nbr

/*having multiple references to the tables is going to create unncessary */

/*next is to alter the table and add the indexes and reference sequences */

/*Starting to create the Indices on unref_fact_table*/

create index oil_id_idex
on unref_fact_table(oil_id)

create index train_id_idx
on unref_fact_table(train_id)

create index store_nbr_idx
on unref_fact_table(store_nbr)

create index day_date_idx
on unref_fact_table(day_date)


alter table unref_fact_table 
	add foreign key (oil_id)
		references full_oil_holiday_table(oil_id)
		
		
alter table unref_fact_table 
	add foreign key (train_id)
		references train_table(id)

alter table unref_fact_table 
	add foreign key (day_date)
		references date_spine(date_series)

alter table unref_fact_table 
	add foreign key(store_nbr)
		references stores_table(store_nbr)


DROP INDEX unref_fact_table_oil_id_fkey

ALTER TABLE users
    ADD COLUMN last_updated_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP    



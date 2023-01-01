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

select fot.day_date, ht.day_date, ht.holiday_type, ht.holiday_locale,
        ht.holiday_localename,fot.dcoilwtico
from full_oil_table fot join holiday_table ht 
on fot.day_date = ht.day_date


/*table 3: Store numbers*/
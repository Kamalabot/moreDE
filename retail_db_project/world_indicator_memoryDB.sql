/*
 * This script will be modelling the world indicators 
 * taken from the kaggle dataset
 * https://www.kaggle.com/datasets/robertolofaro/selected-indicators-from-world-bank-20002019?select=facttable.csv
 */*/
 
 /*
  * The csv files are uploaded into the memory in duckdb and the 
  * tables are created from there
  */*/
  
  /*
   * After the fact_dimension table is created the same exported using
   * the dbeaver export tool
   */*/
   
   /*
    * Another option is to replicate the entire process through the 
    * csv read method in pyspark. Implement the sql commands 
    * inside spark context and then write out the file to csv
    */*/

-- read a CSV file from disk, auto-infer options
SELECT * FROM 'test.csv';

-- read_csv with custom options

SELECT * FROM read_csv('test.csv', delim='|', header=True, columns={'FlightDate': 'DATE', 'UniqueCarrier': 'VARCHAR', 'OriginCityName': 'VARCHAR', 'DestCityName': 'VARCHAR'});
-- read a CSV from stdin, auto-infer options

cat data/csv/issue2471.csv | duckdb -c "select * from read_csv_auto('/dev/stdin')"

-- read a CSV file into a table
CREATE TABLE ontime(FlightDate DATE, UniqueCarrier VARCHAR, OriginCityName VARCHAR, DestCityName VARCHAR);
COPY ontime FROM 'test.csv' (AUTO_DETECT TRUE);

-- alternatively, create a table without specifying the schema manually

CREATE TABLE ontime AS SELECT * FROM 'test.csv';

-- write the result of a query to a CSV file

COPY (SELECT * FROM ontime) TO 'test.csv' WITH (HEADER 1, DELIMITER '|');    

drop table fact_table

CREATE TABLE fact_table AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/facttable.csv', header=True)

drop table dimension_country 

CREATE TABLE dimension_country AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/dimension_country.csv', header=True)

drop table dim_indicator 

CREATE TABLE dim_indicator AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/dimension_indicator.csv', header=True)    

/*The above commands are executed after the in memory database is connected in dbeaver
Note: if the dbeaver instance is closed the in_memory tables are lost in the database.*/
    
select *
from fact_table ft
limit 5

select *
from dim_indicator 
limit 5

select *
from dimension_country 
limit 5

select ft."2000" , dc."Country Name" , di."Indicator Name" , ft."Country Code" , dc."Country Code" 
from dim_indicator di left outer join fact_table ft 
on ft."Indicator Code" = di."Indicator Code" 
join dimension_country dc 
on ft."Country Code" = dc."Country Code" 

/*check the count of each table to see the realtionship*/

select count(*)
from fact_table ft
limit 5
/*row count >>8778*/

select count(*)
from dim_indicator 
/*row count >>33*/

select count(*)
from dimension_country 
/*row count >>266*/

/*There is one to many relation between fact_table and both indicators 
and countries*/

drop table fact_data 

create table fact_data (
	country_code varchar references dimension_country("Country Code"), 
	indicator_code varchar references dimension_indicator("Indicator Code"), 
	year2021 NUMERIC ,year2020 NUMERIC ,year2019 NUMERIC ,year2018 NUMERIC,
	year2017 NUMERIC ,year2016 NUMERIC ,year2015 NUMERIC ,year2014 NUMERIC,
	year2013 NUMERIC ,year2012 NUMERIC,
	year2011 NUMERIC ,year2010 NUMERIC ,year2009 NUMERIC ,year2008 NUMERIC,
	year2007 NUMERIC ,year2006 NUMERIC ,year2005 NUMERIC ,year2004 NUMERIC,
	year2002 NUMERIC ,year2001 NUMERIC ,year2000 NUMERIC)

/*The above query will fail since the primary and unique option is not implemented 
in the dimension tables */
	
/*alter table not implemented in duck db*/	
alter table fact_data
	add foreign key(country_code)
	references dimension_country("Country Code")

/*duckdb table needs to be created with COPY command since we want the primary keys in the 
dimension tables*/	
	
create table primary_country(country_code varchar primary key unique, 
								country_name varchar)

create table primary_indicator(indicator_code varchar primary key unique,
								indicator_name varchar)
								
COPY primary_country FROM '/run/media/solverbot/repoA/gitFolders/rilldash/dimension_country.csv' (DELIMITER ',', HEADER);

COPY primary_indicator FROM '/run/media/solverbot/repoA/gitFolders/rilldash/dimension_indicator.csv' (DELIMITER ',', HEADER);

COPY primary_indicator FROM '/run/media/solverbot/repoA/gitFolders/M3nD3/ObservableData/dimension_indicator.csv' DELIMITER ',' CSV HEADER;

select *
from primary_country 
limit 5

select *
from primary_indicator 
limit 5

/*stating the main table that contains the facts*/

CREATE TABLE fact_data(country_code varchar references primary_country(country_code), 
	indicator_code varchar references primary_indicator(indicator_code), 
	year2000 NUMERIC ,year2001 NUMERIC ,year2002 NUMERIC ,year2003 NUMERIC,
	year2004 NUMERIC ,year2005 NUMERIC ,year2006 NUMERIC ,year2007 NUMERIC,
	year2008 NUMERIC ,year2009 NUMERIC,
	year2010 NUMERIC ,year2011 NUMERIC ,year2012 NUMERIC ,year2013 NUMERIC,
	year2014 NUMERIC ,year2015 NUMERIC ,year2016 NUMERIC ,year2017 NUMERIC,
	year2018 NUMERIC ,year2019 NUMERIC ,year2020 NUMERIC ,year2021 NUMERIC
	)

COPY fact_data FROM '/run/media/solverbot/repoA/gitFolders/M3nD3/ObservableData/facttable.csv' (DELIMITER ',', HEADER);

COPY fact_data FROM '/run/media/solverbot/repoA/gitFolders/M3nD3/ObservableData/facttable.csv' DELIMITER ',' CSV HEADER;

select count(*)
from fact_data


select fd.country_code, pc.country_name ,fd.indicator_code, pi.indicator_name , fd.year2000
from fact_data fd join primary_country pc 
on fd.country_code = pc.country_code 
join primary_indicator pi
on fd.indicator_code = pi.indicator_code 
limit 5

select pc.country_name ,pi.indicator_name , fd.year2019
from fact_data fd join primary_country pc 
on fd.country_code = pc.country_code 
join primary_indicator pi
on fd.indicator_code = pi.indicator_code 
where fd.indicator_code = 'IC.BUS.DISC.XQ'


select pc.country_name ,pi.indicator_name , fd.year2014
from fact_data fd join primary_country pc 
on fd.country_code = pc.country_code 
join primary_indicator pi
on fd.indicator_code = pi.indicator_code 
where fd.indicator_code = 'EG.USE.ELEC.KH.PC'
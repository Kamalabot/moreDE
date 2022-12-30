CREATE TABLE seasons AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/seasons.csv')

CREATE TABLE actors AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/actors.csv', header=True)

CREATE TABLE apperances AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/appearances.csv')

CREATE TABLE casts AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/casts.csv')

CREATE TABLE characters AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/characters.csv')

CREATE TABLE episodes AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/episodes.csv')

CREATE TABLE hosts AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/hosts.csv')

CREATE TABLE impressions AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/impressions.csv')

CREATE TABLE sketches AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/sketches.csv')

CREATE TABLE tenure AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/tenure.csv')

CREATE TABLE titles AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/titles.csv')


/*Seasons has multiple columns that can be chosen for joining
 * sid, year, first_epid
 * */

select * from seasons 

select count(*) from seasons 

/*46 seasons*/

/*The actor aid can be made primary and unique*/
select * from actors 

select count(*) from actors

/*2306 actors*/

/* Appearances has sid and aid which can join this table on seasons
 * and actors for analysis
 * */
select * from apperances

select count(*) from apperances

create table new_appearences as
select a.aid ,a.tid ,a.capacity ,a."role" ,a.charid::int as charid ,a.impid::int as impid ,a.voice ,a.epid ,a.sid 
from apperances a

/*55,355 appearances*/

select * from casts

select count(*) from casts

/*614 casts*/

select * from "characters" 

select count(*) from "characters" 

/*1099 characters*/

select count(*) from episodes 

/*906 episodes*/

select * from episodes 

/* Some of the functions are not available 
 * in duckDB. 
 * */

select e.sid , e.epid , SUBSTRING(e.aired, '....$')::VARCHAR, 
	e.aired::DATE as date_aired
from episodes e 


/*aid is the key*/
select * from hosts

select count(*) from hosts

select h.aid, h.epid  
from hosts h
where h.aid = 'The Rolling Stones'
/*925 hosts*/

/*There is impid, which could be the key*/
select * from impressions 

select count(*) from impressions

/*What are impressions? 
 * 4,115 impressions
 * */

/*There is skid*/
select * from sketches 

select count(*) from sketches

/*What are sketches?
 * There are 301 of them
 * */

/*There is aid, which seems to be sufficient key*/
select * from tenure 

select count(*) from tenure

/*There are 154 tenures
 * */

select * from titles 

select count(*) from titles 

/*13,704 titles. Seems like a fact table of some sort*/

create table new_titles
as
select t."order" ,t.epid ,t.tid ,t.name ,t.category, t.skid::INT as skid, t.sid 
from titles t

/*How about using the script to migrate the data into postgres snldb database?*/

/*The script cannot read from the :memory: database and write to postgres.. The 
same command has to do it. */



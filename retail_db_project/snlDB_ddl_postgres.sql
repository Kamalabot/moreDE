/*There are many functions yet to be implementend in DuckDB
 * so moving the tables inside the postgres database
 * */

/* Will be using the DDL creation function from the in-memory database
 * and create the tables first
 * */

/*DDL function provides only the column names type. The constraints needs to be 
 * added manually
 * */


DROP TABLE if exists actors;

CREATE TABLE actors (
	aid VARCHAR primary key unique,
	url VARCHAR,
	"type" VARCHAR,
	gender VARCHAR
);

copy actors from '/run/media/solverbot/repoA/gitFolders/rilldash/output/actors.csv' delimiter ',' csv header

select * from actors limit 5
/*The above copy went smoothly*/

/*The Rolling Stones is not present in actors, so adding in*/

insert into actors(aid, url,"type",gender)
values('The Rolling Stones',null,null,'male')

DROP TABLE if exists seasons;

CREATE TABLE seasons (
	sid INTEGER primary key unique,
	"year" INTEGER,
	first_epid INTEGER,
	last_epid INTEGER,
	n_episodes INTEGER
);

copy seasons from '/run/media/solverbot/repoA/gitFolders/rilldash/output/seasons.csv' delimiter ',' csv header

select * from seasons limit 5
/*The above copy went smoothly*/

DROP TABLE if exists casts;

CREATE table casts (
	aid VARCHAR references actors(aid),
	sid INTEGER references seasons(sid),
	featured BOOLEAN,
	first_epid NUMERIC,
	last_epid NUMERIC,
	update_anchor BOOLEAN,
	n_episodes INTEGER,
	season_fraction NUMERIC
);

copy casts from '/run/media/solverbot/repoA/gitFolders/rilldash/output/casts.csv' delimiter ',' csv header

select * from casts limit 5
/*This table refers the seasons and actors table. The above copy went smoothly*/

/*Changing the name from characters to character_details*/
DROP TABLE if exists character_details;

CREATE TABLE character_details (
	charid INTEGER primary key unique,
	aid VARCHAR references actors(aid),
	name VARCHAR
);

copy character_details from '/run/media/solverbot/repoA/gitFolders/rilldash/output/characters.csv' delimiter ',' csv header

select * from character_details order by charid limit 5 
/*This table refers actors table. The above copy went smoothly*/

DROP TABLE if exists episodes;

CREATE TABLE episodes (
	sid INTEGER references seasons(sid),
	epid INTEGER primary key unique,
	aired VARCHAR,
	epno INTEGER
);

copy episodes from '/run/media/solverbot/repoA/gitFolders/rilldash/output/episodes.csv' delimiter ',' csv header

select * from episodes limit 5
/*The copy went smooth, and the table refers sid in seasons*/


DROP table if exists hosts;

CREATE TABLE hosts (
	epid INTEGER references episodes(epid),
	aid VARCHAR references actors(aid)
);

copy hosts from '/run/media/solverbot/repoA/gitFolders/rilldash/output/hosts.csv' delimiter ',' csv header

/*This copy raised the error that rolling stones not present in actors aid*/

select a.aid ,a.gender 
from actors a 
where a.aid ~ 'Rolling Stones'

select count(*)
from actors a 

select * from hosts limit 5

/*the actors The rolling stones was inserted into actors table and then above copy 
went through*/

DROP TABLE if exists impressions;

CREATE TABLE impressions (
	impid INTEGER primary key unique,
	aid VARCHAR references actors(aid),
	name VARCHAR
);

copy impressions from '/run/media/solverbot/repoA/gitFolders/rilldash/output/impressions.csv' delimiter ',' csv header

select * from impressions limit 5
/*The copy went smoothly*/

DROP table if exists sketches cascade;

CREATE TABLE sketches (
	skid INTEGER primary key unique,
	name VARCHAR
);

copy sketches from '/run/media/solverbot/repoA/gitFolders/rilldash/output/sketches.csv' delimiter ',' csv header

select * from sketches limit 5
/*The copy went through smooth*/

DROP TABLE if exists tenure;

CREATE TABLE tenure (
	aid VARCHAR references actors(aid),
	n_episodes INTEGER,
	eps_present INTEGER,
	n_seasons INTEGER
);

copy tenure from '/run/media/solverbot/repoA/gitFolders/rilldash/output/tenure.csv' delimiter ',' csv header

select * from tenure limit 5
/*copy went smooth*/

DROP TABLE if exists titles cascade;

CREATE TABLE titles (
	"order" INTEGER,
	epid INTEGER references episodes(epid),
	tid INTEGER unique primary key,
	name VARCHAR,
	category VARCHAR,
	skid INTEGER references sketches(skid),
	sid INTEGER references seasons(sid)
);

/*The referencing even checks the types of the columns before attaching the constraint*/

copy titles from '/run/media/solverbot/repoA/gitFolders/rilldash/output/new_titles.csv' delimiter ',' csv header


/*titles.csv contains the skid in numeric format, which is not required. Cleaned it 
using the in memory db*/

/*The above copy forced me to work on the datatypes of skid, made me clean the column 
headers using the vim.*/

DROP TABLE if exists apperances;

CREATE TABLE apperances (
	aid VARCHAR references actors(aid),
	tid INTEGER references titles(tid),
	capacity VARCHAR,
	"role" VARCHAR,
	charid integer references character_details(charid),
	impid integer references impressions(impid),
	voice BOOLEAN,
	epid INTEGER references episodes(epid),
	sid INTEGER references seasons(sid)
);

copy apperances from '/run/media/solverbot/repoA/gitFolders/rilldash/output/new_appearences.csv' delimiter ',' csv header

/*the format of charid is wrong, the same is corrected using the casting from inmemory database*/

select * from apperances a limit 5

/*after correcting it the copy went smooth*/


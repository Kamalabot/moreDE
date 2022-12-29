CREATE TABLE seasons AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/seasons.csv')

CREATE TABLE actors AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/actors.csv')

CREATE TABLE apperances AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/appearances.csv')

CREATE TABLE casts AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/casts.csv')

CREATE TABLE characters AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/characters.csv')

CREATE TABLE episodes AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/episodes.csv')

CREATE TABLE hosts AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/hosts.csv')

CREATE TABLE impressions AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/impressions.csv')

CREATE TABLE sketches AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/sketches.csv')

CREATE TABLE tenure AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/tenure.csv')

CREATE TABLE titles AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/output/titles.csv')

CREATE TABLE fact_table AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/facttable.csv')

CREATE TABLE dimension_country AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/dimension_country.csv')

CREATE TABLE dim_indicator AS SELECT * FROM read_csv_auto('/run/media/solverbot/repoA/gitFolders/rilldash/dimension_indicator.csv')



select * from seasons 

select count(*) from seasons 

select * from actors 

select count(*) from actors

select * from apperances 

select count(*) from apperances 

select * from casts

select count(*) from casts 

select * from "characters" 

select count(*) from "characters" 

select count(*) from episodes 

select * from episodes 

select * from hosts

select count(*) from hosts

select * from impressions 

select count(*) from impressions 

select * from sketches 

select count(*) from sketches 

select * from tenure 

select count(*) from tenure 

select * from titles 

select count(*) from titles 





































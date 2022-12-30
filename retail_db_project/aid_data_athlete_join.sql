/*Trying the join between aid_data and athletes data in same database*/

/*starting with the aid_data table*/

select ad.year, ad.donor ,ad.recipient , ad.commitment_amount_usd_constant,
	ad.coalesced_purpose_code , ad.coalesced_purpose_name 
from aid_data ad
limit 5

/*The country names in aid data is full names*/


select a.nationality , a.height , a.id , a.info 
from athletes a 

/*while the nationality in athletes is abbreviations. Need the table that contains the expansions
 * Bringing in the world indicator data that I have in another script.*/

create table primary_country(country_code varchar primary key unique, 
								country_name varchar)
								
COPY primary_country FROM '/run/media/solverbot/repoA/gitFolders/rilldash/dimension_country.csv' DELIMITER ',' CSV HEADER;

with first_tables as(
select pc.country_code , a.nationality , a."name" , pc.country_name 
from primary_country pc join athletes a 
on pc.country_code = a.nationality 
)
,
second_table as (select ad.donor , pc.country_code , pc.country_name 
from aid_data ad join primary_country pc 
on pc.country_name = ad.donor)
select distinct tt.country_code, st.donor,tt.name
from first_tables tt join second_table st
on tt.country_code = st.country_code






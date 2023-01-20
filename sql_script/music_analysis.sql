/*This script is the out of the playbook execution. 
 * It analyses the music usage file shared by someone 
 */*/
 
 create table if not exists music_analysis(
 	Datetime timestamp ,
 	listener_Age numeric,
 	Primary_Service Varchar,
 	hours_listening_pday numeric,
 	While_working boolean,
 	Instrumentalist boolean,
 	Composer boolean,
 	Fav_genre varchar,
 	Exploratory boolean,
 	Foreignlanguages boolean,
 	BPM numeric,
 	FrequencyClassical varchar,
 	FrequencyCountry varchar,
 	FrequencyEDM varchar,
 	FrequencyFolk varchar,
 	FrequencyGospel varchar,
 	FrequencyHip_hop varchar,
 	FrequencyJazz varchar,
 	FrequencyKpop varchar,
 	FrequencyLatin varchar,
 	FrequencyLofi varchar,
 	FrequencyMetal varchar,
 	FrequencyPop varchar,
 	FrequencyRnB varchar,
 	FrequencyRap varchar,
 	FrequencyRock varchar,
 	FrequencyVideo_game_music varchar,
 	Anxiety numeric,
 	Depression numeric,
 	Insomnia numeric,
 	OCD numeric,
 	Musiceffects varchar,
 	Permissions varchar
 )

 
 
 
 
 
 
 
 
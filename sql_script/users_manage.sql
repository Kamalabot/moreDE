drop sequence if exists user_table_user_id_seq

select * from information_schema.columns
where table_name ='user_table'

select column_name ,
character_maximum_length, is_nullable ,column_default 
from information_schema.columns 
where table_name = 'user_table'

alter table user_table 
add column new_time TIMESTAMP default current_timestamp

select first_name ,new_time
from user_table ut 

alter table user_table 
alter column created_dt date notnull  

create sequence  user_table_trial_seq

select nextval('user_table_trial_seq')
from user_table ut 

alter table user_table 
alter column user_id set default nextval('user_table_trial_seq')

select * from user_table ut 

alter table user_table 
	alter column user_role set
data type character (1)

alter table user_table 
	alter column user_role set
default 'U'
	
select
	*
from
	information_schema."views" v 

/*This is how you comment eh???*/
		
select
	table_catalog ,
	table_schema ,
	constraint_type ,
	table_name,
	constraint_name 
from
	information_schema.table_constraints tc
where 
table_name = 'user_table'

alter table user_table 
	add constraint users_pk primary key (user_id)
/*The above command will error out as there are multiple p-keys*/		
	
drop sequence user_table_user_id_seq
/*Since the user_id has a different sequence attached, this get dropped*/
	
drop sequence user_table_trial_seq
/*This will raise error, since the user_table depends on it*/

alter table user_table 
	drop 
	
create table user_logins(
	user_login_id serial primary key,
	user_id INTEGER not null,
	user_login_time TIMESTAMP default current_timestamp
)
/*The user_logins table need foriegn key and child key that 
 * will be added next*/
/*Each of the constraint will be listed int the table_constraints*/

select * from user_logins

select table_catalog, table_name, constraint_type, constraint_name
from information_schema.table_constraints tc 
where table_name ='user_logins'
/*The above query will show the names of the constraint. Use that drop*/

alter table user_logins drop constraint user_logins_pkey

select
	table_catalog,
	table_name,
	constraint_type,
	constraint_name
from
	information_schema.table_constraints tc
where
	table_name = 'user_logins'


alter table user_logins add primary key (user_login_id)
/*The primary key naming convention is column name + _pkey*/

select
	table_catalog,
	table_name,
	constraint_type,
	constraint_name
from
	information_schema.table_constraints tc
where
	table_name = 'user_logins'

alter table user_logins add unique (user_id)
	
alter table user_logins add unique (user_login_time)
	
alter table user_logins
	alter column user_id set not null, 
	alter column user_login_time set not null, 
	alter column user_login_id set not null

alter table user_logins 
	add foreign key (user_id)
	references user_table(user_id)
	
/*Foreign key takes the reference of the primary key*/
select table_name , constraint_name 
	from information_schema.table_constraints tc 
	where table_name ='user_logins'
	
drop table user_table
/*The table will not drop, since the user_logins table refer to it through 
 * foreign key relationship.*/

drop table if exists user_logins

select * from pg_catalog.pg_indexes pi2 
where schemaname  ='public'
and tablename ='user_table'

select
	tc.table_catalog ,
	tc.table_name ,
	tc.constraint_name ,
	pi2.indexname,
	pi2.indexdef
from
	information_schema.table_constraints tc
join pg_catalog.pg_indexes pi2 
on
	tc.constraint_name = pi2.indexname
where
	tc.table_schema = 'public'
	and tc.table_name = 'user_table'
	and tc.constraint_type = 'PRIMARY KEY'

select * from user_table ut 	
	
alter table user_table 
	add unique (email)

/*multiple unique constraints can keep on adding.*/
	
alter table user_table drop constraint user_table_email_key

alter table user_table drop constraint user_table_email_key1
	
select tc.constraint_name ,  tc.table_name , pi2.indexname 
from information_schema.table_constraints tc join pg_catalog.pg_indexes pi2 
on tc.constraint_name = pi2.indexname 
where tc.table_name ='user_table'


select tc.table_name , tc.constraint_name, tc.constraint_type  
from information_schema.table_constraints tc join pg_catalog.pg_indexes pi2 
on tc.constraint_name = pi2.indexname 
where tc.table_catalog  = 'users'
and tc.constraint_type in ('PRIMARY KEY','UNIQUE')

drop index user_table_email_key2
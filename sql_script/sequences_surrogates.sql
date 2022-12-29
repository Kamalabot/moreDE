/*Surrogate keys are columns created without any business relation
 * but there to provide support for indexing and joining tables
 */*/
 
 /*These surrogate keys are created with help of sequences */
 
 /*SERIAL is the keyword for creating the sequence during table creation
  * INCREMENT BY
  * START WITH
  * RESTRAT WITH
  * MINVALUE
  * MAXVALUE
  * CACHE
  */*/
  
  /*Important functions are nextval and currval*/
  
drop sequence if exists test_seq
  

create sequence test_seq
 start with 101
 minvalue 101
 maxvalue 1000
 increment by 100
 
select s.sequence_catalog , s.sequence_name,
s.data_type , s.numeric_scale , s."increment" 
from information_schema."sequences" s  

select nextval('test_seq')

select currval('test_seq')
 
select nextval('test_seq')

select nextval('test_seq')

select currval('test_seq')

select nextval('test_seq')

alter sequence test_seq
increment by 1
restart with 101

select s.sequence_name , s.sequence_schema , s.start_value , s."increment" 
from information_schema."sequences" s 

select t.table_catalog , t.table_name , t.table_type 
from information_schema."tables" t 

create table users(
	user_id serial primary key,
	user_firstname varchar(30) not null,
	user_lastname varchar(30) not null,
	user_mail varchar(150) not null,
	mail_validate boolean default false, 
	user_password varchar(200),
	user_role varchar(1),
	is_active boolean default false,
	created_dt date default current_date
)

select * from information_schema."sequences" s 
/*Will see two sequences in the */


drop sequence users_user_id_seq cascade /*The table will be still there*/

select * from users

create sequence users_user_id_seq
	start with 57
	minvalue 1

/*This is will alter the sequence and attach it to users table*/
alter sequence users_user_id_seq 
owned by users.user_id

alter table users
	alter column user_id
	set default nextval('users_user_id_seq') 

insert into users(user_firstname, user_lastname, user_mail)
values('Matt','Moon','att.mooner.com')

/*This will get the index to start at 57 */
	
select currval('users_user_id_seq')	

/*Starting to discuss the truncate table*/

create table user_logins(
	user_login_id serial primary key, 
	user_id integer,
	user_login_ts timestamp default current_timestamp,
	user_ip VARCHAR(20)
)

alter table user_logins 
	add foreign key (user_login_id)
	references users(user_id)
	
truncate table users
/*cannot truncate users, due to the foreign key reference*/

insert into users(user_firstname, user_lastname, user_mail)
VALUES ('Donald', 'Duck', 'donald@duck.com')

INSERT INTO users 
    (user_firstname, user_lastname, user_mail, user_password, user_role, is_active) 
VALUES 
    ('Gordan', 'Bradock', 'gbradock0@barnesandnoble.com', 'h9LAz7p7ub', 'U', true),
    ('Tobe', 'Lyness', 'tlyness1@paginegialle.it', 'oEofndp', 'U', true),
    ('Addie', 'Mesias', 'amesias2@twitpic.com', 'ih7Y69u56', 'U', true)

select * from users

insert into user_logins (user_id)
values (1),(2),(3),(4)
/*This is throwing error since user_id is linked with users.user_id*/






	
	
	
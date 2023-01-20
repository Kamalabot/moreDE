/*This is script working on RDS instance in AWS*/

create table new_user(
	id_user int primary key unique,
	name_first varchar,
	experience numeric 
)


insert into new_user(id_user,name_first,experience)
values(1,'hive', 25),
(2,'spark',15),
(3,'hue',57)

select *
from new_user

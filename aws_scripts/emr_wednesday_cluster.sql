CREATE EXTERNAL TABLE external_user_tbl
(
	userid string,
	age bigint,
	income bigint,
	name string
)
stored by 'org.apache.hadoop.hive.dynamodb.DynamoDBStorageHandler'
tblproperties(
	"dynamodb.table.name"="Users",
	"dynamodb.column.mapping"="userid:userid,age:age,income:income,name:name"
)

SELECT * FROM external_user_tbl

CREATE DATABASE localhivedb;

create table localhivedb.local_table(id int, name string)
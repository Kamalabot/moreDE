import psycopg2

host = 'my-postgres-lab.coc5gkht2i7a.us-east-1.rds.amazonaws.com'
dbname = 'dvdrental'
user = 'postgres'
password = 'pass1234'
port = 3306

dvdConn = psycopg2.connect(host=host,dbname=dbname, user=user, password=password,port=port)

def lambda_handler(event, context):
	cursor = dvdConn.cursor()
	query = """SELECT * FROM actor LIMIT 5"""
	
	cursor.execute(query)
	rows = cursor.fetchall()
	print(rows)


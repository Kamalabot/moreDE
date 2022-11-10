import boto3

def lambda_handler(event, context):
	client = boto3.resource('dynamodb')
	table = client.Table('YOUR TABLE NAME')

	# S, N, M, L, B, SS, NS
	input = {'TransactionId': '31', 'State': 'PENDING',
	'RelatedTransactions': [32, 33, 34],
	'CustomerDetails': { 'Name': 'John Doe', 'AccountBalance': 50}}

	response = table.put_item(Item=input)

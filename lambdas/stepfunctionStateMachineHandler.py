import json
import boto3
import uuid

client = boto3.client('stepfunctions')

def lambda_handler(event, context):
	#INPUT -> { "TransactionId": "foo", "Type": "PURCHASE"}
	transactionId = str(uuid.uuid1()) #90a0fce-sfhj45-fdsfsjh4-f23f

	input = {'TransactionId': transactionId, 'Type': 'PURCHASE'}

	response = client.start_execution(
		stateMachineArn='YOUR ARN HERE!',
		name=transactionId,
		input=json.dumps(input)	
		)

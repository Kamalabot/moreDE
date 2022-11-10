import json

print('Loading Function')

def lambda_handler(event, context):
	#parse the query that is coming from the gateway
	txnId = event['queryStringParameters']['transactionId']
	txnType = event['queryStringParameters']['type']
	txnAmount = event['queryStringParameters']['amount']
	
	print(txnId, txnType, txnAmount)
	
	#construct response body
	txnResp = {}
	txnResp['txnId'] = txnId
	txnResp['type'] = txnType
	txnResp['amount'] = txnAmount
	txnResp['message'] = 'Hello from the other side.'
	
	#construct http response
	respObj = {}
	respObj['statusCode'] = 200
	respObj['headers'] = {}
	respObj['headers']['Content-Type'] = 'application/json'
	respObj['body'] = json.dumps(txnResp) 
	
	#return the response obj
	return respObj

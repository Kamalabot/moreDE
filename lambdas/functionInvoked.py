import json
import uuid

def lambda_handler(event, context):
    customer = event['CustomerId']#This is coming from the argument
    txnId = str(uuid.uuid1())
    return {'CustomerId': customer,'success':'true','txnId':txnId}

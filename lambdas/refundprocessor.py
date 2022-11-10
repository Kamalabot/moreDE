from __future__ import print_function

import json
import urllib
import boto3
import datetime

print('Loading message function...')

def process_refund(message, context):

    #1. Log input message
    print('Received message from Step Function:')
    print(message)
    
    #2. Construct response
    response = {}
    response['TransactionType'] = message['TransactionType']
    response['Timestamp'] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    response['Message'] = 'Hello from Refund Processor!'
    
    #3. Return response
    print(response)
    
    return (response)
@Kamalabot


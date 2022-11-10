import json
import boto3

client = boto3.client('lambda') #Need to research about this object

def lambda_handler(event, context):
    inputForInvoker = {"CustomerId":123,"Amount":578}
    
    response = client.invoke(
        FunctionName = "arn:aws:lambda:us-east-1:642924624251:function:lambda2Invoke",
        InvocationType = 'RequestResponse',
        Payload = json.dumps(inputForInvoker)
        )
    
    responseJson = json.load(response['Payload'])
    
    print('\n')
    print(f'This is {responseJson} json')
    print('\n')

import json
import boto3
import os

ssm = boto3.client('ssm')

def lambda_handler(event, context):
    param_name = os.environ.get("DYNAMIC_PARAM")
    value = ssm.get_parameter(Name=param_name)['Parameter']['Value']

    html = f"""
    <html>
    <head><title>Dynamic HTML</title></head>
    <body>
      <h1>The saved string is {value}</h1>
    </body>
    </html>
    """

    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'text/html'},
        'body': html
    }

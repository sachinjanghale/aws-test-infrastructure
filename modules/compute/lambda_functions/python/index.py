import json
import os

def lambda_handler(event, context):
    project_name = os.environ.get('PROJECT_NAME', 'unknown')
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Hello from {project_name} Python Lambda!',
            'event': event
        })
    }

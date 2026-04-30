import json
import os

def lambda_handler(event, context):
    project_name = os.environ.get('PROJECT_NAME', 'unknown')
    db_secret_arn = os.environ.get('DB_SECRET_ARN', '')
    rds_endpoint = os.environ.get('RDS_ENDPOINT', '')
    dynamodb_table = os.environ.get('DYNAMODB_TABLE', '')
    s3_bucket = os.environ.get('S3_BUCKET', '')

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Hello from {project_name} Python Lambda!',
            'runtime': 'python3.11',
            'network': 'vpc',
            'config': {
                'has_db_secret': bool(db_secret_arn),
                'has_rds': bool(rds_endpoint),
                'dynamodb_table': dynamodb_table,
                's3_bucket': s3_bucket
            },
            'event': event
        })
    }

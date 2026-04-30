def format_response(status_code, body):
    return {
        'statusCode': status_code,
        'body': body,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }


def get_env_config():
    import os
    return {
        'project_name': os.environ.get('PROJECT_NAME', 'unknown'),
        'environment': os.environ.get('ENVIRONMENT', 'test'),
        'db_secret_arn': os.environ.get('DB_SECRET_ARN', ''),
        'rds_endpoint': os.environ.get('RDS_ENDPOINT', ''),
        'dynamodb_table': os.environ.get('DYNAMODB_TABLE', ''),
        's3_bucket': os.environ.get('S3_BUCKET', '')
    }

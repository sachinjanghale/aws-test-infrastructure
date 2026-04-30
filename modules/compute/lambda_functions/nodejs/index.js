exports.handler = async (event) => {
    const projectName = process.env.PROJECT_NAME || 'unknown';
    const apiKeysSecretArn = process.env.API_KEYS_SECRET_ARN || '';
    const dynamodbTable = process.env.DYNAMODB_TABLE || '';
    const s3Bucket = process.env.S3_BUCKET || '';

    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
            message: `Hello from ${projectName} Node.js Lambda!`,
            runtime: 'nodejs20.x',
            network: 'public',
            integration: 'api-gateway',
            config: {
                hasApiKeys: Boolean(apiKeysSecretArn),
                dynamodbTable,
                s3Bucket
            },
            event
        })
    };
};

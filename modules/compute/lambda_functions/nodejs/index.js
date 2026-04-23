exports.handler = async (event) => {
    const projectName = process.env.PROJECT_NAME || 'unknown';
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: `Hello from ${projectName} Node.js Lambda!`,
            event: event
        })
    };
};

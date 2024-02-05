import { InvokeCommand, LambdaClient } from '@aws-sdk/client-lambda';

async function fireInternalLambda(functionName, payload) {

    console.log("internal lambda function called - " + functionName + ", with payload");

    console.log(payload);

    const client = new LambdaClient({});

    const command = new InvokeCommand({
        FunctionName: functionName,
        Payload: JSON.stringify(payload),
    });

    const response = await client.send(command);

    console.log("response payload");

    console.log(response);

    return response;

}

export { fireInternalLambda }
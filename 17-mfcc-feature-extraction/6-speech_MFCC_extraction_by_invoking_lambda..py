import boto3
import json

client = boto3.client('lambda')
print("Processing...")

response = client.invoke(
    FunctionName='ExtractMFCCLambda',
    InvocationType='RequestResponse',
    Payload=json.dumps({
        "Records": [
            {
                "s3": {
                    "bucket": {"name": "knodax-feature-engineering"},
                    "object": {"key": "input/TranscribeDemo.wav"}
                }
            }
        ]
    })
)

print("Processing completed successfully.")
print(response['Payload'].read().decode())

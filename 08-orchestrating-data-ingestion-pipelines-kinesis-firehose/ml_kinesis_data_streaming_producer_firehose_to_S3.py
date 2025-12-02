import boto3
import json
import time
import random

for i in range(10):
    record = {
        "event_id": i,
        "timestamp": time.time(),
        "value": random.randint(1, 100)
    }

    firehose_client = boto3.client('firehose')
    firehose_client.put_record(
        DeliveryStreamName='StreamToS3',
        Record={'Data': json.dumps(record) + '\n'}
    )

    print(f"Uploaded to S3: {record}")
    time.sleep(1)

import boto3
import json
import time
import random

client = boto3.client('kinesis')

for i in range(10):
    record = {
        "event_id": i,
        "timestamp": time.time(),
        "value": random.randint(1, 100)
    }
    response = client.put_record(
        StreamName='ml-streaming-input',
        Data=json.dumps(record),
        PartitionKey="partitionKey"
    )
    print(response)

time.sleep(1)

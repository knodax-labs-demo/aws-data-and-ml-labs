# **Hands-on Lab: Understanding Streaming Data Jobs with Kinesis Data Streams**

## **Objective**

This hands-on lab introduces real-time data ingestion using **Amazon Kinesis Data Streams**. You will create a stream, deploy a Python producer to push event records, and observe or consume the data.

🎥 **YouTube Tutorial:**  
https://youtu.be/YcyxTY1Ofek
---

> ⚠️ **AWS Cost Warning**
>
> Kinesis Data Streams is **not Free Tier** and can incur charges if the stream remains active.
>
> To minimize costs:
>
> * **Delete the Kinesis Stream** immediately after the lab.
> * Avoid creating more than 1 shard.
> * Stop producer/consumer scripts when not needed.
> * Set an **AWS Budget** ($1–$5).
>
> Always delete Kinesis resources when done.

---

## **Step 2: Deploy a Real-Time Streaming Data Producer Using Amazon Kinesis Data Streams**

---

### **2.1 Create a Kinesis Data Stream**

1. Go to **Kinesis Console → Data Streams → Create data stream**
2. Name it: `ml-streaming-input`
3. Choose:

   * **Capacity mode: Provisioned**
   * **Provisioned shards: 1**

---

### **2.2 Simulate a Real-Time Producer (Python + Boto3)**

This script sends 10 random events into the stream.

```python
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
```

---

### **2.3 Monitor Stream Data**

You can view incoming records using:

* **Kinesis Console → Data Viewer**, or
* A **consumer script** (below)

---

### **Consumer Python Example**

```python
import boto3
import base64

client = boto3.client('kinesis', region_name='us-east-1')

stream_name = 'ml-streaming-input'
shard_id = client.describe_stream(StreamName=stream_name)['StreamDescription']['Shards'][0]['ShardId']

shard_iter = client.get_shard_iterator(
    StreamName=stream_name,
    ShardId=shard_id,
    ShardIteratorType='TRIM_HORIZON'
)['ShardIterator']

response = client.get_records(ShardIterator=shard_iter, Limit=10)
for record in response['Records']:
    print(record['Data'].decode('utf-8'))
```

---

## **Summary**

| Task           | Outcome                                 |
| -------------- | --------------------------------------- |
| Kinesis Stream | Created provisioned 1-shard data stream |
| Producer       | Sent random JSON events in real time    |
| Consumer       | Pulled and decoded records from stream  |


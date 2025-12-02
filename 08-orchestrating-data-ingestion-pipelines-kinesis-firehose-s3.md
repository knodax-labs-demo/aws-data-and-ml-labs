# **Hands-on Lab: Orchestrating Data Ingestion Pipelines**

## **Objective**

This lab demonstrates how to orchestrate a complete **data ingestion pipeline** using AWS streaming and delivery services.
You will:

* Create a **Kinesis Data Stream**
* Build a **Python producer** to publish real-time events
* Configure a **Kinesis Data Firehose** delivery stream
* Deliver the streaming data into **Amazon S3**
* Understand Firehose buffering behavior for real-time ML ingestion workflows

These steps give you hands-on experience with **streaming ingestion + delivery orchestration**, both essential for production ML pipelines.

---

🎥 YouTube Tutorial:
https://youtu.be/11GLROw3bEQ

--

📁 **Source Code and Data:**  
https://github.com/knodax-labs-demo/aws-data-and-ml-labs/tree/main/08-orchestrating-data-ingestion-pipelines-kinesis-firehose

---

> ⚠️ **AWS Cost Warning**
>
> This lab uses **Amazon Kinesis Data Streams**, **Kinesis Data Firehose**, and **Amazon S3**, which **are not fully Free Tier–eligible**.
>
> To minimize costs:
>
> * Delete the **Kinesis Data Stream** after testing.
> * Delete the **Kinesis Firehose** delivery stream after use.
> * Remove S3 objects created by Firehose.
> * Do not increase the shard count beyond 1.
> * Set an **AWS Budget** ($1–$5 recommended) with email alerts.
>
> Always clean up ingestion services after finishing the exercise.

---

# **Step 1: Create a Kinesis Data Stream and Publish Sample Records**

---

## **1.1 Create a Kinesis Data Stream**

1. Go to **Amazon Kinesis Console → Data Streams**
2. Click **Create data stream**
3. Stream name:

   ```
   ml-streaming-input
   ```
4. Choose:

   * **Capacity mode:** Provisioned
   * **Shard count:** 1
5. Click **Create data stream**

---

## **1.2 Write a Python Producer to Publish Real-Time Records**

Use this script to send 10 sample events into your Kinesis Data Stream.

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

### **Verify Delivery**

* Go to your Kinesis stream → **Data Viewer**
* Check that records appear

---

# **Step 2: Configure a Kinesis Data Firehose Delivery Stream to Amazon S3**

---

## **2.1 Create the Firehose Delivery Stream**

1. Go to **Kinesis Data Firehose**
2. Click **Create delivery stream**
3. Enter name:

   ```
   ml-firehose-delivery-stream
   ```
4. Choose:

   * **Source:** *Amazon Kinesis Data Stream*
   * Select your stream: `ml-streaming-input`
5. **Destination:** Amazon S3
6. Select or create a bucket:

   ```
   ml-ingestion-bucket
   ```
7. Leave all remaining settings at defaults
8. Click **Create Firehose stream**

---

## 🔎 **Understanding Firehose Buffering (Very Important)**

When Firehose reads from a Kinesis Data Stream:

* It **buffers incoming data**
* Delivers to S3 when **either** condition is met:

| Condition           | Default Value           |
| ------------------- | ----------------------- |
| **Buffer Size**     | 5 MB                    |
| **Buffer Interval** | 300 seconds (5 minutes) |

Adjustable ranges:

* **Buffer size:** 1 MB → 128 MB
* **Buffer interval:** 60 sec → 900 sec

Once a condition is met:

> Firehose writes the batch of records into S3.

This explains why delivery may take **up to 5 minutes by default**.

---

## **2.2 (Optional) Update Producer to Send Directly to Firehose**

Use this alternative script only if Firehose is configured with **Direct PUT** as the source.

```python
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
```

### **Delivery Timing**

Allow **up to 5 minutes** for S3 delivery to appear based on Firehose buffering configuration.

---

# **Summary**

| Task                | Outcome                                                         |
| ------------------- | --------------------------------------------------------------- |
| Kinesis Data Stream | Real-time ingestion source created                              |
| Python Producer     | Published streaming event records                               |
| Firehose Stream     | Buffered + delivered data to Amazon S3                          |
| S3 Bucket           | Receives JSON batches every ~5 min (default buffering)          |
| Tools Used          | Kinesis Data Streams, Kinesis Firehose, Amazon S3, Python/Boto3 |



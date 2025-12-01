
# **Hands-on Lab: Scheduling and Automating Jobs**

## **Objective**

This lab teaches you how to automate data workflows using:

* **AWS Glue Workflows** for scheduling and chaining batch data jobs
* **Amazon EventBridge** rules to trigger streaming or ingestion jobs in real time
* **Amazon CloudWatch** to monitor ingestion pipelines, track failures, and create alerts

By the end of this lab, you'll orchestrate batch and streaming pipelines and configure automated monitoring for production-grade ML workflows.

---


---

> ⚠️ **AWS Cost Warning**
>
> This hands-on lab uses **AWS Glue**, **EventBridge**, **Lambda (optional)**, and **CloudWatch Alarms**, all of which may incur charges depending on usage.
>
> To minimize costs:
>
> * Delete **Glue Workflows**, **triggers**, and **jobs** after testing
> * Remove **EventBridge rules** if they’re no longer required
> * Delete **CloudWatch alarms** and old log groups
> * Keep Glue job runs short and avoid continuous triggers
> * Set an **AWS Budget** ($1–$5 recommended) with alert notifications
>
> Always clean up orchestration and monitoring resources once the lab is complete.

---

# **Step 1: Create an AWS Glue Workflow to Schedule Batch Jobs**

---

## **1.1 Prepare Your Glue Job**

1. Go to **AWS Glue Console → ETL Jobs → Create job**
2. Add a job that:

   * Reads from an S3 source
   * Processes or transforms data
   * Writes results to another S3 bucket or database
3. Ensure the Glue execution role has:

   * `s3:GetObject`
   * `s3:PutObject`
   * Access to both input/output S3 buckets
4. Save and run the job to verify it works

---

## **1.2 Create a Glue Workflow**

1. Go to **AWS Glue → Workflows**
2. Click **Add workflow**
3. Name it:

   ```
   DailyBatchWorkflow
   ```
4. Click **Create**

---

## **1.3 Add Job Triggers**

1. Open your workflow
2. Click **Add trigger**
3. Choose **Add new**
4. Configure:

   * **Trigger name:**

     ```
     DailyBatchWorkflowJobTrigger
     ```
   * **Trigger type:** Scheduled
   * **Frequency:** Daily
   * **Time:** 1 AM (example)
5. Add your Glue job as the trigger target
6. Save the trigger

---

## **1.4 Visualize and Run**

1. Use the visual workflow editor to review dependencies
2. Click **Save**
3. Click **Run workflow** to test end-to-end execution

---

# **Step 2: Set Up EventBridge Rules to Trigger Streaming Pipelines**

---

## **2.1 Choose the Trigger Source**

Example ingestion-triggering event:

* A new file uploaded to an S3 bucket
* A Glue job state change
* A Kinesis Data Stream event
* A scheduled CRON trigger

---

## **2.2 Create an EventBridge Rule**

1. Open **Amazon EventBridge Console**
2. Click **Create rule**
3. Name it:

   ```
   TriggerKinesisStream
   ```
4. **Rule type:** Rule with an event pattern
5. Event source settings:

   * AWS services
   * Service: **Amazon S3**
   * Event Type: **Object Created**
   * Event Subtype: Specific events → `Object Created`

Click **Next**

---

## **2.3 Configure Target Action**

You may choose:

* **Kinesis Data Stream**
* **Kinesis Firehose**
* **Lambda function**
* **Glue Job or Workflow Trigger**

Example target name:

```
KinesisDataStreamToIngestS3EventNotification
```

If using Lambda, write a simple handler that forwards S3 event data into Kinesis.

---

## **2.4 Permissions**

EventBridge must have permission to invoke the target:

* EventBridge → Lambda: require resource-based permissions
* EventBridge → Glue: requires Glue privilege in IAM
* EventBridge → Kinesis: requires `kinesis:PutRecord` or `PutRecords`

---

# **Step 3: Use CloudWatch to Monitor Jobs and Configure Alarms**

---

## **3.1 Open CloudWatch Logs**

1. Go to **CloudWatch Console → Logs → Log groups**
2. Review logs such as:

   * `/aws-glue/crawlers/`
   * `/aws-glue/jobs/`
   * `/aws/kinesis-analytics/`

---

## **3.2 Create a CloudWatch Alarm**

1. Go to **Alarms → All alarms → Create alarm**
2. Choose metrics:

   * **Glue job FailedRuns**
   * **Kinesis GetRecords.Errors**
   * **Lambda Errors** (optional)

### **Threshold Example**

*"Trigger an alarm if more than 1 Glue job failure occurs within 5 minutes."*

Set:

* **Metric:** `glue.failed.ALL`
* **Statistic:** `Sum`
* **Period:** `5 minutes`
* **Condition:** `Greater than 1`

---

## **3.3 Configure Alarm Actions**

Choose actions:

* Send an SNS email or SMS
* Trigger Lambda for automated remediation
* Invoke EventBridge rules
* Notify Slack (via webhook)

---

## **3.4 Enable Notifications**

* Subscribe to the SNS topic
* Confirm email subscription
* Verify alarm state changes

---

# **Summary Table**

| Step  | Tool        | Action                                   |
| ----- | ----------- | ---------------------------------------- |
| **1** | AWS Glue    | Create workflow and scheduled batch jobs |
| **2** | EventBridge | Trigger streaming pipelines on events    |
| **3** | CloudWatch  | Monitor job failures and set alarms      |


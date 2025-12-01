# **1.3.5 Lab: Designing Secure and Accessible Data Repositories**

## **Objective**

This lab focuses on building secure, access-controlled, encrypted, and cost-optimized **Amazon S3 repositories** suitable for machine learning data storage.

You will:

* Apply an IAM policy granting **read/write** access to an S3 bucket
* Enable **server-side encryption (SSE-S3)**
* Configure **bucket versioning**
* Add **lifecycle rules** to transition objects to **Glacier Instant Retrieval**
* Review **Cost Explorer** to analyze storage class trends and optimize costs

---

> ⚠️ **AWS Cost Warning**
>
> This lab uses **Amazon S3**, **IAM**, and **Cost Explorer**.
> While most steps remain within the Free Tier, storing multiple S3 object versions or transitioning data to Glacier may incur charges.
>
> To minimize costs:
>
> * Delete test objects and unused versions after completing the lab.
> * Remove lifecycle rules if you no longer need them.
> * Set an **AWS Budget** ($1–$5 recommended) to monitor costs.
>
> Always clean up S3 objects, test buckets, and configurations after the exercise.

---

## **Step 1: Apply IAM Policies Granting Read/Write Permissions on the S3 Bucket**

### **1.1 Navigate to IAM Console**

👉 [https://console.aws.amazon.com/iam](https://console.aws.amazon.com/iam)

### **1.2 Create IAM Policy**

* Go to **Policies → Create Policy**
* Select **JSON** tab
* Paste the following policy
* Replace **your-bucket-name** before saving:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::your-bucket-name",
        "arn:aws:s3:::your-bucket-name/*"
      ]
    }
  ]
}
```

### **1.3 Create and Attach Policy**

* Click **Next**
* Name the policy: **S3ReadWritePolicy**
* Create policy
* Go to **Users → [YourUser] → Add permissions**
* Attach the new policy

---

## **Step 2: Enable Server-Side Encryption (SSE-S3)**

### **2.1 Navigate to the S3 Bucket**

* Open **Amazon S3 Console**
* Choose your bucket

### **2.2 Enable Default Encryption**

* Go to **Properties → Default encryption → Edit**
* Choose:

  * **Enable**
  * **SSE-S3 (Amazon S3-managed keys)**
* Click **Save changes**

All new objects uploaded to the bucket will now be encrypted automatically.

---

## **Step 3: Configure Bucket Versioning and Lifecycle Transition to Glacier**

### **3.1 Enable Bucket Versioning**

* Go to **Properties → Bucket versioning → Edit**
* Choose **Enable**
* Click **Save changes**

This preserves object history and supports rollback during ML development.

---

### **3.2 Configure Lifecycle Rule**

* Go to **Management → Lifecycle rules → Create lifecycle rule**
* Rule name: **TransitionToGlacier**
* Apply to:

  * **All objects**, or
  * **Prefix/tag filters** (optional)

### **3.3 Add Transition Action**

* Under **Transitions**, add:

  * Transition **current object version** to **Glacier Instant Retrieval**
  * After **30 days**

(Optional) Add expiration rules to automatically delete older versions.

Click **Create rule**

---

## **Step 4: Review S3 Cost Optimization in Cost Explorer**

### **4.1 Navigate to Cost Explorer**

👉 [https://console.aws.amazon.com/cost-reports](https://console.aws.amazon.com/cost-reports)

### **4.2 Analyze S3 Costs**

* Choose **Service → Amazon Simple Storage Service**
* Filter by:

  * Region (optional)
  * Account (optional)
* Review S3 usage across:

  * Standard
  * Standard-IA
  * Glacier
  * Versioned objects

Identify potential long-term cost optimization opportunities.

---

## **Summary**

| Task                | Outcome                                         |
| ------------------- | ----------------------------------------------- |
| **IAM Access**      | Read/Write permissions applied to bucket        |
| **Encryption**      | SSE-S3 enforced for all new objects             |
| **Versioning**      | Object history retained                         |
| **Lifecycle Rules** | Data transitions to Glacier after 30 days       |
| **Cost Review**     | Visibility into long-term storage cost patterns |





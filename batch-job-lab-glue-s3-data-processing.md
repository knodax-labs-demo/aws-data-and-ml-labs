

# **Hands-on Lab: Understanding Batch Data Jobs with AWS Glue**

## **Objective**

This hands-on lab walks you through building a **batch data processing job** using **Amazon S3** and **AWS Glue**. You will upload sample data to S3, catalog it using a Glue crawler, and run a Glue ETL job that transforms the data and writes it back to S3 in Parquet format.

---

> ⚠️ **AWS Cost Warning**
>
> This lab uses **Amazon S3**, **AWS Glue Crawlers**, and **Glue Jobs**, which may incur charges—especially Glue Jobs and Crawlers.
>
> To minimize costs:
>
> * Delete Glue **crawlers**, **temporary tables**, and **ETL jobs** after the exercise.
> * Remove output files from S3.
> * Avoid leaving Glue jobs running.
> * Set an **AWS Budget** ($1–$5) with email alerts.
>
> Always clean up Glue and S3 resources once you finish the lab.

---

## **Step 1: Set Up a Sample S3 Batch Job Using AWS Glue**

---

### **1.1 Upload Sample Files to S3**

1. Go to **Amazon S3 Console**
2. Create a bucket (ex: `ml-batch-input-bucket`)
3. Upload a CSV file such as:

```csv
customer_id,age,purchase_total
101,29,500
102,34,750
103,45,1200
```

---

### **1.2 Create a Glue Database**

1. Navigate to: **AWS Glue Console → Data Catalog → Databases**
2. Click **Add database**
3. Name it: **batch_lab_db**

---

### **1.3 Create a Glue Crawler to Catalog the S3 Files**

1. Go to **Crawlers → Create crawler**
2. Configure:

| Setting     | Value                          |
| ----------- | ------------------------------ |
| Data source | S3 path of your CSV            |
| Target      | Glue database (`batch_lab_db`) |

3. Run the crawler
4. Verify that a table is created in the Data Catalog

---

### **1.4 Create and Run a Glue Job**

1. Go to **ETL Jobs → Create job**

2. Choose:

   * **Glue Studio visual editor** or **Script editor**
   * **Source**: the cataloged table
   * **Transformation**: Add SQL Query → `SELECT * FROM source`
   * **Target**: S3 (write to same bucket in **Parquet format**)

3. Save and run the job

4. Verify that the output Parquet files appear in your S3 bucket

---

## **Summary**

| Task          | Outcome                            |
| ------------- | ---------------------------------- |
| S3 Upload     | Raw data uploaded to S3            |
| Glue Database | Created for data catalog           |
| Glue Crawler  | Automatically cataloged S3 files   |
| Glue Job      | Transformed & output Parquet files |


# Hands-on Lab — Automatically Catalog CSV Data from S3 (AWS Glue)

🎥 **YouTube Tutorial:**  
https://youtu.be/ah83c3lMMK8


> ⚠️ **AWS Cost Warning**
>
> This hands-on lab uses AWS Glue, Amazon S3, and related services that may incur small charges in your AWS account.  
> To minimize costs:
> - Delete Glue Crawlers, Data Catalog tables, and temporary S3 objects after completing the lab.
> - Use the AWS Free Tier where possible.
> - Set an **AWS Budget** (recommended: $1–$5) with email alerts.
>
> Always clean up resources when you finish the exercise.

## 🎯 Objective

This lab focuses on identifying, cataloging, and evaluating internal and external data sources using **AWS Glue**.  
You will:

- Work with sample datasets stored in **Amazon S3**
- Use **AWS Glue Crawlers** to automatically discover schema
- Populate the **AWS Glue Data Catalog**


These steps provide hands-on experience with foundational AWS data management tasks required for machine learning workflows.

---

## 🪜 Step 1: Set Up Required AWS Resources

### **1.1 Launch AWS Glue Console**

1. Sign in to the AWS Management Console.  
2. Navigate to **AWS Glue**.  
3. Ensure your IAM role has access to:
   - AWS Glue  
   - Amazon S3  
   - (Optional) Amazon RDS  

---

### **1.2 Create or Identify Data Sources**

You will use a sample CSV file stored in Amazon S3.

#### **Internal Source (Amazon S3)**  
Upload the following CSV file to your S3 bucket, for example:

```

s3://ml-lab-datasets/customer_orders.csv

````

### **Sample CSV: `customer_orders.csv`**

```csv
order_id,customer_id,order_date,order_amount,order_status
1001,CUST001,2023-11-01,150.25,Shipped
1002,CUST002,2023-11-02,89.90,Processing
1003,CUST003,2023-11-03,120.00,Delivered
1004,CUST004,2023-11-04,,Cancelled
1005,CUST005,2023-11-05,75.50,Delivered
````

⚠️ **Note:** The CSV contains a missing value (`order_amount` in row 4).
You will detect this using AWS Glue Data Quality Rules.

---

## 🪜 Step 2: Catalog Data Using the AWS Glue Data Catalog

### **2.1 Catalog Internal Data in Amazon S3**

#### **a. Create a Crawler for S3**

1. Go to **AWS Glue → Crawlers**.
2. Click **Add crawler**.
3. Name it:

   ```
   s3-internal-crawler
   ```
4. Click **Add a data source**.
5. Choose **Amazon S3** and provide your S3 path:

```
s3://your-bucket-name/sample-data/
```

6. Click **Add an S3 data source → Next**.
7. Select an IAM role with permissions for AWS Glue and S3.

   * Ensure access to your S3 folder, e.g.:

```
s3://your-bucket-name/sample-data/*
```

8. For **Target database**, choose an existing database or create a new one:

   ```
   internal_data_db
   ```
9. For **Crawler schedule**, choose **On demand**.
10. Click **Next → Create crawler**.
11. You should see the confirmation:
    **“One crawler successfully created.”**

---

#### **b. Run the Crawler**

1. Select the crawler → click **Run**.
2. Wait for the crawler to complete execution.
3. Go to **AWS Glue → Data Catalog → Databases → Tables**.
4. Verify that a table is created for your S3 dataset.

## ✅ Summary

By cataloging internal S3 datasets you gain visibility into the structure of your data sources.

This ensures your **ML workflows start with high-quality, well-organized data**, which is essential for accurate model training and robust machine learning pipelines.


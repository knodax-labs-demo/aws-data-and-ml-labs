
# **Hands-on Lab: Understanding Data Transformation**

## **Objective**

In this lab, you will learn how to build an AWS Glue ETL job that performs **data transformation in motion**—cleaning and validating data as it moves between ingestion and storage.

You will:

* Upload sample raw data to S3
* Use AWS Glue Crawler to generate schema metadata
* Build an ETL job in Glue Studio to **clean**, **validate**, and **transform** data
* Apply custom transformation logic
* Write the processed dataset to a **new S3 bucket**

---

> ⚠️ **AWS Cost Warning**
>
> This lab uses **AWS Glue Crawlers**, **Glue ETL Jobs**, and **S3 buckets**, which may generate charges—especially Glue job runs.
>
> To minimize costs:
>
> * Delete **ETL jobs**, **crawlers**, and **temporary tables** after the lab
> * Delete output files from S3 when no longer needed
> * Choose Glue worker type **G.1X** or lower for small datasets
> * Set an AWS **Budget Alert** ($1–$5 recommended)
>
> Always stop, delete, or clean Glue resources when done with the exercise.

---

# **Step 1: Prepare Sample Input Data**

Upload a CSV or JSON dataset to an S3 bucket.

Example source file:

```
s3://my-source-bucket/customer.csv
```

### **Sample CSV**

```csv
name,age,email,timestamp
Alice,29,alice@example.com,2025-07-11 11:45:00
Bob,,bob[at]example.com,2025-07-10 11:47:00
John,,john[at]example.com,2025-07-10 12:47:00
Charlie,32,charlie@example.com,2025-07-10 13:49:00
Rod,27,david@example.com,2025-07-12 09:49:00
```

---

# **Step 2: Create a New Glue ETL Job (Visual ETL)**

---

## **2.1 Upload the Input File**

Upload the file (e.g., `customers.csv`) to the source bucket.

---

## **2.2 Create a Data Catalog Table (Crawler)**

1. Go to **AWS Glue Console → Crawlers**
2. Create a new crawler:

   * **Source:** Your S3 bucket path
   * **Target:** Glue database
3. Run the crawler
4. Verify the table created under **Data Catalog → Tables**

---

## **2.3 Build the Glue ETL Job**

Go to **AWS Glue Studio → Visual ETL**

### **Configure the job:**

* **Source node:** S3 or Data Catalog table
* **Transform node:** Custom transform (Python code)
* **Select From Collection node:** Select the processed output
* **Target:** S3 bucket for cleaned data

Example output location:

```
s3://my-target-bucket/
```

Output format:

* **CSV**
* Compression: **None** (easier for viewing)
* *(Production workloads normally use Parquet + Snappy compression)*

---

# **Step 3: Add Custom Transformation Logic**

Create a **Custom Transform** node and paste the following code:

```python
def MyTransform (glueContext, dfc) -> DynamicFrameCollection:
    key = list(dfc.keys())[0]
    df = dfc[key].toDF()
    
    # Fix malformed email if exists
    from pyspark.sql.functions import col, regexp_replace
    
    if "email" in df.columns:
        df = df.withColumn("email", regexp_replace("email", r"\\?\[at\]", "@"))
      
    # Replace null in age column with 30
    df_filled = df.fillna({"age": 30})
    
    dyf_filled = DynamicFrame.fromDF(df_filled, glueContext, "dyf_filled")
      
    return DynamicFrameCollection({"processed_data": dyf_filled}, glueContext)

    return dyf_filled
```

### ✔ What this transform does

* Fixes malformed emails by replacing `[at]` or `\[at\]` with `@`
* Replaces missing `age` values with **30**
* Returns a cleaned DynamicFrame for output

---

# **Step 4: Configure Job Settings**

### Configure:

| Setting         | Value                                      |
| --------------- | ------------------------------------------ |
| **Job Name**    | `TransformGlueETLJob`                      |
| **IAM Role**    | Must allow read/write to both S3 buckets   |
| **Worker Type** | `G.1X` for small datasets                  |
| **Job Type**    | Spark ETL                                  |
| **Script**      | Automatically generated + custom transform |

Click **Save**, then **Run Job**

---

# **Step 5: Verify the Output**

Go to your target bucket:

```
s3://my-target-bucket/
```

You should now see cleaned CSV files with:

* Valid email formats
* Missing age values filled
* All rows preserved

---

# **Summary**

| Task             | Outcome                                     |
| ---------------- | ------------------------------------------- |
| Input Data       | Uploaded raw dataset to S3                  |
| Data Catalog     | Schema created with Glue Crawler            |
| Custom Transform | Cleaned and validated dataset               |
| Output           | Cleaned data written to target S3 bucket    |
| Tools Used       | S3, Glue Data Catalog, Glue Studio, PySpark |



Just tell me!

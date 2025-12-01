# Hands-on Lab: AWS Glue Data Quality Tutorial -- Validate and Clean Your Data in S3


🎥 **YouTube Tutorial:**  
https://youtu.be/ZXP683XmiGo

> ⚠️ **AWS Cost Warning**
>
> This hands-on lab uses AWS Glue, Amazon S3, and related services that may incur small charges in your AWS account.  
> To minimize costs:
> - Delete Glue Crawlers, Data Catalog tables, and temporary S3 objects after completing the lab.
> - Use the AWS Free Tier where possible.
> - Set an **AWS Budget** (recommended: $1–$5) with email alerts.
>
> Always clean up resources when you finish the exercise.

---

## 🎯 Objective

This lab focuses on evaluating external data sources using **AWS Glue**.  
You will:
- Apply **AWS Glue Data Quality Rules** to assess health, completeness, and reliability of your data

These steps provide hands-on experience with foundational AWS data management tasks required for machine learning workflows.

---

## Evaluate Data Quality Using AWS Glue Data Quality Rules

### **Create a Data Quality Ruleset**

1. Go to **AWS Glue → Data Quality** (or "Evaluate Data Quality" depending on UI).
2. Create a new evaluation job.
3. Select the S3-based data source discovered earlier.
4. Choose **Evaluate Data Quality (Multiframe)**.
5. In the **Ruleset Editor**, define rule types.

### **Example Data Quality Rules**

```text
RowCount > 0
IsComplete("customer_id")
IsUnique("email")      # Adjust to match your columns
```

(For this dataset, replace `"email"` with a valid column such as `"order_id"`.)

---

### **Run the Data Quality Evaluation**

1. Click **Save** or **Run evaluation**.
2. Wait for the job to complete.

---

### **Interpret the Results**

In the **Data Preview** or **Data Quality Results** panel, you will see:

* **Rule**
* **Outcome** (PASS/FAIL)
* **FailureReason**
* **EvaluatedRule**

These results help you determine whether your data is:

* Complete
* Consistent
* Unique
* Validated for downstream ML pipelines

---

## ✅ Summary

By applying AWS Glue Data Quality rules, you gain visibility into completeness, and reliability of your data sources.

This ensures your **ML workflows start with high-quality, well-organized data**, which is essential for accurate model training and robust machine learning pipelines.

---


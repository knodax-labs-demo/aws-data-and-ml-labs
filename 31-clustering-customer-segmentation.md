
# 🧪 Hands-On Exercise: Clustering – Customer Segmentation with K-Means

## Lab Overview

This hands-on exercise walks you through performing **customer segmentation using K-Means clustering** in **Amazon SageMaker Studio**. You will load a customer dataset, preprocess the data, apply unsupervised learning, and visualize customer clusters to gain actionable business insights.

Customer segmentation is commonly used in **marketing analytics**, **customer behavior analysis**, and **personalized recommendations**.

---

## Learning Objectives

By completing this lab, you will be able to:

- Launch and use **Amazon SageMaker Studio**
- Load and explore a customer dataset
- Preprocess numeric features for clustering
- Apply **K-Means clustering**
- Visualize and interpret customer segments

---
🎥 YouTube Tutorial:
https://youtu.be/5tXAST_ttrI
---
📁 Source Code and Data:
https://github.com/knodax-labs-demo/aws-data-and-ml-labs/tree/main/31-clustering-customer-segmentation
---
# ## 🔥 Cost Warning

> ⚠️ **AWS Cost Warning — Please Read Before Proceeding**
> This lab uses SageMaker Studio notebook sessions and Amazon S3. These components may incur charges.

### **Costs That May Apply**

* SageMaker **kernel compute time**
* S3 **storage** for uploaded datasets
* Optional SageMaker **training jobs**

### **Cost Best Practices**

* Shut down unused **kernel sessions**
* Delete unnecessary **S3 objects**
* Remove the **SageMaker Domain** after labs (if used only for practice)

💡 **Tip:**
This lab runs entirely in the notebook environment—**no heavy compute jobs**, so cost remains minimal.

---

## 1. Launch Amazon SageMaker Studio

### 1.1 Open the Amazon SageMaker Console

1. Sign in to the AWS Management Console  
2. Navigate to **Amazon SageMaker AI**
3. From the left navigation pane, click **SageMaker Studio**

---

### 1.2 Launch (or Create) a SageMaker Domain

- If a domain already exists:
  - Click **Launch Studio**

- If no domain exists:
  1. Click **Create SageMaker Domain**
  2. Choose **Set up for single user**
  3. Accept default settings
  4. Wait for domain creation to complete
  5. Click **Launch Studio**
  6. Ensure the user profile IAM role has required S3 permissions (`GetObject`, `PutObject`, `ListBucket`)

---

### 1.3 Create a New Jupyter Notebook

Inside SageMaker Studio:

1. Select **Notebook**
2. Choose **Python 3 (Data Science)** kernel
3. Provide a meaningful notebook name (for example: `customer-segmentation-kmeans.ipynb`)

---

## 2. Load the Customer Dataset

Use a sample customer dataset containing features such as:

- Annual income
- Spending score
- Age or purchase behavior metrics

Upload the dataset to your notebook environment or load it from Amazon S3.

```python
import pandas as pd

df = pd.read_csv("customers.csv")
df.head()
````

---

## 3. Exploratory Data Analysis (EDA)

Before clustering, explore the dataset:

* Check data types
* Identify missing values
* Review feature distributions

```python
df.info()
df.describe()
```

---

## 4. Feature Selection and Preprocessing

Select relevant numeric features for clustering and scale them to ensure equal contribution.

```python
from sklearn.preprocessing import StandardScaler

features = df[['AnnualIncome', 'SpendingScore']]
scaler = StandardScaler()
scaled_features = scaler.fit_transform(features)
```

---

## 5. Apply K-Means Clustering

### 5.1 Choose Number of Clusters

Use the **Elbow Method** to determine the optimal number of clusters.

```python
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

inertia = []
for k in range(1, 10):
    kmeans = KMeans(n_clusters=k, random_state=42)
    kmeans.fit(scaled_features)
    inertia.append(kmeans.inertia_)

plt.plot(range(1, 10), inertia)
plt.xlabel("Number of Clusters")
plt.ylabel("Inertia")
plt.show()
```

---

### 5.2 Train the K-Means Model

```python
kmeans = KMeans(n_clusters=4, random_state=42)
df['Cluster'] = kmeans.fit_predict(scaled_features)
```

---

## 6. Visualize Customer Segments

```python
import seaborn as sns

sns.scatterplot(
    x=df['AnnualIncome'],
    y=df['SpendingScore'],
    hue=df['Cluster'],
    palette='viridis'
)
```

---

## 7. Interpret the Clusters

Analyze each cluster to understand customer behavior:

* High income / high spending
* High income / low spending
* Low income / high spending
* Low income / low spending

These insights help drive **targeted marketing strategies** and **personalized offers**.

---

## Summary

In this lab, you:

* Launched Amazon SageMaker Studio
* Loaded and explored a customer dataset
* Scaled numeric features for clustering
* Applied K-Means clustering
* Visualized and interpreted customer segments

Customer segmentation using clustering is a foundational unsupervised learning technique widely used in retail, marketing, and customer analytics.

---

## 🧹 Cleanup (Important)

To avoid unnecessary AWS charges:

* Stop or delete the SageMaker notebook
* Delete the SageMaker Domain if it is no longer needed



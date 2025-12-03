
# Hands-on Lab: Creating Graphs for Data Visualization

## 🎯 Objective
This hands-on lab builds your data visualization skills using **Matplotlib** and **Seaborn**.  
You will create:

- Scatter plots  
- Time series charts  
- Histograms  
- Box plots  

These visualizations help you explore distributions, relationships, and trends—essential steps before building machine learning models.

---
🎥 **YouTube Tutorial:**  
https://youtu.be/O4CN3r6lLO8

---

📁 **Source Code and Data:**  
https://github.com/knodax-labs-demo/aws-data-and-ml-labs/tree/main/24-creating-graphs-for-data-visualization

---

## ⚠️ AWS Cost Warning
This exercise uses **Amazon S3** to store and load the dataset.  
The cost impact is minimal, but keep the following in mind:

- S3 storage incurs small monthly charges.
- S3 GET requests used for reading the dataset also incur minor costs.
- Delete sample files from the bucket when you finish.

This lab **does not use any compute services** (EC2, Lambda, SageMaker), so additional charges are not expected.

---

## 📁 Dataset for This Lab

Upload the following dataset to your S3 bucket (e.g.,  
`s3://your-bucket/ml-datasets/sample-data.csv`):

```

id,date,age,income,category,sales
1,2024-01-05,25,45000,A,120
2,2024-01-12,30,52000,B,150
3,2024-01-19,22,39000,A,100
4,2024-01-26,45,78000,C,200
5,2024-02-02,35,61000,B,180
6,2024-02-09,29,48000,A,130
7,2024-02-16,41,72000,C,210
8,2024-02-23,38,67000,B,190
9,2024-03-01,26,46000,A,140
10,2024-03-08,33,59000,C,170

```

---

## 🧪 Step 1: Upload Sample Dataset to Amazon S3
Upload `sample-data.csv` to:

```

s3://your-bucket/ml-datasets/sample-data.csv

````

Ensure your IAM role or credentials permit reading from S3 via boto3 or s3fs.

---

## 🧪 Step 2: Launch a Jupyter Notebook Environment
You may use:

- Amazon SageMaker Studio  
- SageMaker Studio Lab  
- A local Python notebook environment  

Make sure your environment has access to S3.

---

## 🧪 Step 3: Install and Import Required Libraries

```bash
!pip install matplotlib seaborn boto3 pandas s3fs
````

```python
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
```

---

## 🧪 Step 4: Load Data Directly from Amazon S3

```python
df = pd.read_csv('s3://your-bucket/ml-datasets/sample-data.csv')
df.head()
```

This displays the first five rows of your dataset, containing:

* ID
* Date
* Age
* Income
* Category
* Sales

---

## 🧪 Step 5: Generate a Scatter Plot

Visualize the relationship between **Age** and **Income**:

```python
sns.scatterplot(data=df, x='age', y='income')
plt.title('Scatter Plot: Age vs Income')
plt.show()
```

A scatter plot helps identify correlations, clusters, and potential trends.

---

## 🧪 Step 6: Create a Time Series Plot

Ensure the date column is parsed correctly:

```python
df['date'] = pd.to_datetime(df['date'])
sns.lineplot(data=df, x='date', y='sales')
plt.title('Time Series Plot: Date vs Sales')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
```

This highlights weekly or monthly sales trends.

---

## 🧪 Step 7: Draw a Histogram

Examine the distribution of income:

```python
sns.histplot(df['income'], bins=20, kde=True)
plt.title('Histogram of Income')
plt.show()
```

Histograms help diagnose skewness, spread, and modality.

---

## 🧪 Step 8: Generate a Box Plot

Visualize income differences across categories:

```python
sns.boxplot(data=df, x='category', y='income')
plt.title('Box Plot: Income by Category')
plt.show()
```

Box plots reveal:

* Outliers
* Group disparities
* Median comparisons

---

## 📊 Step 9: Interpret the Visuals

### ✔ Scatter Plot

Shows correlation patterns between age and income.

### ✔ Time Series Plot

Reveals trends, spikes, or gradual changes in sales.

### ✔ Histogram

Shows distribution shape and skewness of income.

### ✔ Box Plot

Highlights category-level income variation and outliers.

---

## 🎉 Summary

In this exercise, you:

* Loaded data stored in Amazon S3
* Generated four foundational visualization types
* Interpreted key insights from each chart
* Built essential skills for data exploration and ML preprocessing

These visualization techniques form the foundation of exploratory data analysis (EDA) in machine learning workflows.



# Hands-on Lab: Interpreting Descriptive Statistics

## 🎯 Objective
This lab focuses on computing and interpreting descriptive statistics using **pandas** and **SciPy**.  
You will:

- Calculate summary statistics (mean, median, standard deviation, quartiles)
- Examine correlations between numerical features
- Perform hypothesis testing using *t-tests* to determine statistical significance

By the end of this lab, you will understand how descriptive statistics support data exploration and data-driven decisions in machine learning workflows.

---
🎥 **YouTube Tutorial:**  
https://youtu.be/Lf6aLcGkgvg

---

📁 **Source Code and Data:**  
https://github.com/knodax-labs-demo/aws-data-and-ml-labs/tree/main/25-interpreting-descriptive-statistics

---

## ⚠️ AWS Cost Warning
If you load the dataset from **Amazon S3**, note:

- S3 storage incurs minimal monthly costs  
- S3 GET requests incur small per-request charges  
- Delete your sample files when finished  

No compute services (EC2, Lambda, SageMaker) are required, so overall cost is negligible.

---

## 🧪 Step 1: Load the Sample Dataset

You may load the dataset from a **local file** or from **Amazon S3** using pandas.

```python
import pandas as pd
df = pd.read_csv('sample-data.csv')
````

### Sample Input Dataset (`sample-data.csv`)

This dataset includes:

* **Numeric features**: age, income, score
* **Categorical grouping feature**: category (A or B)
* Useful for descriptive statistics, correlation analysis, and hypothesis testing.

```
id,age,income,score,category
1,25,48000,78,A
2,30,52000,85,A
3,22,35000,65,B
4,28,49000,80,A
5,35,61000,88,A
6,24,41000,70,B
7,40,68000,90,A
8,21,34000,60,B
9,33,59000,86,A
10,23,40000,72,B
```

After loading, you can quickly explore the basic structure:

```python
df.head()
```

The dataset includes a mix of demographic and performance values suitable for statistical analysis.

---

## 🧪 Step 2: Compute Descriptive Statistics

Use `pandas.describe()` to compute measures such as:

* Mean
* Median
* Standard deviation
* Minimum
* Maximum
* Quartiles

```python
desc_stats = df.describe()
print(desc_stats)
```

These metrics help you understand central tendency and variability in the dataset.

---

## 🧪 Step 3: Compute the Correlation Matrix

The correlation matrix quantifies the linear relationship between pairs of numerical features.

```python
correlation_matrix = df.select_dtypes(include='number').corr()
print(correlation_matrix)
```

### Interpreting Correlations

* Values close to **+1** = strong positive relationship
* Values close to **−1** = strong negative relationship
* Values near **0** = no linear relationship

For example:

* Age and income may show a **strong positive correlation**
* Score may also correlate strongly with age and income
* ID typically shows no meaningful correlation and can be ignored

These relationships help identify feature redundancy and guide feature selection or dimensionality reduction.

---

## 🧪 Step 4: Perform Hypothesis Testing Using SciPy

Use a **two-sample t-test** to determine whether two groups differ significantly.

Example: Compare **income** distributions between category A and B.

```python
from scipy.stats import ttest_ind

group_a = df[df['category'] == 'A']['income']
group_b = df[df['category'] == 'B']['income']

t_stat, p_value = ttest_ind(group_a, group_b)
print(f"T-Statistic: {t_stat}, P-Value: {p_value}")
```

### Interpretation

* **p-value < 0.05** → Statistically significant difference
* **p-value ≥ 0.05** → No significant difference detected

Hypothesis testing is essential for validating whether observed variations are meaningful or due to chance.

---

## 🧪 Step 5: Interpret the Results

### ✔ Descriptive Statistics

Help identify:

* Typical values
* Spreads
* Potential anomalies
* Skewness
* Differences in scale

### ✔ Correlation Analysis

Reveals:

* Feature interactions
* Redundant features
* Whether multicollinearity may impair models

### ✔ Hypothesis Testing

Allows you to:

* Validate assumptions
* Compare groups
* Support data-driven decisions

---

## 📘 Summary

In this lab, you:

* Loaded and explored a sample dataset
* Calculated descriptive statistics
* Analyzed correlations between numerical features
* Applied hypothesis testing to compare groups

These statistical foundations are crucial for building reliable, well-informed machine learning workflows.

```

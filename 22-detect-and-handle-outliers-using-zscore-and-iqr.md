# Hands-on Lab Detect and Handle Outliers Using Z-Score and IQR Methods in pandas

### 📘 Overview  
This hands-on exercise demonstrates how to identify and handle outliers using two widely used statistical approaches:  
- **Z-Score** — identifies values far from the mean  
- **Interquartile Range (IQR)** — a robust technique based on percentiles  

You will generate a synthetic dataset with intentionally injected outliers, visualize distributions using boxplots, and compare results from Z-Score and IQR filtering.

---

🎥 **YouTube Tutorial:**  
https://youtu.be/tJRHdm9BU-M

---

📁 **Source Code and Data:**  
https://github.com/knodax-labs-demo/aws-data-and-ml-labs/tree/main/22-detect-and-handle-outliers

---

### ⚠️ Cost Warning  
This exercise runs **locally** in Python and requires **no AWS services**.  
You can safely perform all steps in Jupyter Notebook, SageMaker Studio Lab, or any Python IDE **at zero AWS cost**.

---

## 🧪 Step 1: Set Up Sample Data With Injected Outliers

The following code generates 100 realistic samples for height, weight, and income, followed by manually added extreme values to simulate outliers.

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

np.random.seed(42)

n = 100
# Create mostly normal-looking data
height = np.random.normal(170, 10, n)
weight = np.random.normal(70, 12, n)
income = np.random.lognormal(mean=10, sigma=0.4, size=n)

# Inject some obvious outliers
height = np.append(height, [250, 30])      # very tall, very short
weight = np.append(weight, [200, 5])       # very heavy, very light
income = np.append(income, [1e7, 1])       # extremely high, extremely low

df = pd.DataFrame({
    "height_cm": height,
    "weight_kg": weight,
    "income": income
})

print(df.shape)
df.head()
````

This dataset now contains multiple abnormal values across all three features.

---

## 📊 Step 2: Visualize Raw Data Using Boxplots

Before removing outliers, examine the data visually:

```python
df.boxplot(figsize=(10,6))
plt.title("Boxplots Before Outlier Removal")
plt.show()
```

### Interpretation

A **boxplot** shows:

* **Q1 (25th percentile)**
* **Median**
* **Q3 (75th percentile)**
* **Whiskers** extending to non-outlier values
* Any points outside **1.5 × IQR** are flagged as outliers

You should see:

* Height outliers near ~250, ~150, and ~10
* Weight outliers near ~200, ~100+, and ~5
* Income outliers near ~10 million and close to 0

---

## 📉 Step 3: Detect Outliers Using Z-Score

Z-score indicates how many standard deviations a value lies from the mean.
Common rule: **absolute Z-score > 3 = outlier**.

```python
from scipy.stats import zscore

df_z = df[(np.abs(zscore(df)) < 3).all(axis=1)]
df_z.head()
```

### Observation

Extreme values distort the mean and standard deviation, causing Z-Score to **miss** some outliers—especially in skewed features like income.

---

## 📈 Step 4: Detect Outliers Using IQR (More Reliable)

IQR is far more robust because it is based only on percentiles.

```python
def remove_outliers_iqr(data, column):
    Q1 = data[column].quantile(0.25)
    Q3 = data[column].quantile(0.75)
    IQR = Q3 - Q1
    lower = Q1 - 1.5 * IQR
    upper = Q3 + 1.5 * IQR
    return data[(data[column] >= lower) & (data[column] <= upper)]

df_height_clean = remove_outliers_iqr(df, "height_cm")
df_weight_clean = remove_outliers_iqr(df, "weight_kg")
df_income_clean = remove_outliers_iqr(df, "income")
```

---

## 📊 Step 5: Visualize Cleaned Data

```python
plt.figure(figsize=(10,6))
plt.boxplot([
    df_height_clean["height_cm"],
    df_weight_clean["weight_kg"],
    df_income_clean["income"]
], labels=["Height Cleaned", "Weight Cleaned", "Income Cleaned"])

plt.title("Boxplots After Outlier Removal (IQR Method)")
plt.show()
```

Now the distributions appear smooth and free from extreme anomalies.

---

## 🧠 Summary: Z-Score vs IQR

| Method          | Advantage                                       | Limitation                                       |
| --------------- | ----------------------------------------------- | ------------------------------------------------ |
| **Z-Score**     | Simple; intuitive                               | Fails when data is skewed; distorted by outliers |
| **IQR**         | Robust, percentile-based, works for skewed data | Each feature cleaned independently               |
| **Best for ML** | —                                               | **IQR is often preferred** for preprocessing     |

---

## 📁 Optional: Save Cleaned Outputs

```python
df_height_clean.to_csv("height_cleaned.csv", index=False)
df_weight_clean.to_csv("weight_cleaned.csv", index=False)
df_income_clean.to_csv("income_cleaned.csv", index=False)
```

---

## 🎉 End of Lab

You now understand how to detect outliers using both statistical and robust techniques and how to visualize and clean real-world datasets effectively.

```

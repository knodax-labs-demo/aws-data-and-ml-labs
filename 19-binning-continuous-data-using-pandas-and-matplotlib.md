# **Hands-on Lab: Perform Binning of Continuous Data Using pandas and Visualize Distributions With Matplotlib**

🎥 **YouTube Tutorial:**  
https://youtu.be/k6t4jbSZ9_8

## 📘 Companion Notebook

A runnable Jupyter notebook for this lab is available here:

👉 https://github.com/knodax-labs-demo/aws-data-and-ml-labs/blob/main/notebooks/binning-of-continuous-data.ipynb

## ⚠️ Cost & Resource Usage Warning

Running pandas and matplotlib in a notebook environment (such as **SageMaker Studio Lab**, **Google Colab**, or **Jupyter**) is generally free or low cost.
However:

* Studio Lab GPU/CPU runtime hours are limited.
* Large datasets may use more RAM or local storage.
* Always shut down unused notebook sessions to avoid exceeding resource quotas.

This exercise uses a small dataset and is safe to run in any environment.

---

# **Objective**

In this hands-on exercise, you will:

* Perform **equal-width binning** using `pandas.cut()`.
* Perform **equal-frequency (quantile) binning** using `pandas.qcut()`.
* Visualize:

  * the **original continuous distributions**
  * the **binned categorical distributions**
    using **matplotlib histograms and bar plots**.

Binning is a useful technique for transforming continuous variables into discrete categories that can simplify analysis and support certain machine learning workflows.

---

# **Sample Dataset (20 Records)**

```
id,age,income
1,22,35000
2,24,38000
3,26,40000
4,29,42000
5,31,48000
6,35,60000
7,38,68000
8,41,75000
9,44,82000
10,47,90000
11,50,97000
12,53,110000
13,55,117000
14,58,125000
15,60,135000
16,63,150000
17,66,160000
18,68,170000
19,71,185000
20,74,200000
```

Load the dataset:

```python
import pandas as pd

data = {
    'id': list(range(1, 21)),
    'age': [22, 24, 26, 29, 31, 35, 38, 41, 44, 47, 50, 53, 55, 58, 60, 63, 66, 68, 71, 74],
    'income': [35000, 38000, 40000, 42000, 48000, 60000, 68000, 75000, 82000, 90000, 97000,
               110000, 117000, 125000, 135000, 150000, 160000, 170000, 185000, 200000]
}

df = pd.DataFrame(data)
df.head()
```

---

# **Walkthrough and Explanation**

## **Step 1: Explore the Dataset**

```python
df.head()
df.describe()
```

* `head()` shows the first five rows.
* `describe()` summarizes min, max, quartiles, mean, etc.

---

# **Step 2: Perform Equal-Width Binning (Using `pd.cut()`)**

Equal-width binning divides the full range of values into intervals of **equal size**.

Formula:

```
bin_width = (max - min) / number_of_bins
```

For this dataset:

* Age range: 22 → 74
* Four equal-width bins
* Bin size ≈ 13 years

Apply binning:

```python
df['age_bin_equal_width'] = pd.cut(df['age'], bins=4)
df['age_bin_equal_width'].value_counts()
```

Interpretation:

* Each bin covers an equal width range (e.g., 22–35, 36–48, 49–61, 62–74).
* Some bins may have more or fewer data points depending on distribution.

---

# **Step 3: Perform Equal-Frequency Binning (Using `pd.qcut()`)**

Equal-frequency (quantile) binning ensures **each bin contains the same number of records**, regardless of value range.

Apply:

```python
df['income_bin_equal_freq'] = pd.qcut(df['income'], q=4)
df['income_bin_equal_freq'].value_counts()
```

Key points:

* Each bin has exactly **five values** (20 total / 4 bins).
* Bin ranges will differ—for example:

  * One bin may span 35,000–48,000
  * Another may span 150,000–200,000

This method preserves **balanced counts** across bins.

---

# **Step 4: Visualize Original Continuous Distributions**

```python
import matplotlib.pyplot as plt

plt.hist(df['age'], bins=5, edgecolor='black')
plt.title('Age Distribution')
plt.xlabel('Age')
plt.ylabel('Frequency')
plt.show()

plt.hist(df['income'], bins=5, edgecolor='black')
plt.title('Income Distribution')
plt.xlabel('Income')
plt.ylabel('Frequency')
plt.show()
```

The histograms show how age and income values fall into various ranges and highlight any skewness.

---

# **Step 5: Visualize Binned Data With Bar Plots**

### **Equal-Width Age Bins**

```python
df['age_bin_equal_width'].value_counts().sort_index().plot(kind='bar')
plt.title('Equal-Width Age Bin Counts')
plt.xlabel('Age Bins')
plt.ylabel('Count')
plt.show()
```

### **Equal-Frequency Income Bins**

```python
df['income_bin_equal_freq'].value_counts().sort_index().plot(kind='bar')
plt.title('Equal-Frequency Income Bin Counts')
plt.xlabel('Income Bins')
plt.ylabel('Count')
plt.show()
```

Observation:

* Age bins vary in size → different counts
* Income bins have equal counts → different ranges

---

# **Step 6: Compare Both Binning Techniques Side by Side**

You can display both bin results together:

```python
comparison = pd.DataFrame({
    'age_bin_equal_width': df['age_bin_equal_width'],
    'income_bin_equal_freq': df['income_bin_equal_freq']
})
comparison.head()
```

This helps illustrate how each method categorizes data differently.

---

# **Summary of What You Learned**

* **`pd.cut()`** performs **equal-width** binning → uniform intervals, uneven counts.
* **`pd.qcut()`** performs **equal-frequency** binning → uniform counts, uneven intervals.
* **Histograms** visualize continuous distributions.
* **Bar plots** visualize categorical bin counts.
* Binning supports:

  * Feature engineering
  * Data simplification
  * Visualization
  * Certain machine learning models

Binning is a powerful tool for transforming continuous variables into meaningful categories for clearer analysis and improved modeling workflows.

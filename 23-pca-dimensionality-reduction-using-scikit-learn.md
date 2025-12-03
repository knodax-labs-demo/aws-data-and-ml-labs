
# Hands-on Apply PCA for Dimensionality Reduction Using scikit-learn and Visualize Variance Explained Ratio

### 📘 Overview  
Principal Component Analysis (PCA) is a powerful dimensionality reduction technique used to transform high-dimensional datasets into a smaller set of components while retaining most of the original information. In this hands-on exercise, you will standardize the dataset, apply PCA, analyze the **explained variance ratio**, and visualize the results using scree plots and PCA scatter plots.

---
🎥 **YouTube Tutorial:**  
https://youtu.be/QgnVC5U15_E

---

📁 **Source Code and Data:**  
https://github.com/knodax-labs-demo/aws-data-and-ml-labs/tree/main/23-PCA

---


### ⚠️ Cost Warning  
This exercise runs **entirely on local Python environments** such as Jupyter Notebook or SageMaker Studio Lab.  
It **does not use any AWS services**, so **no AWS costs** are incurred.

---

## 🧪 Step 1: Imports + Generate Sample Dataset

We create a toy dataset with **200 rows and 6 numerical features**, including intentionally correlated features like BMI, calories, and steps.

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA

np.random.seed(42)

n = 200
height_cm = np.random.normal(170, 10, n)
weight_kg = np.random.normal(70, 12, n)

# BMI derived from height & weight to intentionally add correlation
bmi = weight_kg / ((height_cm / 100) ** 2)

income = np.random.lognormal(mean=10, sigma=0.4, size=n)  # skewed distribution
steps_per_day = np.random.normal(6000, 1500, n)
calories = 2000 + 0.3 * steps_per_day + np.random.normal(0, 200, n)  # correlated with steps

df = pd.DataFrame({
    "height_cm": height_cm,
    "weight_kg": weight_kg,
    "bmi": bmi,
    "income": income,
    "steps_per_day": steps_per_day,
    "calories": calories
})

df.head()
````

---

## 🧹 Step 2: Standardize the Dataset

PCA is sensitive to differences in scale.
We use **StandardScaler** to normalize all features:

```python
scaler = StandardScaler()
scaled_data = scaler.fit_transform(df)
```

---

## 🧮 Step 3: Apply PCA and Examine Explained Variance

Compute PCA with all components:

```python
pca = PCA(n_components=df.shape[1])
pca_result = pca.fit_transform(scaled_data)

explained_variance = pca.explained_variance_ratio_
cumulative_variance = explained_variance.cumsum()

print("Explained Variance Ratio:")
print(explained_variance)

print("\nCumulative Variance:")
print(cumulative_variance)
```

### 📊 Interpretation Example

Typical PCA output might show:

* **PC1 ≈ 36% variance**
* **PC1 + PC2 ≈ 64% variance**
* **PC1 + PC2 + PC3 ≈ 83% variance**
* **4 components capture ~98%** of the information

This suggests dimensionality can be reduced from 6 → **3 or 4 components** without significant information loss.

---

## 📈 Step 4: Create Scree Plot and Cumulative Variance Plot

```python
plt.figure(figsize=(10, 6))
plt.bar(range(1, len(explained_variance) + 1), explained_variance, alpha=0.7, label='Variance Ratio')
plt.plot(range(1, len(cumulative_variance) + 1), cumulative_variance, marker='o', color='red', label='Cumulative Variance')

plt.xlabel("Principal Component")
plt.ylabel("Explained Variance")
plt.title("PCA Scree Plot + Cumulative Variance")
plt.grid(True)
plt.legend()
plt.show()
```

### What This Tells You

* Bars show the variance explained by each component.
* The line shows cumulative variance.
* Look for the **elbow point**, where additional components contribute very little improvement.
* Many workflows keep **90–95%** of variance.

---

## 🎨 Step 5: Visualize PCA Components Using a 2D Scatter Plot

```python
plt.figure(figsize=(8, 6))
plt.scatter(pca_result[:, 0], pca_result[:, 1], alpha=0.6)
plt.xlabel("Principal Component 1")
plt.ylabel("Principal Component 2")
plt.title("2D PCA Scatter Plot")
plt.grid(True)
plt.show()
```

This visualization helps reveal patterns, grouping structure, or potential clusters.

---

## 🧠 Key Takeaways

* **Always standardize** features before applying PCA.
* Use `explained_variance_ratio_` to determine the number of components worth keeping.
* Scree plots and cumulative variance plots help identify the optimal cutoff.
* PCA is highly useful for:

  * Noise reduction
  * Feature compression
  * Improving model speed
  * Visualization of high-dimensional data
* You can automatically retain 95% of variance using:

  ```python
  PCA(n_components=0.95)
  ```

---

## 📁 Optional: Save PCA Output

```python
pca_df = pd.DataFrame(pca_result, columns=[f"PC{i+1}" for i in range(df.shape[1])])
pca_df.to_csv("pca_transformed_output.csv", index=False)
```

---

## 🎉 End of Lab

You have successfully applied PCA for dimensionality reduction, analyzed the explained variance ratio, and visualized the transformed features using practical and widely used PCA techniques.


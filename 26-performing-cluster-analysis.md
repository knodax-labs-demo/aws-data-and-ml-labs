
# Hands-on Lab: Performing Cluster Analysis

## 🎯 Objective
In this lab, you will apply **unsupervised learning techniques** to discover natural groupings within your dataset.  
You will:

- Perform **hierarchical clustering** and visualize it using a **dendrogram**
- Use the **elbow method** to estimate the optimal number of clusters
- Apply **Agglomerative Clustering** to group the data
- Visualize and interpret cluster assignments

By the end of this exercise, you’ll understand how clustering reveals hidden structure useful for customer segmentation, anomaly detection, and exploratory data analysis.

---
🎥 **YouTube Tutorial:**  
https://youtu.be/fgRLkmmVuGQ

---

📁 **Source Code and Data:**  
https://github.com/knodax-labs-demo/aws-data-and-ml-labs/tree/main/26-performing-cluster-analysis

---

## ⚠️ AWS Cost Warning
If your dataset is stored in **Amazon S3**, remember:

- S3 storage incurs minimal monthly charges  
- S3 GET requests cost a small amount per request  
- Delete uploaded sample files when you finish  

No compute services (EC2, Lambda, or SageMaker) are required. Total cost impact is very low.

---

## 🧪 Step 1: Import Required Libraries

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from sklearn.cluster import AgglomerativeClustering, KMeans
from sklearn.preprocessing import StandardScaler

from scipy.cluster.hierarchy import dendrogram, linkage
````

These libraries provide tools for clustering, scaling, and data visualization.

---

## 🧪 Step 2: Load and Preprocess the Dataset

```python
df = pd.read_csv('sample-data.csv')  # Replace with S3 path if needed
features = df[['Age', 'AnnualIncome', 'SpendingScore']]
```

### Sample Dataset (`sample-data.csv`)

```
CustomerID,AnnualIncome,SpendingScore,Age
1001,15,39,22
1002,16,81,35
1003,17,6,26
1004,18,77,27
1005,19,40,19
1006,20,76,27
1007,21,6,19
1008,22,94,27
1009,23,3,27
1010,24,72,20
1011,25,14,29
1012,26,99,30
1013,27,15,31
1014,28,77,40
1015,29,13,35
1016,30,79,37
1017,31,35,26
1018,32,66,27
1019,33,29,27
1020,34,98,32
```

### Standardize the Data

Standardization ensures all features contribute equally to the clustering algorithm.

```python
scaler = StandardScaler()
scaled_features = scaler.fit_transform(features)
```

---

## 🧪 Step 3: Generate a Dendrogram for Hierarchical Clustering

A **dendrogram** visualizes how data points merge into clusters step-by-step.

```python
linked = linkage(scaled_features, method='ward')

plt.figure(figsize=(10, 6))
dendrogram(linked, labels=df.index.tolist(), orientation='top', distance_sort='descending')
plt.title('Hierarchical Clustering Dendrogram')
plt.xlabel('Data Point Index')
plt.ylabel('Distance')
plt.show()
```

### Understanding the Dendrogram

* Start at the bottom: each point is its own cluster
* Moving upward shows clusters gradually merging
* **Lower merges → more similar observations**
* **Higher merges → less similar**

To decide the number of clusters:

* Imagine drawing a horizontal line through the dendrogram
* Each vertical branch it intersects represents a cluster
* The **largest vertical jump** indicates a good cut point

In this dataset:

* A line near distance **4.5–5.0** produces **three clusters**
* A smaller jump around 3 would yield five clusters

---

## 🧪 Step 4: (Optional) Generate an Elbow Plot

The **elbow method** helps estimate the ideal number of clusters for k-means.

```python
inertia = []
for k in range(1, 10):
    km = KMeans(n_clusters=k, random_state=42)
    km.fit(scaled_features)
    inertia.append(km.inertia_)

plt.plot(range(1, 10), inertia, marker='o')
plt.title('Elbow Plot')
plt.xlabel('Number of Clusters')
plt.ylabel('Inertia')
plt.grid(True)
plt.show()
```

### Interpreting the Elbow Plot

* X-axis: number of clusters
* Y-axis: inertia (WCSS)
* Look for the **point where the curve starts flattening**
* In this example, the elbow typically appears at **3 or 4 clusters**

---

## 🧪 Step 5: Apply Agglomerative (Hierarchical) Clustering

Select the cluster count using the dendrogram or elbow plot.

```python
agglo = AgglomerativeClustering(n_clusters=3)
df['cluster'] = agglo.fit_predict(scaled_features)
```

Agglomerative clustering is **bottom-up**:

* Each point starts as its own cluster
* Closest pairs merge step-by-step
* Stops when desired cluster count is reached

---

## 🧪 Step 6: Visualize Cluster Assignments

```python
plt.figure(figsize=(8, 6))

for cluster_id in sorted(df['cluster'].unique()):
    subset = df[df['cluster'] == cluster_id]
    plt.scatter(subset['AnnualIncome'], subset['SpendingScore'], label=f'Cluster {cluster_id}')

plt.xlabel('Annual Income')
plt.ylabel('Spending Score')
plt.title('Cluster Visualization')
plt.legend()
plt.show()
```

This scatter plot helps reveal:

* Cluster boundaries
* Separation between groups
* High-income / high-score vs. low-income / low-score customer groups

---

## 📝 Summary

In this lab, you:

* Standardized numerical features
* Visualized hierarchical clustering with a dendrogram
* Used the elbow method for cluster selection
* Applied Agglomerative Clustering
* Visualized customer segmentation

Clustering helps uncover hidden structure in unlabeled data—an essential step in exploratory ML workflows.


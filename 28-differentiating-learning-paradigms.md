

# **Differentiating Learning Paradigms**

## **Objective**

This lab helps you understand the distinction between **supervised** and **unsupervised** learning using hands-on examples.
You will:

* Build classification and regression models using **Scikit-learn** (supervised learning).
* Apply **clustering algorithms** (unsupervised learning) to the same dataset.
* Compare how both paradigms learn patterns and when each should be used.

By the end of this lab, you will be able to identify the strengths, limitations, and appropriate use cases for both learning approaches.

---

## **Sample Dataset**

```
CustomerID,Age,Annual_Income,Spending_Score,Segment
1001,22,25000,77,A
1002,35,48000,52,B
1003,40,61000,59,B
1004,23,27000,80,A
1005,31,53000,47,B
1006,45,65000,35,C
1007,52,70000,30,C
1008,24,30000,76,A
1009,33,50000,49,B
```

### **Column Explanation**

* **CustomerID** – Unique identifier
* **Age** – Customer age
* **Annual_Income** – Income in USD
* **Spending_Score** – Score based on purchase behavior
* **Segment** – Label for supervised learning (classification target)

---

## **Generating a Larger Synthetic Dataset (Optional)**

To simulate a realistic dataset with **1,000 entries**, use the script below:

```python
import pandas as pd
import random
 
# Initialize an empty list to hold the data
data = []
 
# Start CustomerID from 1001 and generate 1000 rows
for cid in range(1001, 2001):
    age = random.randint(18, 60)
    income = random.randint(20000, 80000)
    score = random.randint(20, 100)
 
    # Rule-based Segment assignment
    if score >= 70 and income <= 35000:
        segment = 'A'  # low income, high spenders
    elif 45 <= score < 70:
        segment = 'B'  # medium spenders
    else:
        segment = 'C'  # low spenders
 
    data.append([cid, age, income, score, segment])
 
# Create DataFrame
df = pd.DataFrame(data, columns=["CustomerID", "Age", "Annual_Income", "Spending_Score", "Segment"])
 
print(df.head())
df.to_csv("synthetic_customer_data.csv", index=False)
```

---

# **Step 1: Set Up Your Environment**

Install required Python libraries:

```bash
pip install pandas scikit-learn matplotlib seaborn
```

---

# **Step 2: Load and Explore the Dataset**

```python
import pandas as pd

df = pd.read_csv('s3://knodax-business-problems-as-ml-problems/customer_segments_dataset.csv')  
print(df.head())

# Drop "Unnamed: 0" if present
df = df.drop(df.columns[0], axis=1)

# Rename Segment → Target (supervised learning target label)
df = df.rename(columns={'Segment': 'Target'})
print(df.head())
```

---

# **Step 3: Build Train–Test Split (80/20)**

```python
from sklearn.model_selection import train_test_split

X = df.drop('Target', axis=1)
y = df['Target']

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

print("***X_train***\n", X_train)
print("***X_test***\n", X_test)
print("***y_train***\n", y_train)
print("***y_test***\n", y_test)
```

---

# **Step 4: Build a Supervised Classification Model (Logistic Regression)**

```python
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

clf = LogisticRegression(max_iter=5000)
clf.fit(X_train, y_train)

y_pred = clf.predict(X_test)

print("Classification Accuracy:", accuracy_score(y_test, y_pred))
```

**Example Output:**

```
Classification Accuracy: 0.665
```

---

# **Step 5: Build an Unsupervised Clustering Model (KMeans)**

```python
from sklearn.cluster import KMeans
import pandas as pd

kmeans = KMeans(n_clusters=3, random_state=42)
numeric_clusters = kmeans.fit_predict(X)

# Map numeric clusters -> A/B/C labels
label_map = {0: 'A', 1: 'B', 2: 'C'}
clusters = pd.Series(numeric_clusters).map(label_map)

df["Cluster"] = clusters
print(df.head())
```

---

# **Step 6: Compare Supervised vs. Unsupervised Results**

Use visualizations and a confusion matrix to compare predicted clusters with true labels:

```python
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix

sns.scatterplot(x=df["Age"], y=df["Spending_Score"], hue=df['Cluster'])
plt.title("KMeans Clustering Result")
plt.show()

print("Confusion Matrix:\n", confusion_matrix(df['Target'], df['Cluster']))
```

---

# **Step 7: Reflect on Learning Paradigm Differences**

Summarize what you learned about how each method works:

### **Example Conclusion**

Logistic Regression performs better because it learns directly from labeled training data, achieving an accuracy of around **66.5%**.
KMeans clustering, while useful for discovering hidden patterns in unlabeled data, does not match the true labels reliably.

### **When to Use Each Approach**

* **Supervised Learning:**
  Use when labeled data exists and the goal is prediction.

* **Unsupervised Learning:**
  Use when exploring unknown structure, reducing dimensionality, or segmenting unlabeled data.

### **Source code:**
https://github.com/knodax-labs-demo/aws-data-and-ml-labs/tree/main/28-differentiating-learning-paradigms

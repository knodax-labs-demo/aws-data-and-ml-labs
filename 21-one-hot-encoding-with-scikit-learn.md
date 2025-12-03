# **Hands-on Implement One-Hot Encoding on Categorical Data Using scikit-learn**

This hands-on exercise demonstrates how to apply **One-Hot Encoding** to categorical features using the `OneHotEncoder` class from the `sklearn.preprocessing` module. You’ll learn how to encode categorical variables, merge encoded features back into the main DataFrame, drop redundant categories to avoid multicollinearity, and implement a full machine learning pipeline.

---

## **🔧 Objective**

* Identify categorical columns
* Apply `OneHotEncoder` to transform categories into binary columns
* Merge encoded features back with original numeric data
* Optionally drop the first category for each feature
* Build a modern ML pipeline using ColumnTransformer and Logistic Regression

---

🎥 **YouTube Tutorial:**  
https://youtu.be/-NFTLN3uhxQ

---

## **⚠️ Cost Warning**

This lab uses **Python only**—there are **no AWS services**, so no charges are incurred.
If you later store encoded data in **S3**, costs apply:

* **PUT/GET requests cost money**
* **S3 storage** (small CSVs cost only a few cents per month)
* Delete files after experiments if not needed

---

## **📁 Suggested GitHub File Name**

### **`5.2.8.3-one-hot-encoding-with-scikit-learn.md`**

Clean, descriptive, and consistent with your earlier files.

---

## **1. Setup and Load Sample Data**

```python
import pandas as pd
from sklearn.preprocessing import OneHotEncoder

# ---- Sample data ----
df = pd.DataFrame({
    "id": [1, 2, 3, 4, 5],
    "gender": ["Male", "Female", "Female", "Male", "Other"],
    "region": ["North", "South", "East", "West", "South"],
    "product_category": ["A", "B", "A", "C", "B"],
    "spend": [120.5, 99.9, 233.0, 150.75, 80.0]  # numeric column
})

print(df)
```

---

## **2. Identify Categorical Columns**

```python
categorical_cols = ["gender", "region", "product_category"]
categorical_cols
```

---

## **3. Apply One-Hot Encoding**

```python
ohe = OneHotEncoder(sparse_output=False)

encoded_array = ohe.fit_transform(df[categorical_cols])

encoded_cols = ohe.get_feature_names_out(categorical_cols)

df_encoded = pd.DataFrame(encoded_array, columns=encoded_cols)

df_encoded
```

---

## **4. Merge Encoded Features Back Into the Original DataFrame**

```python
df_merged = pd.concat([df, df_encoded], axis=1)
df_merged
```

---

## **5. Drop the First Category (Avoid Multicollinearity)**

This is recommended for linear models to avoid the **dummy variable trap**.

```python
ohe_drop = OneHotEncoder(drop='first', sparse_output=False)

encoded_array_drop = ohe_drop.fit_transform(df[categorical_cols])
encoded_cols_drop = ohe_drop.get_feature_names_out(categorical_cols)

df_encoded_drop = pd.DataFrame(encoded_array_drop, columns=encoded_cols_drop)

df_model = pd.concat([df[["id", "spend"]], df_encoded_drop], axis=1)

df_model
```

---

## **6. One-Hot Encoding Using a Full Machine Learning Pipeline**

Modern ML workflows use pipelines for consistency and reproducibility.

```python
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline

numeric_cols = ["spend"]

preprocess = ColumnTransformer(
    transformers=[
        ("cat", OneHotEncoder(drop="first"), categorical_cols),
        ("num", StandardScaler(), numeric_cols)
    ]
)

clf = Pipeline(steps=[
    ("preprocess", preprocess),
    ("model", LogisticRegression())
])

clf
```

This pipeline:

* One-hot encodes categorical features
* Scales numeric features
* Fits a Logistic Regression model
* Ensures consistent transformations across training and inference
* Keeps your workflow clean and production-ready

---

## **📌 Summary**

In this lab, you:

* Loaded a dataset with mixed categorical and numeric features
* Applied One-Hot Encoding using scikit-learn
* Retrieved encoded feature names
* Merged encoded outputs back into your DataFrame
* Dropped the first category to avoid multicollinearity
* Built a complete machine learning preprocessing + modeling pipeline

This encoded dataset can be used for:

* Regression and classification tasks
* Model training workflows
* Feature engineering pipelines
* Scikit-learn, SageMaker, and ETL jobs


# Recommendation System with Amazon SageMaker Factorization Machines

#### This hands-on lab demonstrates how to build a **recommendation system using Amazon SageMaker’s built-in Factorization Machines (FM) algorithm**. The lab walks through the complete end-to-end workflow, from environment setup and data preparation to model training, deployment, and inference.
---

## 📌 What You Will Learn

* How to set up **Amazon SageMaker Studio** and **JupyterLab**
* How to generate **synthetic user–item interaction data**
* How to prepare **sparse feature matrices** for recommendation models
* How to convert data into **RecordIO-Protobuf format**
* How to train a **Factorization Machines model** using SageMaker
* How to deploy a model to a **real-time inference endpoint**
* How to interpret recommendation **scores vs predicted labels**
* How to **clean up AWS resources** to avoid unnecessary charges

---

## 🧰 Prerequisites

Before starting, make sure you have:

* An AWS account
* IAM permissions for:
  * Amazon SageMaker
  * Amazon S3
* A SageMaker execution role with **read/write access to your S3 bucket**
* Basic familiarity with Python and Jupyter notebooks

⚠️ **Cost Warning**
Amazon SageMaker resources are **not free**. This lab includes cleanup steps—follow them carefully.

---
🎥 YouTube Tutorial:
https://youtu.be/M5ZZcwwqZfk
---
📁 Source Code and Data:

---

## 🏗️ Architecture Overview

**High-level flow:**

1. Generate synthetic user–item interaction data
2. Convert data into sparse numeric features
3. Upload data to Amazon S3
4. Train Factorization Machines using SageMaker
5. Deploy the trained model as a real-time endpoint
6. Send inference requests and generate recommendation scores

---

## 🚀 Step-by-Step Lab Instructions

### 1️⃣ Launch Amazon SageMaker Studio

1. Sign in to the AWS Management Console
2. Search for **Amazon SageMaker**
3. From the left navigation pane, choose **SageMaker Studio**

If no domain exists:

* Click **Create SageMaker Domain**
* Choose **Set up for single user**
* Accept default settings
* Click **Set Up**

---

### 2️⃣ Configure User Profile and IAM Role

Before continuing:

* Modify the SageMaker **user profile**
* Ensure the attached IAM role has **S3 access**
* This avoids permission errors when uploading data

---

### 3️⃣ Create and Launch JupyterLab Space

1. Create a **JupyterLab Space**
2. Provide a meaningful name
3. Keep default settings
4. Start the space
5. Open **JupyterLab**

> A SageMaker Space is a self-contained workspace with its own compute, storage, and IAM context.

---

### 4️⃣ Create the Notebook and Install Libraries

Create a new notebook and install required libraries:

```python
!pip install numpy pandas scipy scikit-learn sagemaker boto3
```

---

### 5️⃣ Generate Synthetic User–Item Interaction Data

```python
import pandas as pd
import numpy as np

np.random.seed(42)

num_users = 100
num_items = 50
num_records = 1000

data = {
    "user_id": np.random.randint(1, num_users + 1, num_records),
    "item_id": np.random.randint(1, num_items + 1, num_records),
    "interaction": np.random.choice([0, 1], size=num_records, p=[0.9, 0.1])
}

df = pd.DataFrame(data)
df.to_csv("user_item_interactions.csv", index=False)
df.head()
```

Each record represents:

* `user_id`
* `item_id`
* `interaction` (1 = positive interaction, 0 = no interaction)

---

### 6️⃣ Convert Data to Sparse Format

```python
df["user_index"] = df["user_id"].astype("category").cat.codes
df["item_index"] = df["item_id"].astype("category").cat.codes

num_users = df["user_index"].nunique()
num_items = df["item_index"].nunique()
```

---

### 7️⃣ Build Sparse Feature Matrix

```python
from scipy.sparse import csr_matrix

X = csr_matrix(
    (
        np.ones(len(df)),
        (range(len(df)), df["user_index"])
    ),
    shape=(len(df), num_users + num_items)
)

y = df["interaction"].astype("float32").values
X = X.astype("float32")
```

⚠️ **Important**
Both features and labels must be `float32`, or the SageMaker training job will fail.

---

### 8️⃣ Convert Data to RecordIO-Protobuf

```python
from sagemaker.amazon.common import write_spmatrix_to_sparse_tensor
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

write_spmatrix_to_sparse_tensor("train.recordio", X_train, y_train)
write_spmatrix_to_sparse_tensor("test.recordio", X_test, y_test)
```

Upload these files to Amazon S3.

---

### 9️⃣ Train the Factorization Machines Model

#### Configure the Estimator

```python
import sagemaker
from sagemaker import get_execution_role

role = get_execution_role()
session = sagemaker.Session()

fm = sagemaker.estimator.Estimator(
    image_uri=sagemaker.image_uris.retrieve(
        "factorization-machines", session.boto_region_name
    ),
    role=role,
    instance_count=1,
    instance_type="ml.m5.large",
    output_path="s3://<your-bucket>/fm-output/",
    sagemaker_session=session
)

fm.set_hyperparameters(
    feature_dim=num_users + num_items,
    predictor_type="binary_classifier",
    num_factors=10,
    epochs=10,
    mini_batch_size=100
)
```

#### Start Training

```python
fm.fit({
    "train": "s3://<your-bucket>/train.recordio",
    "test": "s3://<your-bucket>/test.recordio"
})
```

---

### 🔟 Deploy the Model

```python
predictor = fm.deploy(
    initial_instance_count=1,
    instance_type="ml.m5.large"
)
```

Wait until the endpoint status shows **In Service**.

---

### 1️⃣1️⃣ Run Inference and Generate Recommendations

```python
response = predictor.predict(X_test[:10])
response
```

#### Understanding the Output

* **score** → Probability of positive interaction
* **predicted_label** → Derived from a threshold (usually 0.5)

📌 In recommendation systems, **ranking by score** matters more than predicted labels.

---

## 🧹 Cleanup (Very Important)

To avoid unnecessary billing:

* Delete the SageMaker **endpoint**
* Delete the **JupyterLab Space**
* Delete the **SageMaker Domain**

---

## ✅ Lab Complete

You have successfully built, trained, deployed, and evaluated a **recommendation system using Amazon SageMaker Factorization Machines**.

# **Hands-on Lab: Classification – Fraud Detection**

---

## **Step 1: Launch SageMaker Studio Notebook**

Follow these steps to start your lab environment:

1. Sign in to the **AWS Management Console** and open **Amazon SageMaker**.
2. Choose your **Domain** and **User Profile**.
3. Click **Launch → Studio** (if it is not already open).
4. Inside Studio, select **File → New → Notebook**.
5. Choose a **Python 3 kernel** (such as *Python 3 (Data Science)*).
6. Ensure your execution role has permissions for:

   * `s3:*` or at minimum:
     `s3:GetObject`, `s3:PutObject`, `s3:ListBucket`
   * `sagemaker:*` (training + processing)
   * `bedrock:*` (optional for later Bedrock chapters)

In the **first notebook cell**, set up your AWS region and S3 bucket:

```python
import boto3
import sagemaker
from sagemaker import get_execution_role

session = sagemaker.Session()
region = session.boto_region_name

role = get_execution_role()  # Works inside SageMaker Studio
bucket = "<your-s3-bucket-name>"  # e.g., "knodax-ml-labs"
prefix = "fraud-detection-lab"

print("Region:", region)
print("Bucket:", bucket)
```

**Replace `<your-s3-bucket-name>` with your own bucket.**

---

## **Step 2: Classification Model – Fraud Detection**

In this section, you will:

* Create a **synthetic credit card fraud dataset** (~1,000 records).
* Upload it to **S3**.
* Load and preprocess the data.
* Train a **binary classification** model (fraud vs. non-fraud).
* Evaluate the model using accuracy, precision, recall, and a confusion matrix.

---

## **2.1 Create a Synthetic Fraud Dataset (1,000 Records)**

Start with the sample rows and expand them into a larger dataset.

```python
import pandas as pd
import numpy as np

# ---- Base sample rows ----
base_rows = [
    [100001,120.50,"13:45","New York","Electronics",0],
    [100002,8.99,"09:20","San Francisco","Coffee Shop",0],
    [100003,560.00,"02:10","Las Vegas","Jewelry",1],
    [100004,43.25,"17:50","Chicago","Grocery",0],
    [100005,3200.00,"03:30","Los Angeles","Luxury Goods",1],
    [100006,15.00,"11:05","Boston","Books",0],
    [100007,850.75,"01:45","Miami","Electronics",1],
    [100008,25.00,"14:30","Seattle","Clothing",0],
    [100009,199.99,"22:15","New York","Furniture",0],
    [100010,999.00,"04:00","Houston","Travel",1],
]

columns = ["TransactionID","Amount","Time","Location","MerchantCategory","IsFraud"]
base_df = pd.DataFrame(base_rows, columns=columns)
base_df
```

Now generate ~1,000 synthetic transactions using simple fraud-risk rules:

* Higher amounts → more likely fraud
* Late-night transactions (before 6 AM or after 10 PM) → more likely fraud

```python
import random

locations = ["New York", "San Francisco", "Las Vegas", "Chicago", "Los Angeles",
             "Boston", "Miami", "Seattle", "Houston", "Dallas", "Atlanta", "Denver"]
merchant_categories = ["Electronics", "Coffee Shop", "Jewelry", "Grocery",
                       "Luxury Goods", "Books", "Clothing", "Furniture", "Travel", "Online Services"]

def random_time():
    hour = random.randint(0, 23)
    minute = random.randint(0, 59)
    return f"{hour:02d}:{minute:02d}"

def generate_transaction(txn_id):
    amount = round(np.random.lognormal(mean=3.5, sigma=1.0), 2)
    time_str = random_time()
    location = random.choice(locations)
    merchant = random.choice(merchant_categories)
    
    hour = int(time_str.split(":")[0])
    base_prob = 0.03
    if amount > 500: base_prob += 0.10
    if hour < 6 or hour > 22: base_prob += 0.07
    is_fraud = 1 if random.random() < base_prob else 0
    
    return [txn_id, amount, time_str, location, merchant, is_fraud]

synthetic_rows = [generate_transaction(100000 + i) for i in range(1, 1001)]
df = pd.DataFrame(synthetic_rows, columns=columns)

df.head(), len(df)
```

---

## **2.2 Save the Dataset Locally and Upload to S3**

```python
# Save to local CSV
local_path = "sample_credit_card_fraud.csv"
df.to_csv(local_path, index=False)

# Upload to S3
s3 = boto3.client("s3", region_name=region)
s3_key = f"{prefix}/sample_credit_card_fraud.csv"

s3.upload_file(local_path, bucket, s3_key)
print(f"Uploaded to s3://{bucket}/{s3_key}")
```

---

## **2.3 Load the Dataset in the Notebook**

```python
data = pd.read_csv(local_path)
data.head()
data.describe(include="all")
```

---

## **2.4 Feature Engineering and Preprocessing**

Steps:

* Extract hour from `Time`.
* Drop ID and non-feature fields.
* One-hot encode categorical columns.
* Split features (`X`) and label (`y`).

```python
# Extract hour feature
data["Hour"] = data["Time"].str.split(":").str[0].astype(int)

# Drop unused columns
data = data.drop(columns=["TransactionID", "Time"])

# Label
y = data["IsFraud"]
X = data.drop(columns=["IsFraud"])

# One-hot encode categorical features
categorical_cols = ["Location", "MerchantCategory"]
X = pd.get_dummies(X, columns=categorical_cols, drop_first=True)

X.head(), y.head()
```

---

## **2.5 Train–Test Split**

```python
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

X_train.shape, X_test.shape
```

---

## **2.6 Train a Classification Model (Random Forest)**

```python
from sklearn.ensemble import RandomForestClassifier

rf_clf = RandomForestClassifier(
    n_estimators=200,
    max_depth=None,
    random_state=42,
    n_jobs=-1,
    class_weight="balanced"
)

rf_clf.fit(X_train, y_train)
```

---

## **2.7 Evaluate the Model**

```python
from sklearn.metrics import accuracy_score, precision_score, recall_score, classification_report

y_pred = rf_clf.predict(X_test)

accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred, zero_division=0)
recall = recall_score(y_test, y_pred, zero_division=0)

print(f"Accuracy : {accuracy:.4f}")
print(f"Precision: {precision:.4f}")
print(f"Recall   : {recall:.4f}\n")

print("Classification Report:")
print(classification_report(y_test, y_pred, zero_division=0))
```

* **Accuracy** – overall correctness
* **Precision (fraud class)** – predicted frauds that were actually fraud
* **Recall (fraud class)** – actual frauds that were detected
* Fraud detection usually prioritizes **recall** to avoid missing frauds.

---

## **2.8 Visualize the Confusion Matrix**

```python
import matplotlib.pyplot as plt
from sklearn.metrics import ConfusionMatrixDisplay, confusion_matrix

cm = confusion_matrix(y_test, y_pred, labels=[0, 1])

disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=["Legit (0)", "Fraud (1)"])
fig, ax = plt.subplots(figsize=(5, 5))
disp.plot(ax=ax)
plt.title("Fraud Detection – Confusion Matrix")
plt.show()
```

Discussion:

* **True Positives (TP)** – fraud caught
* **False Positives (FP)** – legit flagged as fraud
* **False Negatives (FN)** – missed fraud (highest risk)
* Precision–Recall tradeoff is important for fraud systems.

---

## **2.9 (Optional) Feature Importance**

```python
feature_importances = pd.Series(
    rf_clf.feature_importances_,
    index=X_train.columns
).sort_values(ascending=False)

feature_importances.head(15)
```

This helps understand which signals—such as **Amount**, **Hour**, or specific merchant/location categories—drive model predictions.

---

## **Summary**

By completing these steps, you have:

* Created and uploaded a fraud dataset to Amazon S3.
* Preprocessed numeric and categorical features.
* Trained a binary classification model in SageMaker Studio.
* Evaluated the model using accuracy, precision, recall, and a confusion matrix.



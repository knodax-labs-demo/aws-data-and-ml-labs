# **Hands-on Lab: Classification – Fraud Detection**

## ⚠️ Lab Disclaimer — Important Cost & Usage Notice

> **Please Read Before Starting the Lab**

The exercises in this chapter involve running AWS services such as **SageMaker**, **Lambda**, **EC2-backed compute**, **S3**, and other on-demand resources. These services are **not free**, and charges may accrue as soon as they are created—**even if they are idle**.

To ensure a safe learning experience, please keep the following in mind:

* **SageMaker Domains, Notebooks, and Real-Time Endpoints** incur **per-hour compute charges** until they are shut down or deleted.
* **Training jobs**, **inference endpoints**, and **Lambda invocations** generate additional usage-based charges.
* **S3 storage**, **CloudWatch Logs**, and **network traffic** may produce small but ongoing costs.
* Any AWS resource left running will continue to be billed by AWS until it is **terminated**.
* This lab is designed for hands-on learning, but you may also simply **read through the steps** without executing them to avoid charges.

**Best Practice:**
At the end of each lab, follow the **Cleanup** section carefully to delete all provisioned resources and prevent unnecessary charges.

---

🎥 YouTube Tutorial:
https://youtu.be/mNU6f8-a9OA
---
📁 Source Code and Data:
https://github.com/knodax-labs-demo/aws-data-and-ml-labs/tree/main/29-classification-fraud-detection
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

## 🔥 Cleanup: Delete the SageMaker Domain After Completing the Exercise

If you no longer need SageMaker Studio and want to avoid ongoing charges, you can delete the entire **SageMaker Domain**.
This will remove:

* User profiles
* Spaces
* Studio applications
* The control plane
* (Optional) Home directory storage

> **Important:** You must delete all **user profiles** and **spaces** before deleting the domain.

---

### 1. List Your SageMaker Domain

```bash
aws sagemaker list-domains
```

You will see something like:

```json
{
  "Domains": [
    {
      "DomainId": "d-abc123xyz",
      "DomainName": "default"
    }
  ]
}
```

Copy your **DomainId** (example: `d-abc123xyz`).

---

### 2. Delete All User Profiles

List them:

```bash
aws sagemaker list-user-profiles --domain-id d-abc123xyz
```

Delete each profile:

```bash
aws sagemaker delete-user-profile \
  --domain-id d-abc123xyz \
  --user-profile-name <PROFILE_NAME>
```

---

### 3. Delete All Spaces (if any)

List:

```bash
aws sagemaker list-spaces --domain-id d-abc123xyz
```

Delete each:

```bash
aws sagemaker delete-space \
  --domain-id d-abc123xyz \
  --space-name <SPACE_NAME>
```

---

### 4. Delete the SageMaker Domain

### ❗ Fix for the `--retention-policy` Error

If you previously saw this error:

```
Error parsing parameter '--retention-policy': Expected: '=', received: 'EOF' for input: Delete
```

It means the CLI requires a **JSON key-value pair**, not just the word `Delete`.

Here is the correct syntax.

---

### 🔵 **Delete the domain and delete home directories (full cleanup)**

```bash
aws sagemaker delete-domain \
  --domain-id d-abc123xyz \
  --retention-policy "{\"HomeEfsFileSystem\": \"Delete\"}"
```

### 🟢 **Delete the domain but keep home directories**

```bash
aws sagemaker delete-domain \
  --domain-id d-abc123xyz \
  --retention-policy "{\"HomeEfsFileSystem\": \"Retain\"}"
```

---

### 5. Verify the Domain Is Gone

```bash
aws sagemaker list-domains
```

You should see an empty list.

---

## ✔️ **Cleanup Summary**

* Delete **Spaces** → required
* Delete **User Profiles** → required
* Delete **Domain with correct JSON retention policy**
* Prevents additional billing from:

  * SageMaker Studio control plane
  * EFS home directories (if deleted)

---

If you want, I can also create a **bash cleanup script** that performs all steps automatically with one command.


## **Summary**

By completing these steps, you have:

* Created and uploaded a fraud dataset to Amazon S3.
* Preprocessed numeric and categorical features.
* Trained a binary classification model in SageMaker Studio.
* Evaluated the model using accuracy, precision, recall, and a confusion matrix.


> **Script: Cleanup SageMaker Studio Domain, User Profiles, and Spaces**

---

```bash
#!/usr/bin/env bash
#
# cleanup_sagemaker_domain.sh
#
# Deleting a SageMaker Space may take some time, as the operation is asynchronous.
# To speed up the cleanup process, consider deleting the Space directly from the console.
#
# Deletes:
#   - All SageMaker Spaces (and their Apps) in a Domain
#   - All User Profiles in a Domain
#   - The SageMaker Domain itself
#
# Usage:
#   ./cleanup_sagemaker_domain.sh                 # auto-detect first domain
#   ./cleanup_sagemaker_domain.sh <DOMAIN_ID>     # delete specific domain
#
# Requirements:
#   - AWS CLI configured (aws configure)
#   - jq installed (for JSON parsing)

set -euo pipefail

REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"

echo "=== SageMaker Domain Cleanup Script ==="
echo "Using region: $REGION"

# 1. Resolve Domain ID
if [ $# -ge 1 ]; then
  DOMAIN_ID="$1"
  echo "Using DOMAIN_ID from argument: $DOMAIN_ID"
else
  echo "No DOMAIN_ID provided, attempting to auto-detect the first domain..."
  DOMAIN_ID=$(aws sagemaker list-domains --region "$REGION" --query "Domains[0].DomainId" --output text)

  if [ "$DOMAIN_ID" = "None" ] || [ -z "$DOMAIN_ID" ]; then
    echo "No SageMaker Domains found in this account/region."
    exit 0
  fi

  echo "Auto-detected DOMAIN_ID: $DOMAIN_ID"
fi

echo
echo "WARNING: This will delete:"
echo "  - All Spaces (and their Apps) in domain: $DOMAIN_ID"
echo "  - All User Profiles in domain: $DOMAIN_ID"
echo "  - The Domain itself (HomeEfsFileSystem = Delete)"
echo
read -p "Type 'DELETE' to continue: " CONFIRM

if [ "$CONFIRM" != "DELETE" ]; then
  echo "Aborted by user."
  exit 1
fi

############################################
# Helper: delete all Apps for a Space + wait
############################################
delete_apps_for_space() {
  local domain_id="$1"
  local space_name="$2"

  echo "Listing apps for space: $space_name"

  while true; do
    APPS_JSON=$(aws sagemaker list-apps \
      --region "$REGION" \
      --domain-id-equals "$domain_id" \
      --space-name-equals "$space_name")

    APP_PAIRS=$(echo "$APPS_JSON" | jq -r '.Apps[]? | "\(.AppType) \(.AppName) \(.Status)"')

    if [ -z "$APP_PAIRS" ]; then
      echo "No apps remaining for space: $space_name"
      break
    fi

    echo "Apps still present for space $space_name:"
    echo "$APP_PAIRS"

    echo "$APP_PAIRS" | while read -r APP_TYPE APP_NAME APP_STATUS; do
      if [ -z "$APP_TYPE" ] || [ -z "$APP_NAME" ]; then
        continue
      fi

      if [ "$APP_STATUS" = "Deleted" ]; then
        echo "  App already in Deleted status: type=$APP_TYPE, name=$APP_NAME"
        continue
      fi

      echo "  Deleting app: type=$APP_TYPE, name=$APP_NAME, status=$APP_STATUS"
      set +e
      aws sagemaker delete-app \
        --region "$REGION" \
        --domain-id "$domain_id" \
        --space-name "$space_name" \
        --app-type "$APP_TYPE" \
        --app-name "$APP_NAME" >/dev/null 2>&1
      RC=$?
      set -e
      if [ $RC -ne 0 ]; then
        echo "    (ignore-if-not-found) delete-app returned code $RC for $APP_TYPE/$APP_NAME"
      fi
    done

    echo "Waiting for apps to be fully deleted..."
    sleep 10
  done
}

#########################################################
# Helper: delete all User Profiles for a domain + wait
#########################################################
delete_user_profiles_for_domain() {
  local domain_id="$1"

  echo
  echo "=== Deleting User Profiles for domain: $domain_id ==="

  while true; do
    UPS_JSON=$(aws sagemaker list-user-profiles \
      --region "$REGION" \
      --domain-id-equals "$domain_id")

    UP_NAMES=$(echo "$UPS_JSON" | jq -r '.UserProfiles[].UserProfileName // empty')

    if [ -z "$UP_NAMES" ]; then
      echo "No user profiles remaining for domain: $domain_id"
      break
    fi

    echo "User profiles still present:"
    echo "$UP_NAMES"

    echo "$UP_NAMES" | while read -r UP_NAME; do
      if [ -z "$UP_NAME" ]; then
        continue
      fi
      echo "  Deleting user profile: $UP_NAME"
      set +e
      aws sagemaker delete-user-profile \
        --region "$REGION" \
        --domain-id "$domain_id" \
        --user-profile-name "$UP_NAME" >/dev/null 2>&1
      RC=$?
      set -e
      if [ $RC -ne 0 ]; then
        echo "    (ignore-if-not-found) delete-user-profile returned code $RC for $UP_NAME"
      fi
    done

    echo "Waiting for user profiles to be fully deleted..."
    sleep 10
  done
}

##########################################
# 2. Delete Spaces (and their Apps)
##########################################
echo
echo "=== Deleting Spaces (and Apps) for domain: $DOMAIN_ID ==="

SPACES_JSON=$(aws sagemaker list-spaces --region "$REGION" --domain-id "$DOMAIN_ID")
SPACE_NAMES=$(echo "$SPACES_JSON" | jq -r '.Spaces[].SpaceName // empty')

if [ -z "$SPACE_NAMES" ]; then
  echo "No spaces found."
else
  echo "$SPACE_NAMES" | while read -r SPACE_NAME; do
    if [ -n "$SPACE_NAME" ]; then
      echo
      echo "---- Processing space: $SPACE_NAME ----"

      # 2a. Delete apps and wait until gone
      delete_apps_for_space "$DOMAIN_ID" "$SPACE_NAME"

      # 2b. Delete the space itself
      echo "Deleting space: $SPACE_NAME"
      aws sagemaker delete-space \
        --region "$REGION" \
        --domain-id "$DOMAIN_ID" \
        --space-name "$SPACE_NAME"
    fi
  done
fi

##########################################
# 3. Delete all User Profiles (with wait)
##########################################
delete_user_profiles_for_domain "$DOMAIN_ID"

##########################################
# 4. Delete the Domain
##########################################
echo
echo "=== Deleting Domain: $DOMAIN_ID ==="
echo "Using retention-policy: {\"HomeEfsFileSystem\": \"Delete\"}"

aws sagemaker delete-domain \
  --region "$REGION" \
  --domain-id "$DOMAIN_ID" \
  --retention-policy "{\"HomeEfsFileSystem\": \"Delete\"}"

echo
echo "=== Cleanup complete. Domain $DOMAIN_ID has been deleted. ==="
```
---

### How to use this in the lab

1. Save as a file, e.g.: `cleanup_sagemaker_domain.sh`
2. Make it executable:

```bash
chmod +x cleanup_sagemaker_domain.sh
```

3. Run one of:

```bash
# Let it auto-detect the first (and usually only) domain
./cleanup_sagemaker_domain.sh

# OR pass a specific DomainId
./cleanup_sagemaker_domain.sh d-xxxxxxxxxxxx
```

The script:

* Deletes **all Spaces** in the domain
* Deletes **all User Profiles** in the domain
* Deletes the **Domain** itself with
  `--retention-policy "{\"HomeEfsFileSystem\": \"Delete\"}"`
  (this avoids the `Expected: '=', received: 'EOF' for input: Delete` error and fully cleans up the EFS home storage).


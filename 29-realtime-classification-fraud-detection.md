## 🔥 Lab Extension: Real-Time Fraud Detection with SageMaker, Lambda, and Postman

### Lab Overview

In this extension lab, you will take the fraud detection model you trained earlier and deploy it as a **SageMaker real-time inference endpoint**, then expose it through an **AWS Lambda function**. You will invoke the Lambda function via an HTTPS **Function URL** (or API Gateway), and use **Postman** to send test transactions and receive fraud predictions in real time.

This demonstrates how a model trained in SageMaker can be integrated into a production-style workflow where external applications call an HTTP endpoint to classify transactions as **fraudulent** or **legitimate**.

---

## Learning Objectives

By the end of this lab, you will be able to:

* Train and deploy a fraud detection model as a **SageMaker real-time endpoint**.
* Create an **AWS Lambda function** that calls `InvokeEndpoint` on SageMaker.
* Expose Lambda via an **HTTPS URL**.
* Use **Postman** to send JSON requests and receive real-time fraud predictions.
* Clean up Lambda and the SageMaker endpoint to avoid ongoing costs.

---

Here is a **clean, professional, lab-ready cost warning Markdown block** specifically tailored for your **Real-Time Fraud Detection with SageMaker, Lambda, and Postman** extension lab.

---

## ⚠️ Cost Warning

> **Important:** This lab uses multiple AWS services that **are not free**, and each resource may generate charges while active.

You may incur costs for:

* **SageMaker Training Jobs** (XGBoost training in this lab).
* **SageMaker Real-Time Endpoints** (billed *per hour* while deployed, even when idle).
* **Lambda function invocations** and **Function URL** traffic.
* **CloudWatch Logs** created by Lambda.
* **S3 storage** for training data, validation data, and model artifacts.

SageMaker endpoints and domain compute are the **most expensive components** and will continue to incur hourly charges **until explicitly deleted**.

If you want to avoid charges, you may follow the tutorial conceptually without running the steps in your AWS account. If you do run the lab, remember to **delete the endpoint, Lambda function, and other created resources immediately after completing the exercise**.

---

## Prerequisites

You should have already completed the **Classification Model – Fraud Detection** lab and:

* Prepared a feature matrix `X` and label vector `y`.
* Trained and evaluated a binary classifier.
* Know the order of feature columns in `X` (e.g., `feature_columns = list(X.columns)`).

This lab will:

1. Prepare training data for SageMaker XGBoost.
2. Train and deploy a SageMaker XGBoost endpoint.
3. Create a Lambda function that calls the endpoint.
4. Use Postman to send a request and see the prediction.
5. Clean up.

---

## Step 1: Prepare Training Data for SageMaker XGBoost

SageMaker’s built-in XGBoost algorithm expects:

* Label in the **first column**.
* CSV format, **no header row**.

In your SageMaker notebook:

```python
import pandas as pd
from sklearn.model_selection import train_test_split

# Combine label + features
data_all = pd.concat([y.reset_index(drop=True), X.reset_index(drop=True)], axis=1)
data_all.columns = ["IsFraud"] + list(X.columns)

train_df, val_df = train_test_split(
    data_all, test_size=0.2, random_state=42, stratify=data_all["IsFraud"]
)

# Save as CSV without header and index
train_df.to_csv("fraud_train.csv", index=False, header=False)
val_df.to_csv("fraud_val.csv", index=False, header=False)
```

Upload the files to S3:

```python
import boto3

bucket = "knodax-ml-specialty-lab-exercises"  # replace if needed
prefix = "fraud-detection-xgb"

s3 = boto3.client("s3")
s3.upload_file("fraud_train.csv", bucket, f"{prefix}/train/fraud_train.csv")
s3.upload_file("fraud_val.csv", bucket, f"{prefix}/validation/fraud_val.csv")
```

---

## Step 2: Train the XGBoost Fraud Classifier in SageMaker

```python
import sagemaker
from sagemaker import image_uris, Estimator
from sagemaker.inputs import TrainingInput

session = sagemaker.Session()
role = sagemaker.get_execution_role()
region = session.boto_region_name

xgb_image = image_uris.retrieve(
    framework="xgboost",
    region=region,
    version="1.5-1",
    image_scope="training"
)

xgb_estimator = Estimator(
    image_uri=xgb_image,
    role=role,
    instance_count=1,
    instance_type="ml.m5.large",
    output_path=f"s3://{bucket}/{prefix}/output",
    sagemaker_session=session
)

xgb_estimator.set_hyperparameters(
    objective="binary:logistic",
    eval_metric="logloss",
    num_round=200,
    max_depth=5,
    eta=0.2,
    subsample=0.8,
    colsample_bytree=0.8
)

train_input = TrainingInput(
    s3_data=f"s3://{bucket}/{prefix}/train/",
    content_type="text/csv"
)

val_input = TrainingInput(
    s3_data=f"s3://{bucket}/{prefix}/validation/",
    content_type="text/csv"
)

xgb_estimator.fit({"train": train_input, "validation": val_input})
```

---

## Step 3: Deploy the Model as a SageMaker Endpoint

```python
from sagemaker.serializers import CSVSerializer
from sagemaker.deserializers import JSONDeserializer

endpoint_name = "fraud-detection-realtime-endpoint"

predictor = xgb_estimator.deploy(
    initial_instance_count=1,
    instance_type="ml.m5.large",
    endpoint_name=endpoint_name
)

predictor.serializer = CSVSerializer()
predictor.deserializer = JSONDeserializer()

print("Endpoint deployed:", endpoint_name)
```

Make a note of:

* `endpoint_name`
* AWS region

You’ll need both when configuring Lambda.

---

## Step 4: Create an IAM Role for Lambda

Go to **IAM → Roles → Create role**:

1. **Trusted entity**: AWS service → **Lambda**.
2. Attach policies:

   * **AWSLambdaBasicExecutionRole** (for CloudWatch Logs).
   * A **custom policy** that allows `sagemaker:InvokeEndpoint` on your endpoint.

Example custom policy JSON (create it under IAM → Policies → Create policy → JSON):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "InvokeFraudEndpoint",
      "Effect": "Allow",
      "Action": [
        "sagemaker:InvokeEndpoint"
      ],
      "Resource": "arn:aws:sagemaker:<your-region>:<your-account-id>:endpoint/fraud-detection-realtime-endpoint"
    }
  ]
}
```

Attach this policy to your Lambda role (for example, name the role `FraudDetectionLambdaRole`).

---

## Step 5: Create the Lambda Function to Call the Endpoint

In the **Lambda console**:

1. Click **Create function**.
2. Choose:

   * **Author from scratch**
   * Name: `fraud-detection-lambda`
   * Runtime: **Python 3.10** (or 3.11)
   * Execution role: **Use existing role** → select `FraudDetectionLambdaRole`
3. Click **Create function**.

Set an **environment variable** on the function:

* Key: `SAGEMAKER_ENDPOINT_NAME`
* Value: `fraud-detection-realtime-endpoint`

Replace the default code with:

```python
import os
import json
import boto3

sm_runtime = boto3.client("sagemaker-runtime")
ENDPOINT_NAME = os.environ.get("SAGEMAKER_ENDPOINT_NAME")

def lambda_handler(event, context):
    """
    Expected input (JSON body):
    {
      "features": [f1, f2, f3, ..., fN]
    }

    'features' must match the order of columns used in training X.
    """

    # If coming from Lambda Function URL or API Gateway HTTP API, body may be a JSON string
    if "body" in event:
        try:
            body = json.loads(event["body"])
        except Exception:
            body = event["body"]
    else:
        body = event

    if isinstance(body, str):
        body = json.loads(body)

    features = body.get("features", None)
    if features is None:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Request must contain 'features' array."})
        }

    # Prepare CSV row for SageMaker (single row, comma-separated, no header)
    csv_payload = ",".join(str(v) for v in features)

    response = sm_runtime.invoke_endpoint(
        EndpointName=ENDPOINT_NAME,
        ContentType="text/csv",
        Body=csv_payload
    )

    result = response["Body"].read().decode("utf-8")
    # For XGBoost in SageMaker, result is usually a JSON-like list, e.g.:
    # [{"score": 0.85}]
    try:
        parsed = json.loads(result)
        score = parsed[0]["score"]
    except Exception:
        # Fallback if model returns raw probability
        score = float(result.strip())

    prediction = int(score >= 0.5)

    return {
        "statusCode": 200,
        "body": json.dumps({
            "fraud_probability": score,
            "prediction": prediction,
            "prediction_label": "FRAUD" if prediction == 1 else "LEGIT"
        })
    }
```

Click **Deploy** to save the function.

---

## Step 6: Expose Lambda via a Function URL

For easy testing with Postman, use a **Lambda Function URL**:

1. In your Lambda function, go to the **Configuration** tab.
2. Click **Function URL** → **Create function URL**.
3. Auth type:

   * For lab/demo: **None** (public; do not use this in production).
   * For production, use IAM or a fronting API Gateway.
4. Click **Save**.

Copy the **Function URL** (e.g., `https://abc123xyz.lambda-url.us-east-1.on.aws/`).

---

## Step 7: Test the Pipeline Using Postman

Open **Postman** and create a new **POST** request:

1. **URL**: Paste the Lambda Function URL (for example):
   `https://abc123xyz.lambda-url.us-east-1.on.aws/`
2. **Method**: `POST`
3. **Headers**:

   * `Content-Type: application/json`
4. **Body** → **raw** → select **JSON** → paste something like:

```json
{
  "features": [
    950.0,
    1,
    0,
    0,
    1,
    0,
    0,
    0,
    1
  ]
}
```

> The `features` array must match the feature vector **order and length** used in training `X`. In your book, you can show the exact order (e.g., `[Amount, Hour, Location_LasVegas, ..., MerchantCategory_LuxuryGoods, ...]`).

Click **Send**.

You should receive a JSON response similar to:

```json
{
  "fraud_probability": 0.8423178792,
  "prediction": 1,
  "prediction_label": "FRAUD"
}
```

Change the feature values and resend to see how the fraud probability changes.

---

## Step 8: Clean Up Resources

To avoid ongoing charges:

1. **Delete Lambda Function URL** or the function itself (in Lambda console).
2. Delete the **SageMaker endpoint** (from the notebook or console):

```python
predictor.delete_endpoint()
print("Endpoint deleted:", endpoint_name)
```

3. Optionally, delete the training artifacts from S3 if no longer needed.

---

## Lab Summary

In this extension lab, you:

* Deployed a fraud detection model as a **SageMaker real-time endpoint**.
* Created a **Lambda function** that calls `InvokeEndpoint`.
* Exposed the function via an **HTTPS URL**.
* Used **Postman** to send JSON payloads and receive fraud predictions.
* Practiced a realistic pattern for serving ML models to external systems.

This demonstrates how an ML model built in SageMaker can be integrated into real-world applications that need **low-latency fraud scoring** via a simple HTTP interface.

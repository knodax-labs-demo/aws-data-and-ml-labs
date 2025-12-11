# # 🧪 Hnads-on Lab: Regression Model – Demand Forecasting

This lab demonstrates how to build a **regression model** that forecasts product demand using historical time-series sales data. You will:

* Load a sample time-series dataset
* Generate 1,000 synthetic realistic demand records
* Upload the dataset to Amazon S3
* Engineer date and lag features
* Train a Linear Regression model (and optionally XGBoost)
* Evaluate using RMSE and MAE
* Visualize predicted vs. actual values

---
🎥 YouTube Tutorial:
https://youtu.be/SVNZA2p4KKM
---
📁 Source Code and Data:
https://github.com/knodax-labs-demo/aws-data-and-ml-labs/tree/main/30-regression-demand-forecasting
---

# ## Step 1: Launch SageMaker Studio Notebook

Follow these steps to start your lab environment:

1. **Log in** to the AWS Management Console and open **Amazon SageMaker**.
2. Select your **SageMaker Domain** and **User Profile**.
3. Click **Launch → Studio**.
4. Inside Studio, choose **File → New → Notebook**.
5. Select a **Python 3 kernel** (e.g., Python 3 (Data Science)).
6. Ensure your execution role has permissions:

### **Minimum S3 Permissions**

* `s3:GetObject`
* `s3:PutObject`
* `s3:ListBucket`

### **SageMaker Permissions**

* `sagemaker:*`

### **Optional for later chapters**

* `bedrock:*`

---

# ## 🔥 Cost Warning

> ⚠️ **AWS Cost Warning — Please Read Before Proceeding**
> This lab uses SageMaker Studio notebook sessions and Amazon S3. These components may incur charges.

### **Costs That May Apply**

* SageMaker **kernel compute time**
* S3 **storage** for uploaded datasets
* Optional SageMaker **training jobs**

### **Cost Best Practices**

* Shut down unused **kernel sessions**
* Delete unnecessary **S3 objects**
* Remove the **SageMaker Domain** after labs (if used only for practice)

💡 **Tip:**
This lab runs entirely in the notebook environment—**no heavy compute jobs**, so cost remains minimal.

---

# ## 📘 Sidebar: Understanding RMSE and MAE

### **🔹 RMSE — Root Mean Squared Error**

* Measures how far predictions deviate from actual values
* Penalizes large errors more strongly
* Good when large forecasting mistakes are costly

**Interpretation Example:**
Predicting 120 when actual is 200 leads to a *big* penalty.

---

### **🔹 MAE — Mean Absolute Error**

* Measures the average size of prediction errors
* Treats all errors equally
* Easy to interpret:

  > “On average, the forecast is off by X units.”

---

### **When to Use Which?**

| Metric   | Best For               | Reason                  |
| -------- | ---------------------- | ----------------------- |
| **RMSE** | Detecting large errors | Emphasizes big mistakes |
| **MAE**  | Simpler interpretation | Average deviation       |

---

# # 3. Regression Model – Demand Forecasting

---

# ## 3.1 Sample Dataset (Base Table)

This is the **original sample dataset** you will expand into 1,000 records:

```
Date,ProductID,StoreID,UnitsSold
2023-01-01,101,1,120
2023-01-02,101,1,135
2023-01-03,101,1,150
2023-01-04,101,1,160
2023-01-05,101,1,155
2023-01-06,101,1,148
2023-01-07,101,1,170
2023-01-08,101,1,165
2023-01-09,101,1,180
2023-01-10,101,1,190
2023-01-11,101,1,175
2023-01-12,101,1,160
2023-01-13,101,1,185
```

---

# ## 3.2 Generate 1,000 Synthetic Demand Records and Upload to S3

### **3.2.1 Setup**

```python
import boto3
import pandas as pd
import numpy as np
from io import StringIO
import sagemaker

session = sagemaker.Session()
region = session.boto_session.region_name

bucket = "<YOUR-S3-BUCKET-NAME>"
prefix = "demand-forecasting-lab"

print("Region:", region)
print("Bucket:", bucket)
```

---

### **3.2.2 Create Base Dataset (Exact Sample)**

```python
csv_content = """Date,ProductID,StoreID,UnitsSold
2023-01-01,101,1,120
2023-01-02,101,1,135
2023-01-03,101,1,150
2023-01-04,101,1,160
2023-01-05,101,1,155
2023-01-06,101,1,148
2023-01-07,101,1,170
2023-01-08,101,1,165
2023-01-09,101,1,180
2023-01-10,101,1,190
2023-01-11,101,1,175
2023-01-12,101,1,160
2023-01-13,101,1,185
"""

base_df = pd.read_csv(StringIO(csv_content))
base_df["Date"] = pd.to_datetime(base_df["Date"])
base_df
```

---

### **3.2.3 Generate Synthetic Data (Total 1,000 records)**

```python
total_records = 1000
existing_records = len(base_df)
new_records = total_records - existing_records

start_date = base_df["Date"].max() + pd.Timedelta(days=1)
date_range = pd.date_range(start=start_date, periods=new_records, freq="D")

np.random.seed(42)

synthetic_rows = []

for dt in date_range:
    dow = dt.dayofweek
    t = (dt - base_df["Date"].min()).days
    
    # Base level around 160 with slight upward drift
    base_level = 160 + 0.02 * t
    
    # Weekend boost
    if dow >= 5:
        base_level += 15
    
    # Noise
    noise = np.random.normal(0, 8)
    
    units_sold = int(np.clip(base_level + noise, 80, 260))
    
    synthetic_rows.append({
        "Date": dt,
        "ProductID": 101,
        "StoreID": 1,
        "UnitsSold": units_sold
    })

synthetic_df = pd.DataFrame(synthetic_rows)
synthetic_df.head()
```

---

### **3.2.4 Combine and Save Dataset**

```python
full_df = pd.concat([base_df, synthetic_df], ignore_index=True)
full_df = full_df.sort_values("Date").reset_index(drop=True)

print("Total rows:", len(full_df))
full_df.head(), full_df.tail()
```

---

### **3.2.5 Upload to S3**

```python
local_path = "sample_demand_forecast.csv"
full_df.to_csv(local_path, index=False)

s3 = boto3.client("s3", region_name=region)
s3_key = f"{prefix}/sample_demand_forecast.csv"

s3.upload_file(local_path, bucket, s3_key)

print(f"Uploaded dataset to s3://{bucket}/{s3_key}")
```

---

# ## 3.3 Load the Dataset from S3

```python
s3_uri = f"s3://{bucket}/{s3_key}"

df = pd.read_csv(s3_uri, parse_dates=["Date"])
df.head()
```

---

# ## 3.4 Feature Engineering (Dates + Lags)

```python
df["Day"] = df["Date"].dt.day
df["Month"] = df["Date"].dt.month
df["DayOfWeek"] = df["Date"].dt.dayofweek
df["IsWeekend"] = (df["DayOfWeek"] >= 5).astype(int)

df = df.sort_values("Date").reset_index(drop=True)
df["Lag_1"] = df["UnitsSold"].shift(1)
df["Lag_2"] = df["UnitsSold"].shift(2)

df = df.dropna().reset_index(drop=True)
df.head()
```

---

# ## 3.5 Train/Test Split (Time-Aware)

```python
feature_cols = ["ProductID", "StoreID", "Day", "Month", "DayOfWeek", "IsWeekend", "Lag_1", "Lag_2"]
target = "UnitsSold"

X = df[feature_cols]
y = df[target]

n = len(df)
train_size = int(n * 0.8)

X_train = X.iloc[:train_size]
y_train = y.iloc[:train_size]

X_test = X.iloc[train_size:]
y_test = y.iloc[train_size:]
```

---

# ## 3.6 Train Linear Regression Model

```python
from sklearn.linear_model import LinearRegression

lr_model = LinearRegression()
lr_model.fit(X_train, y_train)

print("Intercept:", lr_model.intercept_)
print("Coefficients:", dict(zip(feature_cols, lr_model.coef_)))
```

---

# ## 3.7 Evaluate (RMSE, MAE)

```python
from sklearn.metrics import mean_squared_error, mean_absolute_error
import numpy as np

y_pred = lr_model.predict(X_test)

rmse = np.sqrt(mean_squared_error(y_test, y_pred))
mae = mean_absolute_error(y_test, y_pred)

print(f"RMSE: {rmse:.2f}")
print(f"MAE:  {mae:.2f}")
```

---

# ## 3.8 Visualize Actual vs. Predicted

```python
test_results = df.iloc[train_size:].copy()
test_results["Actual"] = y_test.values
test_results["Predicted"] = y_pred

plt.figure(figsize=(12,5))
plt.plot(test_results["Date"], test_results["Actual"], marker="o", label="Actual")
plt.plot(test_results["Date"], test_results["Predicted"], marker="x", label="Predicted")

plt.title("Actual vs Predicted Units Sold")
plt.xlabel("Date")
plt.ylabel("Units Sold")
plt.xticks(rotation=45)
plt.legend()
plt.tight_layout()
plt.show()
```

---

# ## Optional: XGBoost Regression Model

```python
!pip install xgboost -q
from xgboost import XGBRegressor

xgb = XGBRegressor(
    n_estimators=200,
    max_depth=4,
    learning_rate=0.1,
    subsample=0.8,
    colsample_bytree=0.8,
    random_state=42
)

xgb.fit(X_train, y_train)
y_pred_xgb = xgb.predict(X_test)

rmse_xgb = np.sqrt(mean_squared_error(y_test, y_pred_xgb))
mae_xgb = mean_absolute_error(y_test, y_pred_xgb)

print(f"[LinearRegression] RMSE: {rmse:.2f}, MAE: {mae:.2f}")
print(f"[XGBoost]         RMSE: {rmse_xgb:.2f}, MAE: {mae_xgb:.2f}")
```

---

# ## Summary

In this lab, you:

* Created and uploaded a **1,000-record synthetic demand forecasting dataset**
* Parsed date features and engineered lag variables
* Trained a **Linear Regression** and optionally an **XGBoost** model
* Evaluated forecasting quality using **RMSE** and **MAE**
* Visualized predicted vs. actual demand

This exercise demonstrates how regression modeling supports **demand forecasting**, an essential skill in retail analytics, supply-chain decision-making, and inventory optimization.



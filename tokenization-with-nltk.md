# **Hands-on Apply Tokenization on Text Data With NLTK and Store Processed Tokens in S3**

This hands-on exercise focuses on processing textual data using the Natural Language Toolkit (NLTK). You will load a small dataset of user reviews, tokenize and clean the text, convert it into both nested and exploded formats, save the results as CSV files, and upload them to an Amazon S3 bucket for storage and downstream workflows.

---

🎥 **YouTube Tutorial:**  
https://youtu.be/OzmOK92P-0k

---

## **🔧 Objective**

* Load a text dataset (sample reviews).
* Apply tokenization using **nltk.word_tokenize()**.
* Remove punctuation and English stop words.
* Store clean tokens in two formats:

  * **nested_tokens.csv** (list per review)
  * **exploded_tokens.csv** (one token per row)
* Upload results to **Amazon S3** using **boto3**.

---


## **⚠️ Cost Warning**

This lab uses only **S3**, which is extremely low cost.
However, keep the following in mind:

* **PUT requests cost money** (fractions of a cent each).
* **Storing files in S3 costs money**, but small CSVs are negligible.
* **Always delete test files after the lab**, especially in non-Free Tier accounts.
* Use **AWS Budget Alerts** if running multiple S3-based labs.

---

## **📁 File Names Used in This Lab**

| Output Description            | File Name             |
| ----------------------------- | --------------------- |
| Token lists stored as arrays  | `nested_tokens.csv`   |
| Token-per-row exploded format | `exploded_tokens.csv` |

---

## **1. Configure AWS Credentials**

> ⚠️ Never hardcode AWS credentials in code.
> Use `aws configure`, environment variables, or IAM roles (recommended).

```bash
aws configure
# AWS Access Key
# AWS Secret Access Key
# Default region
# Output format (json recommended)
```

**Least-Privilege IAM Policy**

Assign to the user/role that uploads tokens to S3:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::your-bucket-name",
        "arn:aws:s3:::your-bucket-name/*"
      ]
    }
  ]
}
```

---

## **2. Load a Sample Review Dataset**

```python
import pandas as pd

data = {
    "review_id": [1, 2, 3, 4, 5],
    "review_text": [
        "I absolutely loved this product! It works great and the quality is fantastic.",
        "Not bad, but shipping was slow... I might try a different seller next time.",
        "Terrible experience. The item broke in two days and support was unhelpful.",
        "Decent value for the price. Could be better packaged.",
        "Amazing! Fast delivery and excellent customer service. Highly recommend."
    ]
}

df = pd.DataFrame(data)
print(df)
```

---

## **3. Download Required NLTK Resources**

```python
import nltk
nltk.download('punkt')
nltk.download('stopwords')
```

---

## **4. Tokenize and Clean the Text**

Steps performed:

* Tokenize using **word_tokenize**
* Convert to lowercase
* Keep only alphabetic tokens
* Remove English stop words

```python
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords

stop_words = set(stopwords.words("english"))

def clean_tokens(text):
    tokens = word_tokenize(text)
    tokens = [t.lower() for t in tokens]
    tokens = [t for t in tokens if t.isalpha()]
    tokens = [t for t in tokens if t not in stop_words]
    return tokens

df["tokens"] = df["review_text"].apply(clean_tokens)
df
```

---

## **5. Create an Exploded Token Format**

```python
df_exploded = df.explode("tokens")
df_exploded
```

This format is ideal for:

* TF–IDF
* Vocabulary building
* Token-level embeddings
* Hugging Face dataset inputs
* ML preprocessing pipelines

---

## **6. Save Outputs as CSV Files**

```python
df.to_csv("nested_tokens.csv", index=False)
df_exploded.to_csv("exploded_tokens.csv", index=False)
```

---

## **7. Upload Token Files to Amazon S3**

```python
import boto3

s3 = boto3.client("s3")

bucket = "your-bucket-name"

s3.upload_file("nested_tokens.csv", bucket, "text-tokens/nested_tokens.csv")
s3.upload_file("exploded_tokens.csv", bucket, "text-tokens/exploded_tokens.csv")

print("Upload complete.")
```

---

## **8. Verify by Listing Objects**

```python
response = s3.list_objects_v2(Bucket=bucket, Prefix="text-tokens/")
for obj in response.get("Contents", []):
    print(obj["Key"])
```

---

## **📌 Summary**

In this lab, you:

* Loaded a dataset of sample reviews
* Applied tokenization and text cleaning using NLTK
* Stored tokens in nested and exploded formats
* Saved both outputs as CSV files
* Uploaded them to Amazon S3 using boto3
* Followed IAM least-privilege best practices

The processed token files can now be used for:

* NLP ETL workflows
* SageMaker text training
* AWS Glue or Lambda pipelines
* Athena text analytics
* Vocabulary/embedding model preparation



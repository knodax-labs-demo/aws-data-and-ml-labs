# **Hands-on Lab: Use SageMaker Processing Jobs to Extract Features From Text Data Using Tokenization and N-Gram Techniques**

## **Objective**

This lab demonstrates how to use **Amazon SageMaker Processing Jobs** to extract text features using:

* **Tokenization** via NLTK
* **Unigram + bigram extraction**
* **TF-IDF vectorization** via scikit-learn
* Processing at scale using a managed SageMaker container

You will:

1. Upload a dataset to S3
2. Dynamically generate a Python preprocessing script
3. Launch a SageMaker **Processing Job**
4. Save extracted TF-IDF feature vectors back to S3

---

🎥 **YouTube Tutorial:**  
https://youtu.be/8yNm7omBEvg

---
📁 **Source Code and Data:**  
https://github.com/knodax-labs-demo/aws-data-and-ml-labs/tree/main/16-sagemaker-processing-text-feature-extraction-tfidf-ngram

---



> ⚠️ **AWS Cost Warning**
>
> SageMaker Processing Jobs run on paid compute instances (e.g., `ml.t3.medium`), and S3 storage + CloudWatch logs may incur charges.
>
> To minimize costs:
>
> * Use the smallest suitable instance (`ml.t3.medium`)
> * Delete S3 output folders after validating results
> * Remove CloudWatch logs if not needed
> * Avoid re-running processing jobs unnecessarily
> * Set an AWS Budget alert ($5 recommended)
>
> Always clean up S3 outputs and SageMaker resources after completing the lab.

---

# **Prerequisites**

* A text dataset stored in S3
* AWS credentials configured via:

  ```
  aws configure
  ```
* Python libraries:

  * `boto3`
  * `nltk`
  * `pandas`
  * `scikit-learn`
  * `sagemaker`

---

# **Sample Input (customer_reviews.csv)**

```csv
review_id,review_text
1,"Great product and fast delivery."
2,"Very satisfied with the quality."
3,"Poor packaging but good value."
4,"The item arrived broken and I’m very disappointed."
5,"Excellent quality and amazing support team."
6,"Not worth the price. Would not buy again."
7,"Quick delivery but the product did not match the description."
8,"Absolutely love it! Highly recommended."
9,"Terrible experience. Customer service was unhelpful."
10,"Decent purchase for the price, but could be better."
```

---

# **Step 1: Upload the Dataset to Amazon S3**

```python
import boto3
 
# Upload Dataset to S3
s3 = boto3.client('s3')
s3.upload_file(
    'customer_reviews.csv',
    's3bucket-feature-engineering',
    'input/customer_reviews.csv'
)
print("The file uploaded successfully to S3")
```

### **Explanation**

* Uploads the file to:

  ```
  s3://s3bucket-feature-engineering/input/customer_reviews.csv
  ```
* This path will be used as the **ProcessingInput** location for SageMaker.

---

# **Step 2: Create the TF-IDF Processing Script**

This script installs NLTK, downloads tokenizers, loads input data, computes TF-IDF with n-grams, and saves the features.

```python
# Create text_processing.py Script
script_content = """
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
 
import subprocess
subprocess.check_call(["pip", "install", "nltk"])
 
import nltk
nltk.download('punkt')
from nltk.tokenize import word_tokenize
 
df = pd.read_csv('/opt/ml/processing/input/customer_reviews.csv')
vectorizer = TfidfVectorizer(ngram_range=(1,2), tokenizer=word_tokenize)
X = vectorizer.fit_transform(df['review_text'])
output_df = pd.DataFrame(X.toarray(), columns=vectorizer.get_feature_names_out())
output_df.to_csv('/opt/ml/processing/output/tfidf_features.csv', index=False)
"""
 
with open('text_processing.py', 'w') as f:
    f.write(script_content)
 
print("The file text_processing.py created successfully.")
```

### **Explanation**

* The script runs inside the SageMaker container at:

  * Input → `/opt/ml/processing/input/`
  * Output → `/opt/ml/processing/output/`
* Uses:

  * **NLTK** for tokenization
  * **TF-IDF** with n-grams `(1,2)`

---

# **Step 3: Configure the SageMaker Processing Job**

```python
print("Starting to run Processing Job via SageMaker SDK")

from sagemaker.processing import ScriptProcessor, ProcessingInput, ProcessingOutput
import sagemaker
 
role = 'arn:aws:iam::XXXXXXXXXXXX:role/service-role/AmazonSageMaker-ExecutionRole'
 
script_processor = ScriptProcessor(
    image_uri='683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:1.2-1',
    role=role,
    instance_count=1,
    instance_type='ml.t3.medium',
    command=['python3']
)
 
print("Script processor is executed successfully.")
```

### **Explanation**

* Uses Amazon’s built-in Scikit-Learn Docker image
* IAM role must allow **S3 read/write**
* Uses **ml.t3.medium** (cost-efficient for text preprocessing)

---

# **Step 4: Run the SageMaker Processing Job**

```python
print("SageMaker is going to run script_processor which will run text_processing.py.")

script_processor.run(
    code='text_processing.py',
    inputs=[
        ProcessingInput(
            source='s3://s3bucket-feature-engineering/input/',
            destination='/opt/ml/processing/input'
        )
    ],
    outputs=[
        ProcessingOutput(
            source='/opt/ml/processing/output',
            destination='s3://s3bucket-feature-engineering/output'
        )
    ]
)
 
print("text_processing.py is executed successfully by SageMaker.")
```

### **Explanation**

* **ProcessingInput** maps S3 input → container input directory
* **ProcessingOutput** maps container output → S3 output
* Output file:

  ```
  s3://s3bucket-feature-engineering/output/tfidf_features.csv
  ```

---

# **Final Result**

After the processing job completes, you will find:

### **Output File**

```
s3://s3bucket-feature-engineering/output/tfidf_features.csv
```

### **What the file contains**

* Rows → individual reviews
* Columns → unigrams + bigrams
* Values → TF-IDF scores representing term importance

You can now use the output for:

* Text classification
* Sentiment analysis
* Clustering
* Topic modeling
* Feature visualization

---

# **Optional Clean-Up (Recommended)**

### **1. Delete S3 Output**

```python
s3 = boto3.resource('s3')
bucket = s3.Bucket('s3bucket-feature-engineering')
bucket.objects.filter(Prefix='output/').delete()
```

### **2. Delete CloudWatch Logs**

* Go to **CloudWatch Console → Logs** and remove logs from the processing job
* This prevents long-term storage costs

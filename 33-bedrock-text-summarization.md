# Generative AI Text Summarization with Amazon Bedrock (Claude Sonnet)

This hands-on lab demonstrates how to build a **text summarization solution using Amazon Bedrock foundation models**, specifically the **Anthropic Claude 3.5 Sonnet** model. You will explore both **console-based experimentation** using the Bedrock Playground and **programmatic model invocation** using **Amazon SageMaker Studio** and the **Bedrock Runtime API**.

---

## Lab Objectives

By completing this lab, you will be able to:

* Use Amazon Bedrock to access a foundation model (Claude Sonnet)
* Run summarization in the Bedrock Playground
* Invoke Claude programmatically using Python (`bedrock-runtime`)
* Clean up SageMaker resources to avoid extra charges

---

## Cost Warning ⚠️

Amazon Bedrock is **not free**. Claude invocations are billed based on **input + output tokens**, and pricing varies by model. SageMaker Studio is also a **paid service**, and costs often come from leaving notebooks/spaces/domains running.

To minimize costs:

* Keep text inputs small
* Set `max_tokens` around **150–250**
* Run only what you need
* **Delete resources immediately after the lab**

---

## Prerequisites

* AWS account with access to **Amazon Bedrock** and **Amazon SageMaker**
* A supported Bedrock Region (e.g., `us-east-1` or `us-west-2`)
* IAM role/user permissions to:
  * Invoke Bedrock models
  * Create SageMaker Domain/Space (for Studio)
* (Recommended) IAM policy: **AmazonBedrockFullAccess**

---

## Step 1: Sign In and Select Region

1. Sign in to the **AWS Management Console**
2. Choose a Bedrock-supported region (this lab uses **us-east-1**)

---

## Step 2: Run Summarization in Bedrock Playground

1. Open **Amazon Bedrock** console
2. Click **Model catalog**
3. Select **Anthropic Claude 3.5 Sonnet**
4. Click **Open in Playground**
5. Enter a summarization prompt and click **Run**

---

## Step 3: Launch Amazon SageMaker Studio

1. Open **Amazon SageMaker** → **SageMaker Studio**
2. If prompted, create a **SageMaker Domain**:

   * Choose **Set up for single user**
   * Click **Set Up**

---

## Step 4: Configure the SageMaker User Profile (Bedrock Permissions)

Before launching Studio, ensure your **SageMaker user profile** uses an IAM role with Bedrock permissions.

* Confirm the role includes **AmazonBedrockFullAccess**
* Update the user profile role if needed
* Return to the SageMaker console

---

## Step 5: Create and Run a JupyterLab Space

1. Create a **JupyterLab Space**
2. Provide a name and accept defaults
3. Run the space and open **JupyterLab**

---

## Step 6: Create the Notebook

1. Create a new notebook in JupyterLab
2. Rename it (example): `bedrock-text-summarization.ipynb`

---

## Step 7: Notebook Code (Install → Invoke → Extract Summary)

### 7.1 Install dependencies (from notebook)

```bash
pip install -U boto3 botocore
```

> In the notebook, this was executed as:
>
> ```python
> !pip -q install -U boto3 botocore
> ```

---

### 7.2 Invoke Claude Sonnet via Bedrock Runtime (from notebook, completed)

```python
import json
import boto3

# -------- Config --------
region = "us-east-1"

# Use an on-demand (pay-per-request) model ID
model_id = "anthropic.claude-3-5-sonnet-20240620-v1:0"

client = boto3.client("bedrock-runtime", region_name=region)

# -------- Input Text --------
text_block = """
Artificial Intelligence (AI) has emerged as a transformative technology across industries,
revolutionizing how businesses operate and interact with customers. From automating routine tasks
to providing personalized recommendations, AI is enabling organizations to improve efficiency,
reduce costs, and deliver better customer experiences.
"""

prompt = f"Summarize the following text in 3–4 sentences:\n\n{text_block}"

# -------- Request Body (Claude Messages API format) --------
body = {
    "anthropic_version": "bedrock-2023-05-31",
    "max_tokens": 200,
    "temperature": 0.3,
    "messages": [
        {
            "role": "user",
            "content": [{"type": "text", "text": prompt}]
        }
    ]
}

# -------- Invoke Model --------
response = client.invoke_model(
    modelId=model_id,
    contentType="application/json",
    accept="application/json",
    body=json.dumps(body),
)

# -------- Parse Response --------
result = json.loads(response["body"].read())
summary = "".join(block.get("text", "") for block in result.get("content", []))

print("----- Summary -----")
print(summary)
```

**What this code does:**

* Creates a Bedrock Runtime client (`bedrock-runtime`)
* Sends a summarization prompt to **Claude 3.5 Sonnet**
* Controls output using `max_tokens` and `temperature`
* Parses the structured JSON response and prints the summary

---

## Expected Output

After running the notebook, you should see a **3–4 sentence summary** printed in the cell output.

---

## Cleanup (Required)

To avoid unnecessary charges:

1. **Delete the JupyterLab Space**
2. **Delete the SageMaker Domain**
3. Confirm deletion completes so all resources are released

---

## Conclusion

You successfully ran **Generative AI text summarization** using Amazon Bedrock and **Anthropic Claude Sonnet**, first through the console Playground and then programmatically using SageMaker Studio and the Bedrock Runtime API.


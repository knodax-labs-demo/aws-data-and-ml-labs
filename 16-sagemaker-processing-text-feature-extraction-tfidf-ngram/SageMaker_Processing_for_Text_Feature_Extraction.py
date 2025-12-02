import boto3

s3 = boto3.client('s3')
s3.upload_file('customer_reviews.csv', 'knodax-feature-engineering', 'input/customer_reviews.csv')
print("The file uploaded successfully to S3")

script_content = """
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer

import subprocess
subprocess.check_call(["pip", "install", "nltk"])

import nltk
nltk.download('punkt_tab')
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

from sagemaker.processing import ScriptProcessor, ProcessingInput, ProcessingOutput

role = 'arn:aws:iam::383246081810:role/service-role/AmazonSageMaker-ExecutionRole-20250406T193573'

script_processor = ScriptProcessor(
    image_uri='683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:1.2-1',
    role=role,
    instance_count=1,
    instance_type='ml.t3.medium',
    command=['python3']
)
print("Script processor is executed successfully.")

print("SageMaker is going to run script_processor which will run text_processing.py.")
script_processor.run(
    code='text_processing.py',
    inputs=[ProcessingInput(source='s3://knodax-feature-engineering/input/', destination='/opt/ml/processing/input')],
    outputs=[ProcessingOutput(source='/opt/ml/processing/output', destination='s3://knodax-feature-engineering/output')]
)

print("text_processing.py is executed successfully by SageMaker.")
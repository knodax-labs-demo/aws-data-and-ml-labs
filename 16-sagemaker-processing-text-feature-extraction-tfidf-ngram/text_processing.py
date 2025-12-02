
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

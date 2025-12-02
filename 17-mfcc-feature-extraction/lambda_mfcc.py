import boto3
import librosa
import pandas as pd
import os

# Write Your Lambda Function (MFCC Example)
def lambda_handler(event, context):
    os.environ['NUMBA_DISABLE_CACHE'] = '1'
    os.environ["NUMBA_CACHE_DIR"] = "/tmp"

    s3 = boto3.client('s3')
    bucket = event['Records'][0]['s3']['bucket']['name']
    print("bucket " + bucket)

    key = event['Records'][0]['s3']['object']['key']
    print("key " + key)

    # Check prefix and suffix
    prefix_required = "input/TranscribeDemo"
    suffix_required = ".wav"

    if not key.startswith(prefix_required) or not key.endswith(suffix_required):
        print(f"Skipping file: {key} (prefix/suffix does not match)")
        return {
            "statusCode": 200,
            "body": f"Ignored file: {key}"
        }

    audio_path = "/tmp/TranscribeDemo.wav"

    s3.download_file(bucket, f'{key}', audio_path)

    # Extract MFCC features
    y, sr = librosa.load(audio_path)
    mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13)

    # Transpose to shape (num_frames, 13) and convert to DataFrame
    df = pd.DataFrame(mfcc.T)
    df.columns = [f"mfcc_{i+1}" for i in range(df.shape[1])]

    # Convert to CSV string
    output_str = df.to_csv(index=False)

    # Save to S3
    output_key = f'features/{key.replace(".wav", "_mfcc.csv")}'
    s3.put_object(Bucket=bucket, Key=output_key, Body=output_str.encode('utf-8'))
    print("ExtractMFCCLambda function executed successfully.")

    return {
        "statusCode": 200,
        "body": f"MFCC features saved to s3://{bucket}/{output_key}"
    }

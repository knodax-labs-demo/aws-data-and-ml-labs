import boto3

# Upload Audio via Python
s3 = boto3.client('s3')
s3.upload_file('TranscribeDemo.wav', 'knodax-feature-engineering', 'input/TranscribeDemo.wav')
print("The audio wav file uploaded successfully.")

# Start Transcribe Job
transcribe = boto3.client('transcribe')

transcribe.start_transcription_job(
    TranscriptionJobName='TranscribeDemo',
    Media={'MediaFileUri': 's3://knodax-feature-engineering/input/TranscribeDemo.wav'},
    MediaFormat='wav',
    LanguageCode='en-US',
    OutputBucketName='knodax-feature-engineering'
)

print("transcribe job completed successfully")

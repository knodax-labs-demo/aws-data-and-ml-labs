import boto3
import base64

client = boto3.client('kinesis', region_name='us-east-1')  # adjust region

stream_name = 'ml-streaming-input'
shard_id = client.describe_stream(StreamName=stream_name)['StreamDescription']['Shards'][0]['ShardId']

# Get shard iterator
shard_iter = client.get_shard_iterator(
    StreamName=stream_name,
    ShardId=shard_id,
    ShardIteratorType='TRIM_HORIZON'  # or 'LATEST'
)['ShardIterator']

# Read records
response = client.get_records(ShardIterator=shard_iter, Limit=10)
for record in response['Records']:
    print(record['Data'].decode('utf-8'))

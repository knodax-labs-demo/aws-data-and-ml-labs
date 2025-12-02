aws lambda create-function \
  --function-name ExtractMFCCLambda \
  --package-type Image \
  --code ImageUri=383246081810.dkr.ecr.us-east-1.amazonaws.com/mfcc-lambda:latest \
  --role arn:aws:iam::383246081810:role/service-role/demo-lambda-role-senk8wh7 \
  --timeout 300 \
  --memory-size 512

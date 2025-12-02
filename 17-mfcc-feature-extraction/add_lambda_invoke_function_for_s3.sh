aws lambda add-permission \
  --function-name ExtractMFCCLambda \
  --principal s3.amazonaws.com \
  --statement-id s3invokeaccess \
  --source-account 383246081810 \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:s3:::knodax-feature-engineering \
  --region us-east-1

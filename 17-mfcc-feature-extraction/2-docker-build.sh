# Authenticate to ECR using AWS CLI
# The command aws ecr get-login-password retrieves a temporary authentication token
# for accessing your Amazon ECR registry. This token is then passed to docker login, which authenticates
# your local Docker client with ECR, allowing you to push or pull container images securely.
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 383246081810.dkr.ecr.us-east-1.amazonaws.com

# Make Sure the ECR Repository Exists
# This is required before you can push your image.
aws ecr create-repository --repository-name mfcc-lambda

# Build the image using a Lambda-compatible base image and architecture.
docker buildx create --use   # (optional, if not set up)

# if you do not include --load it will only have in the cache
docker buildx build --platform linux/amd64 -t mfcc-lambda . --load

# Tag (replace YOUR_ACCOUNT_ID and region)
docker tag mfcc-lambda:latest 383246081810.dkr.ecr.us-east-1.amazonaws.com/mfcc-lambda

# Push (you must create the repo first or use AWS CLI `ecr create-repository`)
docker push 383246081810.dkr.ecr.us-east-1.amazonaws.com/mfcc-lambda
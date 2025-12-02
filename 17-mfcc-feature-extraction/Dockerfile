FROM public.ecr.aws/lambda/python:3.9

ENV NUMBA_DISABLE_CACHE=1

# Optional: also set TMPDIR if needed for temp files
ENV TMPDIR=/tmp

# Install system dependencies
RUN yum -y update && \
    yum -y install python3 pip gcc ffmpeg libsndfile && \
    yum clean all

# Install required libraries
RUN pip install librosa boto3 numpy pandas

# Copy your handler code
COPY lambda_mfcc.py .

# Command for Lambda
CMD ["lambda_mfcc.lambda_handler"]

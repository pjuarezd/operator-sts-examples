#Example with AWS Python SDK
import boto3
import logging

logger = logging.getLogger()
logger.addHandler(logging.StreamHandler()) # Writes to console
logger.setLevel(logging.DEBUG)
logging.getLogger('boto3').setLevel(logging.DEBUG)
logging.getLogger('botocore').setLevel(logging.DEBUG)
logging.getLogger('s3transfer').setLevel(logging.CRITICAL)
logging.getLogger('urllib3').setLevel(logging.CRITICAL)


s3 = boto3.resource('s3')
my_bucket = s3.Bucket('logs.minio.pedrojuarez.me')
for my_bucket_object in my_bucket.objects.all():
    print(my_bucket_object)
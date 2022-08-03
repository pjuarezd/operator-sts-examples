#Example with AWS Python SDK
import boto3

an_policy = """
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
"""

sts = boto3.client('sts', endpoint_url='http://operator.minio-operator.svc.cluster.local:4221/sts/')
assumed_role_object = sts.assume_role_with_web_identity(
    RoleArn='minio-tenant-1/minio-tenant',
    RoleSessionName='optional-session-name',
    Policy=an_policy,
    DurationSeconds=25536
)

credentials = assumed_role_object['Credentials']

s3_client = boto3.resource('s3',
    aws_access_key_id=credentials['AccessKeyId'],
    aws_secret_access_key=credentials['SecretAccessKey'],
    aws_session_token=credentials['SessionToken'],
    endpoint_url='http://minio.minio-tenant-1.svc.cluster.local')

my_bucket = s3_client.Bucket('kafka')
for my_bucket_object in my_bucket.objects.all():
    print(my_bucket_object)

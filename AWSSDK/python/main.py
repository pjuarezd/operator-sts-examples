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

sts = boto3.client('sts', endpoint_url='https://sts.minio-operator.svc.cluster.local:4222/sts/')

jwt_token_path = '/var/run/secrets/kubernetes.io/serviceaccount/token'

sa_jwt = open(jwt_token_path, "r")

assumed_role_object = sts.assume_role_with_web_identity(
    RoleArn='arn:aws:iam:::role/root',
    RoleSessionName='optional-session-name',
    Policy=an_policy,
    DurationSeconds=25536,
    WebIdentityToken=sa_jwt.read()
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

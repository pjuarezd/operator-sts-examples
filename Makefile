

.PHONY: imdsv2_go imdsv2_python

imdsv2_go:
	@cd IMDSV2_go && \
	GOOS=linux go build -o ../client

copy:
	@scp -i ~/Downloads/kp-minio.pem client ec2-user@54.172.157.115:~

invoke:
	@ssh -i ~/Downloads/kp-minio.pem  ec2-user@54.172.157.115 /home/ec2-user/client

imdsv2_python:
	@cd IMDSV2_python && \
	pip3 install -r requirements.txt && \
	AWS_EC2_METADATA_SERVICE_ENDPOINT=http://operator.minio-operator.svc.cluster.local:4221 python3 main.py

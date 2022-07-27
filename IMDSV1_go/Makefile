all: build

build:
	@GOOS=linux go build -o client
	@scp -i ~/Downloads/kp-minio.pem client ec2-user@54.172.157.115:~
invoke:
	@ssh -i ~/Downloads/kp-minio.pem  ec2-user@54.172.157.115 /home/ec2-user/client

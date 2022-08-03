MINIO_VERSION ?=latest
MINIO_TENANT_NAMESPACE ?=minio-tenant-1
MINIO_TENANT_NAME ?=minio-tenant
GET_LATEST_MINIO_VERSION = $(eval MINIO_VERSION=$(shell curl -sL https://api.github.com/repos/minio/operator/releases/latest | jq -r ".tag_name"))

create-kind-cluster:
	@kind create cluster --config kind-cluster.yaml
	
delete-kind-cluster:
	@kind delete cluster --name kind-cluster

operator-namespace:
	@kubectl create namespace $(OPERATOR_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -

minio-operator: operator-namespace
ifeq "$(MINIO_VERSION)"  "latest"
	$(GET_LATEST_MINIO_VERSION)
endif
	@kubectl apply -k github.com/minio/operator/\?ref\=${MINIO_VERSION} -n minio-operator
	@kubectl minio init
	@kubectl apply -f example-setup/console-sa-secret.yaml -n minio-operator
	@kubectl wait --for=condition=ready pod -l name=minio-operator -n minio-operator --timeout=600s
	@kubectl -n minio-operator get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode > minio-operator.key

setup-bucket:
	@kubectl apply -f example-setup/setup-bucket-job.yaml -n $(MINIO_TENANT_NAMESPACE)
	@kubectl wait --for=condition=complete Job/setup-bucket --timeout=300s -n $(MINIO_TENANT_NAMESPACE)

minio-tenant:
	@kubectl create namespace $(MINIO_TENANT_NAMESPACE)  --dry-run=client -o yaml | kubectl apply -f -
	@kubectl minio tenant create $(MINIO_TENANT_NAME)   \
		--servers                 3                          \
		--volumes                 6                          \
		--capacity                16Ti                       \
		--storage-class           standard                   \
		--namespace               $(MINIO_TENANT_NAMESPACE)  \
		--disable-tls

awssdk-python:
	@docker build -t pjuarezd/minio-operator-sts-example-python:latest operator-sts/AWSSDK/python/
	@kubectl apply -f operator-sts/AWSSDK/python/job.yaml
	@kubectl wait --for=condition=complete Job/python-example --timeout=300s -n myapplication

miniosdk-go:
	@go install && go build -o client
	@docker build -t pjuarezd/minio-operator-sts-example-go:latest operator-sts/MinioSDK/go/
	@kubectl apply -f operator-sts/MinioSDK/go/job.yaml
	@kubectl wait --for=condition=complete Job/go-example --timeout=300s -n gosdk

package main

import (
	"context"
	"fmt"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

func main() {
	endpoint := "minio.minio-tenant-1.svc.cluster.local"
	operatorEndpoint := "http://operator.minio-operator.svc.cluster.local:4221/sts/"
	useSSL := true

	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewIAM(operatorEndpoint),
		Secure: useSSL,
	})

	if err != nil {
		fmt.Println(err)
		return
	}

	opts := minio.ListObjectsOptions{
		UseV1:     true,
		Prefix:    "/",
		Recursive: true,
	}

	for object := range minioClient.ListObjects(context.Background(), "kafka", opts) {
		if object.Err != nil {
			fmt.Println(object.Err)
			return
		}
		fmt.Println(object)
	}
	return
}

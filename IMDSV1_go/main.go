package main

import (
	"context"
	"fmt"
	"log"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

func main() {
	endpoint := "s3.amazonaws.com"
	useSSL := true

	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewIAM(""),
		Secure: useSSL,
	})

	if err != nil {
		log.Fatalln(err)
	}

	log.Printf("oops %#v\n", minioClient) // minioClient is now set up

	ctx, cancel := context.WithCancel(context.Background())

	defer cancel()

	objectCh := minioClient.ListObjects(ctx, "logs.minio.pedrojuarez.me", minio.ListObjectsOptions{
		Prefix:    "",
		Recursive: true,
	})
	for object := range objectCh {
		if object.Err != nil {
			fmt.Println(object.Err)
			return
		}
		fmt.Println(object)
	}
}

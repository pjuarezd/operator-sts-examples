
FROM ubuntu:latest
WORKDIR /root
COPY client .

RUN \
    apt-get update && \
    apt-get install -y curl ca-certificates golang-go

CMD ["./client"]

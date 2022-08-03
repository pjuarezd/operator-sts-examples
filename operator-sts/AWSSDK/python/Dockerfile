FROM ubuntu:latest
WORKDIR /root
COPY main.py .
COPY requirements.txt .

RUN \
    apt-get update && \
    apt-get install -y curl ca-certificates python3 python3-pip
RUN pip3 install -r requirements.txt
CMD ["./python3 main.py"]

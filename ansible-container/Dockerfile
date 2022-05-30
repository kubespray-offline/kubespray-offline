#FROM ubuntu:20.04
#RUN apt update && apt install -y python3 python3-pip python3-selinux && apt clean

FROM python:3.8-slim

RUN apt update \
    && apt install -y openssh-client sshpass \
    && apt clean

RUN pip install --no-cache-dir -U pip

COPY requirements.txt /root/
RUN pip install --no-cache-dir -r /root/requirements.txt

RUN pip install --no-cache-dir selinux

# Make ~/.ansible writable
RUN mkdir /root/.ansible && chmod 777 /root/.ansible

WORKDIR /work

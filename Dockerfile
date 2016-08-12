FROM python:3.7-slim-stretch

RUN apt-get update && \
    apt-get install --yes curl netcat

RUN pip3 install --upgrade pip

RUN mkdir /var/nameko/

COPY requirements.txt .
RUN pip install -r requirements.txt 

# Tests configuration
COPY .coveragerc .

ENV PYTHONPATH=/var/nameko

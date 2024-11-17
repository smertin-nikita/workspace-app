FROM python:3.12-slim

WORKDIR /usr/src/app
RUN pip install locust

COPY app .

ENTRYPOINT ["locust"]

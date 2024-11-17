FROM ubuntu:24.10 AS base-build-image

RUN apt-get update && \
    apt-get install --no-install-recommends -y  \
    python3 \
    python3-dev \
    python3-venv \
    python3-pip \
    python3-wheel  \
    build-essential \
    &&  \
    apt-get clean && rm -rf /var/lib/apt/lists/*


RUN python3 -m venv /home/backend/venv
ENV PATH="/home/backend/venv/bin:$PATH"

# Install requirements
COPY ../../requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt && \
    opentelemetry-bootstrap -a install

FROM ubuntu:24.10 AS runner-image

RUN apt-get update && apt-get install --no-install-recommends -y  \
    python3  \
    curl  \
    &&  \
	apt-get clean && rm -rf /var/lib/apt/lists/* && \
    useradd -s /bin/bash --create-home backend

USER backend

COPY --from=base-build-image /home/backend/venv /home/backend/venv

WORKDIR /home/backend/
COPY app src/app


ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
# activate virtual environment
ENV VIRTUAL_ENV=/home/backend/venv
ENV PATH="/home/backend/venv/bin:$PATH"

# Default app's config path
ENV CONFIG_PATH=/home/backend/src/app/config/config.yaml

ENV PYTHONPATH=/home/backend/src

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ENV DEBUG=false

ENTRYPOINT ["uvicorn", "src.app.main:app",  "--host", "0.0.0.0", "--port", "8000"]

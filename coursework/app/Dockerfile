FROM public.ecr.aws/docker/library/python:3.12-slim AS build
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM public.ecr.aws/docker/library/python:3.12-slim
WORKDIR /var/task
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter

RUN apt-get update && apt-get install -y --no-install-recommends libpq5 && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local /usr/local
COPY . .

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DJANGO_SETTINGS_MODULE=mysite.settings \
    PORT=8000 \
    AWS_LWA_PORT=8000

EXPOSE 8000

CMD ["gunicorn", "mysite.wsgi:application", "-w=1", "-b=0.0.0.0:8000"]

FROM python:3.12-slim AS build
WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY ../../requirements.txt .

RUN pip install --no-cache-dir --upgrade pip==24.0 \
    && pip install --no-cache-dir -r requirements.txt

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local /usr/local

RUN adduser --disabled-password --gecos "" appuser
USER appuser

WORKDIR /app

COPY --chown=appuser:appuser ../.. /app/

RUN mkdir -p /app/staticfiles && chown appuser:appuser /app/staticfiles

COPY --chown=appuser:appuser entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

CMD ["/app/entrypoint.sh"]
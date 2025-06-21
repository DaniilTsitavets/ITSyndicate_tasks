#!/bin/sh
echo "Waiting for PostgreSQL..."

while ! nc -z "$POSTGRES_DB" "5432"; do
  sleep 0.1
done

echo "PostgreSQL is up"

echo "Running migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting server..."

exec gunicorn mysite.wsgi:application --bind 0.0.0.0:8000

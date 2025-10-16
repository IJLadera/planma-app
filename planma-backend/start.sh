#!/bin/bash
set -e

echo "=== Running Django migrations ==="
python manage.py migrate --noinput

echo "=== Collecting static files ==="
python manage.py collectstatic --noinput

echo "=== Starting Celery worker in background ==="
celery -A planmaDB worker -l info &

echo "=== Starting Celery Beat in background ==="
celery -A planmaDB beat -l info --scheduler django_celery_beat.schedulers:DatabaseScheduler &

echo "=== Starting Daphne server ==="
daphne -b 0.0.0.0 -p $PORT planmaDB.asgi:application

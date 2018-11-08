release: python manage.py migrate --no-input
web: uwsgi headspace/wsgi/uwsgi.ini
celeryworker: celery worker -A headspace.celeryconf:app --loglevel=info -E
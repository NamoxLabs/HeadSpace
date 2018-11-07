#FROM python:3
#ENV PYTHONUNBUFFERED 1
#RUN mkdir /code
#WORKDIR /code
#ADD requirements.txt /code/
#RUN pip install -r requirements.txt
#ADD . /code/

### Build and install packages
FROM python:3.6 as build-python

RUN \
  apt-get -y update && \
  apt-get install -y gettext && \
  # Cleanup apt cache
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install pipenv
ADD Pipfile /code/
ADD Pipfile.lock /code/
WORKDIR /code
RUN pipenv install --system --deploy --dev

### Build static assets
FROM node:10 as build-nodejs

ARG STATIC_URL
ENV STATIC_URL ${STATIC_URL:-/static/}

# Install node_modules
ADD webpack.config.js app.json package.json package-lock.json tsconfig.json webpack.d.ts /code/
WORKDIR /code
RUN npm install

# Build static
ADD ./static /code/headspace/static/
ADD ./templates /code/templates/
#RUN \
#    yarn install
#RUN \
#  STATIC_URL=${STATIC_URL} \
#  npm run build-assets --production && \
#  npm run build-emails --production


### Final image
FROM python:3.6-slim

ARG STATIC_URL
ENV STATIC_URL ${STATIC_URL:-/static/}

RUN \
  apt-get update && \
  apt-get install -y libxml2 libssl1.1 libcairo2 libpango-1.0-0 libpangocairo-1.0-0 libgdk-pixbuf2.0-0 shared-mime-info mime-support && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ADD . /app
COPY --from=build-python /usr/local/lib/python3.6/site-packages/ /usr/local/lib/python3.6/site-packages/
COPY --from=build-python /usr/local/bin/ /usr/local/bin/
COPY --from=build-nodejs /code/headspace/static /code/headspace/static
COPY --from=build-nodejs /code/webpack-bundle.json /code/
COPY --from=build-nodejs /code/templates /code/templates
WORKDIR /code


RUN SECRET_KEY=dummy \
    STATIC_URL=${STATIC_URL} \
    python3 manage.py collectstatic --no-input

RUN useradd --system headspace && \
    mkdir -p /code/media /code/static && \
    chown -R headspace:headspace /code/

USER headspace


EXPOSE 8000
ENV PORT 8000

ENV PYTHONUNBUFFERED 1
ENV PROCESSES 4
CMD ["uwsgi", "/code/headspace/wsgi/uwsgi.ini"]
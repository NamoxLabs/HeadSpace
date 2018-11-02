FROM python:3.7
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
ADD entrypoint.sh /code/
RUN chmod +x /code/entrypoint.sh
RUN pip install -r requirements.txt
ADD . /code/
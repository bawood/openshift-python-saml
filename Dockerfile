# vim:set ft=dockerfile
FROM python:2.7-slim

RUN apt-get update && apt-get install -y \
	mysql-client libmysqlclient-dev \
	postgresql-client libpq-dev \
	sqlite3 \
	xmlsec1 \
    --no-install-recommends && rm -rf /var/lib/apt/lists/*

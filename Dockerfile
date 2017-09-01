FROM quay.io/vektorcloud/dumb-init:latest

RUN apk add --no-cache \
  mariadb \
  mariadb-client

ENV MYSQL_USER=root \
  MYSQL_PASS=root

COPY entrypoint.sh /

VOLUME /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]

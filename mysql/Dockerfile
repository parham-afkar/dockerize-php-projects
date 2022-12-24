ARG MYSQL_VERSION
FROM mysql:${MYSQL_VERSION}

LABEL maintainer="Parham Afkar"

RUN set -eux; \ 
    apt-get update; \
    apt-get install -y --no-install-recommends \
    curl

COPY my.cnf /etc/mysql/conf.d/my.cnf
RUN chmod 0444 /etc/mysql/conf.d/my.cnf

CMD ["mysqld"]
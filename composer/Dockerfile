FROM composer:latest

LABEL maintainer="Parham Afkar"

ARG UID
ARG GID
ARG APP_USER

ENV APP_USER=${APP_USER}
ENV UID=${UID}
ENV GID=${GID}

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} --system ${APP_USER}
RUN adduser -G ${APP_USER} --system -D -s /bin/sh -u ${UID} ${APP_USER}

WORKDIR /var/www/html

USER ${APP_USER}


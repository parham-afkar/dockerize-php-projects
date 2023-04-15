FROM nginx:alpine

LABEL maintainer="Parham Afkar"

ARG UID
ARG GID
ARG APP_USER

ENV APP_USER=${APP_USER}
ENV UID=${UID}
ENV GID=${GID}

ENV APP_DOMAIN=${APP_DOMAIN}
ENV NGINX_CONTAINER_PHP_UPSTREAM_NAME=${NGINX_CONTAINER_PHP_UPSTREAM_NAME}
ENV NGINX_CONTAINER_PHP_UPSTREAM_PORT=${NGINX_CONTAINER_PHP_UPSTREAM_PORT}
ENV NGINX_CONTAINER_PROJECT_PATH=${NGINX_CONTAINER_PROJECT_PATH}


COPY nginx.conf /etc/nginx/

RUN addgroup -g ${GID} --system ${APP_USER}
RUN adduser -G ${APP_USER} --system -D -s /bin/sh -u ${UID} ${APP_USER}
RUN sed -i "s/user  nginx/user ${APP_USER}/g" /etc/nginx/nginx.conf

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash \
    && apk add --no-cache openssl

RUN apk add --no-cache curl

COPY ./templates/default.conf.template /default.conf.template

CMD ["/bin/sh" , "-c" , "envsubst '$APP_DOMAIN $NGINX_CONTAINER_PHP_UPSTREAM_NAME $NGINX_CONTAINER_PHP_UPSTREAM_PORT $NGINX_CONTAINER_PROJECT_PATH' < /default.conf.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]

WORKDIR /var/www/html

# USER ${APP_USER}

EXPOSE 80

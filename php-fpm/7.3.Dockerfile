FROM php:7.3-fpm

LABEL maintainer="Parham Afkar"
ENV DEBIAN_FRONTEND noninteractive

ARG INSTALL_PHP_VERSION

ARG UID
ARG GID
ARG APP_USER

ENV APP_USER=${APP_USER}
ENV UID=${UID}
ENV GID=${GID}

RUN mkdir -p /var/www/html

WORKDIR /var/www/html



# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN groupadd -g ${GID} --system ${APP_USER}
RUN adduser ${APP_USER} --gid ${GID} --disabled-password --uid ${UID} --system

RUN set -eux; \ 
  apt-get update; \
  apt-get install -y --no-install-recommends \
  git \
  curl \
  zip \
  libpng-dev \
  libonig-dev \
  libxml2-dev \
  unzip \
  libwebp-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libxpm-dev \
  libfreetype6-dev \
  libmemcached-dev \
  libz-dev \
  libpq-dev \
  libjpeg-dev \
  libpng-dev \
  libmcrypt-dev; \
  rm -rf /var/lib/apt/lists/*


RUN pecl install mongodb
RUN echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/mongodb.ini


# RUN apt-get update && \
#     apt-get install -y autoconf pkg-config libssl-dev git libzip-dev zlib1g-dev && \
#     pecl install mongodb && docker-php-ext-enable mongodb && \
#     pecl install xdebug && docker-php-ext-enable xdebug && \
#     docker-php-ext-install -j$(nproc) pdo_mysql zip


# Install additional PHP Packages and project Requirements
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mysqli

RUN docker-php-ext-configure gd --with-gd --with-webp-dir --with-jpeg-dir \
  --with-png-dir --with-zlib-dir --with-xpm-dir --with-freetype-dir

RUN docker-php-ext-install gd


RUN apt-get update -yqq && \
  apt-get install -y zlib1g-dev libicu-dev g++ libzip-dev && \
  docker-php-ext-configure intl && \
  docker-php-ext-install intl zip

RUN docker-php-ext-install opcache
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN rm /etc/apt/preferences.d/no-debian-php && \
  apt-get -y install libxml2-dev php-soap && \
  docker-php-ext-install soap;

COPY ./custom.ini /usr/local/etc/php/conf.d
COPY ./xcustom.pool.conf /usr/local/etc/php-fpm.d/

RUN sed -i "s/user = www-data/user = ${APP_USER}/g" /usr/local/etc/php-fpm.d/xcustom.pool.conf
RUN sed -i "s/group = www-data/group = ${APP_USER}/g" /usr/local/etc/php-fpm.d/xcustom.pool.conf

# Get latest Composer
COPY --from=omposer:latest /usr/bin/composer /usr/bin/composer

# Clean up
RUN apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  rm /var/log/lastlog /var/log/faillog


USER ${APP_USER}

CMD ["php-fpm"]


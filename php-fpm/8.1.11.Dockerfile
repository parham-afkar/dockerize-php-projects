FROM php:8.1.11-fpm

LABEL maintainer="Parham Afkar"
ENV DEBIAN_FRONTEND noninteractive

# Set HTTP_PROXY
ENV http_proxy=""
ENV https_proxy=""

ARG INSTALL_PHP_VERSION

ARG UID
ARG GID
ARG APP_USER

ENV APP_USER=${APP_USER}
ENV UID=${UID}
ENV GID=${GID}

# COPY ./sources.list /etc/apt/

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
    wget \
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
    libzip-dev \
    supervisor \
    procps \
    libmcrypt-dev; \
    rm -rf /var/lib/apt/lists/*


RUN apt-get update && \
    apt-get install -y autoconf pkg-config libssl-dev git libzip-dev zlib1g-dev && \
    # pecl install mongodb && docker-php-ext-enable mongodb && \
    # pecl install xdebug && docker-php-ext-enable xdebug && \
    docker-php-ext-install -j$(nproc) pdo_mysql zip

# Install OpenSSL
RUN apt-get update && apt-get install -y openssl libssl-dev

# Download MongoDB extension source code
RUN curl -OL https://github.com/mongodb/mongo-php-driver/releases/download/1.16.1/mongodb-1.16.1.tgz

# Extract the source code
RUN tar -xf mongodb-1.16.1.tgz

# Build and install the MongoDB extension
RUN cd mongodb-1.16.1 \
    && phpize \
    && ./configure \
    && make \
    && make install

# Enable the MongoDB extension
RUN echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini

# Clean up
RUN rm -rf mongodb-1.16.1.tgz mongodb-1.16.1


RUN docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install \
    pcntl

RUN apt-get install -y \
    zip \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip
# Install additional PHP Packages and project Requirements
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mysqli

RUN apt-get update && \
    apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
    docker-php-ext-install gd


RUN apt-get update -yqq && \
    apt-get install -y zlib1g-dev libicu-dev g++ && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl

RUN docker-php-ext-install opcache
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN rm /etc/apt/preferences.d/no-debian-php && \
    apt-get -y install libxml2-dev php-soap && \
    docker-php-ext-install soap;


# Download and extract Redis source code
RUN wget http://download.redis.io/releases/redis-7.0.9.tar.gz  && tar xzf redis-7.0.9.tar.gz

# Build and install Redis
RUN cd redis-7.0.9 && make && make install

# Install Redis PHP extension
# RUN pecl install redis && docker-php-ext-enable redis

COPY ./custom.ini /usr/local/etc/php/conf.d
COPY ./xcustom.pool.conf /usr/local/etc/php-fpm.d/

RUN sed -i "s/user = www-data/user = ${APP_USER}/g" /usr/local/etc/php-fpm.d/xcustom.pool.conf
RUN sed -i "s/group = www-data/group = ${APP_USER}/g" /usr/local/etc/php-fpm.d/xcustom.pool.conf

# Get latest Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer



# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# Configure Supervisor
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Remove HTTP_Proxy
ENV http_proxy=""
ENV https_proxy=""


# Normal user
USER ${APP_USER}

# Expose port 9000 for FPM
EXPOSE 9000

# Start Supervisor to manage FPM and other processes
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# CMD ["php-fpm"]

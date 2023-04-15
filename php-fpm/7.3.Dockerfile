FROM php:7.3-fpm

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
  supervisor \
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


# Install OpenSSL
RUN apt-get update && apt-get install -y openssl libssl-dev

# Install MongoDB driver
RUN pecl install mongodb && docker-php-ext-enable mongodb

# Install MongoDB driver
#RUN curl -fsSL https://github.com/mongodb/mongo-php-driver/releases/download/1.10.0/mongodb-1.10.0.tgz -o mongodb.tgz \
#    && mkdir -p mongodb \
#    && tar -xf mongodb.tgz -C mongodb --strip-components=1 \
#    && rm mongodb.tgz \
#    && ( \
#        cd mongodb && \
#        phpize && \
#        ./configure && \
#        make && \
#        make install \
#    ) \
#    && rm -r mongodb \
#    && docker-php-ext-enable mongodb


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

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clean up
RUN apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  rm /var/log/lastlog /var/log/faillog


# Configure Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#USER ${APP_USER}

# Expose port 9000 for FPM
EXPOSE 9000

# Start Supervisor to manage FPM and other processes
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
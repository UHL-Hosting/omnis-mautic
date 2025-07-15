FROM php:8.3-apache

LABEL vendor="Mautic"

# Install PHP extensions
RUN apt-get update && apt-get install --no-install-recommends -y \
  cron \
  git \
  wget \
  sudo \
  libc-client-dev \
  libicu-dev \
  libkrb5-dev \
  libmcrypt-dev \
  libpng-dev \
  libssl-dev \
  libz-dev \
  libzip-dev \
  neovim \
  unzip \
  zip \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/* \
  && rm /etc/cron.daily/*

RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos \
  && docker-php-ext-configure opcache --enable-opcache \
  && docker-php-ext-install imap zip gd mysqli pdo_mysql bcmath intl opcache\
  && docker-php-ext-enable imap zip gd mysqli pdo_mysql bcmath intl opcache

# Install composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Install Node 18 and npm
RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh \
  && bash nodesource_setup.sh \
  && apt-get install --no-install-recommends -y nodejs npm \
  && rm nodesource_setup.sh

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 6.0.0

# By default enable cron jobs
ENV MAUTIC_RUN_CRON_JOBS true

# By default disable automatic migrations
ENV MAUTIC_RUN_MIGRATIONS false

# Setting an Default database user for Mysql
ENV MAUTIC_DB_USER mautic

# Setting an Default database name for Mysql
ENV MAUTIC_DB_NAME mautic

# Set up mysql port
ENV MAUTIC_DB_PORT 3306

RUN chmod u+s /usr/sbin/cron
RUN mkdir /var/log/cron
COPY --chmod=644 ./mautic.crontab /etc/cron.d/mautic

RUN chown -R www-data:www-data /var/log/cron

# Enable Apache Rewrite Module
RUN a2enmod rewrite && service apache2 restart
RUN chown -R www-data:www-data /var/www
WORKDIR /var/www/html

RUN echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini

USER www-data
# Clone Mautic Git repository and checkout the configured version
RUN git clone https://github.com/mautic/mautic.git /var/www/html \
    && cd /var/www/html \
    && git checkout tags/${MAUTIC_VERSION}

WORKDIR /var/www/html
RUN composer update && composer install
RUN npm install && npm run build

CMD ["/bin/bash", "-c", "/usr/sbin/cron && apache2-foreground"]

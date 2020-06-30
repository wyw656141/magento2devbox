FROM ubuntu:20.04

MAINTAINER "Ivan Wang, wyw656141@hotmail.com"

RUN set TZ="America/New_York"

RUN export DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

RUN apt-get update && apt-get install -y --no-install-recommends \
  apt-utils \
  cron \
  git \
  mariadb-client \
  mariadb-server \
  nano \
  nodejs \
  python3 \
  python3-pip \
  redis-tools \
  sendmail \
  sendmail-bin \
  sudo \
  unzip \
  vim \
  libbz2-dev \
  libpng-dev \
  libfreetype6-dev \
  libgeoip-dev \
  wget \
  curl \
  telnet \
  libgmp-dev \
  libmagickwand-dev \
  libmagickcore-dev \
  libc-client-dev \
  libkrb5-dev \
  libicu-dev \
  libldap2-dev \
  libpspell-dev \
  librecode0 \
  librecode-dev \
  libssh2-1 \
  libssh2-1-dev \
  libtidy-dev \
  libxslt1-dev \
  libyaml-dev \
  libzip-dev \
  zip \
  nginx \
  openjdk-8-jdk \
  gnupg2

RUN apt-get -y install software-properties-common && add-apt-repository ppa:ondrej/php && apt-get update

RUN apt-get install -y --no-install-recommends \
  php7.3-fpm \
  php7.3-cli \
  php7.3-bcmath \
  php7.3-common \
  php7.3-curl \
  php7.3-dom \
  php7.3-gd \
  php7.3-iconv \
  php7.3-intl \
  php7.3-mbstring \
  php7.3-mysql \
  php7.3-simplexml \
  php7.3-soap \
  php7.3-xsl \
  php7.3-zip

RUN service mysql start && \
  mysql -u root -e "CREATE USER 'magento'@'localhost' IDENTIFIED BY 'magento';" && \
  mysql -u root -e "GRANT ALL PRIVILEGES ON * . * TO 'magento'@'localhost';" && \
  mysql -u root -e "FLUSH PRIVILEGES;" && \
  mysql -u root -e "CREATE DATABASE magento;"

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

RUN touch ~/.composer/auth.json
RUN echo "{\"http-basic\": {\"repo.magento.com\": {\"username\":\"a984ffe7a48048dd56ca0a73ab809e76\",\"password\":\"9dcc9c0291cb501b7fb8f16bcb605a23\"}}}" >> ~/.composer/auth.json

RUN cd /var/www/html && composer create-project --repository=https://repo.magento.com/ magento/project-community-edition magento2

RUN cd /var/www/html/magento2 && find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + && find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + && chown -R :www-data . && chmod u+x bin/magento

RUN service mysql start && cd /var/www/html/magento2 && bin/magento setup:install \
--base-url=http://www.magento-dev.com \
--db-host=localhost \
--db-name=magento \
--db-user=magento \
--db-password=magento \
--backend-frontname=admin \
--admin-firstname=admin \
--admin-lastname=admin \
--admin-email=admin@admin.com \
--admin-user=admin \
--admin-password=admin123 \
--language=en_US \
--currency=USD \
--timezone=America/Chicago \
--use-rewrites=1

RUN touch /etc/nginx/sites-available/magento
RUN echo 'upstream fastcgi_backend {server unix:/run/php/php7.3-fpm.sock;}' >> /etc/nginx/sites-available/magento
RUN echo 'server {listen 80;server_name www.magento-dev.com;set $MAGE_ROOT /var/www/html/magento2;include /var/www/html/magento2/nginx.conf.sample;}' >> /etc/nginx/sites-available/magento
RUN ln -s /etc/nginx/sites-available/magento /etc/nginx/sites-enabled

EXPOSE 80

USER root

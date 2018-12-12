FROM alpine:3.8

#Add Mr Docker and Apache
RUN addgroup -S -g 777 mrdocker && adduser -S -g mrdocker -u 777 mrdocker \
    && addgroup -S -g 48 apache && adduser -S -g apache -u 48 apache

# PHP 7
RUN apk update && apk upgrade && \
    apk add php7 php7-cli \
    php7-mysqlnd php7-gd php7-xml php7-soap php7-ldap php7-mcrypt php7-pspell php7-json php7-phar php7-openssl php7-curl \
    php7-ctype php7-dom php7-sqlite3 php7-iconv php7-opcache php7-mbstring php7-fpm php7-mcrypt php7-common php7-pdo \
    php7-imagick php7-intl php7-tidy php7-yaml php7-fileinfo php7-tokenizer php7-zip php7-session php7-xmlwriter \
    php7-simplexml apache2 php7-apache2 php7-pdo_mysql php7-pdo_sqlite ssmtp mysql-client gd sqlite && \
    rm -rf /var/cache/apk/* && \
    ln -fs /usr/bin/php7 /usr/bin/php

COPY website.ini /etc/php7/conf.d/

RUN mkdir -p /run/apache2 && \
    mkdir /var/www/website && \
    chown apache:apache /var/www/website /run/apache2
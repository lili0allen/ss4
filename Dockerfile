FROM alpine_php_apache_mysql:latest as base

#Install Composer
RUN wget -O - https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

#Install composer package dependencies
RUN apk add git

#Install composer dependencies
COPY --chown=apache:apache src/main/composer.* /var/www/website/
WORKDIR /var/www/website/
RUN composer install --no-ansi --no-interaction --no-progress --no-scripts --optimize-autoloader 2>&1 | grep -v "Cannot create cache directory"

#Copy application source
COPY src/main/ /var/www/website
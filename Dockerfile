FROM alpine_ap:latest as base

##Install Composer
RUN wget -O - https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

VOLUME /var/www/website

# Install composer dependencies (+dev)
COPY --chown=apache:apache src/main/composer.* /var/www/website/
WORKDIR /var/www/website/

# Install Composer package dependencies
RUN apk add git

RUN composer install --no-ansi --no-interaction --no-progress --no-scripts --optimize-autoloader 2>&1 | grep -v "Cannot create cache directory"
# Copy application source
COPY src/main/ /var/www/website

RUN composer vendor-expose

# UNITTEST IMAGE
# To run unittests only:
# docker build --target unittests .
FROM base as unittests

WORKDIR /var/www/website/

# Install test-only dependencies
COPY properties/globals_unittest.env /var/www/website/
RUN mkdir -p public/site-assets/sqlite/ && chown apache:apache -R public
USER apache:apache

ARG SKIPTESTS=false
#build db for tests
RUN if [ "${SKIPTESTS}" != true ] ; then export $(cat ./globals_unittest.env | xargs) && php vendor/silverstripe/framework/cli-script.php dev/build; fi
RUN if [ "${SKIPTESTS}" != true ] ; then export $(cat ./globals_unittest.env | xargs) && vendor/bin/phpunit --log-junit ./test-reports/phpunit.xml mysite; fi

# Cleanup image
FROM base as buildprod

# remove composer dev dependencies from source
RUN composer install --no-dev --no-ansi --no-interaction --no-progress --no-scripts --optimize-autoloader 2>&1

# FINAL IMAGE
FROM alpine_ap:latest

# Update timezone to reflect AU
RUN ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime

# Copy Website and config update
COPY --from=buildprod /var/www/website /var/www/website

# Copy httpd configuration files
COPY container/httpd/httpd.conf /etc/apache2/httpd.conf

# Set XDebug if required
ARG XDEBUG=false
COPY container/php/xdebug.ini /tmp/xdebug.ini
RUN if [ "${XDEBUG}" == true ] ; then apk add php7-xdebug && mv /tmp/xdebug.ini /etc/php7/conf.d/ ; fi

EXPOSE 8080

# Replace default entry-point.sh
COPY container/scripts/entry-point.sh /var/www/entry-point.sh
RUN chmod 0755 /var/www/entry-point.sh
RUN chown -R apache:apache /var/www/website

WORKDIR /var/www/website
USER apache:apache

CMD ["/var/www/entry-point.sh"]
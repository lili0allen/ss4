FROM alpine_apm:latest as base

##Install Composer
#RUN wget -O - https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
#
##Install composer package dependencies
#RUN apk add git
#
##Install composer dependencies
#COPY --chown=apache:apache src/main/composer.* /var/www/website/
#WORKDIR /var/www/website/
#RUN composer install --no-ansi --no-interaction --no-progress --no-scripts --optimize-autoloader 2>&1 | grep -v "Cannot create cache directory"
#
##Copy application source
#COPY src/main/ /var/www/website

RUN apk add tzdata
ENV TZ=Australia/Melbourne
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY httpd/httpd.conf /etc/apache2/httpd.conf
COPY httpd/00-sed.conf /etc/apache2/conf.modules.d/00-sed.conf


RUN addgroup mysql mysql && mkdir /scripts && rm -rf /var/cache/apk/*
VOLUME ["/var/lib/mysql"]
COPY ./startup.sh /scripts/startup.sh
RUN chmod +x /scripts/startup.sh

ENTRYPOINT ["/scripts/startup.sh"]

EXPOSE 8080
EXPOSE 3306


FROM alpine:3.16

WORKDIR /var/www/html/

# Essentials
RUN echo "UTC" > /etc/timezone
RUN apk add --no-cache wget zip unzip curl sqlite nginx supervisor

RUN apk info

# Installing bash
RUN apk add bash
RUN sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd

RUN apk update

# Installing PHP
RUN apk add --no-cache php8 \
php8-common \
php8-fpm \
php8-pdo \
php8-opcache \
php8-zip \
php8-phar \
php8-iconv \
php8-cli \
php8-curl \
php8-openssl \
php8-mbstring \
php8-tokenizer \
php8-fileinfo \
php8-json \
php8-xml \
php8-xmlwriter \
php8-simplexml \
php8-dom \
php8-pdo_mysql \
php8-pdo_sqlite \
php8-tokenizer \
php8-pecl-redis \
php8-gd \
php8-pdo_pgsql \
php8-xmlreader \
composer

# Installing composer
#RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
#RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
#RUN rm -rf composer-setup.php

# Configure supervisor
RUN mkdir -p /etc/supervisor.d/
COPY .docker/supervisord.ini /etc/supervisor.d/supervisord.ini

# Configure PHP
RUN mkdir -p /run/php/
RUN touch /run/php/php8.0-fpm.pid

COPY .docker/php-fpm.conf /etc/php8/php-fpm.conf
COPY .docker/php.ini-production /etc/php8/php.ini

# Configure nginx
COPY .docker/nginx.conf /etc/nginx/
COPY .docker/nginx-laravel.conf /etc/nginx/modules/

RUN mkdir -p /run/nginx/
RUN touch /run/nginx/nginx.pid

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

COPY . /var/www/html

RUN composer install --optimize-autoloader --no-dev

RUN mkdir -p /var/www/html/storage/logs && touch /var/www/html/storage/logs/laravel.log \
&& chmod -R 777 /var/www/html/storage \
&& chmod -R 777 /var/www/html/storage/logs/laravel.log

RUN chmod -R 777 /var/www/html/public/template_files

RUN rm -rf /var/www/html/public/downloaded_files \
&& mkdir -p /var/www/html/public/downloaded_files \
&& chmod -R 777 /var/www/html/public/downloaded_files 

#RUN php artisan view:clear \
#&& php artisan route:clear \
#&& php artisan route:cache \
#&& php artisan config:clear \
#&& php artisan config:cache \
#&& composer dumpautoload -o \
#&& php artisan migrate --no-interaction

RUN chmod +x /var/www/html/entrypoint.sh
RUN chmod +x /etc/supervisor.d/supervisord.ini
EXPOSE 80

CMD ["/var/www/html/entrypoint.sh"]
#CMD ["supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]
#ENTRYPOINT ["sh", "/src/entrypoint.sh"]


#HEALTHCHECK --interval=3m --timeout=3s \
#CMD curl --location --request GET 'localhost:80/api/health'

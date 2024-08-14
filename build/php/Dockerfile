FROM php:8.3-fpm-alpine as php_upstream
FROM composer/composer:2-bin as composer_upstream
FROM nginx:alpine as nginx_upstream


FROM php_upstream as php_base

WORKDIR /var/www/app

RUN apk add --no-cache \
        make \
        autoconf \
        acl \
        g++ \
        zip


COPY --link build/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

COPY --link build/php/docker-test.sh /usr/local/bin/test-script
RUN chmod +x /usr/local/bin/test-script

COPY --link build/php/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

# Разрешаем работу composer от рута и указываем путь к бинакрникам
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

# Подгружаем composer из другого образа
COPY --from=composer_upstream --link /composer /usr/bin/composer

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]


FROM php_base AS php_local
ENV APP_ENV=dev 
ENV SYMFONY_ENV=dev

# ENTRYPOINT ["docker-entrypoint"]
# CMD ["php-fpm"]




FROM php_base AS php
ENV APP_ENV=dev 
ENV SYMFONY_ENV=dev

# RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Копируем файлы для установки зависмостей
COPY --link app/composer.* app/symfony.* ./

# Устанавливаем зависимости
RUN set -eux; \
    composer install --no-cache --prefer-dist --no-autoloader --no-scripts --no-progress;

# Копируем основной код в контейнер
COPY --link app .

# Создаем папки для кеша и логов и выдаем полные права на них
# Устанавливаем оставшиеся зависимости
RUN set -eux; \
    mkdir -p var/cache var/log; \
    chmod -R 777 var/cache var/log; \
    composer dump-autoload --classmap-authoritative; \
    composer dump-env dev; \
    composer run-script post-install-cmd; \
    chmod +x bin/console;


# ENTRYPOINT ["docker-entrypoint"]
# CMD ["php-fpm"]



# NGINX для обработки запросов к php и отдаче статики
FROM nginx_upstream as nginx

WORKDIR /var/www/app
EXPOSE 80

COPY --link build/nginx/default.conf /etc/nginx/conf.d/
COPY --from=php --link /var/www/app/public public/

ENTRYPOINT [ "nginx", "-g", "daemon off;" ]


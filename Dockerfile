ARG SERVERSIDEUP_PHP_VERSION=8.4-fpm-nginx-alpine

FROM serversideup/php:${SERVERSIDEUP_PHP_VERSION} AS composer-deps

USER root
WORKDIR /var/www/html
COPY composer.json composer.lock ./
RUN --mount=type=cache,target=/tmp/cache \
    COMPOSER_CACHE_DIR=/tmp/cache composer install --no-interaction --prefer-dist

FROM node:24-alpine AS static-assets

WORKDIR /app
COPY package*.json vite.config.js postcss.config.cjs ./
RUN --mount=type=cache,target=/root/.npm npm ci
COPY . .
RUN npm run build

FROM serversideup/php:${SERVERSIDEUP_PHP_VERSION}

USER root
WORKDIR /var/www/html

RUN --mount=type=cache,target=/var/cache/apk \
    apk add --no-cache \
    postgresql \
    postgresql-client \
    redis \
    bash

COPY --from=composer-deps --chown=www-data:www-data /var/www/html/vendor ./vendor
COPY --from=static-assets --chown=www-data:www-data /app/public/build ./public/build

COPY --chown=www-data:www-data . .

COPY --chmod=755 docker/all-in-one/scripts/bootstrap-app.sh /usr/local/bin/bootstrap-app.sh
COPY --chmod=755 docker/all-in-one/etc/s6-overlay/ /etc/s6-overlay/

RUN mkdir -p /var/lib/postgresql/data /run/postgresql /data/redis && \
    chown -R postgres:postgres /var/lib/postgresql /run/postgresql && \
    chown -R redis:redis /data/redis && \
    chmod 700 /var/lib/postgresql/data && \
    chmod 2775 /run/postgresql

ENV APP_ENV=local \
    APP_DEBUG=true \
    DB_CONNECTION=pgsql \
    DB_HOST=127.0.0.1 \
    DB_PORT=5432 \
    DB_DATABASE=coolify \
    DB_USERNAME=coolify \
    DB_PASSWORD=coolify \
    REDIS_HOST=127.0.0.1 \
    REDIS_PORT=6379 \
    REDIS_PASSWORD=null

EXPOSE 80 5432 6379

USER www-data

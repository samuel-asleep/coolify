#!/usr/bin/env sh
set -eu

cd /var/www/html

APP_PORT="${APP_PORT:-8000}"
DATABASE_URL="${DATABASE_URL:-}"
REDIS_URL="${REDIS_URL:-}"
DB_DATABASE="${DB_DATABASE:-coolify}"
DB_USERNAME="${DB_USERNAME:-coolify}"
DB_PASSWORD="${DB_PASSWORD:-password}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-5432}"
REDIS_HOST="${REDIS_HOST:-127.0.0.1}"
REDIS_PASSWORD="${REDIS_PASSWORD:-null}"
REDIS_PORT="${REDIS_PORT:-6379}"

if [ ! -f .env ]; then
    cp .env.development.example .env
fi

chown www-data:www-data .env 2>/dev/null || true
chmod ug+rw .env 2>/dev/null || true
mkdir -p storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true

set_env_value() {
    key="$1"
    value="$2"

    if grep -q "^${key}=" .env; then
        sed -i "s#^${key}=.*#${key}=${value}#" .env
    else
        printf '\n%s=%s\n' "$key" "$value" >> .env
    fi
}

set_env_value "APP_ENV" "local"
set_env_value "APP_DEBUG" "false"
set_env_value "APP_URL" "http://localhost:${APP_PORT}"
set_env_value "APP_PORT" "${APP_PORT}"
set_env_value "DB_CONNECTION" "pgsql"

if [ -n "${DATABASE_URL}" ]; then
    set_env_value "DATABASE_URL" "${DATABASE_URL}"
else
    set_env_value "DB_HOST" "${DB_HOST}"
    set_env_value "DB_PORT" "${DB_PORT}"
    set_env_value "DB_DATABASE" "${DB_DATABASE}"
    set_env_value "DB_USERNAME" "${DB_USERNAME}"
    set_env_value "DB_PASSWORD" "${DB_PASSWORD}"
fi

if [ -n "${REDIS_URL}" ]; then
    set_env_value "REDIS_URL" "${REDIS_URL}"
else
    set_env_value "REDIS_HOST" "${REDIS_HOST}"
    set_env_value "REDIS_PASSWORD" "${REDIS_PASSWORD}"
    set_env_value "REDIS_PORT" "${REDIS_PORT}"
fi

if [ ! -f vendor/autoload.php ]; then
    su-exec www-data composer install --no-interaction --prefer-dist
fi

if [ ! -d node_modules ]; then
    su-exec www-data npm ci
fi

if [ ! -f public/build/manifest.json ]; then
    su-exec www-data npm run build
fi

if ! grep -q '^APP_KEY=base64:' .env; then
    php artisan key:generate --force --no-interaction
fi

su-exec www-data php artisan migrate --force --no-interaction

exec su-exec www-data php artisan serve --host=0.0.0.0 --port="${APP_PORT}"

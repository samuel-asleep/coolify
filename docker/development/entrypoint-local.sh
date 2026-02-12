#!/usr/bin/env sh
set -eu

cd /var/www/html

APP_PORT="${APP_PORT:-8000}"
DB_DATABASE="${DB_DATABASE:-coolify}"
DB_USERNAME="${DB_USERNAME:-coolify}"
DB_PASSWORD="${DB_PASSWORD:-password}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-5432}"

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
set_env_value "APP_DEBUG" "true"
set_env_value "APP_URL" "http://localhost:${APP_PORT}"
set_env_value "APP_PORT" "${APP_PORT}"
set_env_value "DB_CONNECTION" "pgsql"
set_env_value "DB_HOST" "${DB_HOST}"
set_env_value "DB_PORT" "${DB_PORT}"
set_env_value "DB_DATABASE" "${DB_DATABASE}"
set_env_value "DB_USERNAME" "${DB_USERNAME}"
set_env_value "DB_PASSWORD" "${DB_PASSWORD}"
set_env_value "REDIS_HOST" "127.0.0.1"
set_env_value "REDIS_PASSWORD" "null"
set_env_value "REDIS_PORT" "6379"

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

if [ ! -s /var/lib/postgresql/data/PG_VERSION ]; then
    su-exec postgres initdb -D /var/lib/postgresql/data
fi

su-exec postgres postgres -D /var/lib/postgresql/data > /tmp/postgres.log 2>&1 &
POSTGRES_PID=$!

for _ in $(seq 1 30); do
    if su-exec postgres pg_isready -q -h 127.0.0.1 -p 5432; then
        break
    fi
    sleep 1
done

su-exec postgres psql -v ON_ERROR_STOP=1 --username postgres <<SQL
DO
\$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${DB_USERNAME}') THEN
        CREATE ROLE ${DB_USERNAME} LOGIN PASSWORD '${DB_PASSWORD}';
    END IF;
END
\$\$;
SQL

su-exec postgres psql -v ON_ERROR_STOP=1 --username postgres -tc "SELECT 1 FROM pg_database WHERE datname = '${DB_DATABASE}'" | grep -q 1 || \
    su-exec postgres createdb --username postgres --owner="${DB_USERNAME}" "${DB_DATABASE}"

su-exec redis redis-server --daemonize yes --bind 127.0.0.1 --port 6379

su-exec www-data php artisan migrate --force --no-interaction

cleanup() {
    kill "${POSTGRES_PID}" >/dev/null 2>&1 || true
    redis-cli shutdown >/dev/null 2>&1 || true
}

trap cleanup EXIT INT TERM

exec su-exec www-data php artisan serve --host=0.0.0.0 --port="${APP_PORT}"

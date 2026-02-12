#!/usr/bin/env bash
set -euo pipefail

cd /var/www/html

if [ ! -f .env ]; then
    if [ -f .env.development.example ]; then
        cp .env.development.example .env
    else
        cp .env.production .env
    fi
fi

php -r '
$path = getcwd() . "/.env";
$env = file_get_contents($path);
$replacements = [
    "APP_ENV" => getenv("APP_ENV") ?: "local",
    "APP_DEBUG" => getenv("APP_DEBUG") ?: "true",
    "DB_CONNECTION" => getenv("DB_CONNECTION") ?: "pgsql",
    "DB_HOST" => getenv("DB_HOST") ?: "127.0.0.1",
    "DB_PORT" => getenv("DB_PORT") ?: "5432",
    "DB_DATABASE" => getenv("DB_DATABASE") ?: "coolify",
    "DB_USERNAME" => getenv("DB_USERNAME") ?: "coolify",
    "DB_PASSWORD" => getenv("DB_PASSWORD") ?: "coolify",
    "REDIS_HOST" => getenv("REDIS_HOST") ?: "127.0.0.1",
    "REDIS_PORT" => getenv("REDIS_PORT") ?: "6379",
    "REDIS_PASSWORD" => getenv("REDIS_PASSWORD") ?: "null",
];
foreach ($replacements as $key => $value) {
    $quoted = preg_quote($key, "/");
    if (preg_match("/^{$quoted}=.*/m", $env) === 1) {
        $env = preg_replace("/^{$quoted}=.*/m", "{$key}={$value}", $env);
    } else {
        $env .= PHP_EOL . "{$key}={$value}";
    }
}
file_put_contents($path, $env);
'

until pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" >/dev/null 2>&1; do
    sleep 1
done

until redis-cli -h "${REDIS_HOST}" -p "${REDIS_PORT}" ping >/dev/null 2>&1; do
    sleep 1
done

php artisan key:generate --force --no-interaction
php artisan migrate --force --no-interaction
php artisan dev --init --no-interaction

#!/bin/bash
set -e

echo "=========================================="
echo "  Coolify Production Deployment"
echo "=========================================="
echo ""

# Check if .env.production.custom exists
if [ ! -f .env.production.custom ]; then
    echo "Error: .env.production.custom file not found!"
    echo "Please create this file with your database and Redis configuration."
    exit 1
fi

# Load environment variables
export $(grep -v '^#' .env.production.custom | xargs)

echo "✓ Configuration loaded from .env.production.custom"
echo ""
echo "Database: ${DB_HOST}"
echo "Redis: ${REDIS_HOST}"
echo "App URL: ${APP_URL}"
echo ""

# Parse command
COMMAND=${1:-up}

case "$COMMAND" in
    up)
        echo "Building and starting Coolify..."
        docker compose -f docker-compose.external.yml up --build
        ;;
    up-detached|up-d)
        echo "Building and starting Coolify in detached mode..."
        docker compose -f docker-compose.external.yml up --build -d
        echo ""
        echo "✓ Coolify is starting in the background"
        echo "  View logs with: $0 logs"
        echo "  Stop with: $0 down"
        ;;
    down)
        echo "Stopping Coolify..."
        docker compose -f docker-compose.external.yml down
        ;;
    restart)
        echo "Restarting Coolify..."
        docker compose -f docker-compose.external.yml restart
        ;;
    logs)
        docker compose -f docker-compose.external.yml logs -f
        ;;
    ps)
        docker compose -f docker-compose.external.yml ps
        ;;
    exec)
        echo "Opening shell in Coolify container..."
        docker compose -f docker-compose.external.yml exec coolify sh
        ;;
    migrate)
        echo "Running database migrations..."
        docker compose -f docker-compose.external.yml exec coolify php artisan migrate --force
        ;;
    key:generate)
        echo "Generating new APP_KEY..."
        docker compose -f docker-compose.external.yml exec coolify php artisan key:generate --show
        ;;
    cache:clear)
        echo "Clearing cache..."
        docker compose -f docker-compose.external.yml exec coolify php artisan cache:clear
        docker compose -f docker-compose.external.yml exec coolify php artisan config:clear
        docker compose -f docker-compose.external.yml exec coolify php artisan route:clear
        docker compose -f docker-compose.external.yml exec coolify php artisan view:clear
        ;;
    test-db)
        echo "Testing database connection..."
        docker compose -f docker-compose.external.yml exec coolify php artisan db:show
        ;;
    test-redis)
        echo "Testing Redis connection..."
        docker compose -f docker-compose.external.yml exec coolify php artisan tinker --execute="Redis::ping()"
        ;;
    build)
        echo "Building Docker image..."
        docker compose -f docker-compose.external.yml build
        ;;
    help)
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  up              Build and start Coolify (default)"
        echo "  up-d            Build and start in detached mode"
        echo "  down            Stop Coolify"
        echo "  restart         Restart Coolify"
        echo "  logs            View logs"
        echo "  ps              Show running containers"
        echo "  exec            Open shell in container"
        echo "  migrate         Run database migrations"
        echo "  key:generate    Generate new APP_KEY"
        echo "  cache:clear     Clear all caches"
        echo "  test-db         Test database connection"
        echo "  test-redis      Test Redis connection"
        echo "  build           Build Docker image only"
        echo "  help            Show this help"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Run '$0 help' for usage information"
        exit 1
        ;;
esac

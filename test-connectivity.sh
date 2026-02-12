#!/bin/bash
# Test script for database and Redis connectivity

set -e

echo "========================================"
echo "  Connectivity Tests"
echo "========================================"
echo ""

# Load environment variables
if [ ! -f .env.production.custom ]; then
    echo "Error: .env.production.custom file not found!"
    exit 1
fi

export $(grep -v '^#' .env.production.custom | xargs)

echo "Testing PostgreSQL connection..."
echo "Host: ${DB_HOST}"
echo "Database: ${DB_DATABASE}"
echo "User: ${DB_USERNAME}"
echo ""

# Test PostgreSQL connection
docker run --rm \
    -e PGPASSWORD="${DB_PASSWORD}" \
    postgres:15-alpine \
    psql -h "${DB_HOST}" -U "${DB_USERNAME}" -d "${DB_DATABASE}" -c "SELECT version();" \
    2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ PostgreSQL connection successful!"
else
    echo ""
    echo "✗ PostgreSQL connection failed!"
    exit 1
fi

echo ""
echo "Testing Redis connection..."
echo "Host: ${REDIS_HOST}"
echo "Port: ${REDIS_PORT}"
echo ""

# Test Redis connection - For TLS connections
docker run --rm redis:alpine redis-cli \
    -h "${REDIS_HOST}" \
    -p "${REDIS_PORT}" \
    -a "${REDIS_PASSWORD}" \
    --tls \
    PING \
    2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Redis connection successful!"
else
    echo ""
    echo "✗ Redis connection failed!"
    exit 1
fi

echo ""
echo "========================================"
echo "  All connectivity tests passed!"
echo "========================================"

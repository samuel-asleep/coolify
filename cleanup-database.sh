#!/bin/bash
# Script to help reset/clean the database if needed

set -e

echo "=========================================="
echo "  Database Cleanup Helper"
echo "=========================================="
echo ""

# Load environment variables
if [ ! -f .env.production.custom ]; then
    echo "❌ Error: .env.production.custom file not found!"
    exit 1
fi

export $(grep -v '^#' .env.production.custom | xargs)

echo "This script will help you clean up the database to fix registration issues."
echo ""
echo "Database: ${DB_DATABASE}"
echo "Host: ${DB_HOST}"
echo ""
echo "⚠️  WARNING: This will DELETE ALL DATA in the database!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Cleaning database..."

# Option 1: Drop and recreate specific tables
echo ""
echo "Choose cleanup method:"
echo "1. Drop only teams and users tables (recommended for fixing registration)"
echo "2. Drop all Coolify tables (complete reset)"
echo "3. Show SQL commands only (manual execution)"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "Dropping teams and users tables..."
        docker run --rm \
            -e PGPASSWORD="${DB_PASSWORD}" \
            postgres:15-alpine \
            psql -h "${DB_HOST}" -U "${DB_USERNAME}" -d "${DB_DATABASE}" \
            -c "DROP TABLE IF EXISTS team_user CASCADE;" \
            -c "DROP TABLE IF EXISTS teams CASCADE;" \
            -c "DROP TABLE IF EXISTS users CASCADE;" \
            2>&1
        echo ""
        echo "✅ Tables dropped. Now restart the application:"
        echo "   ./run-production.sh down"
        echo "   ./run-production.sh up-d"
        ;;
    2)
        echo ""
        echo "⚠️  This will drop ALL tables. Are you ABSOLUTELY sure?"
        read -p "Type 'DELETE EVERYTHING' to confirm: " confirm2
        if [ "$confirm2" != "DELETE EVERYTHING" ]; then
            echo "Aborted."
            exit 0
        fi
        
        echo ""
        echo "Dropping all tables..."
        docker run --rm \
            -e PGPASSWORD="${DB_PASSWORD}" \
            postgres:15-alpine \
            psql -h "${DB_HOST}" -U "${DB_USERNAME}" -d "${DB_DATABASE}" \
            -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO ${DB_USERNAME};" \
            2>&1
        echo ""
        echo "✅ Database reset. Now restart the application:"
        echo "   ./run-production.sh down"
        echo "   ./run-production.sh up-d"
        ;;
    3)
        echo ""
        echo "SQL commands to run manually:"
        echo ""
        echo "-- To drop only teams and users:"
        echo "DROP TABLE IF EXISTS team_user CASCADE;"
        echo "DROP TABLE IF EXISTS teams CASCADE;"
        echo "DROP TABLE IF EXISTS users CASCADE;"
        echo ""
        echo "-- To drop all tables:"
        echo "DROP SCHEMA public CASCADE;"
        echo "CREATE SCHEMA public;"
        echo "GRANT ALL ON SCHEMA public TO ${DB_USERNAME};"
        echo ""
        echo "Connect to your database at:"
        echo "psql '${DATABASE_URL}'"
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

echo ""
echo "=========================================="

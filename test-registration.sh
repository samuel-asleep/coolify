#!/bin/bash
# Test script to verify first user registration works correctly

set -e

echo "=========================================="
echo "  Testing First User Registration"
echo "=========================================="
echo ""

# Check if containers are running
if ! docker compose -f docker-compose.external.yml ps | grep -q "Up"; then
    echo "❌ Containers are not running. Please start them first:"
    echo "   ./run-production.sh up-d"
    exit 1
fi

echo "✅ Containers are running"
echo ""

# Wait for application to be ready
echo "Waiting for application to be ready..."
for i in {1..30}; do
    if curl -sf http://localhost:8000/api/health > /dev/null 2>&1; then
        echo "✅ Application is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Application failed to become ready after 30 seconds"
        exit 1
    fi
    sleep 1
done

echo ""
echo "Testing registration page..."

# Check if registration page is accessible
if curl -sf http://localhost:8000/register > /dev/null; then
    echo "✅ Registration page is accessible"
else
    echo "❌ Registration page is not accessible"
    exit 1
fi

echo ""
echo "=========================================="
echo "  Manual Test Required"
echo "=========================================="
echo ""
echo "1. Open http://localhost:8000/register in your browser"
echo "2. Fill in the registration form:"
echo "   - Name: Test User"
echo "   - Email: test@example.com"
echo "   - Password: (strong password)"
echo "   - Confirm Password: (same password)"
echo "3. Click 'Register'"
echo "4. You should be redirected to the dashboard"
echo ""
echo "If you see an error about 'duplicate key value violates unique constraint', "
echo "you may need to reset the database. To do this:"
echo ""
echo "  # Stop containers"
echo "  ./run-production.sh down"
echo ""
echo "  # Clear the Neon database tables or create a fresh database"
echo "  # Then start again"
echo "  ./run-production.sh up-d"
echo ""
echo "=========================================="

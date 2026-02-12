# Running Coolify with External Database and Redis

This guide explains how to run Coolify using the production Dockerfile with external PostgreSQL (Neon) and Redis (Upstash) services.

## Prerequisites

- Docker and Docker Compose installed
- External PostgreSQL database (e.g., Neon)
- External Redis instance (e.g., Upstash)

## Quick Start

### 1. Configure Environment

The `.env.production.custom` file has been created with your database and Redis credentials. Review and update as needed:

```bash
# Edit configuration if needed
nano .env.production.custom
```

**Important**: Make sure to update these values:
- `ROOT_USER_EMAIL`: Your admin email
- `ROOT_USER_PASSWORD`: A strong password for the admin account
- `APP_URL`: Your actual domain or IP address

### 2. Start Coolify

```bash
# Start in foreground (see logs in real-time)
./run-production.sh up

# OR start in background (detached mode)
./run-production.sh up-d
```

The application will be available at `http://localhost:8000` (or the APP_URL you configured).

### 3. Initial Setup

After the container starts, run migrations to set up the database:

```bash
./run-production.sh migrate
```

## Configuration Details

### Database Configuration

The app is configured to use your Neon PostgreSQL database:
- **Host**: ep-falling-math-aivl7xxh-pooler.c-4.us-east-1.aws.neon.tech
- **Database**: neondb
- **User**: neondb_owner
- **SSL Mode**: require

The `DATABASE_URL` format includes all connection parameters:
```
postgresql://neondb_owner:npg_HpPfuQ8ReN4M@ep-falling-math-aivl7xxh-pooler.c-4.us-east-1.aws.neon.tech/neondb?sslmode=require
```

### Redis Configuration

The app is configured to use your Upstash Redis instance:
- **Host**: proper-platypus-54512.upstash.io
- **Port**: 6379
- **SSL**: Enabled (rediss://)
- **User**: default

The `REDIS_URL` format includes all connection parameters:
```
rediss://default:AdTwAAIncDIyMjQwNTZjMDY5MTk0NDgyYTUwMWY3OWRhY2ExYTNjN3AyNTQ1MTI@proper-platypus-54512.upstash.io:6379
```

## Available Commands

```bash
# Start services
./run-production.sh up              # Start in foreground
./run-production.sh up-d            # Start in background

# Stop services
./run-production.sh down            # Stop all services

# View logs
./run-production.sh logs            # Follow logs

# Service management
./run-production.sh restart         # Restart services
./run-production.sh ps              # Show running containers

# Shell access
./run-production.sh exec            # Open shell in container

# Database operations
./run-production.sh migrate         # Run database migrations
./run-production.sh test-db         # Test database connection

# Redis operations
./run-production.sh test-redis      # Test Redis connection

# Application maintenance
./run-production.sh cache:clear     # Clear all caches
./run-production.sh key:generate    # Generate new APP_KEY

# Build only
./run-production.sh build           # Build Docker image without starting

# Help
./run-production.sh help            # Show all commands
```

## Architecture

The setup uses:
- **docker-compose.external.yml**: Compose file configured for external services
- **docker/production/Dockerfile**: Multi-stage production Dockerfile
- **.env.production.custom**: Environment configuration file
- **run-production.sh**: Convenience script for managing the deployment

### Services

1. **coolify**: Main application container
   - Built from `docker/production/Dockerfile`
   - Uses PHP 8.4 FPM with Nginx
   - Exposes port 8080 internally, mapped to 8000 externally

2. **soketi**: WebSocket server for real-time features
   - Handles real-time updates in the UI
   - Exposes ports 6001 and 6002

### Volumes

Persistent data is stored in Docker volumes:
- `coolify-ssh`: SSH keys
- `coolify-applications`: Application data
- `coolify-databases`: Database backups
- `coolify-services`: Service configurations
- `coolify-backups`: Backup files
- `coolify-logs`: Application logs

## Troubleshooting

### Database Connection Issues

Test the database connection:
```bash
./run-production.sh test-db
```

If connection fails:
1. Verify credentials in `.env.production.custom`
2. Check Neon database status and connection pooler
3. Verify SSL mode is set to `require`
4. Check firewall rules allow connections from your server

### Redis Connection Issues

Test the Redis connection:
```bash
./run-production.sh test-redis
```

If connection fails:
1. Verify credentials in `.env.production.custom`
2. Check Upstash Redis status
3. Verify the TLS/SSL connection (rediss://)
4. Check if IP whitelisting is enabled in Upstash

### Container Won't Start

View logs to diagnose:
```bash
docker-compose -f docker-compose.external.yml logs coolify
```

Common issues:
- Missing or invalid `APP_KEY`
- Database migrations not run
- Invalid environment variables

### Clear Everything and Start Fresh

```bash
# Stop and remove containers
./run-production.sh down

# Remove volumes (WARNING: This deletes all data!)
docker volume rm coolify-ssh coolify-applications coolify-databases coolify-services coolify-backups coolify-logs

# Start again
./run-production.sh up-d
./run-production.sh migrate
```

## Production Recommendations

1. **Use a reverse proxy**: Set up Nginx or Traefik in front of Coolify for HTTPS
2. **Regular backups**: Backup your Docker volumes regularly
3. **Monitor resources**: Keep an eye on memory and CPU usage
4. **Update APP_KEY**: Generate a unique APP_KEY for production
5. **Strong passwords**: Use strong passwords for ROOT_USER_PASSWORD
6. **Environment variables**: Keep `.env.production.custom` secure (don't commit to git)
7. **SSL certificates**: Use Let's Encrypt for HTTPS
8. **Database backups**: Configure regular backups for your Neon database
9. **Redis persistence**: Upstash Redis has built-in persistence

## Security Notes

⚠️ **IMPORTANT**: 
- The `.env.production.custom` file contains sensitive credentials
- Never commit this file to version control
- Rotate credentials regularly
- Use strong passwords for all accounts
- Keep your system and Docker updated

## Next Steps

After successful deployment:
1. Access Coolify at your configured URL
2. Log in with your ROOT_USER_EMAIL and ROOT_USER_PASSWORD
3. Complete the initial setup wizard
4. Configure your servers and applications
5. Set up SSL certificates
6. Configure email notifications (optional)

## Support

For issues and questions:
- [Coolify Documentation](https://coolify.io/docs)
- [GitHub Issues](https://github.com/coollabsio/coolify/issues)
- [Discord Community](https://coolify.io/discord)

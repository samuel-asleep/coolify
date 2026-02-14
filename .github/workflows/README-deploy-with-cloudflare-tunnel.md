# Deploy Coolify with Cloudflare Quick Tunnel

This GitHub Actions workflow automatically builds and deploys the Coolify application, making it accessible via a Cloudflare Quick Tunnel for testing and demonstration purposes.

## Features

- ✅ **Branch Selection**: Choose which branch to deploy via `workflow_dispatch`
- ✅ **Full Build Process**: Complete PHP and Node.js build pipeline
- ✅ **Smart Database Setup**: Automatically detects and uses GitHub Actions PostgreSQL service or local PostgreSQL installation
- ✅ **Smart Redis Setup**: Automatically detects and uses GitHub Actions Redis service or local Redis installation
- ✅ **Public Access**: Exposes the app via Cloudflare Quick Tunnel (no authentication required)
- ✅ **30-Minute Timeout**: Automatically shuts down after 30 minutes
- ✅ **Health Monitoring**: Continuous health checks during runtime
- ✅ **Comprehensive Logging**: Detailed step-by-step execution logs
- ✅ **Automatic Cleanup**: Cleans up all resources after completion

## How to Use

### Trigger the Workflow

1. Go to the **Actions** tab in your GitHub repository
2. Select the **"Deploy App with Cloudflare Tunnel"** workflow
3. Click **"Run workflow"**
4. Select or enter the branch you want to deploy (default: `v4.x`)
5. Click **"Run workflow"** button

### Access Your Deployment

Once the workflow starts:

1. Wait for the **"Start Cloudflare Quick Tunnel"** step to complete (usually 2-3 minutes)
2. Look for the deployment summary in the workflow run page
3. You'll see a public URL like: `https://xxxxx.trycloudflare.com`
4. Click the URL to access your deployed Coolify instance

### Workflow Execution Time

- **Build Time**: ~3-5 minutes (depending on cache)
- **Startup Time**: ~1-2 minutes
- **Running Time**: Up to 30 minutes (configurable)
- **Total Duration**: Maximum 30 minutes

## What Gets Tested

Each workflow run validates the following steps:

### 1. Environment Setup
- ✅ Checkout specified branch
- ✅ Install PHP 8.4 with required extensions
- ✅ Install Node.js 24
- ✅ Verify installed versions

### 2. Dependency Management
- ✅ Cache and restore Composer dependencies
- ✅ Install Composer packages
- ✅ Install npm packages
- ✅ Verify all dependencies resolve correctly

### 3. Application Build
- ✅ Copy and configure environment file
- ✅ Update database connection settings
- ✅ Build frontend assets with Vite
- ✅ Generate application key
- ✅ Set directory permissions
- ✅ Verify build artifacts are created

### 4. Database Operations
- ✅ PostgreSQL service starts and is healthy
- ✅ Redis service starts and is healthy
- ✅ Database migrations run successfully
- ✅ Application connects to database

### 5. Application Runtime
- ✅ Laravel server starts on port 8080
- ✅ Application responds to health checks
- ✅ Optimization caches are generated
- ✅ Application remains stable during runtime

### 6. Cloudflare Tunnel
- ✅ Cloudflared installs successfully
- ✅ Tunnel establishes connection
- ✅ Public URL is generated
- ✅ Application is accessible via public URL

### 7. Continuous Monitoring
- ✅ Health checks run every minute
- ✅ Process monitoring for both server and tunnel
- ✅ Graceful shutdown after timeout
- ✅ Cleanup of all processes

## Configuration

### Timeout Duration

The workflow is set to run for a maximum of 30 minutes. To change this:

```yaml
jobs:
  deploy:
    timeout-minutes: 30  # Change this value
```

### Branch Selection

Default branch is `v4.x`. You can:
- Change the default in the workflow file
- Select a different branch when triggering the workflow manually

### PHP Extensions

The workflow installs the following PHP extensions:
- mbstring, xml, ctype, iconv, intl
- pdo, pdo_pgsql
- dom, filter, gd, json
- redis

To add more extensions, update the `extensions` parameter in the `Set up PHP 8.4` step.

### Environment Variables

The workflow automatically configures these environment variables:
- `DB_HOST=127.0.0.1` (GitHub Actions service)
- `DB_DATABASE=coolify`
- `DB_USERNAME=coolify`
- `DB_PASSWORD=password`
- `APP_PORT=8080`
- `RAY_ENABLED=false`
- `TELESCOPE_ENABLED=false`

## Services

### PostgreSQL
The workflow intelligently detects and uses PostgreSQL:

**GitHub Actions Service (Preferred)**:
- **Version**: 15-alpine
- **Port**: 5432
- **Database**: coolify
- **Username**: coolify
- **Password**: password
- Automatically configured when running in GitHub Actions

**Local PostgreSQL (Fallback)**:
- Used when GitHub Actions service is not available
- Automatically detects existing PostgreSQL installation
- Creates database and user if needed
- Starts PostgreSQL service if stopped
- Cleans up database after workflow completion

### Redis
The workflow also intelligently detects and uses Redis:

**GitHub Actions Service (Preferred)**:
- **Version**: 7-alpine
- **Port**: 6379
- Automatically configured when running in GitHub Actions

**Local Redis (Fallback)**:
- Used when GitHub Actions service is not available
- Automatically detects and starts local Redis if available
- Not critical for basic application functionality

## Stopping the Workflow Early

To stop the workflow before the 30-minute timeout:

1. Go to the running workflow in the Actions tab
2. Click the **"Cancel workflow"** button
3. The cleanup step will automatically run to stop all processes

## Troubleshooting

### Build Fails

Check the logs for each step. Common issues:
- **Composer errors**: Check `composer.lock` is committed
- **npm errors**: Check `package-lock.json` is committed
- **PHP version**: Ensure code is compatible with PHP 8.4

### Application Won't Start

Check these steps:
- Database migration logs
- Laravel server startup logs
- Application health check response

### Tunnel Won't Connect

Check:
- Cloudflared installation step
- Tunnel log output in the workflow
- Network connectivity

### Health Checks Fail

The application might be starting but not responding correctly:
- Check Laravel logs in the cleanup step
- Verify all required services are running
- Check for application errors in the logs

### Database Connection Issues

If the workflow fails to connect to PostgreSQL:

**For GitHub Actions Service**:
- Verify the service is defined in the workflow
- Check service health in the workflow logs
- Ensure port 5432 is properly mapped

**For Local PostgreSQL**:
- Verify PostgreSQL is installed: `psql --version`
- Check PostgreSQL service status: `sudo systemctl status postgresql`
- Review the "Check and setup PostgreSQL" step logs
- Ensure user has permissions to create databases

**Common Solutions**:
- Wait longer for PostgreSQL to start (check health check timeouts)
- Verify pg_isready is available
- Check PostgreSQL authentication configuration

### Redis Connection Issues

Redis issues are generally non-critical:
- The application can often run without Redis
- Check the "Check and setup Redis" step logs
- Verify Redis installation if using local Redis

## Security Considerations

⚠️ **Important Notes**:

- This workflow is designed for **testing and demonstration** purposes only
- The application is **publicly accessible** via the Cloudflare tunnel
- No authentication is required to access the tunnel URL
- The tunnel URL is random and temporary
- All data is stored in ephemeral GitHub Actions environment
- Everything is deleted when the workflow completes

**Do NOT**:
- Use for production deployments
- Store sensitive data
- Use real credentials
- Leave running for extended periods

## Logs and Debugging

### View Logs

All steps produce detailed logs:
1. Click on any step to expand its logs
2. Check the "Cleanup" step for application and tunnel logs
3. Review the job summary for the public URL

### Download Logs

You can download all logs:
1. Go to the workflow run
2. Click the "..." menu
3. Select "Download log archive"

## Workflow File Location

```
.github/workflows/deploy-with-cloudflare-tunnel.yml
```

## Related Files

- `.env.development.example` - Environment template
- `docker-compose.dev.yml` - Development services configuration
- `package.json` - Node.js dependencies
- `composer.json` - PHP dependencies
- `vite.config.js` - Frontend build configuration

## Testing the Workflow

Before running the workflow, you can test individual components locally:

```bash
# Test frontend build
npm ci
npm run build

# Verify PHP version (requires PHP 8.4)
php --version

# Test Vite build artifacts
ls -la public/build/
```

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Cloudflare Quick Tunnels](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/do-more-with-tunnels/trycloudflare/)
- [Coolify Documentation](https://coolify.io/docs)
- [Laravel Documentation](https://laravel.com/docs)

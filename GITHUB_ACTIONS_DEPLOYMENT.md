# Deploying Coolify with GitHub Actions and Cloudflare Tunnel

This workflow allows you to deploy Coolify with external PostgreSQL and Redis using GitHub Actions, with optional exposure via Cloudflare Tunnel.

## Prerequisites

1. **External PostgreSQL Database** (e.g., Neon, Supabase, Railway, or any PostgreSQL service)
   - Note the `DATABASE_URL` in the format: `postgresql://user:password@host:5432/database?sslmode=require`

2. **External Redis Instance** (e.g., Upstash, Redis Cloud, or any Redis service)
   - Note the `REDIS_URL` in the format: `redis://default:password@host:6379` (or `rediss://` for TLS)

3. **Cloudflare Tunnel Token** (Optional)
   - Only needed if you want public access via Cloudflare Tunnel
   - Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
   - Navigate to **Networks** → **Tunnels**
   - Create a new tunnel
   - Copy the tunnel token (starts with `ey...`)

## How to Deploy

### Step 1: Navigate to GitHub Actions

1. Go to your repository on GitHub
2. Click on the **Actions** tab
3. Find **"Deploy with Cloudflare Tunnel"** in the workflows list

### Step 2: Run the Workflow

1. Click on **"Deploy with Cloudflare Tunnel"**
2. Click the **"Run workflow"** button
3. Fill in the inputs:

   ```
   branch: copilot/fix-dockerfile-errors (or any branch you want to deploy)
   database_url: postgresql://user:pass@host:5432/database?sslmode=require
   redis_url: rediss://default:pass@host:6379
   reset_database: ☐ Check this to drop all tables and start fresh (useful for testing)
   cloudflare_tunnel_token: (optional - leave empty for local-only deployment)
   ```

4. Click **"Run workflow"** to start the deployment

### Step 3: Monitor the Deployment

The workflow will:
1. ✅ Checkout the specified branch
2. ✅ Generate a secure `APP_KEY`
3. ✅ Create a minimal `.env` file with only `DATABASE_URL` and `REDIS_URL`
4. ✅ Build the Docker image
5. ✅ Reset database (if requested)
6. ✅ Start Coolify and Soketi services
7. ✅ Fix storage permissions
8. ✅ Run database migrations automatically
9. ✅ Verify application is ready
10. ✅ Start Cloudflare Tunnel (if token provided)
11. ✅ Display connection information
12. ✅ Keep the deployment running

### Step 4: Access Your Deployment

Once the workflow completes:

**With Cloudflare Tunnel:**
1. Check Cloudflare Zero Trust dashboard
2. Navigate to **Networks** → **Tunnels**
3. Find your tunnel and see the public URL
4. Open the public URL in your browser

**Without Cloudflare Tunnel (Local Only):**
- The application runs on the GitHub Actions runner
- Primarily useful for testing the workflow
- Not accessible from outside (no public URL)

**Next Steps:**
- Visit the registration page
- Create your admin account
- You'll be redirected to the dashboard
- Start deploying applications!

## Stopping the Deployment

The deployment runs as long as the GitHub Actions workflow is active. To stop it:

1. Go to the **Actions** tab
2. Find the running workflow
3. Click on it
4. Click **"Cancel workflow"**

This will stop the Cloudflare Tunnel (if running) and shut down the Coolify services.

## Configuration Details

### New Features

#### 1. Branch Selection
- Deploy any branch from your repository
- Default: `copilot/fix-dockerfile-errors`
- Useful for testing different versions

#### 2. Database Reset
- Optional checkbox to reset the database before deployment
- Drops all tables and recreates the schema
- Useful for:
  - Testing fresh installations
  - Fixing corrupt database state
  - Starting over after failed deployments
- **Warning**: This deletes ALL data!

#### 3. Automatic Database Setup
- Workflow automatically runs `php artisan migrate --force` after startup
- Creates all required tables including:
  - `teams`, `users`, `email_notification_settings`
  - All other Coolify tables
- No manual migration needed!

#### 4. Optional Cloudflare Tunnel
- Cloudflare tunnel token is now optional
- Leave empty for local-only testing
- Provide token for public access

### Minimal Environment Variables

The workflow only requires:
- `DATABASE_URL` - Full PostgreSQL connection string
- `REDIS_URL` - Full Redis connection string

All other variables are automatically generated or use sensible defaults:
- `APP_KEY` - Auto-generated with `openssl rand -base64 32`
- `APP_ENV=production`
- `QUEUE_CONNECTION=redis`
- `SESSION_DRIVER=redis`
- `CACHE_DRIVER=redis`
- `MAIL_MAILER=log`

### Database URL Format

#### PostgreSQL (with SSL)
```
postgresql://username:password@host:5432/database?sslmode=require
```

#### PostgreSQL (Neon with pooling)
```
postgresql://username:password@host-pooler.region.aws.neon.tech:5432/database?sslmode=require
```

### Redis URL Format

#### Redis without TLS
```
redis://default:password@host:6379
```

#### Redis with TLS (Upstash, Redis Cloud)
```
rediss://default:password@host:6379
```

## Troubleshooting

### Missing table errors (e.g., "email_notification_settings does not exist")

**Cause**: Database migrations haven't run yet or failed.

**Solution**:
1. Check the "Run database migrations" step in workflow logs
2. If migrations failed, try running the workflow again with "Reset database" checked
3. The workflow now automatically runs migrations, so this should be rare

### Duplicate key errors during registration

**Cause**: Team id=0 already exists in database from previous deployment.

**Solution**:
1. Run the workflow with "Reset database" checkbox enabled
2. This will drop all tables and start fresh
3. The code now handles this case, but reset ensures clean state

### Workflow fails at "Check service health"

**Cause**: Services didn't start properly or health checks failed.

**Solution**:
1. Check the "Show logs" step in the workflow output
2. Verify your `DATABASE_URL` and `REDIS_URL` are correct
3. Ensure your database and Redis instances are accessible from GitHub Actions runners

### Cloudflare Tunnel not starting

**Cause**: Invalid tunnel token or step is skipped.

**Solution**:
1. Verify your Cloudflare Tunnel token is correct (if provided)
2. Make sure the token hasn't expired
3. The tunnel is optional - you can leave it empty for local testing
4. Create a new tunnel in Cloudflare dashboard if needed

### Cannot access the public URL

**Cause**: Tunnel might not be configured properly in Cloudflare, or token wasn't provided.

**Solution**:
1. Make sure you provided a Cloudflare Tunnel token in the workflow
2. Go to Cloudflare Zero Trust dashboard
3. Check your tunnel's **Public Hostname** configuration
4. Make sure it's routing to `http://localhost:8000`

### Database connection errors

**Cause**: Database URL is incorrect or database is not accessible.

**Solution**:
1. Verify the `DATABASE_URL` format is correct
2. Test connection locally with `psql $DATABASE_URL`
3. Check if your database service allows connections from GitHub Actions IPs
4. For Neon: use the pooled connection string, not the direct one

### Redis connection errors

**Cause**: Redis URL is incorrect or Redis is not accessible.

**Solution**:
1. Verify the `REDIS_URL` format (use `rediss://` for TLS)
2. Test connection with `redis-cli --tls -u $REDIS_URL ping`
3. Check if your Redis service allows connections from GitHub Actions IPs
4. For Upstash: make sure you're using the TLS endpoint

## Security Notes

⚠️ **Important Security Considerations:**

1. **GitHub Secrets**: Consider storing `DATABASE_URL`, `REDIS_URL`, and `CLOUDFLARE_TUNNEL_TOKEN` as repository secrets instead of entering them manually each time.

2. **Public Access**: The Cloudflare Tunnel exposes your Coolify instance publicly. Make sure to:
   - Set a strong admin password during registration
   - Enable Cloudflare Access policies to restrict who can access your instance
   - Keep Coolify updated

3. **Database Credentials**: The `DATABASE_URL` and `REDIS_URL` contain passwords. They are:
   - Not logged in the workflow output
   - Not stored in the repository
   - Only exist in the running workflow environment

## Using Repository Secrets

For better security, store your credentials as secrets:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add these secrets:
   - `PRODUCTION_DATABASE_URL`
   - `PRODUCTION_REDIS_URL`
   - `CLOUDFLARE_TUNNEL_TOKEN`

3. Update the workflow to use secrets instead of inputs (modify the workflow file)

## Advanced: Long-Running Deployment

For a long-running deployment:

1. Use GitHub's self-hosted runners instead of GitHub-hosted runners
2. Or use a dedicated server with the `docker-compose.external.yml` file
3. The workflow is designed for testing/staging; for production, deploy to a server

## Next Steps

After deployment:
1. Create your admin account
2. Add your servers to Coolify
3. Deploy your applications
4. Configure email notifications (update `MAIL_*` environment variables)
5. Set up regular backups

## Support

- **Coolify Documentation**: https://coolify.io/docs
- **Cloudflare Tunnel Docs**: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/
- **Issues**: https://github.com/coollabsio/coolify/issues

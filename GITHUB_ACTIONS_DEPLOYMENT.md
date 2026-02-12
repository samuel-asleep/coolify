# Deploying Coolify with GitHub Actions and Cloudflare Tunnel

This workflow allows you to deploy Coolify with external PostgreSQL and Redis using GitHub Actions, with automatic exposure via Cloudflare Tunnel.

## Prerequisites

1. **External PostgreSQL Database** (e.g., Neon, Supabase, Railway, or any PostgreSQL service)
   - Note the `DATABASE_URL` in the format: `postgresql://user:password@host:5432/database?sslmode=require`

2. **External Redis Instance** (e.g., Upstash, Redis Cloud, or any Redis service)
   - Note the `REDIS_URL` in the format: `redis://default:password@host:6379` (or `rediss://` for TLS)

3. **Cloudflare Tunnel Token**
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
3. Fill in the required inputs:

   ```
   database_url: postgresql://user:pass@host:5432/database?sslmode=require
   redis_url: rediss://default:pass@host:6379
   cloudflare_tunnel_token: eyJh...your-token-here
   ```

4. Click **"Run workflow"** to start the deployment

### Step 3: Monitor the Deployment

The workflow will:
1. ✅ Checkout the code
2. ✅ Generate a secure `APP_KEY`
3. ✅ Create a minimal `.env` file with only `DATABASE_URL` and `REDIS_URL`
4. ✅ Build the Docker image
5. ✅ Start Coolify and Soketi services
6. ✅ Fix storage permissions
7. ✅ Start Cloudflare Tunnel
8. ✅ Display connection information
9. ✅ Keep the deployment running

### Step 4: Access Your Deployment

Once the workflow completes:

1. **Check Cloudflare Dashboard**
   - Go to your Cloudflare Zero Trust dashboard
   - Navigate to **Networks** → **Tunnels**
   - Find your tunnel and see the public URL

2. **Access Coolify**
   - Open the public URL in your browser
   - You'll see the Coolify registration page
   - Create your admin account
   - Start deploying applications!

## Stopping the Deployment

The deployment runs as long as the GitHub Actions workflow is active. To stop it:

1. Go to the **Actions** tab
2. Find the running workflow
3. Click on it
4. Click **"Cancel workflow"**

This will stop the Cloudflare Tunnel and shut down the Coolify services.

## Configuration Details

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

### Workflow fails at "Check service health"

**Cause**: Services didn't start properly or health checks failed.

**Solution**:
1. Check the "Show logs" step in the workflow output
2. Verify your `DATABASE_URL` and `REDIS_URL` are correct
3. Ensure your database and Redis instances are accessible from GitHub Actions runners

### Cloudflare Tunnel not starting

**Cause**: Invalid tunnel token.

**Solution**:
1. Verify your Cloudflare Tunnel token is correct
2. Make sure the token hasn't expired
3. Create a new tunnel in Cloudflare dashboard if needed

### Cannot access the public URL

**Cause**: Tunnel might not be configured properly in Cloudflare.

**Solution**:
1. Go to Cloudflare Zero Trust dashboard
2. Check your tunnel's **Public Hostname** configuration
3. Make sure it's routing to `http://localhost:8000`

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

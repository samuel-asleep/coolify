# Zero-Configuration Deployment with Quick Tunnel

This workflow provides the easiest way to deploy and test Coolify with **zero configuration required**. No external services, no credentials, just click and deploy!

## Features

### 🎯 Zero Configuration
- **No DATABASE_URL needed** - Uses local PostgreSQL service
- **No REDIS_URL needed** - Uses local Redis service
- **No Cloudflare account needed** - Uses Cloudflare Quick Tunnel
- **No setup required** - Everything runs automatically

### 🚀 Instant Deployment
- Click "Run workflow" button
- Wait ~2-3 minutes
- Get a public URL instantly
- Start using Coolify immediately

### 🌐 Public Access via Quick Tunnel
- Cloudflare Quick Tunnel provides temporary public URLs
- Format: `https://[random-id].trycloudflare.com`
- No account or token required
- URL changes each workflow run
- Perfect for demos and testing

## How to Use

### Step 1: Navigate to GitHub Actions

1. Go to your repository on GitHub
2. Click on the **Actions** tab
3. Find **"Deploy with Local Services and Quick Tunnel"** in the workflows list

### Step 2: Run the Workflow

1. Click on **"Deploy with Local Services and Quick Tunnel"**
2. Click the **"Run workflow"** button
3. Select the branch you want to deploy (default: `copilot/fix-dockerfile-errors`)
4. Click **"Run workflow"**

That's it! No other inputs needed.

### Step 3: Wait for Deployment

The workflow will:
1. ✅ Start local PostgreSQL service
2. ✅ Start local Redis service
3. ✅ Checkout your code
4. ✅ Generate secure APP_KEY
5. ✅ Build Docker image
6. ✅ Start Coolify and Soketi
7. ✅ Fix storage permissions
8. ✅ Run database migrations
9. ✅ Setup Cloudflare Quick Tunnel
10. ✅ Display public URL

### Step 4: Access Your Deployment

Once the workflow completes (look for the "Display connection info" step):

1. Find the public URL in the logs:
   ```
   🌐 Access URLs:
     • Local: http://localhost:8000
     • Public (Quick Tunnel): https://abc-def-ghi.trycloudflare.com
   ```

2. Open the Quick Tunnel URL in your browser

3. You'll see the Coolify registration page

4. Create your admin account

5. Start deploying applications!

## Architecture

### Services Running

```
┌─────────────────────────────────────────┐
│     GitHub Actions Runner               │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────┐  ┌──────────────┐    │
│  │ PostgreSQL  │  │    Redis     │    │
│  │   :5432     │  │    :6379     │    │
│  └─────────────┘  └──────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │        Coolify Container        │   │
│  │          :8000                  │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │    Soketi (WebSocket)           │   │
│  │       :6001-6002                │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │   Cloudflare Quick Tunnel       │   │
│  │  (cloudflared)                  │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
                  │
                  │ Quick Tunnel
                  ▼
         🌐 Internet 🌐
   https://xyz.trycloudflare.com
```

### Database Configuration

- **PostgreSQL 15 Alpine**
  - Database: `coolify`
  - User: `coolify`
  - Password: `coolify_password`
  - Port: `5432`

- **Redis 7 Alpine**
  - No authentication
  - Port: `6379`

## Quick Tunnel Details

### What is Cloudflare Quick Tunnel?

Cloudflare Quick Tunnel (`cloudflared tunnel --url`) is a free service that:
- Creates a secure tunnel from localhost to the internet
- Provides a temporary public URL
- Requires no account or authentication
- Works immediately
- Is perfect for testing and demos

### Characteristics

✅ **Advantages:**
- Zero configuration
- No account needed
- Works immediately
- Secure HTTPS connection
- No firewall configuration needed

⚠️ **Limitations:**
- URL changes each time
- Temporary (lasts only during workflow)
- Not for production use
- Rate limits may apply

### Example URLs

Each time you run the workflow, you get a new random URL:
- `https://sweet-river-123.trycloudflare.com`
- `https://bold-mountain-456.trycloudflare.com`
- `https://calm-forest-789.trycloudflare.com`

## Use Cases

### Perfect For:
- 🧪 **Quick testing** - Test Coolify features quickly
- 👥 **Demos** - Show Coolify to others instantly
- 🎓 **Learning** - Learn Coolify without setup
- 🐛 **Bug reproduction** - Reproduce issues easily
- 📸 **Screenshots** - Get screenshots for documentation

### Not Recommended For:
- ❌ Production deployments
- ❌ Long-term hosting
- ❌ Storing important data (ephemeral database)
- ❌ Heavy traffic applications

## Stopping the Deployment

The deployment runs as long as the workflow is active:

1. Go to the **Actions** tab
2. Find the running workflow
3. Click on it
4. Click **"Cancel workflow"**

This will:
- Stop Cloudflare tunnel (URL becomes inactive)
- Stop Coolify containers
- Stop PostgreSQL and Redis services
- Delete all data (ephemeral)

## Troubleshooting

### Workflow fails at "Verify services are ready"

**Cause**: PostgreSQL or Redis service didn't start.

**Solution**: 
- Check the service health in the workflow logs
- Re-run the workflow (services sometimes take longer to start)

### No Quick Tunnel URL appears

**Cause**: Cloudflared couldn't establish tunnel or URL extraction failed.

**Solution**:
- Check the "Show logs on failure" step for tunnel logs
- The tunnel may still be working even if URL wasn't extracted
- Re-run the workflow

### Can't access the Quick Tunnel URL

**Cause**: Tunnel may not be fully established or Coolify isn't responding.

**Solution**:
- Wait an additional minute after seeing the URL
- Check that "Keep workflow running" shows health checks passing
- Verify Coolify health at the local URL first

### "Migrations failed" error

**Cause**: Database migration encountered an error.

**Solution**:
- Check the migration error in logs
- Re-run the workflow (starts with fresh database)
- Check "Show logs on failure" for detailed error

### Workflow cancelled but tunnel still accessible

**Cause**: Quick Tunnel URLs may have a short grace period.

**Solution**:
- This is normal - the URL will stop working within a few minutes
- Don't rely on this - always cancel the workflow when done

## Comparing Workflows

| Feature | deploy-with-cloudflare-tunnel.yml | deploy-local-quick-tunnel.yml |
|---------|-----------------------------------|-------------------------------|
| PostgreSQL | External (Neon, etc.) | Local (GitHub Actions service) |
| Redis | External (Upstash, etc.) | Local (GitHub Actions service) |
| Tunnel Type | Managed tunnel (requires token) | Quick tunnel (no token) |
| Configuration | DATABASE_URL, REDIS_URL, Token | None required |
| Setup Time | Requires external services | Instant |
| Data Persistence | Persistent (external DB) | Ephemeral (runner only) |
| Use Case | Staging/Production testing | Quick demos and testing |
| Public URL | Stable (same tunnel) | Changes each run |

## Tips and Best Practices

### For Testing
1. Use this workflow to quickly test new features
2. Test registration and basic workflows
3. Verify migrations work correctly
4. Test with different branches

### For Demos
1. Start the workflow before your demo
2. Share the Quick Tunnel URL
3. Show Coolify features live
4. Cancel workflow after demo

### For Development
1. Test your changes on different branches
2. Verify database migrations
3. Check that permissions are correct
4. Ensure all services communicate properly

## Next Steps

After testing with this workflow, for a production deployment:

1. **Use external services**:
   - PostgreSQL (Neon, Supabase, Railway)
   - Redis (Upstash, Redis Cloud)

2. **Use managed tunnel**:
   - Create a Cloudflare account
   - Set up a named tunnel
   - Use `deploy-with-cloudflare-tunnel.yml` workflow

3. **Or deploy to a server**:
   - Use `docker-compose.external.yml`
   - Set up reverse proxy (Nginx, Traefik)
   - Configure SSL certificates

## Security Notes

⚠️ **Important**:
- The database is temporary and deleted when workflow stops
- Don't store important data in this deployment
- Quick Tunnel URLs are public but hard to guess
- Anyone with the URL can access your instance
- Use only for testing and demos
- Change default passwords if testing security features

## Support

- **Workflow Issues**: Check the Actions logs
- **Coolify Issues**: Check `docker compose logs`
- **Tunnel Issues**: Check `/tmp/tunnel.log` in "Show logs on failure"
- **General Help**: See PRODUCTION_SETUP.md and GITHUB_ACTIONS_DEPLOYMENT.md

## Example Workflow Run

```
🎉 Coolify Deployment Complete!
================================================

Branch: copilot/fix-dockerfile-errors

📊 Services Status:
NAME                IMAGE                                        COMMAND                  SERVICE   CREATED         STATUS                   PORTS
coolify-coolify-1   coolify-coolify                              "docker-php-serversi…"   coolify   2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:8000->8080/tcp
coolify-soketi-1    ghcr.io/coollabsio/coolify-realtime:1.0.10   "/bin/sh /soketi-ent…"   soketi    2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:6001-6002->6001-6002/tcp

🗄️ Local PostgreSQL:
  • Host: localhost:5432
  • Database: coolify
  • User: coolify
  • Status: ✅ Running

📦 Local Redis:
  • Host: localhost:6379
  • Status: ✅ Running

🌐 Access URLs:
  • Local: http://localhost:8000
  • Public (Quick Tunnel): https://magic-pond-1234.trycloudflare.com

Health Check: OK

📝 Next Steps:
1. Visit the public URL above to access Coolify
2. Go to /register to create your account
3. After registration, you'll be redirected to the dashboard
4. Start deploying your applications!

⚠️  Note: The Quick Tunnel URL is temporary and will
    change each time you run this workflow.

================================================
```

Enjoy your zero-configuration Coolify deployment! 🎉

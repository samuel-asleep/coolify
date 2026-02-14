# Run Coolify with Cloudflare Quick Tunnel

This GitHub Actions workflow allows you to run Coolify and expose it publicly via Cloudflare Quick Tunnel for testing and demonstration purposes.

## Features

- ✅ Builds and runs Coolify from any branch
- ✅ Exposes the application via Cloudflare Quick Tunnel (no account required)
- ✅ Configurable tunnel duration
- ✅ Automatic database setup with migrations and seeders
- ✅ Full error logging and cleanup

## How to Use

### Option 1: Manual Trigger (Recommended)

1. Go to the **Actions** tab in your GitHub repository
2. Select **"Run Coolify with Cloudflare Quick Tunnel"** workflow
3. Click **"Run workflow"**
4. Configure the workflow:
   - **Branch to deploy**: Select which branch to deploy (default: `v4.x`)
   - **Tunnel duration**: How long to keep the tunnel alive in minutes (default: `30`)
5. Click **"Run workflow"** button

### Option 2: Automatic Trigger

The workflow automatically runs when you push to the `copilot/create-github-actions-workflow-again` branch.

## Workflow Steps

1. **Checkout code**: Checks out the selected branch
2. **Set up environment**: Creates `.env` file with all necessary configuration
3. **Install dependencies**: Runs `composer install` to install PHP dependencies
4. **Build Docker images**: Builds Coolify and Soketi images
5. **Start services**: Starts PostgreSQL, Redis, and MinIO
6. **Start Coolify**: Launches the main application and Soketi realtime service
7. **Run migrations**: Sets up the database with migrations and seeders
8. **Install Cloudflare Tunnel**: Installs `cloudflared` CLI
9. **Start tunnel**: Creates a public URL via Cloudflare Quick Tunnel
10. **Keep alive**: Maintains the tunnel for the specified duration
11. **Cleanup**: Stops all services and removes volumes

## Accessing the Application

Once the workflow is running, look for the step **"Display access information"** in the workflow logs. You'll see:

```
================================================
🚀 Coolify is running and accessible via Cloudflare Quick Tunnel!
================================================

🌐 Public URL: https://[random-subdomain].trycloudflare.com
🔐 Default Login: test@example.com
🔑 Default Password: password
🌿 Branch: v4.x

================================================
```

## Default Credentials

- **Email**: `test@example.com`
- **Password**: `password`

These credentials are from the database seeder and are only for development/testing purposes.

## Customization

### Change Tunnel Duration

You can keep the tunnel alive longer by adjusting the `tunnel_duration` input when manually triggering the workflow. The maximum duration is limited by the GitHub Actions timeout (60 minutes by default).

### Deploy Different Branches

Select any branch name when manually triggering the workflow to deploy that specific branch.

### Modify Environment Variables

Edit the **"Set up environment file"** step in the workflow to customize environment variables.

## Troubleshooting

### Workflow Fails During Composer Install

If the composer install fails, check the logs for specific error messages. Common issues:
- Missing PHP extensions
- Memory limits
- Network issues downloading packages

### Database Migration Fails

If migrations fail, check the database logs:
```bash
docker compose logs postgres
```

### Tunnel URL Not Generated

If the tunnel URL doesn't appear:
1. Check the **"Start Cloudflare Quick Tunnel"** step logs
2. Look for any cloudflared installation errors
3. Ensure port 8000 is accessible

### Application Not Responding

If the application isn't responding:
1. Check the **"Check service status"** step
2. Review Coolify logs in the **"Show application logs"** step
3. Verify all containers are healthy

## Limitations

- Tunnel URLs are temporary and change with each workflow run
- Free Cloudflare Quick Tunnels have rate limits
- The tunnel will automatically close after the specified duration
- GitHub Actions has usage limits based on your plan

## Security Notes

⚠️ **This workflow is for testing and demonstration purposes only!**

- The generated tunnel URL is publicly accessible
- Default credentials are used (test@example.com / password)
- No authentication is required to access the Cloudflare tunnel
- The application runs with debug mode enabled

**Do not use this workflow for production deployments or with sensitive data!**

## Cleanup

All resources are automatically cleaned up when the workflow completes:
- Docker containers are stopped and removed
- Docker volumes are deleted
- The Cloudflare tunnel is terminated

## Support

For issues with:
- The workflow itself: Open an issue in this repository
- Coolify application: See [Coolify Documentation](https://coolify.io/docs)
- Cloudflare tunnels: See [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

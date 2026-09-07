# AZ-104 Lab 06 — Azure App Service

## What This Covers
Deploying web applications to Azure App Service, configuring deployment slots for zero-downtime releases, setting up autoscaling, and managing app settings and connection strings.

## Tasks

- Create an App Service Plan
- Deploy a web app (Node.js / .NET / Python)
- Deploy using ZIP, GitHub Actions, and local Git
- Configure app settings and connection strings
- Create a staging deployment slot
- Swap staging to production (zero downtime)
- Configure autoscale rules based on CPU
- Enable custom domain and SSL certificate
- Set up backup and restore

## CLI Commands

```bash
# Create App Service Plan
az appservice plan create \
  --name MyPlan --resource-group MyRG \
  --sku S1 --is-linux

# Create web app
az webapp create \
  --name MyWebApp --resource-group MyRG \
  --plan MyPlan --runtime "DOTNETCORE:8.0"

# Deploy via ZIP
az webapp deployment source config-zip \
  --resource-group MyRG --name MyWebApp --src ./app.zip

# Set app settings
az webapp config appsettings set \
  --resource-group MyRG --name MyWebApp \
  --settings ENV="production" API_KEY="mykey"

# Create staging slot
az webapp deployment slot create \
  --resource-group MyRG --name MyWebApp --slot staging

# Swap staging to production
az webapp deployment slot swap \
  --resource-group MyRG --name MyWebApp \
  --slot staging --target-slot production

# View live logs
az webapp log tail --resource-group MyRG --name MyWebApp

# Configure autoscale
az monitor autoscale create \
  --resource-group MyRG \
  --resource MyPlan \
  --resource-type Microsoft.Web/serverfarms \
  --name MyAutoscale \
  --min-count 1 --max-count 5 --count 2

# Scale out when CPU > 70%
az monitor autoscale rule create \
  --resource-group MyRG --autoscale-name MyAutoscale \
  --scale out 1 --condition "Percentage CPU > 70 avg 5m"

# Scale in when CPU < 30%
az monitor autoscale rule create \
  --resource-group MyRG --autoscale-name MyAutoscale \
  --scale in 1 --condition "Percentage CPU < 30 avg 10m"
```

## Key Concepts
**App Service Plan Tiers**
- Free / Shared → no custom domain, shared compute, no SLA
- Basic → dedicated compute, manual scale (up to 3), no deployment slots
- Standard → autoscale, deployment slots (up to 5), backups
- Premium → more slots, VNet integration, faster compute

**Deployment Slots**
- Available from Standard tier upward
- Each slot has its own URL: `myapp-staging.azurewebsites.net`
- Swap is atomic — no downtime for users
- Slot swap warms up the new version before switching traffic
- Easy to roll back by swapping again

**App Settings vs Connection Strings**
- Both are environment variables injected at runtime
- Connection strings show up under a different section in code
- Both are encrypted at rest
- Settings in the portal override values in web.config

**Scaling**
- Scale up = bigger VM (more CPU/RAM). Must stop if not auto
- Scale out = more instances running in parallel. Needs load balancer
- Autoscale requires Standard tier or above
- Always On (keep app loaded) requires Basic tier or above

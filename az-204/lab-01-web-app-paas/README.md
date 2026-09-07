# Lab 01 — Web App on Azure App Service (PaaS)

## What I Did
Deployed a multi-tier web application on Azure App Service. The setup separates the API backend and the web frontend into two independent App Services that share the same App Service Plan and talk to a Storage Account.

The deployment was done entirely through Azure CLI using ZIP deploy — no GUI, no pipeline.

## What I Built

```
Storage Account
      ↓
API App (imgapi) ←→ Web App (imgweb)
      ↑
App Service Plan S1 (ManagedPlan)
```

## Resources

| Resource | Name | Type |
|---|---|---|
| Resource Group | ManagedPlatform-lod61542506 | Resource Group |
| App Service Plan | ManagedPlan | S1 Standard |
| API App | imgapi61542506 | App Service (.NET 8) |
| Web App | imgweb61542506 | App Service (.NET 8) |
| Storage | imgstor61542506 | StorageV2 LRS |

## Commands I Used

```bash
# Check what apps exist in the resource group
az webapp list \
  --resource-group ManagedPlatform-lod61542506 \
  --query "[?starts_with(name, 'imgapi')].{Name:name}" \
  --output tsv

# Deploy the API
az webapp deployment source config-zip \
  --resource-group ManagedPlatform-lod61542506 \
  --src api.zip \
  --name imgapi61542506

# Deploy the frontend
az webapp deployment source config-zip \
  --resource-group ManagedPlatform-lod61542506 \
  --src web.zip \
  --name imgweb61542506
```

## Error I Hit and Fixed
The lab instructions had a literal placeholder `--name <name-of-your-api-app>` and PowerShell threw an error on the `<` character. I realized the angle brackets were placeholders, replaced them with the actual app name, and it worked.

## What I Learned
- PaaS means you focus on the app, Azure handles the OS and runtime
- Both apps share one App Service Plan (the compute underneath)
- S1 tier enables Always On which keeps the app warm
- ZIP deploy is the simplest way to push code via CLI
- LRS replication keeps 3 copies of your storage data locally

## Result
- API live at: https://imgapi61542506.azurewebsites.net
- Web live at: https://imgweb61542506.azurewebsites.net
- Both deployments: Succeeded

**May 6, 2026**

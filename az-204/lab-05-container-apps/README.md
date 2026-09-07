# Lab 05 — Containerized Workloads on Azure

## What I Did
Containerized a .NET 8 console app, pushed it to Azure Container Registry, deployed it as a Container Instance, and then deployed a public container image to Azure Container Apps — a fully managed serverless container platform.

## Flow

```
.NET app + Dockerfile
      ↓
Azure Container Registry (conregistry4918)
      ↓
Container Instances (manualcompute, managedcompute)
      ↓
Container Apps Environment (az204-env-61791760)
      ↓
my-container-app → live on the internet
```

## Resources

| Resource | Type |
|---|---|
| ContainerCompute | Resource Group |
| conregistry4918 | Container Registry |
| manualcompute | Container Instance |
| managedcompute | Container Instance |
| az204-env-61791760 | Container Apps Environment |
| my-container-app | Container App |

## Commands

```powershell
# Create the .NET project
dotnet new console --output . --name ipcheck --framework net8.0
New-Item -ItemType File Dockerfile
dotnet run
```

```bash
# Set up Container Apps
az extension add --name containerapp --upgrade
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights

myRG=ContainerCompute
myAppContEnv=az204-env-61791760

# Create the environment
az containerapp env create \
    --name $myAppContEnv \
    --resource-group $myRG \
    --location eastus

# Deploy a container app
az containerapp create \
    --name my-container-app \
    --resource-group $myRG \
    --environment $myAppContEnv \
    --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
    --target-port 80 \
    --ingress 'external' \
    --query properties.configuration.ingress.fqdn
```

## Result
App live at:
`https://my-container-app.icyglacier-9c7fa413.eastus.azurecontainerapps.io`

Page showed: "Your Azure Container Apps app is live"

## What I Learned
- Container = your app + everything it needs, packaged together
- Container Registry = private storage for your container images
- Container Instance = simplest way to run a container in Azure, no infrastructure to manage
- Container Apps = serverless — you don't configure servers or Kubernetes, Azure handles it
- Consumption workload profile means you pay only when the app is handling requests
- External ingress = publicly accessible URL generated automatically
- Log Analytics workspace gets created automatically for monitoring

**May 14, 2026**

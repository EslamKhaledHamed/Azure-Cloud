# Lab 07 — Secure Secrets with Azure Key Vault

## What I Did
Built an Azure Function that reads a storage connection string from Key Vault instead of having it hardcoded anywhere. The function uses that connection string to download a file from Blob Storage and return its content.

The key point: no secrets in code, no secrets in config files. Everything goes through Key Vault.

## How It Works

```
Key Vault (securevault61929521)
└── stores: StorageConnectionString = real connection string
      ↓
Function App (securefunc61929521)
└── app setting: StorageConnectionString → @Microsoft.KeyVault(...)
└── managed identity → authorized to read from Key Vault
      ↓
FileParser function runs
└── reads env variable → gets connection string
└── creates BlobClient → connects to storage
└── downloads drop/records.json
└── returns content as HTTP response
```

## Resources

| Resource | Type |
|---|---|
| ConfidentialStack-lod61929521 | Resource Group |
| securefunc61929521 | Function App |
| securestor61929521 | Storage Account |
| securevault61929521 | Key Vault |

## Two Phases

**Phase 1** — Tested that the function could read the environment variable:
```csharp
string connectionString = Environment.GetEnvironmentVariable("StorageConnectionString");
response.WriteString(connectionString);
```
Locally returned `[TEST VALUE]`. In Azure returned the real connection string from Key Vault.

**Phase 2** — Used the connection string to read a blob:
```csharp
string connectionString = Environment.GetEnvironmentVariable("StorageConnectionString");
BlobClient blob = new BlobClient(connectionString, "drop", "records.json");
BlobDownloadResult downloadResult = blob.DownloadContent();
response.WriteString(downloadResult.Content.ToString());
```

## Commands

```bash
func init --worker-runtime dotnet-isolated --target-framework net8.0 --force
func new --template "HTTP trigger" --name "FileParser"
dotnet add package Azure.Storage.Blobs --version 12.18.0
func start --build
func azure functionapp publish securefunc61929521 --dotnet-version 8.0
```

## local.settings.json (local only)
```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "StorageConnectionString": "[TEST VALUE]"
  }
}
```

## What I Learned
- Key Vault Reference syntax: `@Microsoft.KeyVault(SecretUri=https://...)` in app settings
- Managed identity removes the need for credentials — Azure handles the auth between services
- Environment.GetEnvironmentVariable() reads app settings at runtime in Azure Functions
- The function app needs the Key Vault Secrets User role to read secrets
- Never put real connection strings in code or config files that get committed to Git

**May 19, 2026**

# Lab 03 — Azure Blob Storage SDK in .NET

## What I Did
Built a C# console app that talks directly to Azure Blob Storage using the Azure SDK. The app lists containers, lists blobs inside them, creates a new container, and retrieves a blob's public URL.

This was also my first time dealing with SDK method nesting issues — the lab instructions caused duplicate methods which broke the build. Fixed and documented below.

## What the App Does

```
Connect to storage account
    ↓
List all containers → compressed-audio, raster-graphics
    ↓
Search raster-graphics → find graph.jpg
    ↓
Create vector-graphics container (if not exists)
    ↓
Find graph.svg in vector-graphics → return its URL
```

## Output

```
Connected to Azure Storage Account
Account name:   mediastor61713443
Account kind:   StorageV2
Account sku:    StandardLrs
Container:      compressed-audio
Container:      raster-graphics
Searching:      raster-graphics
Existing Blob:  graph.jpg
New Container:  vector-graphics
Blob Found, URI: https://mediastor61713443.blob.core.windows.net/vector-graphics/graph.svg
```

## Commands

```bash
dotnet new console --framework net8.0 --name BlobManager --output .
dotnet add package Azure.Storage.Blobs --version 12.18.0
dotnet build
dotnet run
```

## Four Methods I Built

```csharp
// List all containers
await foreach (BlobContainerItem container in client.GetBlobContainersAsync())
    await Console.Out.WriteLineAsync($"Container:\t{container.Name}");

// List blobs in a container
BlobContainerClient container = client.GetBlobContainerClient(containerName);
await foreach (BlobItem blob in container.GetBlobsAsync())
    await Console.Out.WriteLineAsync($"Existing Blob:\t{blob.Name}");

// Create container if it doesn't exist
await container.CreateIfNotExistsAsync(PublicAccessType.Blob);

// Check if blob exists and get its URL
BlobClient blob = client.GetBlobClient(blobName);
bool exists = await blob.ExistsAsync();
if (exists)
    await Console.Out.WriteLineAsync($"Blob Found, URI:\t{blob.Uri}");
```

## Build Errors I Fixed
The lab instructions had me paste new methods inside existing ones by mistake. This caused two C# errors:
- `CS8803` — top-level statements out of order
- `CS0106` — invalid modifier for nested method

Fix: moved all methods to the correct class level, one Main(), all helpers as separate private static async methods.

## What I Learned
- BlobServiceClient → BlobContainerClient → BlobClient is the hierarchy
- StorageSharedKeyCredential authenticates using the storage account key
- PublicAccessType.Blob makes blobs readable via URL without authentication
- CreateIfNotExistsAsync is safe to call multiple times — idempotent
- Blob URL pattern: `https://{account}.blob.core.windows.net/{container}/{blob}`

**May 12, 2026**

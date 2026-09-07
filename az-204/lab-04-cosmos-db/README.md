# Lab 04 — Cosmos DB Polyglot Data Solution

## What I Did
Built a multi-project .NET solution that uploads a product catalog to Azure Cosmos DB and serves it through a web app. Product images are pulled from Azure Blob Storage using a SAS token.

## Architecture

```
AdventureWorks Solution
├── Upload project  → pushes 119 JSON product docs to Cosmos DB
├── Context project → CosmosClient wrapper and queries
├── Models project  → C# product/category models
└── Web project     → ASP.NET app that reads from Cosmos + Blob
```

## Resources

| Resource | Type |
|---|---|
| polycosmos61751749 | Azure Cosmos DB |
| polystor61751749 | Storage Account |
| Retail / Online | Database / Container |

## What I Uploaded

119 product documents — bikes, frames, wheels, pedals, clothing, accessories. Each document has a `Category` field (the partition key) and a nested `Products` array with variants by size and color.

## Queries I Ran in Data Explorer

```sql
-- Browse everything
SELECT * FROM models

-- Count documents
SELECT VALUE COUNT(1) FROM models
-- Result: 119
```

## Commands

```bash
# Add Cosmos SDK to both projects that need it
dotnet add package Microsoft.Azure.Cosmos --version 3.28.0

# Build the full solution
dotnet build

# Upload the data
cd AdventureWorks.Upload
dotnet run

# Run the web app
cd AdventureWorks.Web
dotnet run
```

## What I Learned
- Cosmos DB stores JSON — no fixed schema, each document can look different
- Partition key distributes data across physical partitions for scale
- CosmosClient → database → container is the hierarchy
- Data Explorer in the portal lets you run SQL-style queries on NoSQL data
- SAS tokens give time-limited read access to blob storage without exposing the key
- The web app fetched product data from Cosmos and images from Blob Storage at runtime

## The Web App
Running at localhost:5000 — product catalog with images, detail pages, pricing, and size/color variants. Example: Touring-3000 at $742.35.

**May 13, 2026**

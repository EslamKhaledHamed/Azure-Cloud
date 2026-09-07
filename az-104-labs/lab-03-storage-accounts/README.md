# AZ-104 Lab 03 — Storage Accounts

## What This Covers
Creating and managing Azure Storage accounts — working with Blob containers, uploading files, generating SAS tokens, configuring lifecycle policies, and switching between access tiers.

## Tasks

- Create a StorageV2 storage account
- Create blob containers with different access levels
- Upload and download blobs via portal and CLI
- Generate SAS tokens for time-limited access
- Configure a lifecycle management policy
- Change blob access tiers (Hot, Cool, Archive)
- Create and map an Azure File Share
- Enable soft delete and versioning

## CLI Commands

```bash
# Create storage account
az storage account create \
  --name mystorageaccount \
  --resource-group MyRG \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot

# Get storage key
az storage account keys list \
  --resource-group MyRG \
  --account-name mystorageaccount \
  --query [0].value --output tsv

# Create a container
az storage container create \
  --name mycontainer \
  --account-name mystorageaccount \
  --public-access blob

# Upload a file
az storage blob upload \
  --account-name mystorageaccount \
  --container-name mycontainer \
  --name myfile.txt --file ./myfile.txt

# Generate SAS token for a blob (read only, expires end of year)
az storage blob generate-sas \
  --account-name mystorageaccount \
  --container-name mycontainer \
  --name myfile.txt \
  --permissions r --expiry 2026-12-31 --output tsv

# Change a blob to Cool tier
az storage blob set-tier \
  --account-name mystorageaccount \
  --container-name mycontainer \
  --name myfile.txt --tier Cool

# Create a file share
az storage share create \
  --name myfileshare \
  --account-name mystorageaccount \
  --quota 5
```

## Key Concepts
**Redundancy Options**
- LRS — 3 copies, one datacenter
- ZRS — 3 copies, across availability zones
- GRS — LRS + async copy to a paired region
- GZRS — ZRS + async copy to a paired region
- RA-GRS / RA-GZRS — same as above but with read access to secondary

**Access Tiers**
- Hot — frequent access. Higher storage cost, lower retrieval cost
- Cool — infrequent access. Lower storage cost, higher retrieval cost. Minimum 30 days
- Archive — rarely accessed. Lowest cost. Must rehydrate before reading (can take hours). Minimum 180 days

**Container Access Levels**
- Private — no public access (default)
- Blob — anonymous read for individual blobs
- Container — anonymous read for blobs and listing

**SAS Tokens**
- Can't revoke a SAS token directly — only way is to rotate the account key
- Always set a short expiry
- Use permissions sparingly (r=read, w=write, d=delete, l=list)

**Lifecycle Policies**
- Automatically transition blobs between tiers or delete them based on age
- Applied at the storage account level, can filter by container or blob prefix

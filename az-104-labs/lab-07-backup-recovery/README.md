# AZ-104 Lab 07 — Backup and Site Recovery

## What This Covers
Configuring Azure Backup for virtual machines, creating and managing backup policies, restoring VMs and individual files, and understanding Azure Site Recovery for disaster recovery across regions.

## Tasks

- Create a Recovery Services Vault
- Configure a VM backup policy (schedule + retention)
- Enable backup for a VM
- Trigger an on-demand backup
- Restore a full VM from a recovery point
- Restore individual files from a backup
- Configure Azure Site Recovery replication to another region
- Run a test failover
- Configure file share backup

## CLI Commands

```bash
# Create Recovery Services Vault
az backup vault create \
  --resource-group MyRG \
  --name MyVault \
  --location eastus

# Enable VM backup using default policy
az backup protection enable-for-vm \
  --resource-group MyRG \
  --vault-name MyVault \
  --vm MyVM \
  --policy-name DefaultPolicy

# List backup policies
az backup policy list \
  --resource-group MyRG --vault-name MyVault --output table

# Run an immediate backup
az backup protection backup-now \
  --resource-group MyRG --vault-name MyVault \
  --container-name MyVM --item-name MyVM \
  --backup-management-type AzureIaasVM \
  --retain-until 2026-12-31

# List backup jobs
az backup job list \
  --resource-group MyRG --vault-name MyVault --output table

# List recovery points for a VM
az backup recoverypoint list \
  --resource-group MyRG --vault-name MyVault \
  --container-name MyVM --item-name MyVM \
  --backup-management-type AzureIaasVM --output table

# Restore disks from a recovery point
az backup restore restore-disks \
  --resource-group MyRG --vault-name MyVault \
  --container-name MyVM --item-name MyVM \
  --rp-name <recovery-point-name> \
  --storage-account mystorageaccount
```

## Key Concepts
**Recovery Services Vault**
- Must be in the same region as the protected VM
- One vault can protect resources across multiple subscriptions
- GRS replication is the default — backup data copied to secondary region

**Backup Policy**
- Schedule: daily or weekly
- Retention: daily (up to 9999 days), weekly, monthly, yearly
- Instant restore snapshots kept separately for 1-5 days (faster restore)

**Soft Delete**
- Enabled by default — 14 day grace period after deleting backup data
- Protects against accidental or malicious deletion

**Backup vs Site Recovery**

| | Azure Backup | Azure Site Recovery |
|---|---|---|
| Purpose | Protect data | Business continuity |
| Recovery time | Hours | Minutes |
| Replication | Periodic snapshots | Continuous |
| Use case | Corruption, accidental delete | Region outage |

**Site Recovery Flow**
- Set up replication from source region to target region
- VM data continuously replicates in the background
- Test failover = spin up VM in target region without stopping source (non-disruptive)
- Actual failover = stops source, promotes replica in target region
- Failback = once source region recovers, replicate back and failover again

**RTO and RPO**
- RPO (Recovery Point Objective) = maximum acceptable data loss. How old can the backup be?
- RTO (Recovery Time Objective) = maximum acceptable downtime. How fast must recovery happen?

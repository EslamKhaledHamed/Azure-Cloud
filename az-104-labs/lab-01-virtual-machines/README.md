# AZ-104 Lab 01 — Virtual Machines

## What This Covers
Deploying and managing Azure VMs from scratch — creating, configuring, connecting, resizing, and organizing them into availability sets and scale sets.

## Tasks

- Deploy a Linux and Windows VM from the Azure portal
- Connect via SSH and RDP
- Stop, start, and deallocate VMs
- Resize a VM (requires stopping first)
- Attach a data disk
- Create an Availability Set and deploy VMs into it
- Create a Virtual Machine Scale Set with autoscale rules
- Capture a VM as a managed image

## CLI Commands

```bash
# Create a VM
az vm create \
  --resource-group MyRG \
  --name MyVM \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --size Standard_B1s

# List VMs
az vm list --resource-group MyRG --output table

# Stop and deallocate (stop billing)
az vm deallocate --resource-group MyRG --name MyVM

# Start
az vm start --resource-group MyRG --name MyVM

# Resize
az vm resize \
  --resource-group MyRG --name MyVM --size Standard_B2s

# Add a data disk
az vm disk attach \
  --resource-group MyRG --vm-name MyVM \
  --name MyDataDisk --size-gb 128 --sku Standard_LRS --new

# Create Availability Set
az vm availability-set create \
  --resource-group MyRG --name MyAvailSet \
  --platform-fault-domain-count 2 \
  --platform-update-domain-count 5

# Create Scale Set
az vmss create \
  --resource-group MyRG --name MyScaleSet \
  --image Ubuntu2204 --instance-count 2 \
  --vm-sku Standard_B1s \
  --admin-username azureuser --generate-ssh-keys
```

## Key Concepts

**Stop vs Deallocate**
- Stopped VM → still billed (compute reserved)
- Deallocated VM → not billed (compute released)

**Availability Set**
- Protects against hardware failures (fault domains) and planned maintenance (update domains)
- All VMs must be in the same datacenter
- Max 3 fault domains, 20 update domains

**Availability Zone**
- Physically separate buildings within a region
- Better protection than Availability Sets
- Not all regions support it

**Scale Sets**
- Group of identical VMs that scale in and out automatically
- Need a load balancer to distribute traffic across instances
- Scale rules based on metrics like CPU percentage

**VM Sizes**
- Can't resize while VM is running — must stop first
- Premium SSD only available on certain VM sizes (check documentation)

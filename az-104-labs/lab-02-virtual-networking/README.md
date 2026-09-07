# AZ-104 Lab 02 — Virtual Networking

## What This Covers
Creating and connecting Azure virtual networks — setting up VNets with subnets, controlling traffic with NSGs, connecting networks through peering, and configuring DNS and load balancing.

## Tasks

- Create a VNet with multiple subnets
- Create and configure Network Security Groups
- Add inbound and outbound rules to NSGs
- Associate NSGs with subnets and NICs
- Peer two VNets together
- Test connectivity between peered VNets
- Configure a Load Balancer
- Set up a private DNS zone

## CLI Commands

```bash
# Create VNet
az network vnet create \
  --resource-group MyRG --name MyVNet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name FrontEnd --subnet-prefix 10.0.0.0/24

# Add a second subnet
az network vnet subnet create \
  --resource-group MyRG --vnet-name MyVNet \
  --name BackEnd --address-prefix 10.0.1.0/24

# Create NSG
az network nsg create --resource-group MyRG --name MyNSG

# Allow SSH inbound
az network nsg rule create \
  --resource-group MyRG --nsg-name MyNSG \
  --name AllowSSH --priority 100 \
  --protocol Tcp --destination-port-range 22 \
  --access Allow --direction Inbound

# Allow HTTP inbound
az network nsg rule create \
  --resource-group MyRG --nsg-name MyNSG \
  --name AllowHTTP --priority 200 \
  --protocol Tcp --destination-port-range 80 \
  --access Allow --direction Inbound

# Attach NSG to subnet
az network vnet subnet update \
  --resource-group MyRG --vnet-name MyVNet \
  --name FrontEnd --network-security-group MyNSG

# Peer VNet1 to VNet2 (must do both directions)
az network vnet peering create \
  --resource-group MyRG --name VNet1ToVNet2 \
  --vnet-name VNet1 --remote-vnet VNet2 --allow-vnet-access

az network vnet peering create \
  --resource-group MyRG --name VNet2ToVNet1 \
  --vnet-name VNet2 --remote-vnet VNet1 --allow-vnet-access
```

## Key Concepts
**NSG Rules**
- Lower priority number = higher priority (100 runs before 200)
- Rules go from 100 to 4096
- Default rules at 65000, 65001, 65500 — can't delete them
- NSG can be attached to a subnet, a NIC, or both

**VNet Peering**
- You must create a peering on BOTH sides — it's not automatic
- Peering is NOT transitive: A↔B and B↔C doesn't mean A↔C
- Address spaces cannot overlap between peered VNets
- Works across regions and across subscriptions

**Address Planning**
- Azure reserves 5 IPs in each subnet (.0, .1, .2, .3, .255)
- /24 subnet = 256 total, 251 usable
- Plan your address space before deploying — hard to change later

**Load Balancer vs Application Gateway**
- Load Balancer = Layer 4 (TCP/UDP), distributes by IP and port
- Application Gateway = Layer 7 (HTTP/HTTPS), can route by URL path, has WAF

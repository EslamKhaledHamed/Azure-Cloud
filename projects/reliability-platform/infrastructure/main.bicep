targetScope = 'resourceGroup'

param location string = resourceGroup().location

@description('Administrator username for the Windows VM')
param adminUsername string = 'azureadmin'

@secure()
@description('Administrator password for the Windows VM')
param adminPassword string

// ============================================================
// NAMES AND CONFIGURATION
// ============================================================

var vnetName = 'reliability-vnet'
var subnetName = 'app-subnet'
var nsgName = 'app-subnet-nsg'
var nicName = 'reliability-vm-nic'

var vmName = 'reliability-vm'
var vmSize = 'Standard_D2als_v7'

// Storage account names must be globally unique.
// uniqueString() creates a repeatable unique suffix.
var storageAccountName = 'relplat${uniqueString(resourceGroup().id)}'

// ============================================================
// NETWORK SECURITY GROUP
// ============================================================

resource nsg 'Microsoft.Network/networkSecurityGroups@2025-07-01' = {
  name: nsgName
  location: location

  properties: {
    securityRules: []
  }
}

// ============================================================
// HTTPS SECURITY RULE
// Allows inbound HTTPS traffic on TCP port 443.
// ============================================================

resource httpsRule 'Microsoft.Network/networkSecurityGroups/securityRules@2025-07-01' = {
  parent: nsg
  name: 'Allow-HTTPS-Inbound'

  properties: {
    priority: 100
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'

    sourcePortRange: '*'
    destinationPortRange: '443'

    sourceAddressPrefix: 'Internet'
    destinationAddressPrefix: '*'
  }
}

// ============================================================
// VIRTUAL NETWORK
// ============================================================

resource vnet 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: vnetName
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }

    // Preserve the existing VNet configuration.
    privateEndpointVNetPolicies: 'Disabled'
  }
}

// ============================================================
// APPLICATION SUBNET
// ============================================================

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = {
  parent: vnet
  name: subnetName

  properties: {
    addressPrefix: '10.0.1.0/24'

    // Preserve the existing subnet configuration.
    defaultOutboundAccess: false
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'

    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// ============================================================
// NETWORK INTERFACE
// ============================================================

resource nic 'Microsoft.Network/networkInterfaces@2025-07-01' = {
  name: nicName
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'

        properties: {
          privateIPAllocationMethod: 'Dynamic'

          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
}

// ============================================================
// WINDOWS SERVER VIRTUAL MACHINE
// ============================================================

resource vm 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: vmName
  location: location

  properties: {

    // --------------------------------------------------------
    // CPU / RAM configuration
    // --------------------------------------------------------

    hardwareProfile: {
      vmSize: vmSize
    }

    // --------------------------------------------------------
    // Windows Server image and OS disk
    // --------------------------------------------------------

    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }

      osDisk: {
        createOption: 'FromImage'

        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }

    // --------------------------------------------------------
    // Windows administrator configuration
    // --------------------------------------------------------

    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }

    // --------------------------------------------------------
    // Connect VM to the NIC
    // --------------------------------------------------------

    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id

          properties: {
            primary: true
          }
        }
      ]
    }
  }
}

// ============================================================
// AZURE STORAGE ACCOUNT
// ============================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: storageAccountName
  location: location

  sku: {
    name: 'Standard_LRS'
  }

  kind: 'StorageV2'

  properties: {

    // Require encrypted HTTPS communication.
    supportsHttpsTrafficOnly: true

    // Minimum supported TLS version.
    minimumTlsVersion: 'TLS1_2'

    // Prevent anonymous public Blob access.
    allowBlobPublicAccess: false

    // Default storage tier for frequently accessed data.
    accessTier: 'Hot'
  }
}

// ============================================================
// BLOB STORAGE SERVICE
// ============================================================

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2025-06-01' = {
  parent: storageAccount
  name: 'default'
}

// ============================================================
// PRIVATE BLOB CONTAINER
// ============================================================

resource documentsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01' = {
  parent: blobService
  name: 'documents'

  properties: {
    publicAccess: 'None'
  }
}

// ============================================================
// OUTPUTS
// ============================================================

output virtualNetworkName string = vnet.name
output subnetName string = subnet.name
output networkSecurityGroupName string = nsg.name
output networkInterfaceName string = nic.name
output virtualMachineName string = vm.name

output storageAccountName string = storageAccount.name
output blobContainerName string = documentsContainer.name

// KEY VAULT Private Endpoint module

// import user-defined types from types.bicep
import { AccessPolicies } from '../types.bicep'

@description('Access policies to be created on the key vault.')
param accessPolicies AccessPolicies

@allowed([
  false
  true
])
@description('If true, enables purge protection for the key vault.')
param enablePurgeProtection bool

@description('Optional. Azure region where the resource needs to be deployed. Defaults to location of the resource group where the key vault will be deployed.')
param location string = resourceGroup().location

@description('Name suffix of the key vault. \'kv-\' gets added as the prefix..')
param nameSuffix string

@allowed([
  'new'
  'existing'
])
@description('If \'new\', a new Key Vault resource will be created. If \'existing\', an existing Key Vault resource will be retrieved.')
param newOrExisting string

@description('Resource Id of the private DNS zone named \'privatelink.vaultcore.azure.net\'.')
param privateDnsZoneResourceId string

@allowed([
  'standard'
  'premium'
])
@description('Key vault SKU.')
param sku string

@minValue(7)
@maxValue(90)
@description('Optional. Soft delete retention in days. Defaults to 7 days.')
param softDeleteRetentionInDays int = 7

@description('Optional. Subnet where the privta endpoint of the key vault will be deployed.')
param subnetName string = ''

@description('Optional. Tags to be applied to the key vault resource.')
param tags object = {}

@description('Optional. Name of the VNET where the private endpoint resides.')
param virtualNetworkName string = ''

@description('Optional. RG where the VNET used by the private endpoint is deployed.')
param virtualNetworkRGName string = ''

var name = toLower('kv-${nameSuffix}')

resource existing_kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = if (newOrExisting == 'existing') {
  name: name
}

// create key vault resource
resource new_kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' = if (newOrExisting == 'new') {
  name: name
  location: location
  tags: tags
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    enablePurgeProtection: enablePurgeProtection ? true : null
    enableRbacAuthorization: false
    tenantId: subscription().tenantId
    accessPolicies: [
      for each in accessPolicies: {
        tenantId: subscription().tenantId
        objectId: each.?objectId!
        permissions: {
          certificates: each.?permissions.?certificates
          keys: each.?permissions.?keys
          secrets: each.?permissions.?secrets
        }
      }
    ]
    softDeleteRetentionInDays: softDeleteRetentionInDays
    sku: {
      name: sku
      family: 'A'
    }
  }
}

// create private endpoint
module pe '../PrivateEndpoint/module.bicep' = if (!empty(virtualNetworkName) && !empty(subnetName)) {
  name: 'DeployPrivateEndpoint'
  params: {
    location: location
    groupId: 'vault'
    nameSuffix: newOrExisting == 'existing' ? existing_kv.name : new_kv.name
    privateLinkServiceId: newOrExisting == 'existing' ? existing_kv.id : new_kv.id
    subnetName: subnetName
    tags: tags
    privateDnsZoneId: privateDnsZoneResourceId
    vnetName: virtualNetworkName
    vnetRGName: virtualNetworkRGName
  }
}

//outputs
@description('Resource Id of the key vault deployed by private endpoint.')
output id string = newOrExisting == 'existing' ? existing_kv.id : new_kv.id

@description('Name of the key vault where the private endpoint deployed by the module.')
output name string = newOrExisting == 'existing' ? existing_kv.name : new_kv.name

@description('IP address of the key vault private endpoint.')
output ipAddress string = !empty(virtualNetworkName) && !empty(virtualNetworkRGName) ? pe.outputs.ipAddress : ''

// assertions
assert privateEndpointName = !contains(nameSuffix, 'kv') || !contains(nameSuffix, 'KV')

targetScope = 'resourceGroup'

param accessPolicies array

@allowed([
  false
  true
])
param enablePurgeProtection bool

param location string = resourceGroup().location

param namePrefix string

param privateDnsZoneId string

@allowed([
  'standard'
  'premium'
])
param sku string

@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 7

param subnetName string

param tags object

param vnetName string

param vnetRGName string = ''

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${namePrefix}-kv'
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
    accessPolicies: [for each in accessPolicies: {
      tenantId: subscription().tenantId
      objectId: each.objectId
      permissions: {
        keys: contains(each, 'keys') ? each.keys : []
        secrets: contains(each, 'secrets') ? each.secrets : []
        certificates: contains(each, 'certificates') ? each.certificates : []
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

module kvPe '../PrivateEndpoint/pe.bicep' = {
  name: 'DeployKVPrivateEndpoint'
  params: {
    location: location
    groupId: 'vault'
    namePrefix: keyVault.name
    privateDnsZoneId: privateDnsZoneId
    privateLinkServiceId: keyVault.id
    retrieveSecondaryPrivateIpAddress: false
    subnetName: subnetName
    tags: tags
    vnetName: vnetName
    vnetRGName: vnetRGName
  }
}

output id string = keyVault.id

output name string = keyVault.name

output ipAddress string = kvPe.outputs.ipAddress

output secondaryPrivateIpAddress string = kvPe.outputs.secondaryIpAddress

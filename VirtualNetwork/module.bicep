targetScope = 'resourceGroup'

import * as mahi from '../types.bicep'

@description('Address space of the VNET.')
param cidr string

@description('Optional. Resource Id of the log analytics workspace used to store diagnostic settings of the vnet.')
param diagnosticSettingsWorkspaceId string = ''

@allowed([
  false
  true
])
@description('If true, configures \'CanNotDelete\' lock on the VNET so that its protected against the accidental deletion.')
param enableLocking bool = false

@description('Optional. Azure region where the VNET will be created. Defaults to location of resource group.')
param location string = resourceGroup().location

@description('Name Prefix of the VNET to be created. \'-vnet\' will be as the suffix.')
param namePrefix string

@description('Optional. Subnets to be created.')
param subnets mahi.subnetArray = []

@description('Optional. Tags to be applied to the resource.')
param tags mahi.tagsObject?

// create vnet
resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: '${namePrefix}-vnet'
  location: location
  tags: tags ?? null
  properties: {
    addressSpace: {
      addressPrefixes: [
        cidr
      ]
    }
    subnets: [for each in subnets ?? []: {
      name: each.?name
      properties: {
        addressPrefix: each.?addressPrefix
        delegations: each.?delegations
        natGateway: each.?natGateway
        networkSecurityGroup: each.?nsg
        routeTable: each.?routeTable
        privateEndpointNetworkPolicies: each.?privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: each.?privateLinkServiceNetworkPolicies
        serviceEndpoints: each.?serviceEndpoints
      }
    }]
  }
}

// config diagnostic settings
resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticSettingsWorkspaceId)) {
  name: 'DiagnosticSettings'
  scope: vnet
  properties: {
    workspaceId: diagnosticSettingsWorkspaceId
    logs: [
      {
        enabled: true
        categoryGroup: 'allLogs'
      }
    ]
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
  }
}

// create delete lock
resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (enableLocking) {
  name: 'DeleteProtect'
  scope: vnet
  properties: {
    level: 'CanNotDelete'
    notes: 'Cannot Delete VNET while the lock is assigned.'
  }
}

//outputs
@description('Resource Id of the virtual network deployed by the module.')
output id string = vnet.id

@description('Name of the VNET deployed.')
output name string = vnet.name

@description('RG where the vnet is deployed.')
output rg string = resourceGroup().name

@description('Resource ID of the subnets deployed by the module.')
output subnets array = [for (each, i) in subnets ?? []: {
  id: vnet.properties.subnets[i].id
}]

// asserts
assert vnetName = !contains(namePrefix, '-Vnet') || !contains(namePrefix, '-VNET') || !contains(namePrefix, '-vnet')

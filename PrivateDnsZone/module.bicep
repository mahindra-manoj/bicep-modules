// Private Dns Zone bicep module

import { Tags, VirtualNetworks } from '../types.bicep'

@allowed([
  'privatelink.azconfig.io'
  'privatelink.azurewebsites.net'
  'privatelink.blob.core.windows.net'
  'privatelink.cosmos.azure.com'
  'privatelink.database.windows.net'
  'privatelink.file.core.windows.net'
  'privatelink.queue.core.windows.net'
  'privatelink.table.core.windows.net'
  'privatelink.servicebus.windows.net'
  'privatelink.vaultcore.azure.net'
  'privatelink.redis.cache.windows.net'
  'privatelink.search.windows.net'
  'privatelink.datfactory.azure.net'
  'privatelink.eventgrid.azure.net'
  'privatelink.eventhub.azure.net'
])
@description('Name of the Private DNS Zone to be created.')
param name string

@description('Optional. Tags to be applied to the Private DNS Zone resource,')
param tags Tags = {}

@description('List of virtual Networks to be linked with the Private DNS Zone.')
param virtualNetworks array

// get vnet resource
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = [for each in virtualNetworks: {
  name: each.name
  scope: contains(each, 'resourceGroup') ? resourceGroup(each.resourceGroup) : resourceGroup()
}]

// create Private Dns Zone resource
resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {}
  resource vnetLink 'virtualNetworkLinks' = [for (each, i) in virtualNetworks: {
    name: 'link-${each.name}'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnet[i].id
      }
    }
  }]
}

//outputs
@description('Resource Id of the Private DNS zone created by the module.')
output id string = dnsZone.id

@description('Name of the private DNS zone created.')
output name string = dnsZone.name

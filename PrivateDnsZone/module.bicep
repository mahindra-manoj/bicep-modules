// Private Dns Zone bicep module
metadata name = 'Private DNS Zone bicep module.'

metadata description = 'This module helps create a Private DNS zone resource and links the virtual networks with the resource to successfully resolve the private endpoints for the specific resource type.'

import { PrivateDNSZone,VirtualNetwork } from '../utilities.bicep'

@description('Name of the Private DNS Zone to be created.')
param name PrivateDNSZone

@description('Optional. Tags to be applied to the Private DNS Zone resource,')
param tags object = {}

@description('List of virtual Networks to be linked with the Private DNS Zone.')
param virtualNetworks VirtualNetwork[]

var vnet = [
  for each in virtualNetworks: resourceId(
    each.?subscriptionId ?? subscription().subscriptionId,
    each.?resourceGroup ?? resourceGroup().name,
    'Microsoft.Network/virtualNetworks',
    each.name
  )
]

// create Private Dns Zone resource
resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {}
  resource vnetLink 'virtualNetworkLinks' = [
    for (each, i) in virtualNetworks: {
      name: 'link-${each.name}'
      location: 'global'
      properties: {
        registrationEnabled: false
        virtualNetwork: {
          id: vnet[i]
        }
      }
    }
  ]
}

//outputs
@description('Resource Id of the Private DNS zone created by the module.')
output id string = dnsZone.id

@description('Name of the private DNS zone created.')
output name string = dnsZone.name

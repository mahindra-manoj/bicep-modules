targetScope = 'resourceGroup'

param name string

param tags object

param virtualNetworks array

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = [for (each, i) in virtualNetworks: {
  name: each.name
  scope: contains(each, 'resourceGroup') ? resourceGroup(each.resourceGroup) : resourceGroup()
}]

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {}
  resource vnetLink 'virtualNetworkLinks' = [for (each, i) in virtualNetworks: {
    name: '${each.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnet[i].id
      }
    }
  }]
}

output id string = dnsZone.id

output name string = dnsZone.name

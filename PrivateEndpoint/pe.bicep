targetScope = 'resourceGroup'

param dnsZoneGroupConfigName string = newGuid() //uniqueString(resourceGroup().id, '${namePrefix}-pe', privateLinkServiceId, privateDnsZoneId)

param groupId string

param location string = resourceGroup().location

param namePrefix string

param privateDnsZoneId string

param privateLinkServiceId string

@description('Optional. Whether to retrieve the secondary private IP address of the private endpoint. Some of the Azure services liek Cosmos DB have 2 IPs assigned when private endpoint is configured. Defaults to false.')
param retrieveSecondaryPrivateIpAddress bool = false

param subnetName string

param tags object

param vnetName string

param vnetRGName string

resource epSnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: '${vnetName}/${subnetName}'
  scope: empty(vnetRGName) ? resourceGroup() : resourceGroup(vnetRGName)
}

resource pe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${namePrefix}-pe'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: '${namePrefix}-pe-nic'
    privateLinkServiceConnections: [
      {
        name: '${namePrefix}-pe'
        properties: {
          groupIds: [
            groupId
          ]
          privateLinkServiceId: privateLinkServiceId
        }
      }
    ]
    subnet: {
      id: epSnet.id
    }
  }
  resource peDnsZone 'privateDnsZoneGroups' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: dnsZoneGroupConfigName
          properties: {
            privateDnsZoneId: privateDnsZoneId
          }
        }
      ]
    }
  }
}

output id string = pe.id

output name string = pe.name

output ipAddress string = pe.properties.customDnsConfigs[0].ipAddresses[0]

output secondaryIpAddress string = retrieveSecondaryPrivateIpAddress ? pe.properties.customDnsConfigs[1].ipAddresses[0] : ''

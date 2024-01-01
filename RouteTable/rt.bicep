// route table bicep module
import * as mahi from '../types.bicep'

targetScope = 'resourceGroup'

param routeTableConfig mahi.routeTable

param tags mahi.tagsObject


resource rt 'Microsoft.Network/routeTables@2023-05-01' = {
  name: routeTableConfig.name
  location: routeTableConfig.location
  tags: tags
  properties: {
    disableBgpRoutePropagation: routeTableConfig.disableRoutePropogation
    routes: [for each in (routeTableConfig.routes ?? []): {
      name: each.name
      properties: {
        nextHopType: each.nextHopType
        addressPrefix: each.addressPrefix
        nextHopIpAddress: each.?nextHopIpAddress
      }
    }]
  }
}

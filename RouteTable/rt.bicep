// route table bicep module
import { routes as array, tagsObject as object } from '../types.bicep'

@description('Optional. Whether to disable the routes learned by BGP on that route table. True means disable. Value defaults to false.')
param disableBgpRoutePropagation bool = false

@description('Azure region where the route table needs to be created.')
param location string = resourceGroup().location

@description('Name of the route table resource to be created.')
param nameSuffix string

@description('Routes to be added.')
param routes array

@description('Optional. Tags to be applied.')
param tags object = {}

// create route table
resource rt 'Microsoft.Network/routeTables@2023-05-01' = {
  name: toLower('rt-${nameSuffix}')
  location: location
  tags: tags ?? null
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: [for each in (routes ?? []): {
      name: each.?name
      properties: {
        nextHopType: each.?nextHopType
        addressPrefix: each.?addressPrefix
        nextHopIpAddress: each.?nextHopIpAddress
      }
    }]
  }
}

//outputs

@description('Resource Id of the route table created by the module.')
output id string = rt.id

@description('Name of the route table deployed.')
output name string = rt.name

// assertions
assert routeTableName = !contains(nameSuffix, 'rt') || !contains(nameSuffix, 'RT')

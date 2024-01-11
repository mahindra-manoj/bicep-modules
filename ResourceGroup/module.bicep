// Resource Group Bicep module
targetScope = 'subscription'

// import custom data type from types.biceps
import { tagsObject as object } from '../types.bicep'

@description('Name prefix of the RG to be created. \'rg-\' gets added as suffix.')
param nameSuffix string

@description('Azure region where the RG will need to be created.')
param location string

@description('Optional. Tags to be applied.')
param tags object = {}

// create RG
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: toLower('rg-${nameSuffix}')
  location: location
  tags: tags
  properties: {}
}

// outputs
@description('Resource Id of the rg created by the bicep module.')
output id string = rg.id

@description('Name of the RG created.')
output name string = rg.name

// assertions
assert privateEndpointName = !contains(nameSuffix, 'rg') || !contains(nameSuffix, 'RG')

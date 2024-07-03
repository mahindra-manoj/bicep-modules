// bicep module to create an Azure Container App Environmnet
targetScope = 'resourceGroup'

@description('Name prefix of the Container App Environment. \'-cae\' gets added as the suffix')
param namePrefix string

//create container app environment
resource env 'Microsoft.App/managedEnvironments@2023-11-02-preview' = {
  name: toLower('${namePrefix}-cae')
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'containerapps'
  properties: {
    appInsightsConfiguration: {
      connectionString: ''
    }
    vnetConfiguration: {
      
    }
  }
}

targetScope = 'resourceGroup'

param location string = resourceGroup().location

param namePrefix string

param privateDnsZoneId string

param retrieveSecondaryPrivateIpAddress bool = true

param subnetName string

param tags object

param vnetName string

param vnetRGName string

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-11-15' = {
  name: '${namePrefix}-cosdb'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 1440
        backupRetentionIntervalInHours: 48
        backupStorageRedundancy: 'Local'
      }
    }
    consistencyPolicy: {
      defaultConsistencyLevel: 'Eventual'
      maxStalenessPrefix: 1
      maxIntervalInSeconds: 5
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    capacity: {
      totalThroughputLimit: -1
    }
    cors: []
    disableKeyBasedMetadataWriteAccess: true
    disableLocalAuth: true
    enableAnalyticalStorage: false
    enableFreeTier: false
    enableMultipleWriteLocations: false
    minimalTlsVersion: 'Tls12'
    networkAclBypass: 'AzureServices'
    publicNetworkAccess: 'Disabled'
  }
}

module cosPe '../PrivateEndpoint/pe.bicep' = {
  name: 'DeployCosDBPrivateEndpoint'
  params: {
    groupId: 'sql'
    location: location
    namePrefix: '${cosmosDbAccount.name}-pe'
    privateDnsZoneId: privateDnsZoneId
    privateLinkServiceId: cosmosDbAccount.id
    retrieveSecondaryPrivateIpAddress: retrieveSecondaryPrivateIpAddress
    subnetName: subnetName
    tags: tags
    vnetName: vnetName
    vnetRGName: vnetRGName
  }
}

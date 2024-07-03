// Bicep module to deploy APIM service
targetScope = 'resourceGroup'

@description('')
param capacity int = 1

@description('Azure region where the resource will be deployed. Defaults to location of rg where the APIM will be deployed.')
param location string = resourceGroup().location

@description('Name suffix of the APIM resource. \'apim-\' will be added as prefix.')
param nameSuffix string

@description('Publisher email.')
param publisherEmail string

@description('Name of the publisher.')
param publisherName string

@allowed([
  'Developer'
  'Premium'
])
@description('SKU name.')
param sku string

@allowed([
  'External'
  'Internal'
])
@description('The type of VPN in which API Management service needs to be configured in')
param vnetType string

@description('')
param identityType string

//create APIM resource
resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: 'apim-${nameSuffix}'
  location: location
  sku: {
    capacity: sku == 'Developer' ? 0 : capacity
    name: sku
  }
  properties: {
    virtualNetworkType: vnetType
    publisherEmail: publisherEmail
    publisherName: publisherName
    additionalLocations: [
      {
        location:
        sku: {
          capacity:
          name:
        }
        disableGateway:
        natGatewayState:
        publicIpAddressId:
        virtualNetworkConfiguration: {
          subnetResourceId:
        }
        zones: [

        ]
      }
    ]
    disableGateway:
    natGatewayState:
    publicIpAddressId:
    virtualNetworkConfiguration: {
      subnetResourceId:
    }
    apiVersionConstraint: {
      minApiVersion:
    }
    hostnameConfigurations: [
      {
        hostName:
        type:
        certificateSource: 'KeyVault'
        defaultSslBinding: false
        identityClientId:
        keyVaultId:
        negotiateClientCertificate:
      }
    ]
    notificationSenderEmail:
    publicNetworkAccess: 'Disabled'
  }
}

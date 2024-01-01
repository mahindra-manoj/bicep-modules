module vnet 'br:mahis.azurecr.io/network/vnet:1.0' = {
  name: 'DeployNewVnetModule'
  params: {
    cidr: '10.0.0.0/16'
    namePrefix: 'Mahis' //-VNET gets added by the module.
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: '10.0.0.0/24'
        serviceEndpoints: [
          {
            locations: [
              'CanadaCentral'
              'CanadaEast'
            ]
            service: 'Microsoft.Web'
          }
          {
            locations: [
              'CanadaCentral'
              'CanadaEast'
            ]
            service: 'Microsoft.Storage'
          }
        ]
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'AppTier-Subnet'
        addressPrefix: '10.0.1.0/24'
        serviceEndpoints: [
          {
            locations: [
              'CanadaCentral'
              'CanadaEast'
            ]
            service: 'Microsoft.Storage'
          }
          {
            locations: [
              'CanadaCentral'
              'CanadaEast'
            ]
            service: 'Microsoft.KeyVault'
          }
          {
            locations: [
              'CanadaCentral'
              'CanadaEast'
            ]
            service: 'Microsoft.Web'
          }
        ]
      }
    ]
  }
}

output firewallSubnetId string = vnet.outputs.subnets[0].id
output subnet1Id string = vnet.outputs.subnets[1].id

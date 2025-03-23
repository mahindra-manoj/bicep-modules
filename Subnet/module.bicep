// import custom data type for subnets
import { Subnets } from '../types.bicep'

@description('Subnets to be created. Use ctrl + space to know the available properties offered by the custom data type.')
param subnets Subnets

@description('Name of the VNET where the subnet(s) need to be created.')
param virtualNetworkName resourceInput<'Microsoft.Network/virtualNetworks@2024-05-01'>.name

// creaet subnet(s)
resource snet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [
  for each in subnets: {
    name: '${virtualNetworkName}/${each.name}'
    properties: {
      addressPrefix: each.addressPrefix
      delegations: each.?delegations
      natGateway: each.?natGateway
      networkSecurityGroup: each.?nsg
      defaultOutboundAccess: true
      privateEndpointNetworkPolicies: each.?privateEndpointNetworkPolicies
      privateLinkServiceNetworkPolicies: each.?privateLinkServiceNetworkPolicies
      routeTable: each.?routeTable
      serviceEndpoints: each.?serviceEndpoints
    }
  }
]

// outputs
@description('List of resource Ids of the subnets that were created.')
output id sys.array = [
  for (each, i) in subnets: {
    value: snet[i].id
  }
]

@description('List of names of the subnets that were created.')
output name sys.array = [
  for (each, i) in subnets: {
    value: snet[i].name
  }
]

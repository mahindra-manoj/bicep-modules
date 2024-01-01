param cidr string

param name string

param vnetName string

resource snet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: '${vnetName}/${name}'
  properties: {
    addressPrefix: cidr
  }
}

output name string = name

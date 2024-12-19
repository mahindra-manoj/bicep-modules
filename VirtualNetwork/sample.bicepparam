using './module.bicep'

param cidr = '10.0.0.0/24'
param nameSuffix = 'mahi-hub'
param subnets = [
  {
    name: 'AzureFirewallManagementSubnet'
    addressPrefix: '10.0.0.64/26'
  }
  {
    name: 'AzureFirewallSubnet'
    addressPrefix: '10.0.0.0/26'
  }
]

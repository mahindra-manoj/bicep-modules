@export()
type tagsObject = {
  @description('Environment being deployed.')
  Env: ('Dev' | 'QA' | 'CAT' | 'PROD')

  @description('App Name.')
  App: string

  @description('Optional. Cost Center of the environmnet.')
  CostCenter: string?
}

@export()
type routeTable = {
  @description('NamePrefix of the Route table')
  name: string

  @description('Azure region where the resource will be deployed.')
  location: ('CanadaCentral' | 'CanadaEast')

  @description('If true, disables route propogation for the route table.')
  disableRoutePropogation: (false | true)

  @description('Routes to be added to the table.')
  routes: {
    @description('Name of the route.')
    name: string

    @description('Next Hop Type of the route.')
    nexHopType: ('Internet' | 'None' | 'VirtualAppliance' | 'VnetLocal' | 'VirtualNetworkGateway')

    @description('Destination address prefix of the route table.')
    addressPrefix: string

    @description(
      'If the nextHopType is \'VirtualAppliance\', add the firewall IP address as the next hop IP address.'
    )
    nextHopIpAddress: string?
  }[]?
}

@export()
@discriminator('ruleCollectionType')
type FirewallPolicyRuleCollection = filterRuleCollection | natRuleCollection

type filterRuleCollection = {
  @description('Rule collection type.')
  ruleCollectionType: 'FirewallPolicyFilterRuleCollection'

  @description('he action type of a Filter rule collection.')
  action: {
    @description('Tyoe of the action.')
    type: ('Allow' | 'Deny')
  }

  @description('Name of the Rule Collection Group.')
  name: string

  @minValue(100)
  @maxValue(65000)
  priority: int

  @description('List of rules included in a rule collection.')
  rules: FirewallPolicyRule[]
}

type natRuleCollection = {
  @description('Rule collection type.')
  ruleCollectionType: 'FirewallPolicyNatRuleCollection'

  @description('he action type of a Filter rule collection.')
  action: {
    @description('Tyoe of the action.')
    type: 'DNAT'
  }

  @description('Name of the Rule Collection Group.')
  name: string

  @minValue(100)
  @maxValue(65000)
  priority: int

  @description('List of rules included in a rule collection.')
  rules: natRuleType[]
}

@discriminator('ruleType')
type FirewallPolicyRule = networkRule | applicationRule

type networkRule = {
  ruleType: 'NetworkRule'
  description: string?
  destinationAddresses: array
  destinationFqdns: array?
  destinationIpGroups: array?
  destinationPorts: array
  ipProtocols: ('Any' | 'ICMP' | 'TCP' | 'UDP')[]
  name: string
  sourceAddresses: array
  sourceIpGroups: array?
}

type applicationRule = {
  ruleType: 'ApplicationRule'
  description: string?
  destinationAddresses: array
  fqdnTags: array
  httpHeadersToInsert: {
    headerName: string
    headerValue: string
  }[]
  name: string
  protocols: {
    @minValue(0)
    @maxValue(64000)
    port: int
    protocolType: ('Http' | 'Https')
  }
  targetFqdns: array
  targetUrls: array
  terminateTLS: (false | true)
  webCategories: array
  sourceAddresses: array
  sourceIpGroups: array?
}

type natRuleType = {
  ruleType: 'NatRule'
  description: string?
  destinationAddresses: array
  destinationPorts: array
  ipProtocols: ('Any' | 'ICMP' | 'TCP' | 'UDP')[]
  name: string
  sourceAddresses: array
  sourceIpGroups: array?
  translatedAddress: string
  translatedFqdn: string?
  translatedPort: string
}

// custom data type for creating subnets
@export()
type subnetArray = {
  @description('Name of the subnet to be created.')
  name: string?
  @description('Address Prefix of the subnet.')
  addressPrefix: string?
  @description('Optional. The name of the service to whom the subnet should be delegated (e.g. Microsoft.Sql/servers).')
  delegations: {
    @description('Name of the delegation. For example, \'AppServicePlan\'.')
    name: string
    @description('Service that needs to be delegated for the subnet. For example, \'Microsoft.Web/serverFarms\'')
    service: string
  }[]?
  @description('Optional. Reference to the NAT gateway resource that will need to be associated with the subnet.')
  natGateway: {
    @description('Resource ID of the NAT Gateway.')
    id: string
  }?
  @description('Optional. Reference to the NSG resource that will need to be associated with the subnet.')
  nsg: {
    @description('Resource Id of the NSG.')
    id: string
  }?
  @description('Optional. Enable or Disable apply network policies on private end point in the subnet.')
  privateEndpointNetworkPolicies: ('Enabled' | 'Disabled')?
  @description('Optional. Enable or Disable apply network policies on private link service in the subnet.')
  privateLinkServiceNetworkPolicies: ('Enabled' | 'Disabled')?
  @description('Optional. Reference to the route table resource that will be associated with the subnet.')
  routeTable: {
    @description('Resource id of the route table.')
    id: string
  }?
  @description('Optional. Array of service endpoints.')
  serviceEndpoints: {
    @description('List of locations.')
    locations: ('CanadaCentral' | 'CanadaEast' | '*')[]
    @description('Service Endpoint Type.')
    service: string
  }[]?
}[]

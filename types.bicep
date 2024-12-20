@export()
@description('User-defined data type used by Tags parameter.')
type Tags = {
  @description('Environment being deployed.')
  Environment: ('Dev' | 'QA' | 'UAT' | 'Prod')?

  @description('Optional. Application name.')
  'Application Name': string?

  @description('Optional. Cost Center.')
  'Cost Center': string?
}

@export()
@description('User-defined data type used by routes parameter within Route Table parameter.')
type Routes = {
  @description('Name of the route.')
  name: string

  @description('Next Hop Type of the route.')
  nexHopType: ('Internet' | 'None' | 'VirtualAppliance' | 'VnetLocal' | 'VirtualNetworkGateway')

  @description('Destination address prefix of the route table.')
  addressPrefix: string

  @description('If the nextHopType is \'VirtualAppliance\', add the firewall IP address as the next hop IP address.')
  nextHopIpAddress: string?
}[]?

@export()
@discriminator('ruleCollectionType')
type FirewallPolicyRuleCollection = FilterRuleCollection | NatRuleCollection

type FilterRuleCollection = {
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

type NatRuleCollection = {
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
  rules: NatRuleType[]
}

@discriminator('ruleType')
type FirewallPolicyRule = NetworkRule | ApplicationRule

type NetworkRule = {
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

type ApplicationRule = {
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

type NatRuleType = {
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
type Subnets = {
  @description('Name of the subnet to be created.')
  name: string
  @description('Address Prefix of the subnet.')
  addressPrefix: string
  @description('Optional. If false, default outbound connectivity for all VMs in the subnet will be disabled.')
  defaultOutboundAccess: (false | true)?
  @description('Optional. The name of the service to whom the subnet should be delegated (e.g. Microsoft.Sql/servers).')
  delegation: {
    @description('Name of the delegation. For example, \'AppServicePlan\'.')
    name: string
    @description('Service that needs to be delegated for the subnet. For example, \'Microsoft.Web/serverFarms\'')
    service: string
  }?
  @description('Optional. Reference to the NAT gateway resource that will need to be associated with the subnet.')
  natGateway: {
    @description('Resource ID of the NAT Gateway.')
    id: string
  }?
  @description('Optional. Name of the existing NSG resource that will need to be associated with the subnet.')
  nsgName: string?
  @description('Optional. RG where the NSG resource resides. This is only needed if the NSG resource is deployed in a rg different than the one where the VNET module is being deployed.')
  nsgResourceGroupName: string?
  @description('Optional. Applu network policies for the private endpoints in the subnet.')
  privateEndpointNetworkPolicies: ('Enabled' | 'Disabled' | 'NetworkSecurityGroupEnabled' | 'RouteTableEnabled')?
  @description('Optional. Apply network policies on private link services in the subnet.')
  privateLinkServiceNetworkPolicies: ('Enabled' | 'Disabled')?
  @description('Optional. Name of the existing route table resource that will need to be associated with the subnet.')
  routeTableName: string?
  @description('Optional. RG where the route table resource resides. This is only needed if the route table needs to be associated with the subnet and it resides in a rg different than the one where the VNET resource is being deployed.')
  routeTableRGName: string?
  @description('Optional. Array of service endpoints.')
  serviceEndpoints: {
    @description('List of locations.')
    locations: ('CanadaCentral' | 'CanadaEast' | '*')[]
    @description('Service Endpoint Type.')
    service: string
  }[]?
}[]

// Custom data type used within key vault.
@export()
@description('User-defined data type used by the param named \'accessPolicies\' within key vault module.')
type AccessPolicies = {
  @description('Optional.The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies.')
  objectId: string?
  @description('Permissions the identity has for keys, secrets and certificates.')
  permissions: {
    @description('Permissions to certificates.')
    certificates: (
      | 'all'
      | 'backup'
      | 'create'
      | 'delete'
      | 'deleteissuers'
      | 'get'
      | 'getissuers'
      | 'import'
      | 'list'
      | 'listissuers'
      | 'managecontacts'
      | 'manageissuers'
      | 'purge'
      | 'recover'
      | 'restore'
      | 'setissuers'
      | 'update')[]?
    @description('Permissions to Keys.')
    keys: (
      | 'all'
      | 'backup'
      | 'create'
      | 'decrypt'
      | 'delete'
      | 'encrypt'
      | 'get'
      | 'getrotationpolicy'
      | 'import'
      | 'list'
      | 'purge'
      | 'recover'
      | 'release'
      | 'restore'
      | 'rotate'
      | 'setrotationpolicy'
      | 'sign'
      | 'unwrapKey'
      | 'update'
      | 'verify'
      | 'wrapKey')[]?
    @description('Permissions to Secrets.')
    secrets: ('all' | 'backup' | 'delete' | 'get' | 'list' | 'purge' | 'recover' | 'restore' | 'set')[]?
  }?
}[]

// custom data type used by the Private DNS zone module.
@export()
@description('User-defined data type used by the parameter named Private DNS zone bicep module.')
type VirtualNetworks = {
  @description('Name of the Virtual network that needs to be linked with the DNS zone.')
  name: string
  @description('RG where the VNET resides.')
  resourceGroup: string?
}[]

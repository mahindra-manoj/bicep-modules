/////////// Custom data types developed for the Azure Bicep modules. ///////////
/// These help provide intellisenese and type checking for the params that need complex data type within the Bicep modules. ///

@export()
@description('User-defined data type used by routes parameter within Route Table module.')
type RouteTableRoutes = {
  @description('Name of the route.')
  name: string

  @description('Next Hop Type of the route.')
  nexHopType: ('Internet' | 'None' | 'VirtualAppliance' | 'VnetLocal' | 'VirtualNetworkGateway')

  @description('Destination address prefix of the route table.')
  addressPrefix: string

  @description('If the nextHopType is \'VirtualAppliance\', add the firewall IP address as the next hop IP address.')
  nextHopIpAddress: string?
}[]

///////////// Firewall Module Data type ///////////////////////////////
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

/////////////// custom data type for creating subnets ////////////////////////
@export()
@description('Custom data type used by the subnets parameter within the VNET module')
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
  @description('Optional. ID of the subscription where the VNET resides. This is only needed if the VNET is in a subscription different than the one where the DNS zone is being deployed. The value does not expect the resource ID format.')
  subscriptionId: resourceInput<'Microsoft.Subscription/subscriptionDefinitions@2017-11-01-preview'>.properties.subscriptionId?
}[]

/////// Custom data type used by the param Security rules within the NSG module.
@export()
type NetworkSecurityGroupRules = {
  @description('Name of the security rule to be created.')
  name: string
  @description('Whether the traffic is allowed or denied.')
  access: ('Allow' | 'Deny')
  @description('he direction of the rule. The direction specifies if rule will be evaluated on incoming or outgoing traffic.')
  direction: ('Inbound' | 'Outbound')
  @description('The priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule.')
  priority: int
  @description('Network protocol this rule applies to.')
  protocol: ('TCP' | 'UDP' | 'ICMP' | '*')
  @description('The CIDR or source IP ranges. Asterisk (*) can also be used to match all IP addresses. Multiple IP ranges can be specified by separating them with a comma. Accepts Service tag as the source address prefix.')
  sourceAddressPrefix: string
  @description('The CIDR or destination IP ranges. Asterisk (*) can also be used to match all IP addresses. Multiple IP ranges can be specified by separating them with a comma. Accepts Service tag as the destination address prefix.')
  destinationAddressPrefix: string
  @description('Destination port or range. Asterisk (*) can also be used to match all ports. Multiple ports or ranges can be specified by separating them with a comma.')
  destinationPortRange: string
  @description('Optional. Description of the rule.')
  description: string?
}[]

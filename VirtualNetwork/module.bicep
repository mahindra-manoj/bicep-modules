targetScope = 'resourceGroup'

import { Subnets, VirtualNetworks } from '../types.bicep'

// asserts
assert vnetName = !startsWith(toLower(nameSuffix), 'vnet-')

@description('Address space of the VNET resource.')
param cidr string

@description('Optional. Ddos Protection Plan details. To associate a ddos protection plan to the virtual network. This is only valid if the enableDddosProtectionPlan is set to true.')
param ddosProtectionPlan {
  @description('Optional. Name of the DDos Protection Plan resource.')
  name: string?

  @description('Optional. Resource Group where the ddos protection plan resource is deployed. Chose this if the rg is different than the one where VNET is being deployed.')
  resourceGroup: string?

  @description('Optioanal. Subscription Guid. This is only needed if the plan is deployed in a subscription different than the one where the VNET is being deployed.')
  subscriptionId: string?
}?

@description('Optional. If true, ddos protection plan needs to be associated. To attach a plan to VNET, ddosProtectionPlan should not be empty.')
param enableDdosProtectionPlan bool = false

@description('Optional. If true, encryption will be enabled. This is only for the traffic betweens the VMs of the selective SKUsnthat are deployed within the VNet. Defaults to false.')
param enableEncryption bool = false

@allowed([
  false
  true
])
@description('Optional. If true, configures \'CanNotDelete\' lock on the VNET so that its protected against the accidental deletion. Defaults to false.')
param enableLocking bool = false

@description('Optional. Azure region where the VNET will be created. Defaults to location of resource group.')
param location string = resourceGroup().location

@description('Optional. Name of the log analytics workspace that is used to store the diagnostic settings of the VNET.')
param logAnalyticsWorkspaceName string = ''

@description('Optional. Name of the Resource group where the log analytics workspace was deployed. Defaults to rg where the VNET will be created.')
param logAnalyticsWorkspaceRGName string = resourceGroup().name

@description('Name suffix of the Virtual Network resource being created. \'vnet-\' will be as the prefix.')
param nameSuffix string

@description('Optional. Name of the NAT gateway resource that needs to be associated with the subnets within the VNET resource being provisioned.')
param natGatewayName string = ''

@description('Optional. RG where the NAT Gateway resource resides. Defaults to rg where the VNET resource is being deployed.')
param natGatewayRGName string = resourceGroup().name

@description('Optional. Subnets to be created. Defaults to [].')
param subnets Subnets = []

@description('Optional. Tags to be applied to the resource.')
param tags object?

// get DDOS protection resource
resource ddosPlan 'Microsoft.Network/ddosProtectionPlans@2023-09-01' existing = if (enableDdosProtectionPlan && !empty(ddosProtectionPlan)) {
  name: ddosProtectionPlan.?name ?? 'dummy'
  scope: resourceGroup(
    ddosProtectionPlan.?subscriptionId ?? subscription().id,
    ddosProtectionPlan.?resourceGroup ?? resourceGroup().name
  )
}

// Get log analytics workspace
resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  name: !empty(logAnalyticsWorkspaceName) ? logAnalyticsWorkspaceName : 'dummy'
  scope: resourceGroup(logAnalyticsWorkspaceRGName)
}

// Get NAT gateway resource
resource nat 'Microsoft.Network/natGateways@2024-01-01' existing = if (!empty(natGatewayName)) {
  name: !empty(natGatewayName) ? natGatewayName : 'dummy'
  scope: resourceGroup(natGatewayRGName)
}

// Get NSG resources
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' existing = [
  for (each, i) in subnets: if (contains(each, 'nsgName')) {
    name: each.?nsgName ?? 'dummy'
    scope: resourceGroup(each.?nsgResourceGroupName ?? resourceGroup().name)
  }
]

// Get Route Tble resource
resource rt 'Microsoft.Network/routeTables@2024-01-01' existing = [
  for (each, i) in subnets: if (contains(each, 'routeTableName')) {
    name: each.?routeTableName ?? 'dummy'
    scope: resourceGroup(each.?routeTableRGName ?? resourceGroup().name)
  }
]

// create vnet
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: toLower('vnet-${nameSuffix}')
  location: location
  tags: tags ?? null
  properties: {
    encryption: {
      enabled: enableEncryption
    }
    addressSpace: {
      addressPrefixes: [
        cidr
      ]
    }
    ddosProtectionPlan: enableDdosProtectionPlan && !empty(ddosProtectionPlan)
      ? {
          id: enableDdosProtectionPlan && !empty(ddosProtectionPlan) ? ddosPlan.id : 'dummy'
        }
      : null
    enableDdosProtection: enableDdosProtectionPlan
    subnets: [
      for (each, i) in subnets ?? []: {
        name: each.?name
        properties: {
          addressPrefix: each.?addressPrefix
          delegations: contains(each, 'delegation')
            ? [
                {
                  name: each.?delegation.name
                  properties: {
                    serviceName: each.?delegation.service
                  }
                }
              ]
            : []
          natGateway: !empty(natGatewayName)
            ? {
                id: nat.id
              }
            : null
          networkSecurityGroup: contains(each, 'nsgName')
            ? {
                id: nsg[i].id
              }
            : null
          routeTable: contains(each, 'routeTableName')
            ? {
                id: rt[i].id
              }
            : null
          privateEndpointNetworkPolicies: each.?privateEndpointNetworkPolicies
          privateLinkServiceNetworkPolicies: each.?privateLinkServiceNetworkPolicies
          serviceEndpoints: each.?serviceEndpoints
          defaultOutboundAccess: each.?defaultOutboundAccess ?? false
        }
      }
    ]
  }
}

// config diagnostic settings
resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceName)) {
  name: 'DiagnosticSettings'
  scope: vnet
  properties: {
    workspaceId: !empty(logAnalyticsWorkspaceName) ? law.id : 'dummy'
    logs: [
      {
        enabled: true
        categoryGroup: 'allLogs'
      }
    ]
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
  }
}

// create delete lock
resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (enableLocking) {
  name: 'DeleteProtect'
  scope: vnet
  properties: {
    level: 'CanNotDelete'
    notes: 'Cannot Delete VNET while the lock is assigned.'
  }
}

//outputs
@description('Resource Id of the virtual network deployed by the module.')
output id string = vnet.id

@description('Name of the VNET deployed.')
output name string = vnet.name

@description('RG where the vnet is deployed.')
output rg string = resourceGroup().name

@description('Resource ID of the subnets deployed by the module.')
output subnets array = [
  for (each, i) in subnets ?? []: {
    id: vnet.properties.subnets[i].id
    name: vnet.properties.subnets[i].name
  }
]

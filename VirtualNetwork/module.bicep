targetScope = 'resourceGroup'

import { tagsObject, subnetArray, virtualNetworks } from '../types.bicep'

// asserts
assert vnetName = !contains(toLower(namePrefix), '-vnet')

@description('Address space of the VNET.')
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

@description('Optional. Resource Id of the log analytics workspace used to store diagnostic settings of the vnet.')
param diagnosticSettingsWorkspaceId string = ''

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

@description('Name Prefix of the VNET to be created. \'-vnet\' will be as the suffix.')
param namePrefix string

@description('Optional. Subnets to be created. Defaults to [].')
param subnets subnetArray = []

@description('Optional. Tags to be applied to the resource.')
param tags tagsObject?

resource ddosPlan 'Microsoft.Network/ddosProtectionPlans@2023-09-01' existing = if (enableDdosProtectionPlan && !empty(ddosProtectionPlan)) {
  name: ddosProtectionPlan.?name
  scope: resourceGroup(ddosProtectionPlan.?subscriptionId, ddosProtectionPlan.?resourceGroup)
}

// create vnet
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: '${namePrefix}-vnet'
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
    ddosProtectionPlan: {
      id: enableDdosProtectionPlan && !empty(ddosProtectionPlan) ? ddosPlan.id : null
    }
    enableDdosProtection: enableDdosProtectionPlan
    subnets: [for each in subnets ?? []: {
      name: each.?name
      properties: {
        addressPrefix: each.?addressPrefix
        delegations: each.?delegations
        natGateway: each.?natGateway
        networkSecurityGroup: each.?nsg
        routeTable: each.?routeTable
        privateEndpointNetworkPolicies: each.?privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: each.?privateLinkServiceNetworkPolicies
        serviceEndpoints: each.?serviceEndpoints
        defaultOutboundAccess: each.defaultOutboundAccess
        serviceEndpointPolicies: [
          {
            properties: {
              contextualServiceEndpointPolicies: [

              ]
              serviceAlias: ''
              serviceEndpointPolicyDefinitions: [
                {
                  name: ''
                  properties: {
                    service: ''
                  }
                }
              ]
            }
          }
        ]
      }
    }]
  }
}

// config diagnostic settings
resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticSettingsWorkspaceId)) {
  name: 'DiagnosticSettings'
  scope: vnet
  properties: {
    workspaceId: diagnosticSettingsWorkspaceId
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
output subnets array = [for (each, i) in subnets ?? []: {
  id: vnet.properties.subnets[i].id
}]

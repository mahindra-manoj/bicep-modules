targetScope = 'resourceGroup'
import * as mahi from '../types.bicep'

@description('Name of the firewall policy where the rule collection group needs to be created.')
param firewallPolicyName string

@description('Name of the rule collection group to be created.')
param name string

@minValue(100)
@maxValue(65000)
@description('Rule collection group priority.')
param priority int

@description('Group of Firewall Policy rule collections.')
param ruleCollections mahi.FirewallPolicyRuleCollection[]

resource pol 'Microsoft.Network/firewallPolicies@2023-06-01' existing = {
  name: firewallPolicyName
  scope: resourceGroup()
}

resource rcg 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-06-01' = {
  name: name
  parent: pol
  properties: {
    priority: priority
    ruleCollections: ruleCollections
  }
}

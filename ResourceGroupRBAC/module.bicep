metadata name = 'Subscription RBAC bicep Module'

metadata description = '''
- This module helps to assign RBAC roles at the subscription level. It supports both "principalId" and "principalName" properties to specify the Entra ID principal for which the role assignment is to be applied. If you are assigning roles for EntraID groups, it is recommended to pass the name (or display name) instead of the Object Id of the group.
- If principalName is being passed ensure to pass the value of parameter "deploymentScriptRGName" as the module uses a deployment script resource to get the Object Id of the principal which is scoped to a resource group.
'''

metadata version = '1.0'

import { RoleAssignment } from '../utilities.bicep'

@description('Role Assignments to be applied at the Resource Group level. You can specify either "principalId" or "principalName" property but cannot specify both of them. If both properties are specified or both properties are not specified, deployment will fail with an error message.')
param roleAssignments RoleAssignment[]

// =============================== //
//          Variables              //
// =============================== //

@description('Filter role assignments to separate the elements of an array with principalName.')
var filteredRoleAssignments = filter(roleAssignments, each => empty(each.?principalId ?? ''))

@description('Unique principal names if the principalName is specified multiple times.')
var uniqueNames = union(map(filteredRoleAssignments, each => each.principalName!), [])

@description('List of unique principals with their types to be used for fetching Object Id.')
var uniquePrincipals = map(uniqueNames, name => {
  principalName: name
  principalType: filter(filteredRoleAssignments, each => each.principalName! == name)[0].principalType
})

// Run the script once per unique principal.
module entraidobject '../EntraIDObject/module.bicep' = [
  for each in uniquePrincipals: {
    name: 'GetEntraIDObjectId_${each.principalName}'
    scope: resourceGroup()
    params: {
      principalName: each.?principalName
      principalType: each.?principalType
      userAssignedManagedIdentityRGName: 'rg-identity'
    }
  }
]

// Create role assignments
resource rg_role_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (each, i) in roleAssignments: {
    name: !empty(each.?principalId ?? '') && !empty(each.?principalName ?? '')
      ? fail('Only one of principalId or principalName can be specified.')
      : empty(each.?principalId ?? '') && empty(each.?principalName ?? '')
          ? fail('Either principalId or principalName must be specified.')
          : guid(subscription().subscriptionId, each.roleName, each.?principalId ?? each.?principalName)
    scope: resourceGroup()
    properties: {
      principalId: !empty(each.?principalId ?? '')
        ? each.principalId!
        : entraidobject[indexOf(uniqueNames, each.principalName!)].outputs.id
      roleDefinitionId: roleDefinitions(each.roleName).id //roleDefinitionId[each.?roleDefinitionName]
      principalType: each.principalType
      condition: each.?condition
      conditionVersion: each.?conditionVersion
      description: each.?description
    }
  }
]

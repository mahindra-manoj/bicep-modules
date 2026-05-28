# Entra ID Object Principal ID Retrieval `[Microsoft.Resources/deploymentScripts]`

This module retrieves the object ID of an Entra ID group, user, or service principal using Microsoft Graph API, packaged as a deployment script resource.

## Navigation

- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Examples](#examples)
- [Key Features](#key-features)

## Resource Types

| Resource Type | API Version | Reference |
|---|---|---|
| `Microsoft.Resources/deploymentScripts` | 2023-08-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.resources_deploymentscripts.html) \| [Template Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.resources/deploymentscripts) |
| `Microsoft.ManagedIdentity/userAssignedIdentities` | 2023-01-31 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.managedidentity_userassignedidentities.html) |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html) |

## Parameters

| Parameter | Type | Description | Required |
|---|---|---|---|
| `principalName` | string | Name of the principal (display name for groups/applications, userPrincipalName for users) | Yes |
| `principalType` | string | Type of principal: 'Group', 'User', or 'ServicePrincipal' | Yes |
| `timeStamp` | string | Read-only. UTC timestamp for uniqueness. Defaults to current time. | No |
| `userAssignedManagedIdentityName` | string | Name of the user-assigned managed identity. Defaults to 'mi-entraid'. | No |
| `userAssignedManagedIdentityRGName` | string | Resource group where the UAMI resides. Defaults to current RG. | No |
| `userAssignedManagedIdentitySubscriptionId` | string | Subscription ID where the UAMI resides. Defaults to current subscription. | No |
| `storageAccount` | object | Optional existing storage account for script storage and mounting | No |
| `containerSettings` | object | Optional network configuration for private endpoint execution | No |

## Outputs

| Output | Type | Description |
|---|---|---|
| `principalId` | string | The object ID of the retrieved principal |
| `principalType` | string | The type of principal that was retrieved |

## Examples

### Example 1: Basic usage - Retrieve user principal ID

```bicep
module entraIdObject 'br/public:avm/res/entra-id-object/principal-id:<version>' = {
  name: 'entraIdObjectDeployment'
  params: {
    principalName: 'user@example.com'
    principalType: 'User'
  }
}
```

### Example 2: Retrieve group principal ID

```bicep
module entraIdObject 'br/public:avm/res/entra-id-object/principal-id:<version>' = {
  name: 'entraIdObjectDeployment'
  params: {
    principalName: 'MySecurityGroup'
    principalType: 'Group'
    userAssignedManagedIdentityName: 'mi-entraid'
  }
}
```

### Example 3: Service principal lookup with custom managed identity

```bicep
module entraIdObject 'br/public:avm/res/entra-id-object/principal-id:<version>' = {
  name: 'entraIdObjectDeployment'
  params: {
    principalName: 'MyManagedIdentity'
    principalType: 'ServicePrincipal'
    userAssignedManagedIdentityName: 'my-custom-identity'
    userAssignedManagedIdentityRGName: 'my-rg'
  }
}
```

## Key Features

- **Principal ID Retrieval**: Retrieves object ID for Entra ID users, groups, and service principals
- **Microsoft Graph Integration**: Uses Microsoft Graph API for secure principal lookups
- **Managed Identity Authentication**: Requires user-assigned managed identity with appropriate permissions
- **Private Endpoint Support**: Optional private endpoint execution via container instance delegation
- **Flexible Identity Configuration**: Support for identities in different resource groups/subscriptions
- **Storage Account Integration**: Optional integration with storage accounts for script storage

## Requirements

- User-assigned managed identity with Entra ID permissions:
  - `Group.Read.All` - for group lookups
  - `User.Read.All` - for user lookups
  - `Application.Read.All` - for service principal lookups
  - OR: Application Administrator Entra ID role
- For private endpoint execution:
  - Subnet with `Microsoft.ContainerInstance/containerGroups` delegation
  - Proper DNS resolution for private endpoints
  - Storage account with appropriate access (if using private execution)

## Best Practices

- Use least-privilege permissions with custom roles when possible
- Implement proper DNS resolution for private endpoint scenarios
- Monitor deployment script execution logs for troubleshooting
- Use managed identities instead of storing credentials
- Consider using private endpoint execution for sensitive principal lookups
- Store scripts and containers in encrypted storage when using private endpoints

## Notes

- The deployment script is idempotent and can be safely re-run
- Principal lookups are case-sensitive for service principals
- For user principals, use the userPrincipalName (email-like format)
- For group principals, use the display name
- The script requires network connectivity to Microsoft Graph endpoints

---

For more information, see [Microsoft Graph API Documentation](https://learn.microsoft.com/en-us/graph/api/overview) and [Deployment Scripts Reference](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deployment-script-template).

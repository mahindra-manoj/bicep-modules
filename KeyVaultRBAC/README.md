# Key Vault RBAC `[Microsoft.Authorization/roleAssignments]`

This module creates RBAC role assignments on a Key Vault for service principals, groups, or users, with built-in support for Entra ID lookups.

## Navigation

- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Examples](#examples)
- [Key Features](#key-features)

## Resource Types

| Resource Type | API Version | Reference |
|---|---|---|
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html) \| [Template Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments) |
| `Microsoft.KeyVault/vaults` | 2023-07-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.keyvault_vaults.html) |

## Parameters

| Parameter | Type | Description | Required |
|---|---|---|---|
| `keyVaultName` | string | Name of the Key Vault on which role assignments will be made | Yes |
| `roleAssignments` | array | Array of role assignments with principal information and role names | Yes |

## Role Assignment Properties

Each role assignment in the array can include:
- `principalName` - Display name (for groups/applications) or userPrincipalName (for users)
- `principalId` - Optional explicit principal object ID
- `principalType` - 'User', 'Group', or 'ServicePrincipal'
- `roleName` - One of the predefined Key Vault roles (see below)

## Supported Key Vault Roles

- Key Vault Administrator
- Key Vault Certificates Officer
- Key Vault Certificate User
- Key Vault Crypto Officer
- Key Vault Crypto Service Encryption User
- Key Vault Crypto User
- Key Vault Data Access Administrator
- Key Vault Secrets Officer
- Key Vault Secrets User

## Outputs

| Output | Type | Description |
|---|---|---|
| `roleAssignmentIds` | array | Array of resource IDs for created role assignments |

## Examples

### Example 1: Assign role to Entra ID user

```bicep
module kvRbac 'br/public:avm/res/key-vault/rbac:<version>' = {
  name: 'kvRbacDeployment'
  params: {
    keyVaultName: 'my-keyvault'
    roleAssignments: [
      {
        principalName: 'user@example.com'
        principalType: 'User'
        roleName: 'Key Vault Secrets User'
      }
    ]
  }
}
```

### Example 2: Assign multiple roles to different principals

```bicep
module kvRbac 'br/public:avm/res/key-vault/rbac:<version>' = {
  name: 'kvRbacDeployment'
  params: {
    keyVaultName: 'my-keyvault'
    roleAssignments: [
      {
        principalName: 'AdminGroup'
        principalType: 'Group'
        roleName: 'Key Vault Administrator'
      }
      {
        principalName: 'AppServiceIdentity'
        principalType: 'ServicePrincipal'
        roleName: 'Key Vault Secrets User'
      }
      {
        principalName: 'user@example.com'
        principalType: 'User'
        roleName: 'Key Vault Crypto User'
      }
    ]
  }
}
```

### Example 3: Assign role using explicit principal ID

```bicep
module kvRbac 'br/public:avm/res/key-vault/rbac:<version>' = {
  name: 'kvRbacDeployment'
  params: {
    keyVaultName: 'my-keyvault'
    roleAssignments: [
      {
        principalId: '12345678-1234-1234-1234-123456789012'
        principalType: 'ServicePrincipal'
        roleName: 'Key Vault Secrets Officer'
      }
    ]
  }
}
```

## Key Features

- **Multiple Principal Types**: Support for users, groups, and service principals
- **Entra ID Lookup**: Automatic principal ID lookup using Microsoft Graph API
- **Flexible Assignment**: Support for explicit principal IDs or name-based lookups
- **Multiple Roles**: Support for all Key Vault RBAC roles
- **Batch Operations**: Create multiple role assignments in one deployment
- **Graph Integration**: Uses Bicep graph extension for user lookups
- **Error Handling**: Validation to prevent dual specification of principalId and principalName

## Requirements

- Existing Key Vault resource
- For name-based lookups:
  - User-assigned managed identity with Entra ID read permissions
  - Proper Microsoft Graph API permissions (User.Read.All, Group.Read.All, Application.Read.All)
  - OR: Application Administrator Entra ID role on the identity
- For explicit principal IDs:
  - Valid principal object IDs

## Best Practices

- Use least-privilege roles (e.g., 'Key Vault Secrets User' instead of 'Key Vault Administrator')
- Assign roles to groups rather than individual users for easier management
- Use explicit principal IDs when possible to avoid lookup dependencies
- Review and audit role assignments regularly
- Document which principals require which roles
- Use service principals for application authentication
- Avoid assigning Administrator role unless absolutely necessary
- Implement proper change management for role assignments
- Monitor role assignment activities through audit logs

## Notes

- The module automatically retrieves principal IDs from Entra ID when using principal names
- Cannot specify both `principalId` and `principalName` - use one or the other
- User principals should use userPrincipalName (email format)
- Group and service principal lookups use display names
- Role names are case-sensitive
- Assignments take effect immediately
- Multiple assignments to the same principal are idempotent

## Cross-referenced Modules

This module integrates with:
- **EntraIDObject**: For principal ID lookups
- **KeyVault**: For the target Key Vault resource

---

For more information, see [Key Vault RBAC Documentation](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide) and [Azure Built-in Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles).

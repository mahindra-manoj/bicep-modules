# Resource Group Lock `[Microsoft.Authorization/locks]`

This module applies CanNotDelete or ReadOnly locks at the resource group level to prevent accidental deletion or modification of resources.

## Navigation

- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Examples](#examples)
- [Key Features](#key-features)

## Resource Types

| Resource Type | API Version | Reference |
|---|---|---|
| `Microsoft.Authorization/locks` | 2020-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html) \| [Template Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/locks) |

## Parameters

| Parameter | Type | Description | Required |
|---|---|---|---|
| `level` | string | Lock level: 'CanNotDelete' or 'ReadOnly'. Defaults to 'CanNotDelete'. | No |
| `name` | string | Name of the lock. Defaults to 'bicep-lock'. | No |
| `notes` | string | Optional notes about the lock (max 512 characters) | No |

## Lock Types

- **CanNotDelete**: Users can read and modify resources, but cannot delete them
- **ReadOnly**: Users can only read resources, cannot modify or delete them

## Outputs

| Output | Type | Description |
|---|---|---|
| `id` | string | Resource ID of the lock |
| `name` | string | Name of the lock |

## Examples

### Example 1: Basic CanNotDelete lock

```bicep
module resourceGroupLock 'br/public:avm/res/authorization/lock:<version>' = {
  name: 'resourceGroupLockDeployment'
  params: {
    level: 'CanNotDelete'
    name: 'prevent-deletion'
    notes: 'Prevents accidental deletion of production resources'
  }
}
```

### Example 2: ReadOnly lock with descriptive notes

```bicep
module resourceGroupLock 'br/public:avm/res/authorization/lock:<version>' = {
  name: 'resourceGroupLockDeployment'
  params: {
    level: 'ReadOnly'
    name: 'production-readonly'
    notes: 'Production resource group locked for read-only access. Changes require approval from security team.'
  }
}
```

### Example 3: Default CanNotDelete lock (minimal)

```bicep
module resourceGroupLock 'br/public:avm/res/authorization/lock:<version>' = {
  name: 'resourceGroupLockDeployment'
  params: {}
}
```

### Example 4: Lock for sensitive resources

```bicep
module resourceGroupLock 'br/public:avm/res/authorization/lock:<version>' = {
  name: 'resourceGroupLockDeployment'
  params: {
    level: 'CanNotDelete'
    name: 'critical-infrastructure-lock'
    notes: 'Lock applied to critical infrastructure resources. Unlock requires approval from infrastructure team and security review.'
  }
}
```

## Key Features

- **Simple Lock Application**: Easy-to-apply protection at resource group level
- **Two Lock Types**: CanNotDelete for modification protection, ReadOnly for strict control
- **Descriptive Notes**: Document lock purpose and requirements
- **Resource Group Scope**: Protects all resources within the group
- **Flexible Configuration**: Optional parameters for standard defaults

## Requirements

- Owner or User Access Administrator role on the resource group
- Understanding of lock implications for operational procedures

## Best Practices

- Use CanNotDelete for production resources to prevent accidental deletion
- Use ReadOnly for critical or immutable configurations
- Include clear, descriptive notes in locks explaining the reason
- Document lock removal procedures
- Combine with RBAC for comprehensive access control
- Regular review of locks to ensure they're still needed
- Use consistent naming conventions for locks
- Implement notification procedures for lock removal requests
- Monitor and audit lock-related operations
- Plan for legitimate resource management needs (updates, scaling, etc.)

## Lock Removal Procedure

To remove a lock:

1. Users with Owner role can use Azure Portal or CLI
2. Azure CLI command: `az lock delete --name <lock-name> --resource-group <rg-name>`
3. PowerShell command: `Remove-AzResourceLock -LockName <lock-name> -ResourceGroupName <rg-name> -Force`
4. Locks prevent deletion but allow other operations (except ReadOnly)

## Important Notes

- Locks at resource group level apply to all resources in the group
- Locks do not prevent all modifications (ReadOnly is more restrictive)
- ReadOnly locks prevent even read operations for some services
- CanNotDelete locks still allow modifications to existing resources
- Child resources inherit locks from parent resource group
- Multiple locks can be applied, but only one per lock type
- Lock names must be unique within the resource group
- Some Azure services may override ReadOnly locks
- Locks persist across deployments
- API calls can bypass locks in some scenarios

## Considerations for CanNotDelete Lock

- Allows configuration changes and updates
- Prevents accidental deletion of entire resource group
- Does not prevent individual resource deletion outside the group
- Operations like scaling, patching, etc. are allowed
- Backup and recovery operations remain possible

## Considerations for ReadOnly Lock

- Prevents all modifications (very restrictive)
- Allows read operations only
- Can impact operational tasks (updates, patches, configuration changes)
- May require lock removal for legitimate maintenance
- Better for immutable or compliance-critical resources

---

For more information, see [Azure Resource Locks Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources) and [Management Locks Overview](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview).

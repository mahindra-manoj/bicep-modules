# Key Vault `[Microsoft.KeyVault/vaults]`

This module deploys an Azure Key Vault with RBAC as the authorization model, supporting advanced features like private endpoints, firewall rules, and automatic role assignments.

## Navigation

- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Examples](#examples)
- [Key Features](#key-features)

## Resource Types

| Resource Type | API Version | Reference |
|---|---|---|
| `Microsoft.KeyVault/vaults` | 2025-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.keyvault_vaults.html) \| [Template Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults) |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html) |
| `Microsoft.Network/privateEndpoints` | 2024-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints.html) |
| `Microsoft.Authorization/locks` | 2020-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html) |

## Parameters

| Parameter | Type | Description | Required |
|---|---|---|---|
| `nameSuffix` | string | Name suffix for the Key Vault (prefix 'kv-' is added automatically) | Yes |
| `sku` | string | Key Vault SKU: 'standard' or 'premium' | Yes |
| `enableRbacAuth` | boolean | Enable RBAC for authorization. Defaults to true. | No |
| `enablePurgeProtection` | boolean | Enable purge protection. Defaults to true. | No |
| `softDeleteRetentionInDays` | integer | Soft delete retention period (7-90 days). Defaults to 7. | No |
| `location` | string | Azure region for deployment. Defaults to resource group location. | No |
| `tags` | object | Resource tags | No |
| `accessPolicies` | array | Access policies (used if RBAC is disabled) | No |
| `ipRules` | string[] | Whitelist of IP addresses for public network access | No |
| `privateEndpoint` | object | Private endpoint configuration | No |
| `roleAssignments` | array | RBAC role assignments | No |
| `virtualNetworkRules` | object | Virtual network service endpoint rules | No |
| `recoverVault` | boolean | Enable recovery mode for soft-deleted vaults. Defaults to false. | No |

## Outputs

| Output | Type | Description |
|---|---|---|
| `id` | string | Resource ID of the Key Vault |
| `name` | string | Name of the Key Vault |
| `uri` | string | URI of the Key Vault (DNS name) |
| `vaultUrl` | string | Vault URL for accessing secrets and keys |

## Examples

### Example 1: Basic Key Vault with RBAC

```bicep
module keyVault 'br/public:avm/res/key-vault/vault:<version>' = {
  name: 'keyVaultDeployment'
  params: {
    nameSuffix: 'myapps'
    sku: 'standard'
    enableRbacAuth: true
    enablePurgeProtection: true
  }
}
```

### Example 2: Key Vault with private endpoint

```bicep
module keyVault 'br/public:avm/res/key-vault/vault:<version>' = {
  name: 'keyVaultDeployment'
  params: {
    nameSuffix: 'secure'
    sku: 'premium'
    enableRbacAuth: true
    privateEndpoint: {
      subnetName: 'private-endpoints'
      vnetName: 'my-vnet'
      privateDnsZoneIds: ['/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net']
    }
  }
}
```

### Example 3: Key Vault with firewall rules

```bicep
module keyVault 'br/public:avm/res/key-vault/vault:<version>' = {
  name: 'keyVaultDeployment'
  params: {
    nameSuffix: 'restricted'
    sku: 'standard'
    enableRbacAuth: true
    ipRules: [
      '203.0.113.0/24'
      '198.51.100.0/24'
    ]
    virtualNetworkRules: {
      subnetName: 'services'
      vnetName: 'my-vnet'
    }
  }
}
```

### Example 4: Premium Key Vault with custom retention

```bicep
module keyVault 'br/public:avm/res/key-vault/vault:<version>' = {
  name: 'keyVaultDeployment'
  params: {
    nameSuffix: 'premium'
    sku: 'premium'
    enableRbacAuth: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
    location: 'eastus'
    tags: {
      environment: 'production'
      tier: 'critical'
    }
  }
}
```

## Key Features

- **RBAC Authorization**: Role-based access control for enhanced security
- **Automatic Role Assignment**: Deplying principal automatically assigned KVAdmin role
- **Purge Protection**: Optional purge protection to prevent accidental deletion
- **Soft Delete**: Automatic soft delete with configurable retention period
- **Private Endpoint Support**: Secure private network connectivity
- **IP Whitelisting**: Restrict access to specific IP addresses
- **Service Endpoint Integration**: Virtual network service endpoint support
- **Access Policies**: Legacy access policy support for backward compatibility
- **Premium SKU Support**: High-performance vault option with dedicated hardware
- **Vault Recovery**: Support for recovering soft-deleted vaults

## Requirements

- Azure subscription with appropriate permissions
- For private endpoint:
  - Configured virtual network and subnet
  - Private DNS zone for DNS resolution (privatelink.vaultcore.azure.net)
- For IP rules:
  - Known static IP addresses or CIDR ranges
- For service endpoints:
  - Virtual network with subnet delegation configured

## Best Practices

- Use RBAC authorization instead of access policies
- Enable purge protection for production vaults
- Implement private endpoints to restrict network access
- Use soft delete with appropriate retention period
- Monitor key rotation and access logs
- Apply least-privilege RBAC assignments
- Use managed identities for application authentication
- Implement network restrictions (IP rules or service endpoints)
- Enable diagnostic logging for compliance and auditing
- Regularly review and audit access policies
- Use separate vaults for different environments

## Notes

- The deploying principal is automatically assigned the Key Vault Administrator role
- Soft delete cannot be disabled once enabled (set `softDeleteRetentionInDays` > 0)
- Access policies are ignored when RBAC is enabled
- Premium SKU provides dedicated HSM support for key storage
- Private endpoint DNS resolution requires proper configuration
- Vault recovery requires soft delete to be enabled
- Purge protection prevents vault deletion even if soft delete is enabled

---

For more information, see [Key Vault Documentation](https://learn.microsoft.com/en-us/azure/key-vault/) and [Key Vault Best Practices](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices).

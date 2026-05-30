# Private Endpoint `[Microsoft.Network/privateEndpoints]`

This module automates the creation of private endpoints for Azure resource types, with optional DNS zone registration for private link resolution.

## Navigation

- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Examples](#examples)
- [Key Features](#key-features)

## Resource Types

| Resource Type | API Version | Reference |
|---|---|---|
| `Microsoft.Network/privateEndpoints` | 2025-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints.html) \| [Template Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/privateendpoints) |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | 2025-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints_privatednszonegroups.html) |

## Parameters

| Parameter | Type | Description | Required |
|---|---|---|---|
| `nameSuffix` | string | Name suffix for the private endpoint (prefix 'pe-' is added automatically) | Yes |
| `groupId` | string | Target sub-resource of the resource type (e.g., 'vault' for Key Vault) | Yes |
| `privateLinkServiceId` | string | Resource ID of the target Azure resource | Yes |
| `vnetName` | string | Name of the virtual network where the private endpoint will be deployed | Yes |
| `subnetName` | string | Name of the subnet where the private endpoint will be deployed | Yes |
| `privateDnsZoneIds` | string[] | Array of Private DNS Zone resource IDs to register with | Yes |
| `location` | string | Azure region for deployment. Defaults to resource group location. | No |
| `tags` | object | Resource tags | No |
| `vnetRGName` | string | Resource group where the VNet resides. Defaults to current RG. | No |

## Supported Group IDs by Resource Type

| Resource Type | Group ID |
|---|---|
| Key Vault | vault |
| Storage Blob | blob |
| Storage File | file |
| Storage Queue | queue |
| Storage Table | table |
| SQL Database | sqlServer |
| PostgreSQL | postgresqlServer |
| MySQL | mysqlServer |
| Cosmos DB | Sql (varies by API type) |
| Redis | redisCache |
| Event Hubs | namespace |
| Service Bus | namespace |
| Azure Search | searchService |
| Application Insights | agentSvc |
| Azure Container Registry | registry |
| Azure App Service | sites |

## Outputs

| Output | Type | Description |
|---|---|---|
| `id` | string | Resource ID of the private endpoint |
| `name` | string | Name of the private endpoint |
| `networkInterfaceId` | string | ID of the network interface created for the private endpoint |

## Examples

### Example 1: Private Endpoint for Key Vault

```bicep
module privateEndpoint 'br/public:avm/res/network/private-endpoint:<version>' = {
  name: 'privateEndpointDeployment'
  params: {
    nameSuffix: 'keyvault'
    groupId: 'vault'
    privateLinkServiceId: '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/my-kv'
    vnetName: 'my-vnet'
    subnetName: 'private-endpoints'
    privateDnsZoneIds: [
      '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
    ]
  }
}
```

### Example 2: Private Endpoint for Storage Blob

```bicep
module privateEndpoint 'br/public:avm/res/network/private-endpoint:<version>' = {
  name: 'privateEndpointDeployment'
  params: {
    nameSuffix: 'storage'
    groupId: 'blob'
    privateLinkServiceId: '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Storage/storageAccounts/mystorageacct'
    vnetName: 'my-vnet'
    subnetName: 'private-endpoints'
    privateDnsZoneIds: [
      '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
    ]
    tags: {
      environment: 'production'
    }
  }
}
```

### Example 3: Private Endpoint in different resource group

```bicep
module privateEndpoint 'br/public:avm/res/network/private-endpoint:<version>' = {
  name: 'privateEndpointDeployment'
  params: {
    nameSuffix: 'database'
    groupId: 'sqlServer'
    privateLinkServiceId: '/subscriptions/xxx/resourceGroups/data-rg/providers/Microsoft.Sql/servers/my-sqldb'
    vnetName: 'app-vnet'
    subnetName: 'private-endpoints'
    vnetRGName: 'app-rg'
    privateDnsZoneIds: [
      '/subscriptions/xxx/resourceGroups/network-rg/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net'
    ]
    location: 'eastus'
  }
}
```

### Example 4: Private Endpoint with multiple DNS zones

```bicep
module privateEndpoint 'br/public:avm/res/network/private-endpoint:<version>' = {
  name: 'privateEndpointDeployment'
  params: {
    nameSuffix: 'cosmosdb'
    groupId: 'Sql'
    privateLinkServiceId: '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.DocumentDB/databaseAccounts/my-cosmosdb'
    vnetName: 'my-vnet'
    subnetName: 'private-endpoints'
    privateDnsZoneIds: [
      '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com'
      '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/privateDnsZones/privatelink-secondary.documents.azure.com'
    ]
  }
}
```

## Key Features

- **Automated Creation**: Simplified private endpoint creation for supported resources
- **DNS Zone Integration**: Automatic registration with Private DNS Zones
- **Network Interface Abstraction**: Automatic creation of network interfaces
- **Multiple DNS Zones**: Support for multiple DNS zone registrations
- **Cross-RG Support**: Deploy private endpoints in different resource groups
- **IP Configuration**: Automatic IP configuration in specified subnet
- **Resource Tagging**: Support for resource tags

## Requirements

- Existing virtual network and subnet
- Target Azure resource (Key Vault, Storage, SQL Database, etc.)
- Private DNS Zone(s) configured and ready for registration
- Subnet with appropriate network policies configured
- Network permissions to create endpoints in the VNet

## Best Practices

- Use consistent subnet naming conventions for private endpoints
- Organize Private DNS Zones centrally for management
- Implement network policies to restrict traffic
- Use Network Security Groups with private endpoints
- Document private endpoint purposes and linked resources
- Monitor private endpoint connections for troubleshooting
- Implement proper RBAC for endpoint management
- Use separate subnets for private endpoints
- Verify DNS resolution after creating endpoints
- Regularly audit private endpoint usage
- Plan IP address space for endpoints
- Consider using a hub-and-spoke topology for shared endpoints

## Notes

- The 'name' suffix parameter must not start with 'pe-' (it's added automatically)
- Multiple private endpoints for the same resource require different names
- Private endpoint creation can take several minutes
- DNS zone registration is automatic when zone IDs are provided
- Network policies apply to private endpoints
- Private endpoints consume IP addresses from the subnet
- DNS resolution may take a few moments to activate
- Azure Default routes (0.0.0.0/0) do not automatically include private endpoints

## Cross-referenced Modules

This module integrates with:
- **PrivateDnsZone**: For DNS zone registration
- **VirtualNetwork**: For subnet configuration

---

For more information, see [Private Endpoint Documentation](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview) and [Private Link Resource Guide](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview).

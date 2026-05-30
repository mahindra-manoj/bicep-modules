# Private DNS Zone `[Microsoft.Network/privateDnsZones]`

This module creates a Private DNS Zone resource and links virtual networks to enable DNS resolution for private endpoints.

## Navigation

- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Examples](#examples)
- [Key Features](#key-features)

## Resource Types

| Resource Type | API Version | Reference |
|---|---|---|
| `Microsoft.Network/privateDnsZones` | 2020-06-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privatednszones.html) \| [Template Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/privatednszones) |
| `Microsoft.Network/privateDnsZones/virtualNetworkLinks` | 2020-06-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privatednszones_virtualnetworklinks.html) |

## Parameters

| Parameter | Type | Description | Required |
|---|---|---|---|
| `name` | string | Name of the Private DNS Zone | Yes |
| `virtualNetworks` | array | Array of virtual networks to link with the Private DNS Zone | Yes |
| `tags` | object | Resource tags | No |

## Virtual Network Link Properties

Each virtual network object should include:
- `name` - Name of the virtual network
- `resourceGroup` - Optional resource group name (defaults to current RG)
- `subscriptionId` - Optional subscription ID (defaults to current subscription)

## Supported Private DNS Zone Names

Common private DNS zones:
- `privatelink.vaultcore.azure.net` - Azure Key Vault
- `privatelink.database.windows.net` - Azure SQL Database
- `privatelink.postgres.database.azure.com` - PostgreSQL
- `privatelink.mysql.database.azure.com` - MySQL
- `privatelink.mariadb.database.azure.com` - MariaDB
- `privatelink.postgres.database.azure.com` - Azure Database for PostgreSQL
- `privatelink.blob.core.windows.net` - Azure Blob Storage
- `privatelink.file.core.windows.net` - Azure File Shares
- `privatelink.queue.core.windows.net` - Azure Queue Storage
- `privatelink.table.core.windows.net` - Azure Table Storage
- `privatelink.dfs.core.windows.net` - Azure Data Lake
- `privatelink.documents.azure.com` - Cosmos DB
- `privatelink.mongo.cosmos.azure.com` - Cosmos DB (Mongo)
- `privatelink.cassandra.cosmos.azure.com` - Cosmos DB (Cassandra)
- `privatelink.gremlin.cosmos.azure.com` - Cosmos DB (Gremlin)
- `privatelink.table.cosmos.azure.com` - Cosmos DB (Table)
- `privatelink.postgres.cosmos.azure.com` - Cosmos DB (PostgreSQL)
- `privatelink.redis.cache.windows.net` - Azure Cache for Redis
- `privatelink.redisenterprise.cache.azure.net` - Azure Cache for Redis Enterprise
- `privatelink.openai.azure.com` - Azure OpenAI Service

## Outputs

| Output | Type | Description |
|---|---|---|
| `id` | string | Resource ID of the Private DNS Zone |
| `name` | string | Name of the Private DNS Zone |

## Examples

### Example 1: Basic Private DNS Zone with single VNet link

```bicep
module privateDnsZone 'br/public:avm/res/network/private-dns-zone:<version>' = {
  name: 'privateDnsZoneDeployment'
  params: {
    name: 'privatelink.vaultcore.azure.net'
    virtualNetworks: [
      {
        name: 'my-vnet'
      }
    ]
  }
}
```

### Example 2: Private DNS Zone with multiple VNet links

```bicep
module privateDnsZone 'br/public:avm/res/network/private-dns-zone:<version>' = {
  name: 'privateDnsZoneDeployment'
  params: {
    name: 'privatelink.database.windows.net'
    virtualNetworks: [
      {
        name: 'prod-vnet'
        resourceGroup: 'prod-rg'
      }
      {
        name: 'dev-vnet'
        resourceGroup: 'dev-rg'
      }
      {
        name: 'hub-vnet'
        resourceGroup: 'hub-rg'
        subscriptionId: '12345678-1234-1234-1234-123456789012'
      }
    ]
    tags: {
      environment: 'production'
      resource: 'sqldb'
    }
  }
}
```

### Example 3: Private DNS Zone for Key Vault

```bicep
module privateDnsZone 'br/public:avm/res/network/private-dns-zone:<version>' = {
  name: 'privateDnsZoneDeployment'
  params: {
    name: 'privatelink.vaultcore.azure.net'
    virtualNetworks: [
      {
        name: 'app-vnet'
      }
      {
        name: 'data-vnet'
      }
    ]
  }
}
```

### Example 4: Private DNS Zone in different subscription

```bicep
module privateDnsZone 'br/public:avm/res/network/private-dns-zone:<version>' = {
  name: 'privateDnsZoneDeployment'
  params: {
    name: 'privatelink.blob.core.windows.net'
    virtualNetworks: [
      {
        name: 'shared-vnet'
        resourceGroup: 'shared-rg'
        subscriptionId: '87654321-4321-4321-4321-210987654321'
      }
    ]
  }
}
```

## Key Features

- **Multiple VNet Links**: Link multiple virtual networks to a single Private DNS Zone
- **Cross-Subscription Support**: Link VNets from different subscriptions
- **Cross-RG Support**: Link VNets from different resource groups
- **Registration Disabled**: VNet links created with registration disabled (manual DNS management)
- **Global Scope**: Private DNS Zones have global location scope
- **Private Resolution**: Enables private IP resolution for private endpoints

## Requirements

- Virtual networks must exist before linking
- For cross-subscription scenarios:
  - Appropriate permissions in target subscription
  - Proper RBAC configuration
- Private endpoint resources to register with the DNS zone

## Best Practices

- Use consistent naming for Private DNS Zones across environments
- Link all relevant VNets to avoid DNS resolution issues
- Use hub-and-spoke topology with shared Private DNS Zones
- Document DNS zone purposes and linked VNets
- Verify DNS resolution after creating Private DNS Zones
- Implement conditional forwarding for on-premises DNS integration
- Monitor Private DNS Zone query logs
- Keep DNS records organized and documented
- Use separate zones for different resource types when managing multiple private endpoints
- Implement proper RBAC for DNS zone management

## Notes

- Private DNS Zones use 'global' as location (not a regional resource)
- VNet links are created with `registrationEnabled: false` - records must be managed manually
- Multiple VNets can be linked to a single Private DNS Zone
- DNS resolution from linked VNets is bidirectional
- VNet links can take a few moments to activate
- Each VNet can have at most 1,000 Private DNS Zone links (Azure limit)

## Cross-referenced Modules

This module works with:
- **PrivateEndpoint**: For creating private endpoints that register with DNS zones
- **VirtualNetwork**: For the VNets being linked to the DNS zone

---

For more information, see [Private DNS Zone Documentation](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview) and [Private Endpoint DNS Configuration](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns).

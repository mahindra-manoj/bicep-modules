# Virtual Network `[Microsoft.Network/virtualNetworks]`

This module deploys a Virtual Network with subnets, optional peering, DDoS protection, and comprehensive diagnostic and monitoring features.

## Navigation

- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Examples](#examples)
- [Key Features](#key-features)

## Resource Types

| Resource Type | API Version | Reference |
|---|---|---|
| `Microsoft.Network/virtualNetworks` | 2024-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_virtualnetworks.html) \| [Template Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks) |
| `Microsoft.Network/virtualNetworks/subnets` | 2024-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_virtualnetworks_subnets.html) |
| `Microsoft.Network/virtualNetworkPeerings` | 2024-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_virtualnetworkpeerings.html) |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html) |
| `Microsoft.Authorization/locks` | 2020-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html) |

## Parameters

| Parameter | Type | Description | Required |
|---|---|---|---|
| `nameSuffix` | string | Name suffix for the VNET (prefix 'vnet-' is added automatically) | Yes |
| `cidr` | string | Address space CIDR for the virtual network | Yes |
| `location` | string | Azure region for deployment. Defaults to resource group location. | No |
| `subnets` | array | Array of subnet configurations | Yes |
| `dnsServers` | string[] | Custom DNS servers. Defaults to Azure-provided DNS. | No |
| `enableDdosProtectionPlan` | boolean | Enable DDoS protection. Defaults to false. | No |
| `ddosProtectionPlan` | object | DDoS protection plan configuration | No |
| `enableEncryption` | boolean | Enable VNet encryption for VM traffic. Defaults to false. | No |
| `peerings` | array | Virtual network peerings configuration | No |
| `lock` | object | Resource lock configuration | No |
| `diagnosticSettings` | array | Diagnostic settings for logging and monitoring | No |
| `tags` | object | Resource tags | No |

## Outputs

| Output | Type | Description |
|---|---|---|
| `id` | string | Resource ID of the virtual network |
| `name` | string | Name of the virtual network |
| `addressSpace` | array | Address space of the VNet |
| `subnets` | array | Array of subnet configurations |

## Examples

### Example 1: Basic Virtual Network with subnets

```bicep
module vnet 'br:crmahi.azurecr.io/network/vnet:1.0' = {
  name: 'vnetDeployment'
  params: {
    nameSuffix: 'prod'
    cidr: '10.0.0.0/16'
    subnets: [
      {
        name: 'subnet-app'
        addressPrefix: '10.0.1.0/24'
      }
      {
        name: 'subnet-data'
        addressPrefix: '10.0.2.0/24'
      }
    ]
  }
}
```

## Key Features

- **Flexible Subnetting**: Define multiple subnets with custom address ranges
- **DDoS Protection**: Optional DDoS Standard protection plan integration
- **VNet Peering**: Support for VNet-to-VNet peering configuration
- **Custom DNS**: Configure custom DNS servers for name resolution
- **VNet Encryption**: Optional encryption for inter-VM traffic
- **Service Endpoints**: Configure Azure service endpoints for subnets
- **Subnet Delegation**: Support for delegating subnets to specific services
- **Resource Locking**: Optional resource locks for protection
- **Diagnostic Settings**: Comprehensive monitoring and logging capabilities
- **NSG Integration**: Support for network security groups on subnets

## Requirements

- Azure subscription with appropriate permissions
- Unique address space (no overlapping CIDR ranges with other VNets)
- For peering: Target VNet must exist
- For DDoS protection: DDoS Standard plan must exist
- For diagnostics: Log Analytics workspace (if using diagnostics)

## Best Practices

- Plan IP address space carefully to avoid fragmentation
- Use non-overlapping CIDR ranges for peering
- Implement subnet segmentation for security
- Use service endpoints to restrict Azure service access
- Enable DDoS protection for critical workloads
- Configure custom DNS only if necessary
- Implement network security groups on subnets
- Monitor VNet traffic through diagnostic settings
- Document subnet purposes and usage
- Use consistent naming conventions

## Notes

- VNet name automatically gets 'vnet-' prefix
- Subnets inherit VNet properties (DNS, encryption)
- Service endpoints add routes, not gateway routes
- Delegated subnets have delegation rules applied
- DDoS Standard provides higher protection than DDoS Basic

---

For more information, see [Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/) and [VNet Planning Guide](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview).
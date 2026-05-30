# Network Security Group `[Microsoft.Network/networkSecurityGroups]`

This module creates a Network Security Group (NSG) resource with configurable security rules for controlling inbound and outbound traffic.

## Navigation

- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Examples](#examples)
- [Key Features](#key-features)

## Resource Types

| Resource Type | API Version | Reference |
|---|---|---|
| `Microsoft.Network/networkSecurityGroups` | 2024-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_networksecuritygroups.html) \| [Template Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups) |

## Parameters

| Parameter | Type | Description | Required |
|---|---|---|---|
| `nameSuffix` | string | Name suffix for the NSG (prefix 'nsg-' is added automatically) | Yes |
| `location` | string | Azure region for deployment. Defaults to resource group location. | No |
| `securityRules` | array | List of security rules to apply to the NSG | Yes |
| `tags` | object | Resource tags | No |

## Security Rule Properties

Each security rule object should include:
- `name` - Name of the security rule
- `access` - 'Allow' or 'Deny'
- `direction` - 'Inbound' or 'Outbound'
- `priority` - Integer between 100-4096
- `protocol` - 'Tcp', 'Udp', '*' (all), or 'Icmp'
- `sourceAddressPrefix` - Source IP address (supports comma-separated values and CIDR notation)
- `sourcePortRange` - Source port (typically '*' for all ports)
- `destinationAddressPrefix` - Destination IP address (supports comma-separated values and CIDR notation)
- `destinationPortRange` - Destination port or range (e.g., '80', '443', '80-443', '*')
- `description` - Optional rule description

## Outputs

| Output | Type | Description |
|---|---|---|
| `id` | string | Resource ID of the NSG |
| `name` | string | Name of the NSG |

## Examples

### Example 1: Basic NSG with HTTP/HTTPS rules

```bicep
module nsg 'br/public:avm/res/network-security-group:<version>' = {
  name: 'nsgDeployment'
  params: {
    nameSuffix: 'web'
    securityRules: [
      {
        name: 'AllowHTTP'
        access: 'Allow'
        direction: 'Inbound'
        priority: 100
        protocol: 'Tcp'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '80'
        description: 'Allow HTTP traffic'
      }
      {
        name: 'AllowHTTPS'
        access: 'Allow'
        direction: 'Inbound'
        priority: 110
        protocol: 'Tcp'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '443'
        description: 'Allow HTTPS traffic'
      }
    ]
  }
}
```

### Example 2: NSG with multiple ports and restricted source

```bicep
module nsg 'br/public:avm/res/network-security-group:<version>' = {
  name: 'nsgDeployment'
  params: {
    nameSuffix: 'app'
    location: 'eastus'
    securityRules: [
      {
        name: 'AllowRDP'
        access: 'Allow'
        direction: 'Inbound'
        priority: 100
        protocol: 'Tcp'
        sourceAddressPrefix: '203.0.113.0/24'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '3389'
        description: 'Allow RDP from management subnet'
      }
      {
        name: 'AllowMultiplePorts'
        access: 'Allow'
        direction: 'Inbound'
        priority: 110
        protocol: 'Tcp'
        sourceAddressPrefix: '10.0.0.0/8'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '80,443,8080'
        description: 'Allow multiple application ports'
      }
      {
        name: 'DenyAll'
        access: 'Deny'
        direction: 'Inbound'
        priority: 4096
        protocol: '*'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '*'
        description: 'Deny all other inbound traffic'
      }
    ]
    tags: {
      environment: 'production'
    }
  }
}
```

## Key Features

- **Multiple Rules Support**: Create multiple security rules in a single NSG
- **Flexible Rule Configuration**: Supports complex rule definitions with multiple ports and addresses
- **Service Tags**: Support for Azure service tags (Sql, Storage, etc.)
- **CIDR Support**: Full CIDR notation support for IP ranges
- **Port Ranges**: Support for individual ports, ranges, and multiple ports
- **Protocols**: Support for TCP, UDP, ICMP, and all protocols
- **Default Rules**: NSGs include default Azure rules plus custom rules

## Requirements

- Azure subscription with appropriate permissions
- Valid virtual network subnet to associate with the NSG (optional at creation)
- Understanding of required inbound/outbound traffic rules

## Best Practices

- Use service tags when available (e.g., 'Sql', 'Storage', 'AzureLoadBalancer')
- Implement default deny rules with specific allow rules
- Use descriptive rule names and descriptions
- Order rules by priority - more specific rules should have lower priority numbers
- Avoid overly permissive source addresses - restrict to specific subnets
- Group related rules logically
- Use network security groups at subnet level for broad protection
- Audit and review NSG rules regularly
- Document the business purpose of each rule
- Test rule changes before applying to production
- Monitor NSG flow logs to verify traffic patterns

## Notes

- NSG rules are processed in order of priority (lower numbers are processed first)
- Default rules cannot be deleted but can be overridden
- A subnet can have only one NSG associated at a time
- Rules support both IPv4 and IPv6 addresses
- The 'name' suffix parameter must not start with 'nsg-' (it's added automatically)
- Multiple address prefixes and ports can be specified using comma-separated values
- Service tags simplify rule management when using specific Azure services

## Rule Priority Guidelines

- 100-199: High-priority custom allow rules
- 200-299: Medium-priority custom rules
- 300-3999: Standard custom rules
- 4000-4095: Reserved for Azure service defaults
- 4096: Default deny rule

---

For more information, see [Network Security Groups Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) and [NSG Best Practices](https://learn.microsoft.com/en-us/azure/virtual-network/security-overview).
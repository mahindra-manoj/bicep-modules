# Route Table `[Microsoft.Network/routeTables]`

This module creates a Route Table resource with optional custom routes for managing network traffic routing in Azure.

## Navigation

- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Examples](#examples)
- [Key Features](#key-features)

## Resource Types

| Resource Type | API Version | Reference |
|---|---|---|
| `Microsoft.Network/routeTables` | 2023-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_routetables.html) \| [Template Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/routetables) |

## Parameters

| Parameter | Type | Description | Required |
|---|---|---|---|
| `nameSuffix` | string | Name suffix for the route table (prefix 'rt-' is added automatically) | Yes |
| `location` | string | Azure region for deployment. Defaults to resource group location. | No |
| `disableBgpRoutePropagation` | boolean | Disable routes learned by BGP. Defaults to false. | No |
| `routes` | array | Array of routes to add to the route table | No |
| `tags` | object | Resource tags | No |

## Route Properties

Each route object should include:
- `name` - Name of the route
- `addressPrefix` - CIDR range that the route applies to (e.g., '10.0.0.0/8')
- `nextHopType` - Type of next hop: 'VirtualAppliance', 'VirtualNetworkGateway', 'Internet', 'None', 'VnetLocal'
- `nextHopIpAddress` - IP address of the next hop (required for 'VirtualAppliance')

## Next Hop Types

| Type | Description | Use Case |
|---|---|---|
| VirtualNetworkGateway | Routes through VPN/ExpressRoute gateway | Hybrid connectivity |
| Internet | Routes to internet gateway | Internet-bound traffic |
| VirtualAppliance | Routes to custom network appliance | Firewall, NVA routing |
| None | Discard traffic | Black hole routes |
| VnetLocal | Local VNet routing | Internal communication |

## Outputs

| Output | Type | Description |
|---|---|---|
| `id` | string | Resource ID of the route table |
| `name` | string | Name of the route table |

## Examples

| Name | Type | Required | Description |

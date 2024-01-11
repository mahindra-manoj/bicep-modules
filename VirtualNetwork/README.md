# Virtual Network

Bicep module to deploy Virtual Network.

## Description

This module deploys a Virtual Network, and optionally configures diagnostic settings and assigns __CanNotDelete__ lock to the vnet deployed.

It will add __vnet-__ as the prefix to the VNET resource.

## Scope

It should be scoped to a resource group.

## Path

The module is not published to a remote registry (such as Container registry).

## Parameters

| Name | Type | Required | Description |
| :--- | :--- | :------- | :---------- |
| `cidr` | `string` | Yes | Address space of the VNET. |
| `diagnosticSettingsWorkspaceId` | `string` | No | Resource Id of the log analytics workspace used to store diagnostic settings of the VNET. |
| `enableLocking` | `bool` | Yes | If true, __CannotDelete__ lock will be configured for the VNET.
| `location` | `string` |  No | Azure region where the VNET will be created. Defaults to location of rg where the resource will be deployed. |
| `namePrefix` | `string` | Yes | Azure region where the VNET will be created. Defaults to location of resource group. |
| `subnets` | `subnetArray` | No | Subnets to be created. |
| `tags` | `tagsObject` | No | Tags to be applied to the resource. |

## Outputs

| Name | Type | Description |
| :--- | :--- | :---------- |
| `id` | `string` | Resource id of the vnet deployed. |
| `name` | `string` | Name of the VNET deployed. |
| `rg` | `string` | Resource group where the VNET is deployed. |
| `subnets` | `array` | List of resource IDs of the subnets. |

## Example

```bicep
param vnetCIDR string
param vnetNamePrefix string

module vnet 'module.bicep' = {
  name: 'DeployVNET'
  params: {
    cidr: vnetCIDR
    namePrefix: vnetNamePrefix
  }
}
```
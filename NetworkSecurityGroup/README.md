# Network Security Group

This module creates a NSG resource.

## Description

Use this module to simplify creation of NSG resource as a part of your main.bicep that will be used to create the infrastructure needed for your project.

## Scope

It should be scoped to a resource group.

## Path

The module can be published to a remote url such as Private registry (Azure Container Registry) or a template spec. ACR is the right choice for storing the modules as it provides secure access and as well as additional features to make the modules accessible easily.

## User-defined data types

This module imports **NetworkSecurityGroupSecurityRules** custom data type from [***types.bicep***](../types.bicep)

## Parameters

| Name | Type | Required | Description |
| :---- | :------ | :------- | :--------------------- |
| `location` | `string` | No | Region where the NSG resource will need to be provisioned |
| ` nameSuffix` | `string` | Yes | Name suffix of the NSG resource to be created |
| `securityRules` | `NetworkSecurityGroupRules` | Yes | List of security rules to be created |
| `tags` | `object` | No | Tags to be applied to the resource |

## Examples
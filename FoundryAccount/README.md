# Microsoft Foundry Account `[Microsoft.CognitiveServices/accounts]`

This module deploys a Microsoft Foundry (Azure AI Services) account with support for optional connections, identity configuration, endpoint management, and advanced networking features.

## Navigation

- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Examples](#examples)
- [Key Features](#key-features)

## Resource Types

| Resource Type | API Version | Reference |
|---|---|---|
| `Microsoft.CognitiveServices/accounts` | 2024-10-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.cognitiveservices_accounts.html) \| [Template Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts) |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html) |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html) |
| `Microsoft.Network/privateEndpoints` | 2024-05-01 | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints.html) |

## Parameters

| Parameter | Type | Description | Required |
|---|---|---|---|
| `nameSuffix` | string | Name suffix for the Foundry account | Yes |
| `kind` | string | Type of Cognitive Services account (e.g., 'AIServices', 'ComputerVision'). Defaults to 'AIServices'. | No |
| `sku` | string | SKU tier for the account | Yes |
| `disableLocalAuth` | boolean | Enable Entra ID authentication only. Defaults to true. | No |
| `location` | string | Azure region for deployment. Defaults to resource group location. | No |
| `tags` | object | Resource tags | No |
| `identity` | object | Managed identity configuration (SystemAssigned/UserAssigned) | No |
| `ipRules` | string[] | List of public IP addresses or CIDRs allowed to access the resource | No |
| `applicationLogging` | object | Application Insights configuration for logging and monitoring | No |
| `credentialStorage` | object | Key Vault configuration for credential storage | No |
| `connections` | object | Connections configuration for the Foundry account | No |
| `privateEndpoint` | object | Private endpoint configuration | No |
| `virtualNetworkRules` | object | Virtual network service endpoint rules | No |

## Outputs

| Output | Type | Description |
|---|---|---|
| `id` | string | Resource ID of the Foundry account |
| `name` | string | Name of the Foundry account |
| `endpoint` | string | API endpoint URL for the Foundry account |
| `keys` | object | Primary and secondary API keys (if local auth is enabled) |

## Examples

### Example 1: Basic Foundry account deployment

```bicep
module foundryAccount 'br/public:avm/res/cognitive-services/account:<version>' = {
  name: 'foundryAccountDeployment'
  params: {
    nameSuffix: 'myai'
    kind: 'AIServices'
    sku: 'S0'
    disableLocalAuth: true
  }
}
```

### Example 2: Foundry account with managed identity and private endpoint

```bicep
module foundryAccount 'br/public:avm/res/cognitive-services/account:<version>' = {
  name: 'foundryAccountDeployment'
  params: {
    nameSuffix: 'myai'
    kind: 'AIServices'
    sku: 'S0'
    identity: {
      type: 'SystemAssigned'
    }
    privateEndpoint: {
      subnetName: 'private-endpoints'
      vnetName: 'my-vnet'
      privateDnsZoneIds: ['/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com']
    }
    disableLocalAuth: true
  }
}
```

### Example 3: Foundry account with Application Insights and Key Vault

```bicep
module foundryAccount 'br/public:avm/res/cognitive-services/account:<version>' = {
  name: 'foundryAccountDeployment'
  params: {
    nameSuffix: 'myai'
    kind: 'AIServices'
    sku: 'S0'
    applicationLogging: {
      appInsightsName: 'my-appinsights'
      resourceGroupName: 'my-rg'
    }
    credentialStorage: {
      keyVaultName: 'my-keyvault'
      resourceGroupName: 'my-rg'
    }
    disableLocalAuth: true
  }
}
```

## Key Features

- **Multiple Account Types**: Support for various cognitive services kinds (AIServices, ComputerVision, Face, etc.)
- **Entra ID Authentication**: Optional enforcement of Entra ID-only authentication for enhanced security
- **Managed Identity Support**: System or user-assigned managed identities for authentication
- **Application Logging**: Optional Application Insights integration for monitoring
- **Credential Management**: Optional Key Vault integration for secure credential storage
- **Private Endpoint Support**: Secure private network connectivity
- **Firewall Rules**: IP-based access restrictions
- **Service Endpoint Integration**: Virtual network service endpoint support
- **Diagnostic Settings**: Optional diagnostic logging configuration

## Requirements

- Azure subscription with appropriate permissions
- For Entra ID-only authentication: Proper role assignments for service principals
- For private endpoint:
  - Configured virtual network and subnet
  - Private DNS zone for DNS resolution
- For Application Insights: Existing or new Application Insights resource
- For Key Vault: Existing or new Key Vault with appropriate access policies

## Best Practices

- Use Entra ID authentication instead of local keys for better security
- Implement private endpoints for sensitive workloads
- Integrate with Application Insights for comprehensive monitoring
- Use Key Vault for credential storage and rotation
- Apply appropriate resource tags for organization and cost tracking
- Configure network restrictions (IP rules or service endpoints) when required
- Use managed identities instead of storing credentials directly
- Enable diagnostic logging for production deployments
- Implement proper RBAC for resource access

## Notes

- Local authentication can be disabled to enforce Entra ID-only access
- API keys are automatically generated but only returned if local auth is enabled
- Some account kinds may have additional SKU constraints
- Private endpoint setup requires network infrastructure planning
- Application Insights integration requires network connectivity to the service
- Key Vault integration requires proper permissions on the vault

---

For more information, see [Azure Cognitive Services Documentation](https://learn.microsoft.com/en-us/azure/cognitive-services/) and [Foundry Account Reference](https://learn.microsoft.com/en-us/azure/ai-services/).

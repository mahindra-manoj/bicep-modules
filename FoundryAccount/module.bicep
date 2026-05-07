metadata name = 'Microsoft Foundry bicep module'

import { Identity, nameBuilder, PrivateEndpoint, VirtualNetworkRules } from '../utilities.bicep'

@description('Optional. Application insights resource that will be used for application logging. If this is not provided, this type of data is stored directly on the Foundry resource.')
param applicationLogging {
  @description('Name of the App Insights resource that will be used to montior Foundry workspace performance and usage.')
  appInsightsName: string
  @description('Optional. RG where the App insights resourcen will be created. Defaults to the rg where the foundry resource is deployed.')
  resourceGroupName: string?
  @description('Optional. Subscription GUID where the App insights resourcen will be created. Defaults to the subscription where the foundry resource is deployed.')
  subscriptionId: resourceInput<'Microsoft.Subscription/aliases@2025-11-01-preview'>.properties.subscriptionId?
}?

@description('Optional. Connections to be setup for the Foundry resource.')
param connections Connections?

@description('Optional. Key Vault resource that will be used to store Application Insights. If this is not provided, this type of data is stored directly on the Foundry resource.')
param credentialStorage {
  @description('Name of the Key vault resource that will be used to store credentials.')
  keyVaultName: string
  @description('Optional. RG where the key vault resides. Defaults to the resource group where the Foundry resource is deployed.')
  resourceGroupName: string?
  @description('Optional. Subscription GUID where the key vault resides. Defaults to the subscription where the Foundry resource is deployed.')
  subscriptionId: resourceInput<'Microsoft.Subscription/aliases@2025-11-01-preview'>.properties.subscriptionId?
}?

@description('Optional. Allow only Entra ID authentication. This should be enabled for security reasons. Defaults to `true`.')
param disableLocalAuth false | true = true

@description('Optional. Managed Identity type. If not provided, defaults to `SystemAssigned`.')
param identity Identity?

@description('Optional. List of public IP addresses  or CIDRs that can access the resource over public network.')
param ipRules string[]?

@description('Optional. Kind of the Cognitive Services account. Use \'Get-AzCognitiveServicesAccountSku\' to determine a valid combinations of \'kind\' and \'SKU\' for your Azure region. Defaults to `AIServices`.')
@allowed([
  'AIServices'
  'AnomalyDetector'
  'CognitiveServices'
  'ComputerVision'
  'ContentModerator'
  'ContentSafety'
  'ConversationalLanguageUnderstanding'
  'CustomVision.Prediction'
  'CustomVision.Training'
  'Face'
  'FormRecognizer'
  'HealthInsights'
  'ImmersiveReader'
  'Internal.AllInOne'
  'LUIS'
  'LUIS.Authoring'
  'LanguageAuthoring'
  'MetricsAdvisor'
  'OpenAI'
  'Personalizer'
  'QnAMaker.v2'
  'SpeechServices'
  'TextAnalytics'
  'TextTranslation'
])
param kind string = 'AIServices'

@description('Optional. Azure region where the Microsoft Foundry resource will be created. Defaults to the location of resource group where the resource is being deployed.')
param location string?

@secure()
@description('Optional. Resource migration token.')
param migrationToken string?

@description('Name suffix of the Microsoft Foundry resource.')
param nameSuffix string

@description('Optional. ')
param networkInjections resourceInput<'Microsoft.CognitiveServices/accounts@2026-01-15-preview'>.properties.networkInjections?

@description('Optional. Should be used only if a private endpoint needs to be created for the Foundry resource.')
param privateEndpoint PrivateEndpoint?

@description('Optional. Restore a soft-deleted cognitive service at deployment time. Will fail if no such soft-deleted resource exists.')
param restore false | true = false

@description('Optional. Restrict outbound network access.')
param restrictOutboundNetworkAccess bool = true

@description('Optional. SKU of the Cognitive Services account. Use \'Get-AzCognitiveServicesAccountSku\' to determine a valid combinations of \'kind\' and \'SKU\' for your Azure region. Defaults to `S0`.')
@allowed([
  'C2'
  'C3'
  'C4'
  'F0'
  'F1'
  'S'
  'S0'
  'S1'
  'S10'
  'S2'
  'S3'
  'S4'
  'S5'
  'S6'
  'S7'
  'S8'
  'S9'
  'DC0'
])
param sku string = 'S0'

@description('Optional. Storage accounts for this resource.')
param userOwnedStorageAccounts resourceInput<'Microsoft.CognitiveServices/accounts@2026-01-15-preview'>.properties.userOwnedStorage?

@description('Optional. List of Virtual networks that can access the resource using Service endpoints over Microsoft backbone network.')
param virtualNetworkRules VirtualNetworkRules?

var resourceName string = nameBuilder('foundryAccount', nameSuffix)

resource credential_kv 'Microsoft.KeyVault/vaults@2025-05-01' existing = if (!empty(credentialStorage ?? {})) {
  name: credentialStorage.?keyVaultName ?? 'foobar'
  scope: resourceGroup(
    credentialStorage.?subscriptionId ?? subscription().subscriptionId,
    credentialStorage.?resourceGroupName ?? resourceGroup().name
  )
}

resource logging_appi 'Microsoft.Insights/components@2020-02-02' existing = if (!empty(applicationLogging ?? {})) {
  name: applicationLogging.?appInsightsName ?? 'foobar'
  scope: resourceGroup(
    applicationLogging.?subscriptionId ?? subscription().subscriptionId,
    applicationLogging.?resourceGroupName ?? resourceGroup().name
  )
}

var defaultConnections Connections = !empty(credentialStorage ?? '') && !empty(applicationLogging ?? '')
  ? [
      {
        name: '${resourceName}-keyvault'
        properties: {
          category: 'AzureKeyVault'
          authType: 'AccountManagedIdentity'
          target: credential_kv.?id
          isSharedToAll: true
          metadata: {
            ApiType: 'Azure'
            ResourceId: credential_kv.?id
            location: resourceGroup().location
          }
        }
      }
      {
        name: '${resourceName}-appinsights'
        properties: {
          authType: 'ApiKey'
          credentials: {
            key: logging_appi.?properties.ConnectionString
          }
          category: 'AppInsights'
          useWorkspaceManagedIdentity: false
          target: logging_appi.?id
          isSharedToAll: true
          metadata: {
            ApiType: 'Azure'
            ResourceId: logging_appi.?id
          }
        }
      }
    ]
  : empty(credentialStorage ?? '') && !empty(applicationLogging ?? '')
      ? [
          {
            name: '${resourceName}-appinsights'
            properties: {
              authType: 'ApiKey'
              credentials: {
                key: logging_appi.?properties.ConnectionString
              }
              category: 'AppInsights'
              useWorkspaceManagedIdentity: false
              target: logging_appi.?id
              isSharedToAll: true
              metadata: {
                ApiType: 'Azure'
                ResourceId: logging_appi.?id
              }
            }
          }
        ]
      : empty(applicationLogging ?? '') && !empty(credentialStorage ?? '')
          ? [
              {
                name: '${resourceName}-keyvault'
                properties: {
                  category: 'AzureKeyVault'
                  authType: 'AccountManagedIdentity'
                  target: credential_kv.?id
                  isSharedToAll: true
                  metadata: {
                    ApiType: 'Azure'
                    ResourceId: credential_kv.?id
                  }
                }
              }
            ]
          : []

var allConnections Connections = union(defaultConnections, connections ?? [])

// Get Virtual Network subnet resides.
resource vnet_snet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = [
  for each in virtualNetworkRules! ?? []: {
    name: '${each.?vnetName ?? 'foo'}/${each.?subnetName ?? 'bar'}'
    scope: resourceGroup(
      each.?vnetSubscriptionId ?? subscription().subscriptionId,
      each.?vnetRGName ?? resourceGroup().name
    )
  }
]

@description('Create Microsoft Foundry resource.')
resource aif 'Microsoft.CognitiveServices/accounts@2025-12-01' = {
  name: resourceName
  location: location ?? resourceGroup().location
  kind: kind
  identity: identity ?? {
    type: 'SystemAssigned'
  }
  sku: {
    name: sku
  }
  properties: {
    allowProjectManagement: false
    customSubDomainName: resourceName
    disableLocalAuth: disableLocalAuth
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: !empty(ipRules) || !empty(virtualNetworkRules) ? 'Deny' : 'Allow'
      ipRules: [
        for each in ipRules ?? []: {
          value: each
        }
      ]
      virtualNetworkRules: [
        for (each, i) in virtualNetworkRules ?? []: {
          id: vnet_snet[i].?id
        }
      ]
    }
    dynamicThrottlingEnabled: false
    publicNetworkAccess: !empty(privateEndpoint) && (empty(ipRules) && empty(virtualNetworkRules))
      ? 'Disabled'
      : 'Enabled'
    restore: restore
    networkInjections: networkInjections
    migrationToken: migrationToken
    restrictOutboundNetworkAccess: restrictOutboundNetworkAccess
    userOwnedStorage: userOwnedStorageAccounts
  }
}

module foundry_identity_kvrbac '../KeyVaultRBAC/module.bicep' = if (!empty(credentialStorage ?? {})) {
  params: {
    keyVaultName: credential_kv.?name!
    roleAssignments: [
      {
        principalType: 'ServicePrincipal'
        roleName: 'Key Vault Secrets Officer'
        principalId: aif.identity.principalId
      }
    ]
  }
}

module foundry_connections 'connections.bicep' = if (!empty(connections ?? []) || (!empty(credentialStorage ?? {}) || !empty(applicationLogging ?? {}))) {
  dependsOn: [
    foundry_identity_kvrbac
  ]
  params: {
    connections: allConnections
    foundryAccountName: aif.name
  }
}

type Connections = {
  name: string
  properties: resourceInput<'Microsoft.CognitiveServices/accounts/connections@2025-12-01'>.properties
}[]

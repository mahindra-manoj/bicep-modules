metadata name = 'Bicep module to create Connections for a Foundry account.'

param connections Connections

param foundryAccountName string

resource foundry_account 'Microsoft.CognitiveServices/accounts@2026-01-15-preview' existing = {
  name: foundryAccountName
}

@batchSize(1)
@description('Connections to be created for the Foundry resource.')
resource foundry_connection 'Microsoft.CognitiveServices/accounts/connections@2025-12-01' = [
  for each in connections! ?? []: {
    name: each.?name
    parent: foundry_account
    properties: each.properties
  }
]

type Connections = {
  name: string
  properties: resourceInput<'Microsoft.CognitiveServices/accounts/connections@2025-12-01'>.properties
}[]


//InstrumentationKey=c9520400-3297-4f09-83bd-94ce82cde6b0;IngestionEndpoint=https://canadacentral-1.in.applicationinsights.azure.com/;LiveEndpoint=https://canadacentral.livediagnostics.monitor.azure.com/;ApplicationId=fb49bf0b-fb47-4923-bd2d-0739615ea1e2

//InstrumentationKey=c9520400-3297-4f09-83bd-94ce82cde6b0;IngestionEndpoint=https://canadacentral-1.in.applicationinsights.azure.com/;LiveEndpoint=https://canadacentral.livediagnostics.monitor.azure.com/;ApplicationId=fb49bf0b-fb47-4923-bd2d-0739615ea1e2

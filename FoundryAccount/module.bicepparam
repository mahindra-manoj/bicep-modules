using './module.bicep'


param nameSuffix = 'mahind-foobar'

param applicationLogging = {
  appInsightsName: 'appi'
}
param credentialStorage = {
  keyVaultName: 'kv-mahi-foobarr'
}

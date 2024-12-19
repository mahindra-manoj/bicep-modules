using './module.bicep'

param accessPolicies = []
param enablePurgeProtection = false
param nameSuffix = 'mahiz'
param newOrExisting = 'existing'
param privateDnsZoneResourceId = ''
param sku = 'standard'

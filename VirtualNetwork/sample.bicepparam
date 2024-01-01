using './vnet.bicep'

param cidr = '10.0.0.0/24'
param namePrefix = 'Test-vnet'
param tags = {
  App: 'Test'
  Env: 'Dev'
}

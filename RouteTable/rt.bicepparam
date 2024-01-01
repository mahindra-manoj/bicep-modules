using './rt.bicep'

param routeTableConfig = {
  name: 'mahirt'
  location: 'CanadaCentral'
  disableRoutePropogation: false
}
param tags = {
  App: 'Mahi'
  CostCenter: '0007'
  Env: 'Dev'
  Portfolio: 'Mah'
}

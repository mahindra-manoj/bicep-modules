using './module.bicep'

param name = ''
param virtualNetworks = [
  {
    name: 'vnet-demo'
  }
  {
    name: 'vnet-demo2'
    //resourceGroup: 'rg-demo2' //optional. Needed only when the vnet resides in an rg other than the one where the private dns zone is being deployed to
  }
]

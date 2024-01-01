test vnet 'module.bicep' = {
  params: {
    cidr: '10.0.0.0/24'
    namePrefix: 'test'
    location: 'CanadaCentral'
  }
}

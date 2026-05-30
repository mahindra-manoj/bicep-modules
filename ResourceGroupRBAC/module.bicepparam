using './module.bicep'

param roleAssignments = [
  {
    principalType: 'Group'
    roleName: 'Key Vault Secrets User'
    principalName: 'FOOBAR'
  }
]

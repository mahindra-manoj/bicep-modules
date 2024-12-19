using './module.bicep'

param apiPermissions = [
  {
    appName: 'Dynamics CRM'
    permissions: [
      {
        name: 'user_impersonation'
        type: 'Delegated'
      }
    ]
  }
  {
    appName: 'Dynamics ERP'
    permissions: [
      {
        name: 'AX.FullAccess'
        type: 'Delegated'
      }
      {
        name: 'CustomService.FullAccess'
        type: 'Delegated'
      }
      {
        name: 'Odata.FullAccess'
        type: 'Delegated'
      }
    ]
  }
]
param name = 'mahiz-appreg-module-app'
param clientSecretName = ''

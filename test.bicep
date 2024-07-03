provider microsoftGraph

resource appregi 'Microsoft.Graph/applications@v1.0' = {
  displayName: 'lavda'
  uniqueName: 'lavda'
  spa: {
    redirectUris: [
      'https://lavada.com'
    ]
  }
  signInAudience: 'AzureADMyOrg'
  web: {
    implicitGrantSettings: {
      enableAccessTokenIssuance: true
      enableIdTokenIssuance: true
    }
  }
  keyCredentials: [
    {
      
    }
  ]
  passwordCredentials: [
    {
      keyId:
      displayName: 'testbicepmodule'
    }
  ]
}

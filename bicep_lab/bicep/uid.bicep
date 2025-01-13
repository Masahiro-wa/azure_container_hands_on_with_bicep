param acr_name string
param id_name string
param location string

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acr_name
  scope: resourceGroup()
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: id_name
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, userAssignedIdentity.id, 'AcrPush')
  scope: acr
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  }
}

output identityResourceName string = userAssignedIdentity.name

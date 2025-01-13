param acr_name string
param docker_image string
param containerapps_env_name string
param ai_connection_string string
param frontend_id_name string
param location string = resourceGroup().location

resource containerappsEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerapps_env_name
  scope: resourceGroup()
}

module roleAssign 'uid.bicep' = {
  name: 'roleAssign'
  params: {
    location: location
    acr_name: acr_name
    id_name: frontend_id_name
  }
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: frontend_id_name
  scope: resourceGroup()
}

resource backendApi 'Microsoft.App/containerApps@2023-05-01' existing = {
  name: 'backend'
  scope: resourceGroup()
}

resource frontendApp 'Microsoft.App/containerApps@2023-05-01' = {
  dependsOn: [
    roleAssign
  ]
  name: 'frontend'
  location: location
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerappsEnv.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 3000
      }
      registries: [
        {
          identity: userAssignedIdentity.id
          server: '${acr_name}.azurecr.io'
        }
      ]
      secrets: [
        {
          name: 'ai-connection-string'
          value: ai_connection_string
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'frontend'
          image: docker_image
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'REACT_APP_APPINSIGHTS_CONNECTION_STRING'
              secretRef: 'ai-connection-string'
            }
            {
              name: 'REACT_APP_BACKEND_API_URL'
              value: 'https://${backendApi.properties.configuration.ingress.fqdn}/api/v1'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}

output frontFqdn string = frontendApp.properties.configuration.ingress.fqdn

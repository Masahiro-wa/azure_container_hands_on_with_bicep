param containerapps_env_name string
param acr_name string
param ai_connection_string string
param docker_image string
param scheduler_id_name string
param location string = resourceGroup().location

module roleAssign 'uid.bicep' = {
  name: 'roleAssign'
  params: {
    location: location
    acr_name: acr_name
    id_name: scheduler_id_name 
  }
}

resource containerappsEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerapps_env_name
  scope: resourceGroup()
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: scheduler_id_name 
  scope: resourceGroup()
}

resource scheduleApp 'Microsoft.App/containerApps@2023-05-01' = {
  dependsOn: [
    roleAssign
  ]
  name: 'scheduler'
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
        targetPort: 8083
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
          name: 'scheduler'
          image: docker_image
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              secretRef: 'ai-connection-string'
            }
          ]
        }
      ]
      scale: {
        maxReplicas: 2
        minReplicas: 1
      }
    }
  }
}

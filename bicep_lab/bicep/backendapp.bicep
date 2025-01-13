param containerapps_env_name string
param acr_name string
param keyvault_name string
param ai_connection_string string
param docker_image string
param backend_id_name string
param location string = resourceGroup().location

resource containerappsEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerapps_env_name
  scope: resourceGroup()
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyvault_name
  scope: resourceGroup()
}

resource scheduleApi 'Microsoft.App/containerApps@2023-05-01' existing = {
  name: 'scheduler'
  scope: resourceGroup()
}

module roleAssign 'uid.bicep' = {
  name: 'roleAssign'
  params: {
    location: location
    acr_name: acr_name
    id_name: backend_id_name
  }
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: backend_id_name
  scope: resourceGroup()
}

resource backendApp 'Microsoft.App/containerApps@2023-05-01' = {
  dependsOn: [
    roleAssign
  ]
  name: 'backend'
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
        targetPort: 8080
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
          name: 'backend'
          image: docker_image
          // K8sとは異なりここでリソース制限は設定できない
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              secretRef: 'ai-connection-string'
            }
            {
              name: 'schedule.api.url'
              value: 'https://${scheduleApi.properties.configuration.ingress.fqdn}/schedule'
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

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: backendApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

output appFqdn string = backendApp.properties.configuration.ingress.fqdn

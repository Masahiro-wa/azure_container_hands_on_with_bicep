param log_analytics_name string
param app_insights_name string
param containerapps_env_name string
param location string = resourceGroup().location

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: log_analytics_name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsightsComponent 'Microsoft.Insights/components@2020-02-02' = {
  name: app_insights_name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource containerappsEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: containerapps_env_name
  location: location
  properties: {
    appLogsConfiguration:{
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
        // 以下のキー取得方法はworkspace@2022-100-01ではサポートされていないので最新版を使用
        // customerId: reference(logAnalyticsWorkspace, '2020-02-02').InstrumentationKey
        // sharedKey: reference(logAnalyticsWorkspace, '2020-06-01').primarySharedKey
      }
    }
  }
}

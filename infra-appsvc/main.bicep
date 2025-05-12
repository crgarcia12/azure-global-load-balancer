param prefix string
param location string = resourceGroup().location // Location for all resources
param containerName string

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: toLower(replace('${prefix}acr', '-', ''))
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${prefix}-plan'
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'B1'
  }
  kind: 'linux'
}

resource webApp 'Microsoft.Web/sites@2021-01-01' = {
  name: '${prefix}-app'
  location: location
  tags: {}
  properties: {
    siteConfig: {
      appSettings: []
      linuxFxVersion: 'DOCKER|${containerName}'
    }
    serverFarmId: appServicePlan.id
  }
}

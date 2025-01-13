param vnet_name string
param vnet_cidr string
param dev_subnet_name string
param dev_subnet_cidr string
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name: vnet_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_cidr
      ]
    }
    subnets: [
      {
        name: dev_subnet_name
        properties: {
          addressPrefix: dev_subnet_cidr
        }
      }
    ]
  }
}

output vnet_id string = vnet.id
output vnet_name string = vnet.name
output subnet_id string = vnet.properties.subnets[0].id
output subnet_name string = vnet.properties.subnets[0].name

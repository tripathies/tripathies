resource "azurerm_virtual_network" "workload" {
  name                = local.names.vnet
  location            = azurerm_resource_group.workload.location
  resource_group_name = azurerm_resource_group.workload.name
  address_space       = ["10.70.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "app_integration" {
  name                 = "snet-app-integration"
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.workload.name
  address_prefixes     = ["10.70.1.0/26"]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "function_integration" {
  name                 = "snet-functions-integration"
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.workload.name
  address_prefixes     = ["10.70.2.0/27"]

  delegation {
    name = "functions-flex-delegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.workload.name
  address_prefixes     = ["10.70.3.0/24"]
}

resource "azurerm_subnet" "test_vm" {
  name                 = "snet-test-vm"
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.workload.name
  address_prefixes     = ["10.70.4.0/24"]
}

resource "azurerm_private_dns_zone" "websites" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.workload.name
  tags                = local.tags
}
resource "azurerm_private_dns_zone" "cosmos" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.workload.name
  tags                = local.tags
}
resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.workload.name
  tags                = local.tags
}
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.workload.name
  tags                = local.tags
}
resource "azurerm_private_dns_zone" "queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.workload.name
  tags                = local.tags
}
resource "azurerm_private_dns_zone" "table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.workload.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "websites" {
  name                  = "link-websites"
  resource_group_name   = azurerm_resource_group.workload.name
  private_dns_zone_name = azurerm_private_dns_zone.websites.name
  virtual_network_id    = azurerm_virtual_network.workload.id
  registration_enabled = false
}
resource "azurerm_private_dns_zone_virtual_network_link" "cosmos" {
  name                  = "link-cosmos"
  resource_group_name   = azurerm_resource_group.workload.name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos.name
  virtual_network_id    = azurerm_virtual_network.workload.id
  registration_enabled = false
}
resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "link-keyvault"
  resource_group_name   = azurerm_resource_group.workload.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.workload.id
  registration_enabled = false
}
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "link-blob"
  resource_group_name   = azurerm_resource_group.workload.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.workload.id
  registration_enabled = false
}
resource "azurerm_private_dns_zone_virtual_network_link" "queue" {
  name                  = "link-queue"
  resource_group_name   = azurerm_resource_group.workload.name
  private_dns_zone_name = azurerm_private_dns_zone.queue.name
  virtual_network_id    = azurerm_virtual_network.workload.id
  registration_enabled = false
}
resource "azurerm_private_dns_zone_virtual_network_link" "table" {
  name                  = "link-table"
  resource_group_name   = azurerm_resource_group.workload.name
  private_dns_zone_name = azurerm_private_dns_zone.table.name
  virtual_network_id    = azurerm_virtual_network.workload.id
  registration_enabled = false
}

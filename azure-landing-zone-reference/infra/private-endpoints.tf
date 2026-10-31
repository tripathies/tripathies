resource "azurerm_private_endpoint" "web_app" {
  name                = format("pe-web-%s", local.suffix)
  location            = azurerm_resource_group.workload.location
  resource_group_name = azurerm_resource_group.workload.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = format("psc-web-%s", local.suffix)
    private_connection_resource_id = azurerm_linux_web_app.storefront.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.websites.id]
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "function_app" {
  name                = format("pe-function-%s", local.suffix)
  location            = azurerm_resource_group.workload.location
  resource_group_name = azurerm_resource_group.workload.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = format("psc-function-%s", local.suffix)
    private_connection_resource_id = azurerm_function_app_flex_consumption.orders.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.websites.id]
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "cosmos" {
  name                = format("pe-cosmos-%s", local.suffix)
  location            = azurerm_resource_group.workload.location
  resource_group_name = azurerm_resource_group.workload.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = format("psc-cosmos-%s", local.suffix)
    private_connection_resource_id = azurerm_cosmosdb_account.workload.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.cosmos.id]
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "key_vault" {
  name                = format("pe-keyvault-%s", local.suffix)
  location            = azurerm_resource_group.workload.location
  resource_group_name = azurerm_resource_group.workload.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = format("psc-keyvault-%s", local.suffix)
    private_connection_resource_id = azurerm_key_vault.workload.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "storage_blob" {
  name                = format("pe-blob-%s", local.suffix)
  location            = azurerm_resource_group.workload.location
  resource_group_name = azurerm_resource_group.workload.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = format("psc-blob-%s", local.suffix)
    private_connection_resource_id = azurerm_storage_account.workload.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "storage_queue" {
  name                = format("pe-queue-%s", local.suffix)
  location            = azurerm_resource_group.workload.location
  resource_group_name = azurerm_resource_group.workload.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = format("psc-queue-%s", local.suffix)
    private_connection_resource_id = azurerm_storage_account.workload.id
    subresource_names              = ["queue"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.queue.id]
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "storage_table" {
  name                = format("pe-table-%s", local.suffix)
  location            = azurerm_resource_group.workload.location
  resource_group_name = azurerm_resource_group.workload.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = format("psc-table-%s", local.suffix)
    private_connection_resource_id = azurerm_storage_account.workload.id
    subresource_names              = ["table"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.table.id]
  }

  tags = local.tags
}

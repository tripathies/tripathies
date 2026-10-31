data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "workload" {
  name                            = local.names.storage
  resource_group_name             = azurerm_resource_group.workload.name
  location                        = azurerm_resource_group.workload.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  allow_nested_items_to_be_public = false
  network_rules {
    default_action = "Deny"
    bypass         = ["None"]
    ip_rules       = [var.terraform_runner_public_ip]
  }
  blob_properties {
    versioning_enabled = true
  }
  tags = local.tags
}
resource "azurerm_storage_container" "function_package" {
  name                  = "function-package"
  storage_account_id    = azurerm_storage_account.workload.id
  container_access_type = "private"
}
resource "azurerm_storage_queue" "orders" {
  name                 = "orders"
  storage_account_name = azurerm_storage_account.workload.name
}
resource "azurerm_cosmosdb_account" "workload" {
  name                          = local.names.cosmos
  location                      = azurerm_resource_group.workload.location
  resource_group_name           = azurerm_resource_group.workload.name
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  free_tier_enabled             = var.enable_cosmos_free_tier
  public_network_access_enabled = false
  automatic_failover_enabled    = false
  multiple_write_locations_enabled = false
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = azurerm_resource_group.workload.location
    failover_priority = 0
  }
  tags = local.tags
}
resource "azurerm_cosmosdb_sql_database" "workload" {
  name                = "littlenest"
  resource_group_name = azurerm_resource_group.workload.name
  account_name        = azurerm_cosmosdb_account.workload.name
  throughput          = 400
}
resource "azurerm_cosmosdb_sql_container" "products" {
  name                  = "products"
  resource_group_name   = azurerm_resource_group.workload.name
  account_name          = azurerm_cosmosdb_account.workload.name
  database_name         = azurerm_cosmosdb_sql_database.workload.name
  partition_key_paths   = ["/id"]
  partition_key_version = 2
}
resource "azurerm_cosmosdb_sql_container" "orders" {
  name                  = "orders"
  resource_group_name   = azurerm_resource_group.workload.name
  account_name          = azurerm_cosmosdb_account.workload.name
  database_name         = azurerm_cosmosdb_sql_database.workload.name
  partition_key_paths   = ["/id"]
  partition_key_version = 2
}
resource "azurerm_key_vault" "workload" {
  name                          = local.names.key_vault
  location                      = azurerm_resource_group.workload.location
  resource_group_name           = azurerm_resource_group.workload.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization      = true
  soft_delete_retention_days     = 7
  purge_protection_enabled      = true
  public_network_access_enabled = false
  tags = local.tags
}

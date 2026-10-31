# App Service identity: read product/order data, read optional Key Vault secrets,
# and enqueue an order message. Control-plane Contributor is not granted.
resource "azurerm_cosmosdb_sql_role_assignment" "web_app_data" {
  resource_group_name = azurerm_resource_group.workload.name
  account_name        = azurerm_cosmosdb_account.workload.name
  role_definition_id  = format("%s/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002", azurerm_cosmosdb_account.workload.id)
  principal_id        = azurerm_linux_web_app.storefront.identity[0].principal_id
  scope               = format("%s/dbs/%s", azurerm_cosmosdb_account.workload.id, azurerm_cosmosdb_sql_database.workload.name)
}

resource "azurerm_role_assignment" "web_app_key_vault_secrets" {
  scope                = azurerm_key_vault.workload.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.storefront.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "web_app_queue_sender" {
  scope                = azurerm_storage_account.workload.id
  role_definition_name = "Storage Queue Data Message Sender"
  principal_id         = azurerm_linux_web_app.storefront.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

# Function identity: operate the queue trigger and update the sample order record.
# Flex host storage uses Blob, Queue and Table data-plane permissions.
resource "azurerm_cosmosdb_sql_role_assignment" "function_data" {
  resource_group_name = azurerm_resource_group.workload.name
  account_name        = azurerm_cosmosdb_account.workload.name
  role_definition_id  = format("%s/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002", azurerm_cosmosdb_account.workload.id)
  principal_id        = azurerm_function_app_flex_consumption.orders.identity[0].principal_id
  scope               = format("%s/dbs/%s", azurerm_cosmosdb_account.workload.id, azurerm_cosmosdb_sql_database.workload.name)
}

resource "azurerm_role_assignment" "function_blob_owner" {
  scope                = azurerm_storage_account.workload.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_function_app_flex_consumption.orders.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "function_queue_contributor" {
  scope                = azurerm_storage_account.workload.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_function_app_flex_consumption.orders.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "function_table_contributor" {
  scope                = azurerm_storage_account.workload.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_function_app_flex_consumption.orders.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

# Flex Consumption host storage additionally needs this management-plane role.
resource "azurerm_role_assignment" "function_storage_account_contributor" {
  scope                = azurerm_storage_account.workload.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_function_app_flex_consumption.orders.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

# The Terraform caller needs to seed the demo catalogue and validate Cosmos access.
# Scope is limited to the LittleNest database rather than the whole account.
resource "azurerm_cosmosdb_sql_role_assignment" "deployer_data" {
  resource_group_name = azurerm_resource_group.workload.name
  account_name        = azurerm_cosmosdb_account.workload.name
  role_definition_id  = format("%s/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002", azurerm_cosmosdb_account.workload.id)
  principal_id        = data.azurerm_client_config.current.object_id
  scope               = format("%s/dbs/%s", azurerm_cosmosdb_account.workload.id, azurerm_cosmosdb_sql_database.workload.name)
}

# Optional Key Vault exercise: the Terraform caller can add a synthetic banner secret.
resource "azurerm_role_assignment" "deployer_key_vault_secrets_officer" {
  scope                = azurerm_key_vault.workload.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = var.deployer_principal_type
}

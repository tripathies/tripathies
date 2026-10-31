output "resource_group_name" {
  value = azurerm_resource_group.workload.name
}

output "location" {
  value = azurerm_resource_group.workload.location
}

output "vnet_name" {
  value = azurerm_virtual_network.workload.name
}

output "web_app_name" {
  value = azurerm_linux_web_app.storefront.name
}

output "web_app_private_hostname" {
  description = "Private App Service hostname. Reachable only from a network connected to the VNet."
  value       = azurerm_linux_web_app.storefront.default_hostname
}

output "function_app_name" {
  value = azurerm_function_app_flex_consumption.orders.name
}

output "cosmos_account_endpoint" {
  value = azurerm_cosmosdb_account.workload.endpoint
}

output "key_vault_uri" {
  value = azurerm_key_vault.workload.vault_uri
}

output "storage_account_name" {
  value = azurerm_storage_account.workload.name
}

output "optional_test_vm_id" {
  value = var.vm_enabled ? azurerm_linux_virtual_machine.test_vm[0].id : null
}

output "private_network_access_note" {
  value = "Public network access is disabled for App Service, Functions, Cosmos DB and Key Vault. Storage has a firewall-denied public endpoint with only the configured Terraform runner IPv4 address allowed; workload traffic uses Private Endpoints and managed identity."
}

output "storage_account_id" {
  value = azurerm_storage_account.workload.id
}

output "key_vault_name" {
  value = azurerm_key_vault.workload.name
}

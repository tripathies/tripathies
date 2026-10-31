resource "azurerm_service_plan" "web" {
  name                = local.names.web_plan
  resource_group_name = azurerm_resource_group.workload.name
  location            = azurerm_resource_group.workload.location
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = local.tags
}

resource "azurerm_linux_web_app" "storefront" {
  name                          = local.names.web_app
  resource_group_name           = azurerm_resource_group.workload.name
  location                      = azurerm_resource_group.workload.location
  service_plan_id               = azurerm_service_plan.web.id
  https_only                    = true
  public_network_access_enabled = false
  virtual_network_subnet_id     = azurerm_subnet.app_integration.id
  ftp_publish_basic_authentication_enabled  = false
  webdeploy_publish_basic_authentication_enabled = false

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = true
    ftps_state = "Disabled"
    application_stack {
      node_version = "22-lts"
    }
  }

  app_settings = {
    NODE_ENV                   = "production"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
    LOCAL_DEMO_MODE            = "false"
    COSMOS_ENDPOINT            = azurerm_cosmosdb_account.workload.endpoint
    COSMOS_DATABASE            = azurerm_cosmosdb_sql_database.workload.name
    COSMOS_PRODUCTS_CONTAINER  = azurerm_cosmosdb_sql_container.products.name
    COSMOS_ORDERS_CONTAINER    = azurerm_cosmosdb_sql_container.orders.name
    KEY_VAULT_URL              = azurerm_key_vault.workload.vault_uri
    STORAGE_ACCOUNT_NAME       = azurerm_storage_account.workload.name
    ORDERS_QUEUE_NAME          = azurerm_storage_queue.orders.name
  }

  tags = local.tags

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.websites
  ]
}

resource "azurerm_service_plan" "functions" {
  name                = local.names.function_plan
  resource_group_name = azurerm_resource_group.workload.name
  location            = azurerm_resource_group.workload.location
  os_type             = "Linux"
  sku_name            = "FC1"
  tags                = local.tags
}

resource "azurerm_function_app_flex_consumption" "orders" {
  name                = local.names.function_app
  resource_group_name = azurerm_resource_group.workload.name
  location            = azurerm_resource_group.workload.location
  service_plan_id     = azurerm_service_plan.functions.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = format("%s/%s", trimsuffix(azurerm_storage_account.workload.primary_blob_endpoint, "/"), azurerm_storage_container.function_package.name)
  storage_authentication_type = "SystemAssignedIdentity"
  runtime_name                = "node"
  runtime_version             = "22"
  maximum_instance_count      = 2
  instance_memory_in_mb       = 2048
  virtual_network_subnet_id   = azurerm_subnet.function_integration.id
  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    AzureWebJobsStorage__accountName      = azurerm_storage_account.workload.name
    AzureWebJobsStorage__credential       = "managedidentity"
    OrdersQueue__queueServiceUri          = format("https://%s.queue.core.windows.net", azurerm_storage_account.workload.name)
    OrdersQueue__credential               = "managedidentity"
    ORDERS_QUEUE_NAME                     = azurerm_storage_queue.orders.name
    COSMOS_ENDPOINT                       = azurerm_cosmosdb_account.workload.endpoint
    COSMOS_DATABASE                       = azurerm_cosmosdb_sql_database.workload.name
    COSMOS_ORDERS_CONTAINER               = azurerm_cosmosdb_sql_container.orders.name
  }

  site_config {}

  tags = local.tags

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.websites,
    azurerm_private_dns_zone_virtual_network_link.blob,
    azurerm_private_dns_zone_virtual_network_link.queue,
    azurerm_private_dns_zone_virtual_network_link.table
  ]
}

resource "azurerm_network_interface" "test_vm" {
  count               = var.vm_enabled ? 1 : 0
  name                = format("nic-test-%s", local.suffix)
  location            = azurerm_resource_group.workload.location
  resource_group_name = azurerm_resource_group.workload.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test_vm.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

resource "azurerm_linux_virtual_machine" "test_vm" {
  count               = var.vm_enabled ? 1 : 0
  name                = format("vm-test-%s", local.suffix)
  resource_group_name = azurerm_resource_group.workload.name
  location            = azurerm_resource_group.workload.location
  size                = var.vm_size
  admin_username      = "azureuser"
  disable_password_authentication = true
  network_interface_ids = [azurerm_network_interface.test_vm[0].id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.vm_admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = local.tags
}

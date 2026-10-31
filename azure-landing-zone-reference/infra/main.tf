resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}
locals {
  suffix = random_string.suffix.result
  names = {
    resource_group = format("rg-%s-%s-%s", var.project, var.environment, local.suffix)
    vnet           = format("vnet-%s-%s", var.project, local.suffix)
    web_plan       = format("asp-%s-web-%s", var.project, local.suffix)
    function_plan  = format("asp-%s-fn-%s", var.project, local.suffix)
    web_app        = format("app-%s-%s", var.project, local.suffix)
    function_app   = format("func-%s-%s", var.project, local.suffix)
    cosmos         = format("cosmos-%s-%s", var.project, local.suffix)
    key_vault      = format("kv-%s-%s", var.project, local.suffix)
    storage        = format("st%s%s", replace(var.project, "-", ""), local.suffix)
  }
  tags = merge({
    application        = var.project
    environment        = var.environment
    owner              = var.owner
    costCenter         = var.cost_center
    managedBy          = "Terraform"
    dataClassification = "synthetic"
    workload           = "kidswear-demo"
  }, var.additional_tags)
}
resource "azurerm_resource_group" "workload" {
  name     = local.names.resource_group
  location = var.location
  tags     = local.tags
}

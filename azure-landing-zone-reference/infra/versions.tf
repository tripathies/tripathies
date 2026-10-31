terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.66.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.6.3"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id   = var.subscription_id
  storage_use_azuread = true
}

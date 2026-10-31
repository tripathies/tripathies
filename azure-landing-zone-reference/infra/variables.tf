variable "subscription_id" {
  description = "Exact non-production subscription ID. Never rely only on the current CLI subscription."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "subscription_id must be a subscription GUID."
  }
}
variable "location" {
  description = "Azure region. Verify Flex Consumption regional availability before deployment."
  type        = string
  default     = "centralindia"
}
variable "project" {
  description = "Short lowercase project prefix used in resource names."
  type        = string
  default     = "littlenest"
  validation {
    condition     = can(regex("^[a-z0-9-]{3,16}$", var.project))
    error_message = "project must be 3-16 lowercase letters, numbers or hyphens."
  }
}
variable "environment" {
  description = "Workload environment."
  type        = string
  default     = "nonprod"
  validation {
    condition     = contains(["dev", "test", "nonprod"], var.environment)
    error_message = "Profile A only supports dev, test or nonprod."
  }
}
variable "owner" {
  description = "Workload owner tag."
  type        = string
  default     = "lab-owner"
}
variable "cost_center" {
  description = "Cost centre tag."
  type        = string
  default     = "learning"
}
variable "enable_cosmos_free_tier" {
  description = "Request Cosmos DB Free Tier. Only one eligible Free Tier account is allowed per subscription."
  type        = bool
  default     = true
}
variable "vm_enabled" {
  description = "Create a small private test VM. Disabled by default to avoid idle compute charges."
  type        = bool
  default     = false
}
variable "vm_admin_ssh_public_key" {
  description = "SSH public key for the optional private Linux test VM. Never supply a private key."
  type        = string
  default     = ""
  validation {
    condition     = !var.vm_enabled || length(trimspace(var.vm_admin_ssh_public_key)) > 0
    error_message = "Set vm_admin_ssh_public_key when vm_enabled is true."
  }
}
variable "vm_size" {
  description = "Optional private test VM size. Availability and price vary by region."
  type        = string
  default     = "Standard_B1s"
}
variable "additional_tags" {
  description = "Additional organisation-approved tags."
  type        = map(string)
  default     = {}
}

variable "terraform_runner_public_ip" {
  description = "The public IPv4 address seen by Azure Storage for the Terraform workstation. Supply the address without a CIDR suffix."
  type        = string

  validation {
    condition     = can(cidrnetmask("${var.terraform_runner_public_ip}/32"))
    error_message = "terraform_runner_public_ip must be a valid IPv4 address without a CIDR suffix."
  }
}

variable "deployer_principal_type" {
  description = "Principal type for the Terraform caller in Azure RBAC: User for az login, ServicePrincipal for CI/CD."
  type        = string
  default     = "User"

  validation {
    condition     = contains(["User", "ServicePrincipal"], var.deployer_principal_type)
    error_message = "deployer_principal_type must be User or ServicePrincipal."
  }
}

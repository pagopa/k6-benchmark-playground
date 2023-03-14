#
# Variables
#

variable "vnet_common_rg" {
  type        = string
  description = "Common Virtual network resource group name."
  default     = ""
}

variable "vnet_name" {
  type        = string
  description = "Common Virtual network resource name."
  default     = ""
}

variable "cidr_subnet" {
  type        = string
  description = "Subnet address space."
}

#
# External dependency
#

data "azurerm_resource_group" "vnet_common_rg" {
  name = var.vnet_common_rg
}

data "azurerm_virtual_network" "vnet_common" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.vnet_common_rg.name
}

data "azurerm_subnet" "private_endpoints_subnet" {
  count = var.env_short == "p" ? 1 : 0

  name                 = "pendpoints"
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_common_rg
}

data "azurerm_private_dns_zone" "privatelink_documents_azure_com" {
  count = var.env_short == "p" ? 1 : 0

  name                = "privatelink.documents.azure.com"
  resource_group_name = var.vnet_common_rg
}

#
# SNET definition
#

module "app_snet" {
  source               = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=v5.2.0"
  name                 = format("%s-%s-snet", local.project, var.application_basename)
  address_prefixes     = [var.cidr_subnet]
  resource_group_name  = data.azurerm_resource_group.vnet_common_rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet_common.name

  service_endpoints = [
    "Microsoft.Web",
    "Microsoft.AzureCosmosDB",
    "Microsoft.Storage",
  ]

  delegation = {
    name = "default"
    service_delegation = {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

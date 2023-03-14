resource "azurerm_resource_group" "rg" {
  name     = format("%s-rg", local.project)
  location = var.location

  tags = var.tags
}

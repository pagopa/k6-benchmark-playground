resource "random_uuid" "db_password" {}


module "db" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//postgres_flexible_server?ref=v5.2.0"

  name                = "${local.project}-db-postgresql"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login    = replace("${local.project}_user", "-", "")
  administrator_password = random_uuid.db_password.result

  sku_name                     = "GP_Standard_D2s_v3"
  db_version                   = 13
  geo_redundant_backup_enabled = true

  private_endpoint_enabled = false
  #private_dns_zone_id      = data.azurerm_private_dns_zone.privatelink_documents_azure_com.id
  delegated_subnet_id = module.app_snet.id

  high_availability_enabled = false

  pgbouncer_enabled = true

  storage_mb = 32768 # 32GB

  alerts_enabled = false

  diagnostic_settings_enabled = false

  tags = var.tags
}

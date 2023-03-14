resource "azurerm_service_plan" "app_docker" {

  name                = "${local.project}-plan-app-service-docker"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = "P1v2"

  tags = var.tags
}

module "webapp" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//app_service?ref=v6.0.0"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  plan_type = "external"
  plan_id   = azurerm_service_plan.app_docker.id

  # App service plan
  name                = "${local.project}-app-service-docker"
  client_cert_enabled = false
  always_on           = false
  docker_image        = "postgrest/postgrest"
  docker_image_tag    = "latest"

  health_check_path = "/"
  sku_name          = "P1v2"

  app_settings = {
    PGRST_DB_URI = format("postgres://%s:%s@%s:%s/%s",
      module.db.administrator_login,
      module.db.administrator_password,
      module.db.fqdn,
      module.db.connection_port,
      "app_db"
    )
    PGRST_DB_SCHEMAS = "servicecatalog"
    #PGRST_OPENAPI_SERVER_PROXY_URI: http://127.0.0.1:$SERVER_PORT
    PGRST_DB_ANON_ROLE = module.db.administrator_login
    PGRST_DB_MAX_ROWS  = 100

    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    WEBSITES_PORT                       = 8000
  }

  allowed_ips = []

  subnet_id = module.app_snet.id

  allowed_subnets = [
    module.app_snet.id,
    module.db_snet.id,
  ]

  tags = var.tags
}

#
# Role assignments
#
# resource "azurerm_role_assignment" "webapp_docker_to_acr" {
#   count = var.is_web_app_service_docker_enabled ? 1 : 0

#   scope                = data.azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = module.web_app_service_docker[0].principal_id
# }

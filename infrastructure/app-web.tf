module "template_app_web" {
  #checkov:skip=CKV_TF_1: Use of commit hash are not required for our Terraform modules
  source = "github.com/Planning-Inspectorate/infrastructure-modules.git//modules/node-app-service?ref=1.53"

  resource_group_name = azurerm_resource_group.primary.name
  location            = module.primary_region.location

  # naming
  app_name        = "web"
  resource_suffix = var.environment
  service_name    = local.service_name
  tags            = local.tags

  # service plan
  app_service_plan_id                  = azurerm_service_plan.apps.id
  app_service_plan_resource_group_name = azurerm_resource_group.primary.name

  # container
  container_registry_name = var.tooling_config.container_registry_name
  container_registry_rg   = var.tooling_config.container_registry_rg
  image_name              = "devops/template"

  # networking
  app_service_private_dns_zone_id = data.azurerm_private_dns_zone.app_service.id
  front_door_restriction          = true
  inbound_vnet_connectivity       = true
  integration_subnet_id           = azurerm_subnet.apps.id
  endpoint_subnet_id              = azurerm_subnet.main.id
  outbound_vnet_connectivity      = true
  public_network_access           = true

  # monitoring
  action_group_ids                  = local.action_group_ids
  log_analytics_workspace_id        = azurerm_log_analytics_workspace.main.id
  monitoring_alerts_enabled         = var.alerts_enabled
  health_check_path                 = var.health_check_path
  health_check_eviction_time_in_min = var.health_check_eviction_time_in_min

  #Easy Auth setting
  auth_config = {
    auth_enabled           = var.auth_config.auth_enabled
    require_authentication = var.auth_config.require_authentication
    auth_client_id         = var.auth_config.auth_client_id
    #checkov:skip=CKV_SECRET_6: "Base64 High Entropy String"
    auth_provider_secret = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
    auth_tenant_endpoint = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
    allowed_applications = var.auth_config.allowed_applications
    allowed_audiences    = var.auth_config.allowed_audiences
  }

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING      = local.key_vault_refs["app-insights-connection-string"]
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    NODE_ENV                                   = var.apps_config.node_environment
    APP_HOSTNAME                               = var.web_app_domain

    # logging
    LOG_LEVEL_FILE   = var.apps_config.logging.level_file
    LOG_LEVEL_STDOUT = var.apps_config.logging.level_stdout

    #Auth
    MICROSOFT_PROVIDER_AUTHENTICATION_SECRET = local.key_vault_refs["microsoft-provider-authentication-secret"]
    WEBSITE_AUTH_AAD_ALLOWED_TENANTS         = data.azurerm_client_config.current.tenant_id
  }

  providers = {
    azurerm         = azurerm
    azurerm.tooling = azurerm.tooling
  }
}

# ## RBAC for secrets
# resource "azurerm_role_assignment" "app_web_secrets_user" {
#   scope                = azurerm_key_vault.main.id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = module.template_app_web.principal_id
# }

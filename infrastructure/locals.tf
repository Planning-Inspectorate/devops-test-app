locals {
  org              = "pins"
  service_name     = "template"
  primary_location = "uk-south"

  resource_suffix = "${local.service_name}-${var.environment}"

  tags = merge(
    var.tags,
    {
      CreatedBy   = "Terraform"
      Environment = var.environment
      location    = local.primary_location
      Owner       = "DevOps"
      ServiceName = local.service_name
    }
  )

  #action groups
  all_action_groups = toset([
    "template-app-service"

  ])

  secrets = [
    "microsoft-provider-authentication-secret",
    "test-secret"
  ]

  # tflint-ignore: terraform_unused_declarations
  key_vault_refs = merge(
    {
      for k, v in azurerm_key_vault_secret.manual_secrets : k => "@Microsoft.KeyVault(SecretUri=${v.versionless_id})"
    },
    {
      "app-insights-connection-string" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.app_insights_connection_string.versionless_id})",
      "sql-app-connection-string"      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.sql_app_connection_string.versionless_id})"
    }
  )

  # tflint-ignore: terraform_unused_declarations
  action_group_ids = {
    tech            = data.azurerm_monitor_action_group.common["tech"].id,
    service_manager = data.azurerm_monitor_action_group.common["service_manager"].id,
    iap             = data.azurerm_monitor_action_group.common["iap"].id,
    its             = data.azurerm_monitor_action_group.common["its"].id,
    info_sec        = data.azurerm_monitor_action_group.common["info_sec"].id
  }
}

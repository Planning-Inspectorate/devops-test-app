resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.org}-log-${local.resource_suffix}"
  location            = module.primary_region.location
  resource_group_name = azurerm_resource_group.primary.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 0.01

  tags = local.tags
}

resource "azurerm_application_insights" "main" {
  name                 = "${local.org}-ai-${local.resource_suffix}"
  location             = module.primary_region.location
  resource_group_name  = azurerm_resource_group.primary.name
  workspace_id         = azurerm_log_analytics_workspace.main.id
  application_type     = "web" # should this be Node.JS, or general?
  daily_data_cap_in_gb = 0.01

  tags = local.tags
}

resource "azurerm_key_vault_secret" "app_insights_connection_string" {
  #checkov:skip=CKV_AZURE_41: expiration not valid
  key_vault_id = azurerm_key_vault.main.id
  name         = "${local.service_name}-app-insights-connection-string"
  value        = azurerm_application_insights.main.connection_string
  content_type = "connection-string"

  tags = local.tags
}

# Metric Alerts for log cap
resource "azurerm_monitor_metric_alert" "log_cap_alert" {
  count = var.alerts_enabled ? 1 : 0 #&& var.environment == "prod"

  name                = "${local.service_name} Log cap Alert ${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.primary.name
  scopes              = [azurerm_log_analytics_workspace.main.id]
  description         = "Action will be triggered when log cap is met."
  window_size         = "PT5M"
  frequency           = "PT1M"
  severity            = 2
  enabled             = var.alerts_enabled

  #dynamic_criteria uses historical data and machine learning to set thresholds automatically.
  #The alert triggers when the metric deviates from its normal pattern (anomaly detection).
  dynamic_criteria {
    metric_namespace  = "Microsoft.OperationalInsights/workspaces"
    metric_name       = "Daily Cap reached"
    aggregation       = "Total"
    operator          = "GreaterThanOrEqual"
    alert_sensitivity = "Medium" # Low, Medium, High
  }

  action {
    action_group_id = local.action_group_ids.tech
  }

  tags = local.tags
}

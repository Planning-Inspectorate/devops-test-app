# note: these are a global resources
#souce: https://github.com/Planning-Inspectorate/infrastructure-environments/blob/528cb47325402fa58675c98dc7e7d0e7f2517d52/app/stacks/uk-west/common/action-group.tf
resource "azurerm_monitor_action_group" "all_action_groups" {
  for_each = local.all_action_groups

  name                = "pins-ag-odt-${each.value}-${var.environment}"
  resource_group_name = "pins-rg-common-dev-ukw-001"
  short_name          = "CoreServices" # 1-12 chars only
  tags                = local.tags

  # we set emails in the action groups in Azure Portal - to avoid needing to manage
  # emails in terraform
  lifecycle {
    ignore_changes = [
      email_receiver
    ]
  }
}
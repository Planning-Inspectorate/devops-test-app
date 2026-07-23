resource "azurerm_key_vault_secret" "this_protected" {
  name         = var.name
  key_vault_id = var.key_vault_id
  value        = var.value
  content_type = var.content_type
  tags         = var.tags

  lifecycle {
    ignore_changes = [
      "value",
      "expiration_date",
    ]
    prevent_destroy = true
  }
}


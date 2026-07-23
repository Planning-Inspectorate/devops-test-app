module "primary_region" {
  #checkov:skip=CKV_TF_1: Trusted module source
  source  = "claranet/regions/azurerm"
  version = "8.0.5"

  azure_region = local.primary_location
}

resource "azurerm_resource_group" "primary" {
  name     = format("%s-rg-%s", local.org, local.resource_suffix)
  location = module.primary_region.location

  tags = local.tags
}

resource "azurerm_key_vault" "main" {
  name                          = format("%s-kv-%s", local.org, local.resource_suffix)
  location                      = module.primary_region.location
  resource_group_name           = azurerm_resource_group.primary.name
  enabled_for_disk_encryption   = true
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  rbac_authorization_enabled    = true
  public_network_access_enabled = false
  sku_name                      = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "keyvault" {
  name                = "${local.org}-pe-${local.service_name}-kv-${var.environment}"
  resource_group_name = azurerm_resource_group.primary.name
  location            = module.primary_region.location
  subnet_id           = azurerm_subnet.main.id

  private_dns_zone_group {
    name                 = "keyvaultprivatednszone"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.keyvault.id]
  }

  private_service_connection {
    name                           = "privateendpointconnection"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  tags = local.tags
}

resource "azurerm_key_vault_access_policy" "admins" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = "1f09c724-3d26-4a14-b52b-5af4acafab55" # Entra Group "All DevOps"

  certificate_permissions = ["Create", "Get", "Import", "List"]
  key_permissions         = ["Create", "Get", "List"]
  secret_permissions      = ["Get", "List", "Set"]
  storage_permissions     = ["Get", "List", "Set"]
}

# secrets to be manually populated
resource "azurerm_key_vault_secret" "manual_secrets" {
  #checkov:skip=CKV_AZURE_41: expiration not valid
  for_each = toset(local.secrets)

  key_vault_id = azurerm_key_vault.main.id
  name         = each.value
  value        = "<terraform_placeholder>"
  content_type = "plaintext"

  lifecycle {
    ignore_changes = [
      value,
      expiration_date,
    ]
  }

  depends_on = [
    azurerm_private_endpoint.keyvault,
    azurerm_private_dns_zone_virtual_network_link.keyvault
  ]

  tags = local.tags
}

# Testing Terraform with secret expiries so Terraform does not change secret expiration metadata after creation.
resource "azurerm_key_vault_secret" "secret_ignore_only_value" {
  #checkov:skip=CKV_AZURE_41: test secret - expiry intentionally omitted for testing
  name         = "secret-ignore-only-value"
  value        = "<terraform_placeholder>"
  content_type = "plaintext"
  key_vault_id = azurerm_key_vault.main.id

  lifecycle {
    ignore_changes = [
      value,
      expiration_date,
    ]
  }

  tags = merge(local.tags, { scenario = "experiment", scenario2 = "can-be-deleted" })
}

# Testing using a module.
module "manual_secret_test_new" {
  #checkov:skip=CKV_AZURE_41: test secret - expiry intentionally omitted for testing
  source       = "./modules/manual_secret"
  name         = "module-created-secret"
  key_vault_id = azurerm_key_vault.main.id
  value        = "<terraform_placeholder>"
  content_type = "plaintext"
  tags         = merge(local.tags, { scenario = "module-tag-test", scenario2 = "can-be-deleted" })

  # keep TF from changing the secret payload or expiry after creation
  ignore_value  = true
  ignore_expiry = true

  prevent_destroy = false
}

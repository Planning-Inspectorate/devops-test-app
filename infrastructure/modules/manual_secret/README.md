# manual_secret module

Usage example:

```hcl
module "manual_secret_example" {
  source        = "../../modules/manual_secret"
  name          = "microsoft-provider-authentication-secret"
  key_vault_id  = azurerm_key_vault.main.id
  value         = "<terraform_placeholder>"
  content_type  = "plaintext"
  tags          = local.tags

  # Options: keep TF from touching secret `value` and/or expiry
  ignore_value  = true
  ignore_expiry = true
  prevent_destroy = true
}
```

This module centralises lifecycle protections for secrets that are populated/rotated outside Terraform.

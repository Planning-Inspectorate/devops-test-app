module "primary_region" {
  #checkov:skip=CKV_AZURE_1: Trusted Source
  #checkov:skip=CKV_TF_1: Trusted module source
  source  = "claranet/regions/azurerm"
  version = "7.3.1"

  azure_region = local.primary_location
}

locals {
  org              = "pins"
  service_name     = "template-packer"
  primary_location = "uksouth"

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

  agent_pools = {
    main = {
      name     = "pins-vmss-${local.resource_suffix}"
      nic_name = "pins-vnet-azure-agents-nic-test-${local.resource_suffix}"
    }
  }
}

resource "random_password" "packer_admin_password" {
  length  = 20
  special = true
}

resource "azurerm_key_vault_secret" "agents_admin_password" {
  #checkov:skip=CKV_AZURE_41: TODO: Secret rotation
  name            = "packer-admin-password"
  value           = random_password.packer_admin_password.result
  key_vault_id    = data.azurerm_key_vault.template_key_vault.id
  expiration_date = "2026-01-01T00:00:00Z"
  content_type    = "text/plain"

  tags = local.tags
}

resource "azurerm_key_vault_secret" "dont_remove_with_terraform" {
  #checkov:skip=CKV_AZURE_41: TODO: Secret rotation
  name            = "dont-remove-with-terraform"
  value           = random_password.packer_admin_password.result
  key_vault_id    = data.azurerm_key_vault.template_key_vault.id
  expiration_date = "2026-01-01T00:00:00Z"
  content_type    = "text/plain"
}

resource "azurerm_key_vault_secret" "dont_remove_with_terraform2" {
  #checkov:skip=CKV_AZURE_41: TODO: Secret rotation
  name            = "dont-remove-with-terraform2"
  value           = random_password.packer_admin_password.result
  key_vault_id    = data.azurerm_key_vault.template_key_vault.id
  expiration_date = "2026-01-01T00:00:00Z"
  content_type    = "text/plain"
}

resource "azurerm_linux_virtual_machine_scale_set" "azure_devops_agent_pool" {

  #checkov:skip=CKV_AZURE_49: SSH key authentication not required
  #checkov:skip=CKV_AZURE_97: Encryption at host not required
  #checkov:skip=CKV_AZURE_149: Password authentication required
  #checkov:skip=CKV_AZURE_178: No need for encryption at host

  for_each = local.agent_pools

  name                = each.value["name"]
  resource_group_name = data.azurerm_resource_group.template_rg.name
  location            = local.primary_location
  sku                 = "Standard_DS2_v2"
  instances           = 4

  overprovision          = false
  single_placement_group = false

  admin_username                  = "adminuser"
  admin_password                  = azurerm_key_vault_secret.agents_admin_password.value
  disable_password_authentication = false

  platform_fault_domain_count = 1

  source_image_id = data.azurerm_image.packer_images.id

  # source_image_reference {
  #   publisher = "Canonical"
  #   offer     = "0001-com-ubuntu-server-jammy"
  #   sku       = "22_04-lts"
  #   version   = "latest"
  # }

  boot_diagnostics {
    storage_account_uri = null
  }

  network_interface {
    enable_accelerated_networking = true
    name                          = each.value["nic_name"]
    primary                       = true

    ip_configuration {
      name      = "default"
      primary   = true
      subnet_id = azurerm_subnet.packer_main_subnet.id
    }
  }

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"

    diff_disk_settings {
      option = "Local"
    }
  }

  lifecycle {
    ignore_changes = [
      automatic_instance_repair,
      automatic_os_upgrade_policy,
      extension,
      instances,
      tags
    ]
  }

  tags = local.tags
}

resource "azurerm_virtual_network" "packer" {
  name                = "${local.org}-vnet-${local.resource_suffix}"
  location            = local.primary_location
  resource_group_name = data.azurerm_resource_group.template_rg.name
  address_space       = [var.vnet_packer.address_space]

  tags = local.tags
}

resource "azurerm_subnet" "packer_main_subnet" {
  name                 = "${local.org}-snet-images-${local.resource_suffix}"
  resource_group_name  = data.azurerm_resource_group.template_rg.name
  virtual_network_name = azurerm_virtual_network.packer.name
  address_prefixes     = [var.vnet_packer.packer_subnet]
}

resource "azurerm_virtual_network_peering" "packer_to_template" {
  name                      = "${local.org}-peer-${local.service_name}-to-template-${var.environment}"
  resource_group_name       = azurerm_virtual_network.packer.resource_group_name
  remote_virtual_network_id = data.azurerm_virtual_network.template_vnet.id # template VNet changeme
  virtual_network_name      = azurerm_virtual_network.packer.name
}

resource "azurerm_virtual_network_peering" "template_to_packer" {
  name                      = "${local.org}-peer-tooling-to-${local.service_name}-${var.environment}"
  resource_group_name       = data.azurerm_virtual_network.template_vnet.resource_group_name
  remote_virtual_network_id = azurerm_virtual_network.packer.id
  virtual_network_name      = data.azurerm_virtual_network.template_vnet.name # changme to template vnet data call or var
}

terraform {
  backend "azurerm" {
    subscription_id      = "edb1ff78-90da-4901-a497-7e79f966f8e2"
    resource_group_name  = "pins-rg-shared-terraform-uks"
    storage_account_name = "pinssttfstateukstemplate"
    # per-environment key & container_name specified init step
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "> 4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
  required_version = ">= 1.11.0, < 1.15.0"
}

provider "azurerm" {
  features {}
}

# Provider for cross-subscription access to 'pins-rg-common-tooling'
provider "azurerm" {
  alias           = "common"
  subscription_id = "76cf28c6-6fda-42f1-bcd9-6d7dbed704ef"
  features {}
}

provider "azurerm" {
  alias           = "tooling"
  subscription_id = var.tooling_config.subscription_id
  features {}
}

provider "azurerm" {
  alias           = "front_door"
  subscription_id = var.tooling_config.subscription_id
  features {}
}

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
      version = "~> 3.7"
    }
  }
  required_version = ">= 1.11.0, < 1.15.0"
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "tooling"

  features {}
}

provider "azurerm" {
  # either tooling or prod for shared FD instance
  alias = "front_door"

  features {}
}

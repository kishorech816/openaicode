terraform {
  #required_version = "1.5.5"
  backend "azurerm" {
    container_name = "terraform"
    key            = "np_network.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  #subscription_id            = var.AZURE_SPOKE_SUBSCRIPTION_ID
  skip_provider_registration = true

}

#
#provider "azurerm" {
#  alias                      = "hub-subscription"
#  skip_provider_registration = true
#  features {}
#  subscription_id = var.AZURE_HUB_SUBSCRIPTION_ID
#}
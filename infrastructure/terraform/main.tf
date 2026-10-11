terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "range" {
  name     = "rg-${var.prefix}"
  location = var.location
}

module "detections" {
  source                     = "../../detections/rules"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.range.id
}
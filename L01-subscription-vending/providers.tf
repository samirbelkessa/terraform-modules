terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.8.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.9.0"
    }
  }
}

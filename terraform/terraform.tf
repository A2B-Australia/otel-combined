terraform {
  required_version = ">= 1.10.0"

  ####################################################
  backend "azurerm" {
    resource_group_name     = "Phoenix_Terraform"
    storage_account_name    = "alltfstatefilesdev"
    container_name          = "phoenixterraformmaindev"
    # key                   = "otel.tfstate"
    use_azuread_auth        = true
    subscription_id         = "5eb414e5-8dd1-4192-9209-98c04543c66c"
    tenant_id               = "0e38730c-f9b8-4d07-9f70-46b518bde035"
  }

  ####################################################
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.15.0"
    }
    azapi = {
        source  = "Azure/azapi"
        version = "~>2.2.0"
    }
  }
}
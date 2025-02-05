# See: https://techcommunity.microsoft.com/blog/fasttrackforazureblog/can-i-create-an-azure-container-apps-in-terraform-yes-you-can/3570694


####################################################
# Create a Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                    = "phoenix-otel-ace-vnet"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  address_space           = ["10.0.0.0/16"]
}

####################################################
# Create a Subnet
resource "azurerm_subnet" "subnet" {
  name                    = "phoenix-otel-ace-vnet-subnet"
  resource_group_name     = azurerm_resource_group.rg.name
  virtual_network_name    = azurerm_virtual_network.vnet.name
  address_prefixes        = ["10.0.0.0/21"]

  # delegation {
  #   name                  = "container-app-delegation"

  #   service_delegation {
  #     name                = "Microsoft.App/environments"
  #     actions             = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  #   }
  # }
}                                                                                                                                                                                                                                        

####################################################
# Container App Environment
resource "azurerm_container_app_environment" "env" {
  name                              = var.container_app_env_name
  location                          = azurerm_resource_group.rg.location
  resource_group_name               = azurerm_resource_group.rg.name
  infrastructure_subnet_id          = azurerm_subnet.subnet.id
  # internal_load_balancer_enabled  = var.internal_load_balancer_enabled
  log_analytics_workspace_id        = null                          
  zone_redundancy_enabled           = false  # For high availability

  # workload_profile {
  #   name = "Consumption"
  #   # Or "D4" for dedicated resources
  # }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  # dapr {
  #   enabled = true
  # }
}


####################################################
# Storage Account
resource "azurerm_storage_account" "storage" {
  name                            = "phxotelstorage"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"

  # Enable blob encryption
  blob_properties {
      versioning_enabled = true
      delete_retention_policy {
          days = 7
      }
  }

  # Blob access IP restrictions
  network_rules {
    default_action                = "Allow"
    # ip_rules                    = ["YOUR_IP_HERE"]
    # bypass                      = ["AzureServices"]
  }  
}

####################################################
# Storage Share
resource "azurerm_storage_share" "storage" {
    name                          = "phxotelshare2"
    storage_account_id            = azurerm_storage_account.storage.id
    # storage_account_name        = azurerm_storage_account.storage.name
    quota                         = 5
    enabled_protocol              = "SMB"
}

####################################################
# Container App Environment Storage
resource "azurerm_container_app_environment_storage" "blob_file_share" {
  name                            = "mycontainerappstorage"
  container_app_environment_id    = azurerm_container_app_environment.env.id
  account_name                    = azurerm_storage_account.storage.name
  share_name                      = azurerm_storage_share.storage.name
  access_key                      = azurerm_storage_account.storage.primary_access_key
  access_mode                     = "ReadWrite"
}





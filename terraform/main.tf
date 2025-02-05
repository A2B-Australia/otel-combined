####################################################
# Configure the Azure provider
resource "azurerm_resource_group" "rg" {
  name        = var.resource_group_name
  location    = var.location
  tags        = local.az_tags
}


# File: azure_tags.tf

#########################################

locals {
    az_tags = {
        Product_Group           = "Phoenix"
        Product_Name            = "Platform"
        Created_By              = "Ian Scrivener - A2B Sydney"
        createdby               = "Ian Scrivener - A2B Sydney"
        PHX_Product             = "Phoenix_Obs_OTEL_2"
        PHX_Repo                = "cabcharge/phoenix-terraform-main"
        PHX_Version             = var.release_version
        PHX_Group_ID            = 0
        PHX_Group_Name          = "DevOps"
        PHX_Deploy_Method       = "Terraform-Manual"
    }
}

output "az_tags" {
    value = local.az_tags
}
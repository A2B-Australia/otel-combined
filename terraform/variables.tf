# File: variables.tf


####################################################
# Variables
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

####################################################
variable "container_app_env_name" {
  type        = string
  description = "Name of the Container App Environment"
}

############################
variable "location" {
    type        = string
    description = "location of resources, region."
    default     = "australiaeast"
    sensitive   = false
    validation {
        condition = contains(["australiaeast", "australiasoutheast"], var.location)
        error_message = "Hey: invalid location."
    }
}

# ############################
# #used to convert location to abbreviation for resource names
# variable "location_abbr" {
#     type = map(string)
#     default = {
#         australiaeast      = "ae"
#         australiasoutheast = "ase"
#     }
# }

# ############################
# variable "project" {
#     type        = string
#     description = "(optional) describe your variable"
#     validation {
#         condition     = (length(var.project) >= 3 && length(var.project) <= 12)
#         error_message = "Hey: project length must be >=3 and <=12."
#     }
# }

# ############################
# variable "full_project" {
#     type        = string
#     description = "(optional) describe your variable"
#     validation {
#         condition     = (length(var.full_project) >= 3 && length(var.full_project) <= 40)
#         error_message = "Hey: project length must be >=6 and <=40."
#     }
# }

############################
variable "domain_name" {
    type = string
    description = "custom domain name"
}

############################
variable "DNS_RG" {
    type = string
    description = "Resource Group of the DNS"
}

############################
variable "release_version" {
    type = string
    description = "Version of the release"
}

# ############################
# variable "identity_name" {
#     type = string
#     description = "Name of the user assigned identity"
# }

# ############################
# variable "github_username" {
#     type = string
# }

# ############################
# variable "jaegar_repo" {
#     type = string
# }

# ############################
# variable "github_token" {
#     type = string
# }

############################
variable "azure_container_registry_id" {
    type = string
}

# variable "azure_container_registry_id" {
#     type = string
# }

# variable "azure_container_registry_id" {
#     type = string
# }

# variable "container_app_name" {
#     type = string
# }

variable "interim_image_name" {
    type = string
}

variable "interim_image" {
    type = string
}

# variable "image_name" {
#     type = string
# }

# variable "image" {
#     type = string
# }

# variable "memory" {
#     type = string
# }

# variable "cpu" {
#      type = number
# }

# variable "azure_container_login" {
#     type = string
# }




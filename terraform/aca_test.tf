##########################################
# create container App
resource "azurerm_container_app" "app" {
  name                      = "test-aca"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name       = azurerm_resource_group.rg.name
  revision_mode             = "Single"

  template {
    container {
      name                  = "hello"
      image                 = "nginxdemos/hello:latest"
      cpu                   = 0.25
      memory                = "0.5Gi"
    }
  }
  ingress {
    external_enabled = true
    target_port             = 80
    transport               = "auto"

    traffic_weight {
      percentage            = 100
      latest_revision       = true
    }
  }
}

##########################################
# create CNAME DNS record
resource "azurerm_dns_cname_record" "cname" {
  name                      = "test-aca"
  zone_name                 = var.domain_name
  resource_group_name       = var.DNS_RG
  ttl                       = 60
  record                    = azurerm_container_app.app.ingress[0].fqdn
}

##########################################
# create TXT DNS record
resource "azurerm_dns_txt_record" "txt" {
  name                      = "asuid.test-aca"
  zone_name                 = var.domain_name
  resource_group_name       = var.DNS_RG
  ttl                       = 60
  record {
    value                   = azurerm_container_app.app.custom_domain_verification_id
  }
}


##########################################
# create custom domain binding
resource "azurerm_container_app_custom_domain" "custom_domain" {
  name                      = "test-aca.${var.domain_name}"
  container_app_id          = azurerm_container_app.app.id
  certificate_binding_type  = "SniEnabled"

  lifecycle {
    ignore_changes          = [certificate_binding_type, container_app_environment_certificate_id]
  }

  depends_on = [
    azurerm_dns_cname_record.cname,
    azurerm_dns_txt_record.txt
    ]
}

##########################################
# create Managed TLS Certificate
resource "azapi_resource" "managed_certificate" {
  depends_on                = [azurerm_dns_cname_record.cname]
  type                      = "Microsoft.App/managedEnvironments/managedCertificates@2024-03-01"
  name                      = "test-aca"
  parent_id                 = azurerm_container_app_environment.env.id
  location                  = azurerm_resource_group.rg.location

  body = {
    properties = {
      subjectName             = azurerm_container_app_custom_domain.custom_domain.name
      domainControlValidation = "CNAME"
    }
  }

  response_export_values = ["*"]
}

##########################################
# on create - apply custom domain binding
resource "azapi_resource_action" "apply_custom_domain_binding" {
  resource_id               = azurerm_container_app.app.id
  when                      = "apply"
  type                      = "Microsoft.App/containerApps@2024-03-01"
  method                    = "PATCH"
  body = {
    properties = {
      configuration = {
        ingress = {
          customDomains = [
            {
              bindingType   = "SniEnabled",
              name          = azurerm_container_app_custom_domain.custom_domain.name,
              certificateId = azapi_resource.managed_certificate.output.id
            }
          ]
        }
      }
    }
  }
}

##########################################
# on destroy - remove custom domain binding
# on destroy provisioner necessary to remove domain before removing Certificate see error in comments below
resource "azapi_resource_action" "destroy_custom_domain_binding" {
  depends_on                  = [azurerm_container_app_custom_domain.custom_domain]
  when                        = "destroy"
  resource_id                 = azurerm_container_app.app.id
  
  type                        = "Microsoft.App/containerApps@2024-03-01"
  method                      = "PATCH"
  body = {
    properties = {
      configuration = {
        ingress = {
          customDomains = []
        }
      }
    }
  }
}
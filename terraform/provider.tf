####################################################
# Configure the Microsoft Azure Provider
provider "azurerm" {

  subscription_id      = "5eb414e5-8dd1-4192-9209-98c04543c66c"
  tenant_id            = "0e38730c-f9b8-4d07-9f70-46b518bde035"

  features {

    key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_key_vaults = false
    }

    resource_group {
      # Enable this as a work around because of Application Insights auto-generated Failure Anomalies rules.
      # In this case delete, even if there are resources not tracked in terraform state.
      prevent_deletion_if_contains_resources = false

    }
    application_insights {
      # Enable this as a work around because of Application Insights auto-generated Failure Anomalies rules.
      # In this case - do not make Failure Anomaly rules.
      disable_generated_rule = false
    }
  }
}

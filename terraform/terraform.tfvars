resource_group_name             = "Phoenix_otel_terraform"
location                        = "australiaeast"

# ACE Name
container_app_env_name          = "phoenix-otel-ace"

# Interim Container
interim_image_name              = "nginx-hello"
interim_image                   = "nginxdemos/hello"

# ACR 
azure_container_registry_id     = "/subscriptions/5eb414e5-8dd1-4192-9209-98c04543c66c/resourceGroups/Phoenix_Containers/providers/Microsoft.ContainerRegistry/registries/A2bPhoenixDevAcr"
release_version                 = "0.0.3"


# DNS
domain_name                     = "phoenixdev.com.au"
DNS_RG                          = "Phoenix-Dev-DNS"
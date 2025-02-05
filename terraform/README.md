# obs-otel-terraform

### About
This repo containers the Terraform Infrastructure-as-Code (IaC) to create, managed, delete the OpenTelemetry (OTEL) Azure infrastructure.

There are multiple "OTEL Collectors" running as containers in Azure Container Apps (ACA). ACAs are being adopted broadly in Phoenix. 

The rationale behind multiple separate OTEL Collectors include;
 - more/easier configuration - eg route Logs/Metrics/Traces to different places for different programing language/ and service classes
 - redundancy and continuity of service in the event that one OTEL Collectors fails or experiences problems
 - more visability of load & costs - for scaling and cost management purposes

---

### How-To deploy
```
# 1) connect/switch Terraform backend
source ./scripts/switch_TF_backend.sh otel       

# 2) validate TF code
terraform validate

# 3) plan the TF changes
teraform plan

# 4) execute the TF plan
terraform apply -auto-approve
```


<br />
### How-To Destroy the Azure infrastructure


```
# destroy the created resources
terraform destroy -auto-approve
```

---
---

### About the Custom VNet

We create a custom VNet equivalent to the following `az cli`

```

# create Resource Group
RG=Phoenix_VNet_temp

az group create \
  --name $RG \
  --location australiaeast \
  --tags \
    Product_Group=Phoenix \
    Product_Name=Other \
    PHX_Project=$RG \
    createdby="Ian Scrivener"



# create the VNET and subnet
az network vnet create \
  --name                tmpVNet \
  --resource-group      $RG \
  --location            australiaeast \
  --address-prefix      10.0.1.0/16 \
  --subnet-name         tmpSubnet \
  --subnet-prefix       10.0.1.0/23

# Create the Container Apps Environment with VNET
az containerapp env create \
  --name                phoenix-otel-ace \
  --resource-group      $RG \
  --location            australiaeast \
  --infrastructure-subnet-resource-id $(az network vnet subnet show \
    --name              tmpSubnet \
    --vnet-name         tmpVNet \
    --resource-group    $RG \
    --query id -o tsv)

# Create the Container App
az containerapp create \
  --name                tmpWebApp \
  --resource-group      $RG \
  --environment         myTmpEnv \
  --image               nginxdemos/hello:latest \
  --target-port         80 \
  --ingress             external
```






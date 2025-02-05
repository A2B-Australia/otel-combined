
####################
# (1) set variables
RG=Phoenix_VNet_temp_2
DNS_RG=Phoenix-Dev-DNS
LOCATION=australiaeast
VNET_NAME=tmpVNet2
SUBNET_NAME=tmpSubnet2
ACA_NAME=foo123aca
DN_Prefix=foo123
ACE_NAME=temp-ace-2
DOMAIN_NAME=phoenixdev.com.au


####################
# (2) Create the resource group
az group create \
  --name                    $RG \
  --location                $LOCATION \
  --tags \
    Product_Group=Phoenix \
    Product_Name=Other \
    PHX_Project=$RG \
    createdby="Ian Scrivener"

####################
# (3) create the VNET and subnet
az network vnet create \
  --name                    $VNET_NAME \
  --resource-group          $RG \
  --location                $LOCATION \
  --address-prefix          10.0.0.0/16 \
  --subnet-name             $SUBNET_NAME \
  --subnet-prefix           10.0.0.0/23

####################
# (4) Add the required delegation to the subnet
az network vnet subnet update \
  --name                    $SUBNET_NAME \
  --vnet-name               $VNET_NAME \
  --resource-group          $RG \
  --delegations             Microsoft.App/environments

####################
# (5) Create the Container Apps Environment with VNET
az containerapp env create \
  --name                    $ACE_NAME \
  --resource-group          $RG \
  --location                $LOCATION \
  --infrastructure-subnet-resource-id $(az network vnet subnet show \
    --name                  $SUBNET_NAME \
    --vnet-name             $VNET_NAME \
    --resource-group        $RG \
    --query id -o tsv)

####################
# (6) Create the Container App
az containerapp create \
  --name                    $ACA_NAME \
  --resource-group          $RG \
  --environment             $ACE_NAME \
  --image                   nginxdemos/hello:latest \
  --target-port             80 \
  --ingress                 external

####################
# (7) get ACA URL
    FQDN=$(az containerapp show \
        --name              $ACA_NAME \
        --resource-group    $RG \
        --query             "properties.configuration.ingress.fqdn" \
        --output            tsv)
    echo $FQDN

####################
# (8) get ACA customer verification id
    verificationID=$(az containerapp show \
        --name              $ACA_NAME \
        --resource-group    $RG \
        --query             "properties.customDomainVerificationId" \
        --output            tsv)
    echo $verificationID

####################
# (9) create cname record in Azure DNS
    az network dns record-set cname set-record \
        --resource-group    $DNS_RG \
        --zone-name         "$DOMAIN_NAME" \
        --record-set-name   "$DN_Prefix" \
        --ttl               60 \
        --cname             $FQDN

####################
# (10) create txt record in Azure DNS
    az network dns record-set txt add-record \
    --resource-group        $DNS_RG \
        --zone-name         "$DOMAIN_NAME" \
        --record-set-name   "asuid.$DN_Prefix" \
        --value             $verificationID

####################
# (11) add hostname 
az containerapp hostname    add \
    --name                  $ACA_NAME \
    --resource-group        $RG \
    --hostname              "$DN_Prefix.$DOMAIN_NAME"

####################
# (12) create binding
az containerapp hostname    bind \
    --hostname              "$DN_Prefix.$DOMAIN_NAME" \
    --name                  $ACA_NAME  \
    --resource-group        $RG \
    --environment           $ACE_NAME  \
    --validation-method     CNAME

####################
# (13) add managed certificate
az containerapp hostname bind \
    --hostname              "$DN_Prefix.$DOMAIN_NAME" \
    --name                  $ACA_NAME \
    --resource-group        $RG \
    --validation-method     CNAME \
    --environment           $ACE_NAME
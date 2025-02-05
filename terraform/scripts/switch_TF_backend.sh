#!/bin/bash

#########################################
# set variables
storage_account_name='alltfstatefilesdev'
container_name='phoenixterraformmaindev'
resource_group='Phoenix_Terraform'

#########################################
# Check if an argument is provided
if [ -z "$1" ]; then
  echo "No argument provided - please provide the required Phoenix environment"
  exit 1
fi

#########################################
# Check if an argument is provided
if [ -z "$TF_BACKEND_SAS" ]; then
  echo "No TF_BACKEND_SAS argument provided - please add a valid SAS key to your local environment - export TF_BACKEND_SAS=***"
  exit 1
fi

#########################################
# # generate expiry date for Azure Storage SAS key
# if [[ "$OSTYPE" == "darwin"* ]]; then
#   # macOS
#   expiry_date=$(date -u -v +10M '+%Y-%m-%dT%H:%MZ')
# else
#   # Ubuntu and other Unix-like systems
#   expiry_date=$(date -u -d "10 minutes" '+%Y-%m-%dT%H:%MZ')
# fi

#########################################
# get SAS token for the Azure Storage Blob

# TF_BACKEND_SAS=$(az storage blob generate-sas \
#   --account-name $storage_account_name \
#   --container-name $container_name \
#   --account-key "F5VHkTYFGKk5gsSC5p4opfkB18f7YQx7B511cqJMOser+QVBoBllE6ZeqagHX9LNm201SwhRQGLn+ASt7EkTCQ==" \
#   --connection-string "DefaultEndpointsProtocol=https;AccountName=alltfstatefilesdev;AccountKey=F5VHkTYFGKk5gsSC5p4opfkB18f7YQx7B511cqJMOser+QVBoBllE6ZeqagHX9LNm201SwhRQGLn+ASt7EkTCQ==;EndpointSuffix=core.windows.net"\
#   --blob-url "https://$storage_account_name.blob.core.windows.net/$container_name/$1.tfstate" \
#   --permissions "acrdrw" \
#   --expiry $expiry_date \
#   --https-only \
#   --output tsv \
#   --auth-mode key)

# az storage blob user-delegation-key create \
#     --account-name $storage_account_name \
#     --expiry-time $expiry_date

# # Step 2: Generate SAS token using the User Delegation Key
# TF_STATE_BLOB_SAS_TOKEN=$(az storage container generate-sas \
#     --account-name $storage_account_name \
#     --name $container_name \
#     --permissions acdlrw \
#     --expiry $expiry_date \
#     --auth-mode login \
#     --as-user \
#     --delegated-key "$(az storage blob user-delegation-key create \
#         --account-name $storage_account_name \
#         --expiry-time $expiry_date \
#         --query '{keyInfo:keyInfo}' -o json)"
 
#########################################
# export the SAS token as an environment variable 
# export TF_BACKEND_SAS=$TF_BACKEND_SAS 


# Print the provided argument
echo ""
echo "########################################"
echo "Switching the Terraform backend to: *** $1 ****"
echo ""
echo "Getting SAS token from environment variables"
echo "TF_BACKEND_SAS: $TF_BACKEND_SAS"
echo ""
echo "Getting TF state file"
echo ""
echo "storage_account_name=$storage_account_name"
echo "container_name=$container_name"

cd TERRAFORM

terraform init \
  -backend-config "storage_account_name=$storage_account_name" \
  -backend-config "container_name=$container_name" \
  -backend-config "key=$1.tfstate" \
  -backend-config "sas_token=$TF_BACKEND_SAS" \
  -reconfigure

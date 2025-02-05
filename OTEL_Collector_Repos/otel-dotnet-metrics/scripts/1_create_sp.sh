#!/bin/bash

# Define color codes for better visibility
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env file not found in current directory${NC}"
    exit 1
fi

# Check if az CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI (az) is not installed${NC}"
    echo "Please install it from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if az CLI is logged in
if ! az account show &> /dev/null; then
    echo -e "${RED}Error: Not logged into Azure CLI${NC}"
    echo "Please run 'az login' first"
    exit 1
fi

# Function to backup .env file
backup_env() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file=".env.backup_${timestamp}"
    cp .env "$backup_file"
    echo -e "${GREEN}Created backup of .env file: $backup_file${NC}"
}

# Read AZURE_SUBSCRIPTION_ID from .env
SUBSCRIPTION_ID=$(grep "^GH_VAR_AZURE_SUBSCRIPTION_ID=" .env | cut -d'=' -f2- | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")

if [ -z "$SUBSCRIPTION_ID" ]; then
    echo -e "${RED}Error: AZURE_SUBSCRIPTION_ID not found in .env file${NC}"
    echo "Please add GH_VAR_AZURE_SUBSCRIPTION_ID=your-subscription-id to your .env file"
    exit 1
fi

echo -e "${GREEN}Found Subscription ID: $SUBSCRIPTION_ID${NC}"

# Confirm subscription ID is valid
if ! az account show --subscription "$SUBSCRIPTION_ID" &> /dev/null; then
    echo -e "${RED}Error: Invalid or inaccessible subscription ID${NC}"
    echo "Please check if the subscription ID is correct and you have access to it"
    exit 1
fi

# Generate a unique name for the service principal with timestamp
SP_NAME="GitHub-Actions-$(date +%Y%m%d-%H%M%S)"

echo -e "${YELLOW}Creating Service Principal: $SP_NAME${NC}"

# Create service principal and save output
SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "$SP_NAME" \
    --role contributor \
    --scopes "/subscriptions/$SUBSCRIPTION_ID" \
    --sdk-auth)

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to create service principal${NC}"
    exit 1
fi

echo -e "${GREEN}Service Principal created successfully${NC}"

# Create backup of current .env file
backup_env

# Format the JSON output properly for .env file
# Format as a single line with single quotes
FORMATTED_JSON=$(echo "$SP_OUTPUT" | tr -d '\n')

# Update or add AZURE_CREDENTIALS in .env file
if grep -q "^GH_SECRET_AZURE_CREDENTIALS=" .env; then
    # Update existing credentials
    sed -i.tmp "s|^GH_SECRET_AZURE_CREDENTIALS=.*|GH_SECRET_AZURE_CREDENTIALS='$FORMATTED_JSON'|" .env
else
    # Add new credentials
    echo "GH_SECRET_AZURE_CREDENTIALS='$FORMATTED_JSON'" >> .env
fi

# Extract individual values from the JSON for separate secrets
CLIENT_ID=$(echo "$SP_OUTPUT" | grep -o '"clientId": *"[^"]*"' | cut -d'"' -f4)
CLIENT_SECRET=$(echo "$SP_OUTPUT" | grep -o '"clientSecret": *"[^"]*"' | cut -d'"' -f4)
TENANT_ID=$(echo "$SP_OUTPUT" | grep -o '"tenantId": *"[^"]*"' | cut -d'"' -f4)

# Update or add individual secrets in .env file
update_env_var() {
    local key=$1
    local value=$2
    if grep -q "^$key=" .env; then
        sed -i.tmp "s|^$key=.*|$key='$value'|" .env
    else
        echo "$key='$value'" >> .env
    fi
}

update_env_var "GH_SECRET_AZURE_CLIENT_ID" "$CLIENT_ID"
update_env_var "GH_SECRET_AZURE_CLIENT_SECRET" "$CLIENT_SECRET"
update_env_var "GH_SECRET_AZURE_TENANT_ID" "$TENANT_ID"




# Clean up temporary files
rm -f .env.tmp

echo -e "${GREEN}Successfully updated .env file with new credentials${NC}"
echo -e "${YELLOW}A backup of your original .env file has been created${NC}"
echo -e "\nService Principal Details:"
echo "Name: $SP_NAME"
echo "Subscription: $SUBSCRIPTION_ID"
echo "Role: Contributor"

echo -e "\n${GREEN}✓ Setup complete! The following secrets have been added/updated in .env:${NC}"
echo "- GH_SECRET_AZURE_CREDENTIALS (complete JSON)"
echo "- GH_SECRET_AZURE_CLIENT_ID"
echo "- GH_SECRET_AZURE_CLIENT_SECRET"
echo "- GH_SECRET_AZURE_TENANT_ID"
echo "- GH_SECRET_AZURE_SUBSCRIPTION_ID (unchanged)"

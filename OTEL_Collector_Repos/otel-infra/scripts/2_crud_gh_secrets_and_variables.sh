#!/bin/bash

# gh-secrets-sync.sh
# Purpose: Synchronize GitHub Actions secrets and variables from a local .env file
# Usage: ./gh-secrets-sync.sh [owner/repo]

# Define color codes for better visibility
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# [VALIDATION SECTION]
validate_requirements() {
    # Check if .env file exists
    if [ ! -f ".env" ]; then
        echo -e "${RED}Error: .env file not found in current directory${NC}"
        exit 1
    fi

    # Check if gh CLI is installed
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
        echo "Please install it from: https://cli.github.com/"
        exit 1
    fi

    # Check if user is authenticated with gh
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}Error: Not authenticated with GitHub CLI${NC}"
        echo "Please run 'gh auth login' first"
        exit 1
    fi
}

# [REPOSITORY SETUP SECTION]
get_repository() {
    local repo_arg=$1
    if [ -z "$repo_arg" ]; then
        local repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Please provide repository name (e.g., owner/repo) as argument${NC}"
            echo "Usage: $0 owner/repo"
            exit 1
        fi
        echo "$repo"
    else
        echo "$repo_arg"
    fi
}

# [FILE PROCESSING FUNCTIONS]
extract_env_items() {
    local env_file=".env"
    local secrets_file=$1
    local vars_file=$2

    # Extract secrets and variables from .env file
    grep "^GH_SECRET_" "$env_file" | cut -d'=' -f1 | sed 's/^GH_SECRET_//' > "$secrets_file"
    grep "^GH_VAR_" "$env_file" | cut -d'=' -f1 | sed 's/^GH_VAR_//' > "$vars_file"
}

fetch_current_items() {
    local repo=$1
    local secrets_file=$2
    local vars_file=$3

    gh secret list --repo="$repo" --json name --jq '.[].name' > "$secrets_file"
    gh variable list --repo="$repo" --json name --jq '.[].name' > "$vars_file"
}

# [CLEANUP FUNCTIONS]
remove_obsolete_items() {
    local repo=$1
    local secrets_to_remove=$2
    local vars_to_remove=$3

    if [ ! -z "$secrets_to_remove" ]; then
        echo -e "${YELLOW}Removing obsolete secrets:${NC}"
        echo "$secrets_to_remove" | while read -r secret; do
            if [ ! -z "$secret" ]; then
                echo -e "  Removing secret: $secret"
                if gh secret remove "$secret" --repo="$repo"; then
                    echo -e "${GREEN}  ✓ Successfully removed secret: $secret${NC}"
                else
                    echo -e "${RED}  ✗ Failed to remove secret: $secret${NC}"
                fi
            fi
        done
    fi

    if [ ! -z "$vars_to_remove" ]; then
        echo -e "${YELLOW}Removing obsolete variables:${NC}"
        echo "$vars_to_remove" | while read -r var; do
            if [ ! -z "$var" ]; then
                echo -e "  Removing variable: $var"
                if gh variable remove "$var" --repo="$repo"; then
                    echo -e "${GREEN}  ✓ Successfully removed variable: $var${NC}"
                else
                    echo -e "${RED}  ✗ Failed to remove variable: $var${NC}"
                fi
            fi
        done
    fi
}

# [PROCESSING FUNCTION]
process_env_file() {
    local repo=$1
    local total_secrets=0
    local loaded_secrets=0
    local total_vars=0
    local loaded_vars=0

    while IFS='=' read -r key value || [ -n "$key" ]; do
        # Skip empty lines and comments
        if [ -z "$key" ] || [[ $key == \#* ]]; then
            continue
        fi

        # Trim whitespace from key and value
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        # Process GitHub Variables (GH_VAR_)
        if [[ $key == GH_VAR_* ]]; then
            local actual_key=${key#GH_VAR_}
            ((total_vars++))
            echo -e "${YELLOW}Setting variable: $actual_key${NC}"
            if gh variable set "$actual_key" --repo="$repo" --body "$value"; then
                echo -e "${GREEN}✓ Successfully set variable: $actual_key${NC}"
                ((loaded_vars++))
            else
                echo -e "${RED}✗ Failed to set variable: $actual_key${NC}"
            fi
        
        # Process GitHub Secrets (GH_SECRET_)
        elif [[ $key == GH_SECRET_* ]]; then
            local actual_key=${key#GH_SECRET_}
            ((total_secrets++))
            echo -e "${YELLOW}Setting secret: $actual_key${NC}"
            if gh secret set "$actual_key" --repo="$repo" --body "$value"; then
                echo -e "${GREEN}✓ Successfully set secret: $actual_key${NC}"
                ((loaded_secrets++))
            else
                echo -e "${RED}✗ Failed to set secret: $actual_key${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ Skipping: $key (no GH_VAR_ or GH_SECRET_ prefix)${NC}"
        fi
    done < ".env"

    # Set global variables for the main function to use
    TOTAL_SECRETS=$total_secrets
    LOADED_SECRETS=$loaded_secrets
    TOTAL_VARS=$total_vars
    LOADED_VARS=$loaded_vars
}

# [MAIN SCRIPT]
main() {
    # Validate requirements
    validate_requirements

    # Get repository
    REPO=$(get_repository "$1")
    echo -e "${GREEN}Analyzing repository: $REPO${NC}"

    # Setup temporary files
    TEMP_DIR=$(mktemp -d)
    ENV_SECRETS_FILE="$TEMP_DIR/env_secrets.txt"
    ENV_VARS_FILE="$TEMP_DIR/env_vars.txt"
    CURRENT_SECRETS_FILE="$TEMP_DIR/current_secrets.txt"
    CURRENT_VARS_FILE="$TEMP_DIR/current_vars.txt"

    # Cleanup trap
    trap 'rm -rf "$TEMP_DIR"' EXIT

    # Extract items from .env and fetch current items
    extract_env_items "$ENV_SECRETS_FILE" "$ENV_VARS_FILE"
    fetch_current_items "$REPO" "$CURRENT_SECRETS_FILE" "$CURRENT_VARS_FILE"

    # Calculate items to be removed
    SECRETS_TO_REMOVE=$(comm -23 "$CURRENT_SECRETS_FILE" "$ENV_SECRETS_FILE")
    VARS_TO_REMOVE=$(comm -23 "$CURRENT_VARS_FILE" "$ENV_VARS_FILE")

    # Remove obsolete items
    remove_obsolete_items "$REPO" "$SECRETS_TO_REMOVE" "$VARS_TO_REMOVE"

    # Process .env file
    echo -e "\n${GREEN}Setting new secrets and variables:${NC}"
    process_env_file "$REPO"

    # Print summary
    echo "----------------------------------------"
    echo -e "${GREEN}Summary:${NC}"
    echo "Secrets:"
    echo "  - Total processed: $TOTAL_SECRETS"
    echo "  - Successfully loaded: $LOADED_SECRETS"
    echo "  - Removed: $(echo "$SECRETS_TO_REMOVE" | grep -c '^')"
    echo "  - Failed: $((TOTAL_SECRETS - LOADED_SECRETS))"
    echo ""
    echo "Variables:"
    echo "  - Total processed: $TOTAL_VARS"
    echo "  - Successfully loaded: $LOADED_VARS"
    echo "  - Removed: $(echo "$VARS_TO_REMOVE" | grep -c '^')"
    echo "  - Failed: $((TOTAL_VARS - LOADED_VARS))"

    # Exit with appropriate status code
    if [ $((LOADED_SECRETS + LOADED_VARS)) -eq $((TOTAL_SECRETS + TOTAL_VARS)) ]; then
        echo -e "${GREEN}✓ All secrets and variables were processed successfully!${NC}"
        exit 0
    else
        echo -e "${RED}⚠ Some items failed to process. Please check the output above.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"

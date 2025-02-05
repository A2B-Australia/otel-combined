az containerapp show \
    --name jaeger \
    --resource-group Phoenix_Obs_OTEL_Terraform \
    --query "properties.configuration.ingress" \


# az containerapp show \
# --name ${{ env.CONTAINER_APP_NAME }} \
# --resource-group ${{ env.RESOURCE_GROUP }} \
# --query "properties.latestRevisionName" \
# --output tsv

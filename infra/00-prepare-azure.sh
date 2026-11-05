#!/usr/bin/env bash
set -euo pipefail

NOMBRE="${NOMBRE:-oscarlasso}"
RG="${RG:-rg-arepas-$NOMBRE}"
LOC="${LOC:-northcentralus}"
PUBLISHER_EMAIL="${PUBLISHER_EMAIL:-oscar.lasso-m@mail.escuelaing.edu.co}"

echo "Preparando recursos en Azure ($NOMBRE / $LOC)..."

az extension add --name containerapp --upgrade || true
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.ApiManagement
az provider register --namespace Microsoft.ContainerInstance
az provider register --namespace Microsoft.ContainerRegistry

if ! az group show --name "$RG" &>/dev/null; then
  echo "Creando grupo de recursos $RG en $LOC..."
  az group create --name "$RG" --location "$LOC"
fi

if ! az apim show --name "arepas-gw-$NOMBRE" --resource-group "$RG" &>/dev/null; then
  echo "Aprovisionando API Management arepas-gw-$NOMBRE (Consumption)..."
  az apim create --name "arepas-gw-$NOMBRE" --resource-group "$RG" --location "$LOC" \
    --publisher-name "Arepa Express" --publisher-email "$PUBLISHER_EMAIL" \
    --sku-name Consumption --no-wait
fi

echo "Entorno base preparado correctamente."

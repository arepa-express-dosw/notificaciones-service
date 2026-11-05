#!/usr/bin/env bash
# ==============================================================================
# 00-prepare-azure.sh
# Registra los proveedores de Azure, crea el grupo de recursos y el API Management
# ==============================================================================
set -euo pipefail

NOMBRE="${NOMBRE:-oscarlasso}"
RG="${RG:-rg-arepas-$NOMBRE}"
LOC="${LOC:-northcentralus}"
PUBLISHER_EMAIL="${PUBLISHER_EMAIL:-oscar.lasso-m@mail.escuelaing.edu.co}"

echo "==> [00-prepare-azure] Preparando Azure para Arepa Express ($NOMBRE)..."
echo "==> Resource Group: $RG | Region: $LOC"

# Registro de extensiones y proveedores
az extension add --name containerapp --upgrade || true
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.ApiManagement
az provider register --namespace Microsoft.ContainerInstance
az provider register --namespace Microsoft.ContainerRegistry

# Crear grupo de recursos de manera idempotente
if ! az group show --name "$RG" &>/dev/null; then
  echo "Creando grupo de recursos $RG en $LOC..."
  az group create --name "$RG" --location "$LOC"
else
  echo "Grupo de recursos $RG ya existe."
fi

# Crear API Management en plan Consumption si no existe
if ! az apim show --name "arepas-gw-$NOMBRE" --resource-group "$RG" &>/dev/null; then
  echo "Creando APIM arepas-gw-$NOMBRE en $LOC..."
  az apim create --name "arepas-gw-$NOMBRE" --resource-group "$RG" --location "$LOC" \
    --publisher-name "Arepa Express" --publisher-email "$PUBLISHER_EMAIL" \
    --sku-name Consumption --no-wait
else
  echo "APIM arepas-gw-$NOMBRE ya existe."
fi

echo "==> Preparación inicial completada con éxito."


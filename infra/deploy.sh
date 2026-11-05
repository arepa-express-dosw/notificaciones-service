#!/usr/bin/env bash
set -euo pipefail

NOMBRE="${NOMBRE:-oscarlasso}"
RG="${RG:-rg-arepas-$NOMBRE}"
LOC="${LOC:-northcentralus}"
APP_NAME="notificaciones-service"
RABBIT_HOST="${RABBIT_HOST:-arepas-rabbit-$NOMBRE.$LOC.azurecontainer.io}"
RABBIT_USER="${RABBIT_USER:-arepas}"
RABBIT_PASS="${RABBIT_PASS:-Arepa-$NOMBRE-2026}"

echo "Desplegando $APP_NAME en Container Apps..."

ACR_SERVER=$(az acr list -g "$RG" --query "[0].loginServer" -o tsv)
ACR_NAME="${ACR_SERVER%%.*}"
ACR_USER=$(az acr credential show -n "$ACR_NAME" --query "username" -o tsv)
ACR_PASS=$(az acr credential show -n "$ACR_NAME" --query "passwords[0].value" -o tsv)
IMAGE="$ACR_SERVER/$APP_NAME:latest"

az containerapp up --name "$APP_NAME" --resource-group "$RG" --location "$LOC" \
  --environment arepas-env --image "$IMAGE" \
  --registry-server "$ACR_SERVER" --registry-username "$ACR_USER" --registry-password "$ACR_PASS" \
  --ingress internal --target-port 8080 \
  --env-vars "RABBIT_HOST=$RABBIT_HOST" "RABBIT_USER=$RABBIT_USER" "RABBIT_PASS=$RABBIT_PASS"

az containerapp update --name "$APP_NAME" --resource-group "$RG" --min-replicas 1 --max-replicas 1

echo "$APP_NAME desplegado con réplica fija."

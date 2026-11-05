#!/usr/bin/env bash
set -euo pipefail

NOMBRE="${NOMBRE:-oscarlasso}"
RG="${RG:-rg-arepas-$NOMBRE}"
GW_NAME="arepas-gw-$NOMBRE"

echo "Configurando APIs en $GW_NAME..."

MENU_FQDN=$(az containerapp show -n menu-service -g "$RG" --query properties.configuration.ingress.fqdn -o tsv 2>/dev/null || echo "")
PEDIDOS_FQDN=$(az containerapp show -n pedidos-service -g "$RG" --query properties.configuration.ingress.fqdn -o tsv 2>/dev/null || echo "")

if [ -z "$MENU_FQDN" ] || [ -z "$PEDIDOS_FQDN" ]; then
  echo "Aviso: uno o ambos microservicios no están disponibles aún en Container Apps."
fi

MENU_URL="https://$MENU_FQDN"
PEDIDOS_URL="https://$PEDIDOS_FQDN"

echo "Registrando menu-api en $MENU_URL..."
az apim api create --resource-group "$RG" --service-name "$GW_NAME" \
  --api-id menu-api --path menu-api --display-name "Menu API" \
  --service-url "$MENU_URL" --protocols https --subscription-required true || true

az apim api operation create --resource-group "$RG" --service-name "$GW_NAME" \
  --api-id menu-api --url-template "/menu" --method GET --display-name "Ver menú" || true

echo "Registrando pedidos-api en $PEDIDOS_URL..."
az apim api create --resource-group "$RG" --service-name "$GW_NAME" \
  --api-id pedidos-api --path pedidos-api --display-name "Pedidos API" \
  --service-url "$PEDIDOS_URL" --protocols https --subscription-required true || true

az apim api operation create --resource-group "$RG" --service-name "$GW_NAME" \
  --api-id pedidos-api --url-template "/pedidos" --method POST --display-name "Crear pedido" || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POLICY_FILE="$SCRIPT_DIR/policy-arepa-gateway.xml"
if [ -f "$POLICY_FILE" ]; then
  echo "Aplicando política de encabezado X-Arepa-Gateway..."
  az apim api policy update --resource-group "$RG" --service-name "$GW_NAME" \
    --api-id menu-api --value "@$POLICY_FILE" --format rawxml || true
fi

echo "APIs configuradas exitosamente en el gateway."

#!/usr/bin/env bash
# ==============================================================================
# 02-setup-apim.sh
# Publica las APIs (menu-api y pedidos-api) en Azure API Management y aplica
# la política de salida X-Arepa-Gateway: DOSW Company
# ==============================================================================
set -euo pipefail

NOMBRE="${NOMBRE:-oscarlasso}"
RG="${RG:-rg-arepas-$NOMBRE}"
GW_NAME="arepas-gw-$NOMBRE"

echo "==> [02-setup-apim] Configurando APIs en API Management: $GW_NAME..."

# Obtener FQDNs de los microservicios desplegados
MENU_FQDN=$(az containerapp show -n menu-service -g "$RG" --query properties.configuration.ingress.fqdn -o tsv 2>/dev/null || echo "")
PEDIDOS_FQDN=$(az containerapp show -n pedidos-service -g "$RG" --query properties.configuration.ingress.fqdn -o tsv 2>/dev/null || echo "")

if [ -z "$MENU_FQDN" ] || [ -z "$PEDIDOS_FQDN" ]; then
  echo "ADVERTENCIA: Uno o ambos servicios no están desplegados aún. Revisa az containerapp list."
fi

MENU_URL="https://$MENU_FQDN"
PEDIDOS_URL="https://$PEDIDOS_FQDN"

# Registrar menu-api
echo "Registrando menu-api (URL: $MENU_URL)..."
az apim api create --resource-group "$RG" --service-name "$GW_NAME" \
  --api-id menu-api --path menu-api --display-name "Menu API" \
  --service-url "$MENU_URL" --protocols https --subscription-required true || true

az apim api operation create --resource-group "$RG" --service-name "$GW_NAME" \
  --api-id menu-api --url-template "/menu" --method GET --display-name "Ver menú" || true

# Registrar pedidos-api
echo "Registrando pedidos-api (URL: $PEDIDOS_URL)..."
az apim api create --resource-group "$RG" --service-name "$GW_NAME" \
  --api-id pedidos-api --path pedidos-api --display-name "Pedidos API" \
  --service-url "$PEDIDOS_URL" --protocols https --subscription-required true || true

az apim api operation create --resource-group "$RG" --service-name "$GW_NAME" \
  --api-id pedidos-api --url-template "/pedidos" --method POST --display-name "Crear pedido" || true

# Aplicar política X-Arepa-Gateway a menu-api
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POLICY_FILE="$SCRIPT_DIR/policy-arepa-gateway.xml"
if [ -f "$POLICY_FILE" ]; then
  echo "Aplicando política de salida X-Arepa-Gateway a menu-api..."
  az apim api policy update --resource-group "$RG" --service-name "$GW_NAME" \
    --api-id menu-api --value "@$POLICY_FILE" --format rawxml || true
fi

echo "==> Configuración de APIM completada."

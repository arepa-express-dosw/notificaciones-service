#!/usr/bin/env bash
set -euo pipefail

NOMBRE="${NOMBRE:-oscarlasso}"
RG="${RG:-rg-arepas-$NOMBRE}"
LOC="${LOC:-northcentralus}"
RABBIT_PASS="${RABBIT_PASS:-Arepa-$NOMBRE-2026}"
DNS_LABEL="arepas-rabbit-$NOMBRE"

echo "Desplegando RabbitMQ en Azure Container Instances ($LOC)..."

if ! az container show --resource-group "$RG" --name arepas-rabbit &>/dev/null; then
  az container create --resource-group "$RG" --name arepas-rabbit \
    --image rabbitmq:3-management --os-type Linux --cpu 1 --memory 1.5 \
    --ports 5672 15672 --ip-address Public --dns-name-label "$DNS_LABEL" \
    --location "$LOC" \
    --environment-variables RABBITMQ_DEFAULT_USER=arepas \
    --secure-environment-variables RABBITMQ_DEFAULT_PASS="$RABBIT_PASS"
fi

RABBIT_HOST="$DNS_LABEL.$LOC.azurecontainer.io"
echo "RabbitMQ activo en: $RABBIT_HOST:5672"
echo "Panel web: http://$RABBIT_HOST:15672 (usuario: arepas)"

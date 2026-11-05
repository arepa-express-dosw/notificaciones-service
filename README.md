# notificaciones-service

Consumidor asíncrono que procesa eventos de pedidos creados para registrar las notificaciones al cliente.

## Integración con RabbitMQ

- Exchange: `arepas.eventos` (topic)
- Cola: `notificaciones.pedidos` (durable)
- Routing key vinculada: `pedido.creado`

Aplica el patrón de distribución uno a muchos: comparte el exchange con `cocina-service`, manteniendo su propia cola de mensajes independiente.

## Variables de entorno

| Variable | Valor por defecto | Propósito |
|---|---|---|
| `RABBIT_HOST` | `localhost` | Host del broker RabbitMQ |
| `RABBIT_USER` | `arepas` | Usuario de conexión AMQP |
| `RABBIT_PASS` | `arepas123` | Contraseña del broker |

## Ejecución local

```bash
docker run -d -p 5672:5672 -p 15672:15672 \
  -e RABBITMQ_DEFAULT_USER=arepas \
  -e RABBITMQ_DEFAULT_PASS=arepas123 \
  rabbitmq:3-management

mvn spring-boot:run
```

En Azure Container Apps opera con ingress interno y una réplica fija para procesar los mensajes en segundo plano.

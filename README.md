# notificaciones-service

Arepa Express notificaciones microservice. Spring Boot 3.5, Java 21, Maven, Spring AMQP.

Consumes `pedido` events from RabbitMQ and logs a customer notification.

| Item | Value |
|---|---|
| Exchange | `arepas.eventos` (topic) |
| Queue | `notificaciones.pedidos` (durable) |
| Binding | `pedido.creado` |

## Configuration

| Variable | Default |
|---|---|
| `RABBIT_HOST` | `localhost` |
| `RABBIT_USER` | `arepas` |
| `RABBIT_PASS` | `arepas123` |

## Run locally

```bash
docker run -d -p 5672:5672 -p 15672:15672 -e RABBITMQ_DEFAULT_USER=arepas -e RABBITMQ_DEFAULT_PASS=arepas123 rabbitmq:3-management
mvn spring-boot:run
```

Deployed to Azure Container Apps as `notificaciones-service` with internal ingress and one always-on replica.

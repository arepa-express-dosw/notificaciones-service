package edu.dosw.arepas.notificaciones;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class NotificacionesListener {

    private static final Logger log = LoggerFactory.getLogger(NotificacionesListener.class);

    @RabbitListener(queues = RabbitConfig.QUEUE)
    public void avisar(PedidoCreadoEvent pedido) {
        log.info("Notificación para {}: pedido {} recibido y en preparación.", pedido.cliente(), pedido.pedidoId());
    }
}

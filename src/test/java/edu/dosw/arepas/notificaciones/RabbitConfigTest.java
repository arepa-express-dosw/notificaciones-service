package edu.dosw.arepas.notificaciones;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;
import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.Queue;

class RabbitConfigTest {

    private final RabbitConfig config = new RabbitConfig();

    @Test
    void bindsDurableQueueToArepasExchange() {
        Queue cola = config.cola();
        Binding binding = config.binding(cola, config.arepasExchange());

        assertTrue(cola.isDurable());
        assertEquals("notificaciones.pedidos", cola.getName());
        assertEquals("arepas.eventos", binding.getExchange());
        assertEquals("pedido.creado", binding.getRoutingKey());
    }
}

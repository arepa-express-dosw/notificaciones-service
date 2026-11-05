package edu.dosw.arepas.notificaciones;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitConfig {

    static final String EXCHANGE = "arepas.eventos";
    static final String QUEUE = "notificaciones.pedidos";
    static final String ROUTING_KEY = "pedido.creado";

    @Bean
    public TopicExchange arepasExchange() {
        return new TopicExchange(EXCHANGE);
    }

    @Bean
    public Queue cola() {
        return new Queue(QUEUE, true);
    }

    @Bean
    public Binding binding(Queue cola, TopicExchange arepasExchange) {
        return BindingBuilder.bind(cola).to(arepasExchange).with(ROUTING_KEY);
    }

    @Bean
    public MessageConverter jsonConverter() {
        Jackson2JsonMessageConverter converter = new Jackson2JsonMessageConverter();
        converter.setAlwaysConvertToInferredType(true);
        return converter;
    }
}

package edu.dosw.arepas.notificaciones;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

import java.util.List;

import org.junit.jupiter.api.Test;

class NotificacionesListenerTest {

    @Test
    void avisarHandlesOrderWithoutError() {
        assertDoesNotThrow(() -> new NotificacionesListener().avisar(
                new PedidoCreadoEvent("abc12345", "Laura", List.of("choclo"), "2026-11-05T10:00:00")));
    }
}

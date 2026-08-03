# Scrolling Background Spec

## Objetivo

Agregar un ejemplo de fondo espacial con parallax vertical para transmitir avance durante la partida sin afectar la simulación multijugador.

## Alcance

- Reemplazar el fondo estático de `GameScreen` por capas desplazables.
- Usar dos capas visuales basadas en el fondo espacial existente.
- Mover las capas verticalmente a velocidades distintas.
- Reciclar cada capa al salir de pantalla para crear scroll continuo.
- Mantener el fondo detrás de HUD, naves, enemigos y proyectiles.
- Hacer el efecto local y puramente visual, sin mensajes de red.

## Diseño inicial

| Capa | Velocidad | Tratamiento |
| --- | ---: | --- |
| Nebulosa lejana | 8 px/s | Oscura, movimiento lento |
| Campo espacial cercano | 24 px/s | Más visible, movimiento rápido |

Cada capa tendrá dos copias verticales de su textura. Al salir una por debajo del viewport, reaparece arriba de la otra, sin interrupción visible.

## Criterios de aceptación

- [ ] El fondo se desplaza continuamente durante la partida.
- [ ] Las dos capas se mueven a velocidades diferentes.
- [ ] No aparece un corte vacío al reciclar una capa.
- [ ] El HUD y el gameplay permanecen por encima del fondo.
- [ ] El efecto no altera posiciones, colisiones ni red.
- [ ] Godot carga sin errores en modo headless.

## Fuera de alcance

- Fondos nuevos por nivel.
- Partículas interactivas.
- Transiciones de bioma.
- Sincronización de scroll entre clientes.

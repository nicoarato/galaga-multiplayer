# Parallax Visibility Spec

## Objetivo

Hacer que el movimiento de parallax sea evidente durante los primeros segundos de juego, conservando una estética espacial legible.

## Problema observado

Las velocidades iniciales de `8 px/s` y `24 px/s`, junto con capas demasiado transparentes sobre un fondo base completo, hacen que el desplazamiento sea difícil de percibir.

## Ajuste

| Capa | Velocidad anterior | Nueva velocidad | Tratamiento |
| --- | ---: | ---: | --- |
| Base | Estática y brillante | Estática y oscura | Reduce competencia visual |
| Lejana | 8 px/s | 28 px/s | Nebulosa visible |
| Cercana | 24 px/s | 96 px/s | Movimiento claramente perceptible |

Las capas aumentarán su opacidad para que las estrellas y nebulosas se distingan del fondo base.

## Criterios de aceptación

- [x] El movimiento se aprecia dentro de los primeros 3 segundos.
- [x] La capa cercana se mueve claramente más rápido que la lejana.
- [x] El HUD y enemigos se mantienen legibles.
- [x] No hay huecos al reciclar las capas.
- [x] Godot carga sin errores en modo headless.

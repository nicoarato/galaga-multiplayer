# Player Health UI and Regen Spec

## Objetivo

Agregar el primer sistema visible de energia para jugadores: cada nave tiene vida maxima, una clase con stats iniciales y una barra superior de energia.

Este corte prioriza feedback jugable local y prepara el camino para daño sincronizado. La regeneracion se activa despues de `4 segundos` sin disparar, tomando como referencia la recuperacion fuera de combate de Brawl Stars.

## Alcance

- Definir clases iniciales de nave con stats distintos.
- Asignar clase deterministica segun orden de jugador.
- Mostrar energia/vida de jugadores en el HUD superior.
- Mostrar clase de nave en el HUD.
- Mantener vida en porcentaje y puntos internos.
- Trackear ultimo disparo local.
- Regenerar vida local despues de `4 segundos` sin disparar.
- Cortar/reiniciar timer de regeneracion al disparar.
- Mantener vida clamp entre `0` y `maxHealth`.

## Fuera de Alcance

- Daño recibido por jugadores.
- Muerte/respawn.
- Seleccion manual de clase.
- Backend como autoridad de vida.
- Sincronizacion de vida entre clientes.
- Danio real de proyectiles contra jugadores.
- Balance final de stats.

## Stats Iniciales

| Clase | Vida Maxima | Daño | Regeneracion | Intencion |
| --- | ---: | ---: | ---: | --- |
| Scout | 80 | 18 | 18/s | Fragil y recupera rapido |
| Fighter | 100 | 24 | 14/s | Balanceada |
| Tank | 140 | 16 | 9/s | Mucha vida y menor daño |
| Striker | 90 | 32 | 12/s | Alto daño y menos margen |

## Checklist

- [x] Crear catalogo de clases de nave.
- [x] Asignar clase por indice de jugador.
- [x] Guardar health/maxHealth por jugador en `GameScreen`.
- [x] Crear HUD superior de energia.
- [x] Mostrar nombre, clase y porcentaje de energia.
- [x] Actualizar HUD al cambiar jugadores.
- [x] Trackear disparo local como actividad ofensiva.
- [x] Regenerar despues de `4 segundos` sin disparar.
- [x] Reiniciar timer de regeneracion al disparar.
- [x] Mantener clamp de vida a `maxHealth`.
- [x] No modificar backend.

## Criterios de Aceptacion

- [x] Cada jugador tiene una barra de energia visible arriba.
- [x] Cada barra muestra clase y porcentaje.
- [x] P1 y P2 pueden tener stats distintos por clase.
- [x] Disparar reinicia la espera de regeneracion.
- [x] La regeneracion no supera `100%`.
- [x] Movimiento, disparos y destruccion de enemigos siguen funcionando.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

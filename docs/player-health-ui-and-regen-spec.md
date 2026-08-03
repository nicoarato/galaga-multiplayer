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

- [ ] Crear catalogo de clases de nave.
- [ ] Asignar clase por indice de jugador.
- [ ] Guardar health/maxHealth por jugador en `GameScreen`.
- [ ] Crear HUD superior de energia.
- [ ] Mostrar nombre, clase y porcentaje de energia.
- [ ] Actualizar HUD al cambiar jugadores.
- [ ] Trackear disparo local como actividad ofensiva.
- [ ] Regenerar despues de `4 segundos` sin disparar.
- [ ] Reiniciar timer de regeneracion al disparar.
- [ ] Mantener clamp de vida a `maxHealth`.
- [ ] No modificar backend.

## Criterios de Aceptacion

- [ ] Cada jugador tiene una barra de energia visible arriba.
- [ ] Cada barra muestra clase y porcentaje.
- [ ] P1 y P2 pueden tener stats distintos por clase.
- [ ] Disparar reinicia la espera de regeneracion.
- [ ] La regeneracion no supera `100%`.
- [ ] Movimiento, disparos y destruccion de enemigos siguen funcionando.
- [ ] Godot carga sin errores con `godot --headless --path game --quit`.

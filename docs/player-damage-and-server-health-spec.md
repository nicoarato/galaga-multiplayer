# Player Damage and Server Health Spec

## Objetivo

Agregar daño recibido por los jugadores y mover la autoridad de vida al backend para que ambos clientes compartan el mismo estado de combate.

## Alcance del corte

- Agregar proyectiles enemigos periódicos y sincronizados.
- Detectar impactos contra las naves de los jugadores.
- Solicitar al backend la aplicación de daño.
- Mantener la vida actual de cada jugador en `RoomStore`.
- Replicar cambios de vida a todos los clientes de la sala.
- Hacer que el backend controle la regeneración después de 4 segundos sin disparar.
- Cortar la regeneración cuando el jugador dispara o recibe daño.
- Mostrar en el HUD la vida recibida desde el backend.
- Definir estado de jugador derrotado al llegar a cero de vida.

## Diseño de autoridad

El cliente solo informa acciones y eventos de colisión. El backend valida el contexto de partida, calcula el nuevo valor de vida, aplica límites y publica el estado resultante.

```text
Cliente detecta impacto
        |
        v
Backend valida jugador y partida
        |
        v
Backend aplica daño o regeneración
        |
        v
Broadcast player_health
        |
        v
Todos los clientes actualizan HUD y estado visual
```

## Contrato de red propuesto

Mensaje cliente para reportar un impacto enemigo:

```json
{
  "type": "enemy_hit_player",
  "playerId": "player-2",
  "damage": 12
}
```

Mensaje servidor para publicar vida:

```json
{
  "type": "player_health",
  "playerId": "player-2",
  "health": 76,
  "maxHealth": 100,
  "defeated": false
}
```

El backend debe rechazar daños no finitos, no positivos, dirigidos a jugadores inexistentes o enviados fuera de una partida iniciada. En esta primera versión el servidor recibe el evento de colisión, pero conserva la validación y el estado final.

## Balance inicial

- Daño de proyectil enemigo: `12`.
- Cadencia de disparo enemigo: `2.5 segundos`.
- Regeneración: comienza después de `4 segundos` sin disparar ni recibir daño.
- La vida nunca supera `maxHealth` ni baja de `0`.
- Un jugador derrotado deja de regenerar y no puede volver a disparar en este corte.

## Fuera de alcance

- IA compleja de enemigos.
- Patrones diferenciados de proyectiles enemigos.
- Respawn.
- Pantalla de game over.
- Reinicio de ronda.
- Anticheat completo contra falsos reportes de colisión.

## Criterios de aceptación

- [ ] El backend valida el mensaje `enemy_hit_player`.
- [ ] El backend mantiene vida y estado derrotado por jugador.
- [ ] El backend replica `player_health` a todos los clientes.
- [ ] Los proyectiles enemigos se generan periódicamente.
- [ ] Un impacto reduce la vida del jugador en ambas pantallas.
- [ ] La regeneración comienza después de 4 segundos sin disparar ni recibir daño.
- [ ] Disparar o recibir daño reinicia el temporizador de regeneración.
- [ ] La vida se mantiene entre cero y el máximo.
- [ ] Un jugador con cero de vida deja de disparar.
- [ ] Se mantienen lint, typecheck y 100% de coverage del backend.
- [ ] Godot carga sin errores en modo headless.

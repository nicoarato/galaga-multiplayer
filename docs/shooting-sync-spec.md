# Shooting Sync Spec

Spec del siguiente corte: sincronizar disparos entre clientes conectados.

## Objetivo

Cuando un jugador dispara, los demas clientes de la sala deben ver ese proyectil.

```text
local shoot -> player_shot -> backend broadcast -> remote projectile spawn
```

Este corte completa el primer loop multiplayer visible: movimiento y disparo compartidos.

## Alcance

Incluye:

- agregar mensaje WebSocket `player_shot`;
- validar payload del disparo;
- backend broadcast del disparo a la sala;
- Godot envia `player_shot` al disparar localmente;
- Godot recibe disparos remotos;
- Godot instancia proyectiles remotos;
- evitar duplicar el proyectil local;
- mantener proyectiles sin colisiones.

No incluye:

- colisiones;
- daño;
- score;
- enemigos;
- owner authoritative projectiles;
- reconciliacion de proyectiles;
- timestamps de servidor;
- persistencia de disparos.

## Protocolo

Nuevo mensaje cliente -> servidor:

```json
{
  "type": "player_shot",
  "shot": {
    "x": 320,
    "y": 240
  }
}
```

Reglas:

- solo se acepta si el jugador ya hizo `join_room`;
- solo se acepta si la sala esta `in_game`;
- `shot.x` y `shot.y` deben ser numeros finitos;
- el backend no guarda proyectiles todavia;
- el backend rebroadcast a todos los clientes de la sala.

Nuevo mensaje servidor -> cliente:

```json
{
  "type": "player_shot",
  "playerId": "player-id",
  "shot": {
    "x": 320,
    "y": 240
  }
}
```

## Decision Tecnica

El cliente local crea el proyectil inmediatamente para respuesta visual. Cuando recibe el broadcast propio desde backend, lo ignora usando `playerId`.

Motivos:

- control local sigue inmediato;
- clientes remotos ven el disparo;
- backend sigue simple;
- no necesitamos IDs de proyectil todavia.

Tradeoff aceptado:

- los proyectiles no quedan autoritativos;
- puede haber una pequena diferencia visual de spawn entre clientes;
- si luego agregamos colisiones online, haremos otro corte.

## Godot

Actualizar `RoomSocket`:

- agregar senal `player_shot_received(player_id, shot_position)`;
- agregar `send_player_shot(shot_position)`;
- manejar mensajes `player_shot`.

Actualizar `Main`:

- conectar disparos locales desde `GameScreen` hacia `RoomSocket`;
- conectar disparos recibidos desde `RoomSocket` hacia `GameScreen`.

Actualizar `GameScreen`:

- emitir `local_player_shot(spawn_position)`;
- crear proyectil local inmediatamente;
- crear proyectil remoto al recibir shot de otro player;
- ignorar disparos recibidos del `local_player_id`.

## Backend

Actualizar protocolo:

- parsear `player_shot`;
- validar `shot.x` y `shot.y`;
- agregar tests.

Actualizar server:

- rechazar si no hizo `join_room`;
- rechazar si la sala no esta `in_game`;
- broadcast `player_shot` con `playerId` y `shot`.

No se requiere cambio persistente en `RoomStore`, pero puede agregarse un helper de validacion de estado si mejora testabilidad.

## Checklist

- [x] Crear spec `docs/shooting-sync-spec.md`.
- [x] Actualizar `docs/milestones.md`.
- [x] Agregar mensaje `player_shot`.
- [x] Validar payload `player_shot`.
- [x] Agregar tests backend de mensaje.
- [x] Backend rechaza disparo sin `join_room`.
- [x] Backend rechaza disparo si sala no esta `in_game`.
- [x] Backend broadcast de disparo con `playerId`.
- [x] Agregar `RoomSocket.send_player_shot`.
- [x] Agregar senal `player_shot_received`.
- [x] Godot envia disparo local.
- [x] Godot recibe disparos remotos.
- [x] Godot ignora broadcast propio.
- [x] Godot instancia proyectil remoto.
- [x] No agregar colisiones.
- [x] Godot carga sin errores.
- [x] Backend mantiene lint/typecheck/coverage OK.

## Criterios de Aceptacion

- [x] Host crea sala.
- [x] Guest entra y marca `READY`.
- [x] Host presiona `START GAME`.
- [x] P1 dispara y P2 ve el proyectil.
- [x] P2 dispara y P1 ve el proyectil.
- [x] El cliente local no duplica su propio proyectil.
- [x] Los proyectiles siguen moviendose hacia arriba.
- [x] No hay colisiones ni score en este corte.
- [x] `godot --headless --path game --quit` pasa.
- [x] `npm run lint` pasa.
- [x] `npm run typecheck` pasa.
- [x] `npm run coverage` pasa con 100%.

## Observaciones de Validacion

- Los disparos se sincronizan entre dos clientes.
- El proyectil local no se duplica al recibir el broadcast propio.
- Colisiones, enemigos y score quedan para cortes posteriores.

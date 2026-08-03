# Ready / Start Spec

Spec del siguiente corte: completar el lobby para que los jugadores puedan marcarse listos y el host pueda iniciar la partida.

## Objetivo

Convertir el lobby en un flujo jugable completo hasta el evento `game_started`.

```text
Entrar al lobby -> marcar READY -> host inicia -> todos reciben game_started
```

Este corte no incluye gameplay. `game_started` puede mostrar un estado placeholder o preparar el cambio posterior a una escena vacia de juego.

## Alcance

Incluye:

- boton `READY` funcional en Godot;
- envio de `set_ready`;
- actualizacion visual del estado ready por jugador;
- deteccion de host en cliente;
- boton `START GAME` visible/habilitado para host;
- envio de `start_game`;
- recepcion de `game_started`;
- feedback claro si el start falla.

No incluye:

- escena de gameplay real;
- seleccion de nave;
- matchmaking publico;
- persistencia;
- reconexion a partidas ya iniciadas.

## Reglas de Lobby

### Host

- El primer jugador que entra a una sala es host.
- El backend expone `room.hostPlayerId`.
- Godot debe comparar `hostPlayerId` contra el jugador local.
- Solo el host puede iniciar partida.

### Ready

- Cada jugador puede alternar su estado ready.
- El host no necesita marcar ready para iniciar en este corte.
- Los invitados deben estar ready para que el host pueda iniciar.
- Godot debe mostrar `READY` / `WAIT` por jugador.

### Start

- `START GAME` debe estar habilitado solo para host.
- Si hay invitados no listos, el backend responde `players_not_ready`.
- Si el start es valido, el backend cambia `room.status` a `in_game` y emite `game_started`.
- Al recibir `game_started`, Godot muestra estado claro.

Mensaje placeholder sugerido:

```text
Game starting...
```

## Cambios Tecnicos Esperados

### Godot

Actualizar `RoomSocket`:

- metodo `set_ready(ready: bool)`;
- metodo `start_game()`;
- guardar estado de conexion suficiente para enviar mensajes solo cuando el socket esta abierto.

Actualizar `Main`:

- guardar `local_player_id` al recibir `room_state`;
- determinar si el jugador local es host;
- pasar a `LobbyScreen`:
  - room;
  - local player id;
  - host status;
- manejar `ready_requested`;
- manejar `start_game_requested`;
- manejar `game_started`.

Actualizar `LobbyScreen`:

- mostrar host visualmente;
- mostrar ready/wait por jugador;
- alternar texto del boton `READY` si el jugador local esta listo;
- habilitar/deshabilitar `START GAME` segun host;
- mostrar error/status de start.

### Backend

Backend ya tiene:

- `set_ready`;
- `start_game`;
- `players_not_ready`;
- `game_started`.

Revisar si hace falta ajustar:

- host no necesita ready;
- invitados deben estar ready;
- errores estan correctamente emitidos;
- `game_started` llega a todos los sockets de la sala.

## Protocolo

### Client -> Server

```json
{
  "type": "set_ready",
  "ready": true
}
```

```json
{
  "type": "start_game"
}
```

### Server -> Client

```json
{
  "type": "room_state",
  "room": {
    "id": "room-id",
    "status": "lobby",
    "hostPlayerId": "player-id",
    "players": []
  }
}
```

```json
{
  "type": "game_started",
  "room": {
    "id": "room-id",
    "status": "in_game",
    "hostPlayerId": "player-id",
    "players": []
  }
}
```

## Checklist

- [ ] `RoomSocket.set_ready(ready)` envia `set_ready`.
- [ ] `RoomSocket.start_game()` envia `start_game`.
- [ ] Godot guarda `local_player_id`.
- [ ] Godot detecta host con `room.hostPlayerId`.
- [ ] `LobbyScreen` muestra host.
- [ ] `LobbyScreen` muestra ready/wait.
- [ ] `READY` alterna estado del jugador local.
- [ ] `START GAME` esta habilitado solo para host.
- [ ] Host recibe error claro si faltan jugadores ready.
- [ ] Invitado recibe error claro si intenta iniciar.
- [ ] `game_started` se muestra en todos los clientes.
- [ ] No se agregan endpoints HTTP nuevos.
- [ ] Godot carga sin errores.
- [ ] Backend mantiene lint/typecheck/coverage OK.

## Criterios de Aceptacion

- Un invitado puede marcarse ready.
- La lista de jugadores se actualiza con `READY`.
- El host ve `START GAME` habilitado.
- Un invitado no puede iniciar partida.
- El host no puede iniciar si falta un invitado ready.
- El host puede iniciar cuando corresponde.
- Todos los clientes reciben `game_started`.
- `godot --headless --path game --quit` pasa.
- `npm run lint` pasa.
- `npm run typecheck` pasa.
- `npm run coverage` pasa con 100%.

# Multiplayer Protocol

Contrato inicial de mensajes entre el cliente Godot y el backend.

## Transporte

- HTTP para crear y consultar salas.
- WebSocket para lobby y eventos realtime.
- Payloads JSON.

## HTTP

### `GET /health`

Respuesta:

```json
{
  "ok": true
}
```

### `POST /api/rooms`

Crea una sala efimera en memoria.

Respuesta:

```json
{
  "roomId": "room-id",
  "joinPath": "/room/room-id",
  "room": {
    "id": "room-id",
    "status": "lobby",
    "hostPlayerId": null,
    "players": [],
    "createdAt": "2026-08-02T00:00:00.000Z"
  }
}
```

### `GET /api/rooms/{roomId}`

Devuelve el estado publico de una sala.

Respuesta `200`:

```json
{
  "room": {
    "id": "room-id",
    "status": "lobby",
    "hostPlayerId": "player-id",
    "players": [
      {
        "id": "player-id",
        "name": "Nico",
        "ready": false,
        "connected": true
      }
    ],
    "createdAt": "2026-08-02T00:00:00.000Z"
  }
}
```

Respuesta `404`:

```json
{
  "error": "room_not_found"
}
```

## WebSocket

Endpoint:

```text
WS /ws/rooms/{roomId}
```

## Flujo Implementado en Godot

El cliente Godot ya implementa el primer flujo de lobby:

1. El jugador ingresa nombre en la Home.
2. Presiona `START ROOM`.
3. Godot llama `POST /api/rooms`.
4. El backend crea una sala y devuelve `room.id`.
5. Godot conecta a `WS /ws/rooms/{roomId}`.
6. Godot envia `join_room` con `playerName`.
7. El backend responde `room_state`.
8. Godot muestra la cantidad de jugadores conectados.

Estado esperado en UI:

```text
Lobby conectado: 1 jugador(es).
```

## Client -> Server

### `join_room`

```json
{
  "type": "join_room",
  "playerName": "Nico"
}
```

Reglas:

- `playerName` se recorta con trim.
- No puede estar vacio.
- Maximo 24 caracteres.

### `leave_room`

```json
{
  "type": "leave_room"
}
```

### `set_ready`

```json
{
  "type": "set_ready",
  "ready": true
}
```

### `start_game`

```json
{
  "type": "start_game"
}
```

### `ping`

```json
{
  "type": "ping",
  "timestamp": 1785628800000
}
```

## Server -> Client

### `room_state`

```json
{
  "type": "room_state",
  "room": {
    "id": "room-id",
    "status": "lobby",
    "hostPlayerId": "player-id",
    "players": [],
    "createdAt": "2026-08-02T00:00:00.000Z"
  }
}
```

### `game_started`

```json
{
  "type": "game_started",
  "room": {
    "id": "room-id",
    "status": "in_game",
    "hostPlayerId": "player-id",
    "players": [],
    "createdAt": "2026-08-02T00:00:00.000Z"
  }
}
```

### `pong`

```json
{
  "type": "pong",
  "timestamp": 1785628800000
}
```

### `error`

```json
{
  "type": "error",
  "reason": "room_not_found"
}
```

Regla cliente:

- Si el error ocurre antes de recibir `room_state`, Godot debe permanecer en Home.
- Si el error ocurre dentro de Lobby, Godot debe mostrar el error en el estado del lobby.
- El cliente debe mapear `reason` a un mensaje legible de UI.

Errores iniciales:

- `room_not_found`
- `room_full`
- `game_already_started`
- `player_not_joined`
- `player_not_found`
- `not_host`
- `already_started`
- `players_not_ready`

## Room

```json
{
  "id": "room-id",
  "status": "lobby",
  "hostPlayerId": "player-id",
  "players": [],
  "createdAt": "2026-08-02T00:00:00.000Z"
}
```

`status` puede ser:

- `lobby`
- `in_game`

## Player

```json
{
  "id": "player-id",
  "name": "Nico",
  "ready": false,
  "connected": true
}
```

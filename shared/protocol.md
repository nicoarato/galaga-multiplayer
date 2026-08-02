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

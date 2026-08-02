# Lobby Error Handling Spec

Spec del corte actual: robustecer errores y desconexiones del lobby antes de avanzar a `READY / START`.

## Objetivo

El flujo de lobby debe comportarse de forma predecible cuando:

- un jugador intenta entrar a una sala inexistente;
- una sala rechaza el ingreso;
- un jugador vuelve a Home usando `BACK`;
- un jugador se desconecta o cierra el cliente;
- otro cliente necesita ver la lista de jugadores actualizada.

## Alcance

Este corte cubre solo lobby. No incluye gameplay, ready/start, matchmaking publico ni persistencia.

## Comportamiento Esperado

### Join a sala inexistente

Cuando el jugador intenta unirse a un `roomId` que no existe:

- El backend responde por WebSocket con `error`.
- Godot muestra un mensaje claro en Home.
- Godot no cambia a Lobby.
- La conexion WebSocket se cierra o queda descartada de forma controlada.

Mensaje sugerido:

```text
Sala no encontrada.
```

### Join a sala llena

Cuando el jugador intenta unirse a una sala que alcanzo el limite:

- El backend responde por WebSocket con `error`.
- Godot muestra un mensaje claro en Home.
- Godot no cambia a Lobby.

Mensaje sugerido:

```text
Sala llena.
```

### Back desde Lobby

Cuando el jugador presiona `BACK`:

- Godot envia `leave_room` si corresponde.
- Godot cierra el WebSocket.
- Godot vuelve a Home.
- No debe mostrarse `Conexion de lobby cerrada.` como error despues de volver.
- La sala debe actualizarse para los otros jugadores.

### Desconexion de otro jugador

Cuando un jugador se va:

- El backend lo elimina de la sala.
- Si quedan jugadores, el backend emite `room_state`.
- Los clientes restantes actualizan la lista.
- Si la sala queda vacia, el backend la elimina.

## Cambios Tecnicos Esperados

### Godot

Actualizar `RoomSocket` para:

- distinguir cierre intencional vs cierre inesperado;
- emitir errores con `reason` normalizado;
- no mostrar errores de cierre cuando el usuario presiono `BACK`;
- cerrar socket despues de errores de join cuando corresponda.

Actualizar `Main` para:

- mantener estado del flujo actual (`home`, `connecting`, `lobby`);
- mostrar errores de join en Home;
- cambiar a Lobby solo al recibir `room_state`;
- manejar `BACK` como salida intencional.

Actualizar `LobbyScreen` solo si hace falta para mostrar estado.

### Backend

Revisar comportamiento actual:

- `join_room` a sala inexistente debe emitir `error` con `reason: "room_not_found"`.
- `join_room` a sala llena debe emitir `error` con `reason: "room_full"`.
- `leave_room` y `close` deben actualizar a los clientes restantes.

No se esperan endpoints nuevos.

## Mapeo de Errores UI

| Reason | Mensaje UI |
| --- | --- |
| `room_not_found` | `Sala no encontrada.` |
| `room_full` | `Sala llena.` |
| `game_already_started` | `La partida ya empezo.` |
| `player_not_joined` | `Todavia no entraste a la sala.` |
| `player_not_found` | `Jugador no encontrado.` |
| `not_host` | `Solo el host puede hacer eso.` |
| `already_started` | `La partida ya empezo.` |
| `players_not_ready` | `Faltan jugadores listos.` |
| otro | `Error de lobby.` |

## Checklist

- [ ] `RoomSocket` distingue cierre intencional.
- [ ] `RoomSocket` expone `reason` de errores del backend.
- [ ] `Main` mapea errores a mensajes claros.
- [ ] Join a sala inexistente queda en Home.
- [ ] Join a sala llena queda en Home.
- [ ] `BACK` vuelve a Home sin error visual.
- [ ] `BACK` notifica salida al backend.
- [ ] Otro cliente ve lista actualizada al salir un jugador.
- [ ] No se agregan endpoints nuevos.
- [ ] Godot carga sin errores.
- [ ] Backend mantiene lint/typecheck/coverage OK.

## Criterios de Aceptacion

- Intentar unirse a una sala inexistente muestra `Sala no encontrada.`.
- Intentar unirse a una sala llena muestra `Sala llena.`.
- Los errores de join se muestran en Home.
- `BACK` vuelve a Home sin mostrar error de desconexion.
- Si un jugador sale, los clientes restantes ven la lista actualizada.
- `godot --headless --path game --quit` pasa.
- `npm run lint` pasa.
- `npm run typecheck` pasa.
- `npm run coverage` pasa con 100%.

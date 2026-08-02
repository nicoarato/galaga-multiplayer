# Milestones

Checklist operativo para avanzar en cortes chicos y verificables.

## Milestone 1 - Lobby Compartible Local

Objetivo: validar la promesa central del producto en entorno local.

```text
Crear sala -> entrar al lobby -> ver jugadores -> unirse desde otro cliente
```

### Estado Actual

- [x] Backend HTTP con `POST /api/rooms`.
- [x] Backend WebSocket con `WS /ws/rooms/{roomId}`.
- [x] Home screen en Godot.
- [x] Crear sala desde Godot.
- [x] Conectar Godot al lobby por WebSocket.
- [x] Enviar `join_room`.
- [x] Recibir `room_state`.
- [x] Mostrar estado basico de lobby en la UI.

### Lobby Screen

- [x] Crear `game/scenes/ui/LobbyScreen.tscn`.
- [x] Crear `game/scripts/ui/lobby_screen.gd`.
- [x] Mostrar `roomId`.
- [x] Mostrar lista de jugadores.
- [x] Mostrar estado de conexion.
- [x] Mostrar boton `READY`.
- [x] Mostrar boton `START GAME` como placeholder.
- [x] Mostrar boton `BACK`.
- [x] Cambiar de Home a Lobby cuando llegue `room_state`.
- [x] Mantener WebSocket abierto al entrar al lobby.

Criterios de aceptacion:

- [x] Desde Home puedo crear una sala.
- [x] Despues de crear sala, la UI cambia a Lobby.
- [x] El Lobby muestra el room id.
- [x] El Lobby muestra mi jugador en la lista.
- [x] El Lobby muestra cantidad/estado de jugadores.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

### Corte Actual - Join Manual por Room ID

- [ ] Usar el campo de codigo de sala de Home.
- [ ] Conectar a `WS /ws/rooms/{roomId}` sin crear sala nueva.
- [ ] Enviar `join_room`.
- [ ] Cambiar de Home a Lobby cuando llegue `room_state`.
- [ ] Mostrar ambos jugadores en los clientes conectados.
- [ ] Manejar error `room_not_found`.
- [ ] Manejar error `room_full`.
- [ ] Mantener `BACK` cerrando la conexion y volviendo a Home.

Checklist de implementacion:

- [ ] Reutilizar `RoomSocket.connect_to_room(roomId, playerName)`.
- [ ] Guardar `playerName` al usar el boton `JOIN`.
- [ ] Mostrar estado `Conectando a sala...` en Home.
- [ ] Reutilizar `LobbyScreen.set_room(room)` para salas creadas y salas existentes.
- [ ] No crear endpoints nuevos en backend.
- [ ] No introducir pantalla nueva para este corte.

Criterios de aceptacion:

- [ ] Un cliente crea sala.
- [ ] Otro cliente entra usando el room id.
- [ ] Ambos clientes ven la misma lista de jugadores.
- [ ] Si un cliente se desconecta, el otro ve la lista actualizada.
- [ ] Godot carga sin errores con `godot --headless --path game --quit`.

### Siguiente Corte - Ready / Start

- [ ] Implementar `set_ready` desde Godot.
- [ ] Actualizar lista con estado ready.
- [ ] Mostrar `START GAME` solo para host.
- [ ] Enviar `start_game`.
- [ ] Recibir `game_started`.

Criterios de aceptacion:

- [ ] Invitados pueden marcar ready.
- [ ] Host puede iniciar cuando corresponde.
- [ ] Todos los clientes reciben `game_started`.

## Milestone 2 - Gameplay Basico Local

Pendiente de detallar cuando Milestone 1 este completo.

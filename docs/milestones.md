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

### Proximo Corte - Lobby Screen

- [ ] Crear `game/scenes/ui/LobbyScreen.tscn`.
- [ ] Crear `game/scripts/ui/lobby_screen.gd`.
- [ ] Mostrar `roomId`.
- [ ] Mostrar lista de jugadores.
- [ ] Mostrar estado de conexion.
- [ ] Mostrar boton `READY`.
- [ ] Mostrar boton `START GAME` como placeholder.
- [ ] Mostrar boton `BACK`.
- [ ] Cambiar de Home a Lobby cuando llegue `room_state`.
- [ ] Mantener WebSocket abierto al entrar al lobby.

Criterios de aceptacion:

- [ ] Desde Home puedo crear una sala.
- [ ] Despues de crear sala, la UI cambia a Lobby.
- [ ] El Lobby muestra el room id.
- [ ] El Lobby muestra mi jugador en la lista.
- [ ] El Lobby muestra cantidad/estado de jugadores.
- [ ] Godot carga sin errores con `godot --headless --path game --quit`.

### Siguiente Corte - Join Manual por Room ID

- [ ] Usar el campo de codigo de sala de Home.
- [ ] Conectar a `WS /ws/rooms/{roomId}` sin crear sala nueva.
- [ ] Enviar `join_room`.
- [ ] Mostrar ambos jugadores en los clientes conectados.
- [ ] Manejar error `room_not_found`.
- [ ] Manejar error `room_full`.

Criterios de aceptacion:

- [ ] Un cliente crea sala.
- [ ] Otro cliente entra usando el room id.
- [ ] Ambos clientes ven la misma lista de jugadores.
- [ ] Si un cliente se desconecta, el otro ve la lista actualizada.

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

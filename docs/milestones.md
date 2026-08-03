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

### Join Manual por Room ID

- [x] Usar el campo de codigo de sala de Home.
- [x] Conectar a `WS /ws/rooms/{roomId}` sin crear sala nueva.
- [x] Enviar `join_room`.
- [x] Cambiar de Home a Lobby cuando llegue `room_state`.
- [x] Mostrar ambos jugadores en los clientes conectados.
- [x] Mantener `BACK` cerrando la conexion y volviendo a Home.
- [x] Mostrar room id en un campo copiable.
- [x] Agregar boton `COPY` para copiar room id al clipboard.

Checklist de implementacion:

- [x] Reutilizar `RoomSocket.connect_to_room(roomId, playerName)`.
- [x] Guardar `playerName` al usar el boton `JOIN`.
- [x] Mostrar estado `Conectando a sala...` en Home.
- [x] Reutilizar `LobbyScreen.set_room(room)` para salas creadas y salas existentes.
- [x] No crear endpoints nuevos en backend.
- [x] No introducir pantalla nueva para este corte.

Criterios de aceptacion:

- [x] Un cliente crea sala.
- [x] Otro cliente entra usando el room id.
- [x] Ambos clientes ven la misma lista de jugadores.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

### Errores y Desconexion de Lobby

Spec: [Lobby Error Handling Spec](lobby-error-handling-spec.md)

- [x] Manejar error `room_not_found`.
- [x] Manejar error `room_full`.
- [x] Mostrar errores de join en Home sin cambiar a Lobby.
- [x] Si un cliente se desconecta, el otro ve la lista actualizada.
- [x] `BACK` no debe mostrar error de desconexion despues de volver a Home.
- [x] `BACK` debe notificar salida al backend.

Criterios de aceptacion:

- [x] Intentar unirse a una sala inexistente muestra error claro.
- [x] Intentar unirse a una sala llena muestra error claro.
- [x] Al cerrar/salir un cliente, el resto ve la lista actualizada.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

### Ready / Start

Spec: [Ready / Start Spec](ready-start-spec.md)

- [x] Implementar `set_ready` desde Godot.
- [x] Actualizar lista con estado ready.
- [x] Mostrar `START GAME` solo para host.
- [x] Enviar `start_game`.
- [x] Recibir `game_started`.
- [x] Mostrar host en el lobby.
- [x] Manejar error `players_not_ready`.
- [x] Manejar error `not_host`.

Criterios de aceptacion:

- [x] Invitados pueden marcar ready.
- [x] Host puede iniciar cuando corresponde.
- [x] Todos los clientes reciben `game_started`.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

## Milestone 2 - Gameplay Basico Local

Objetivo: empezar la transicion desde lobby a partida y construir gameplay en cortes chicos.

### Corte Actual - Game Scene Placeholder

Spec: [Game Scene Placeholder Spec](game-scene-placeholder-spec.md)

- [x] Crear fondo `game_space_bg_1280x720.png`.
- [x] Crear `GameScreen.tscn`.
- [x] Crear `game_screen.gd`.
- [x] Mostrar fondo.
- [x] Mostrar `GAME STARTED`.
- [x] Mostrar room id.
- [x] Mostrar jugadores.
- [x] Cambiar de Lobby a GameScreen al recibir `game_started`.
- [x] Mantener WebSocket abierto.

Criterios de aceptacion:

- [x] Host crea sala.
- [x] Guest entra y marca `READY`.
- [x] Host presiona `START GAME`.
- [x] Ambos clientes cambian a GameScreen.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

### Siguiente Corte - Player Ship Local

Spec: [Player Ship Local Spec](player-ship-local-spec.md)

- [x] Crear asset `player_ship_placeholder.png`.
- [x] Crear `PlayerShip.tscn`.
- [x] Crear `player_ship.gd`.
- [x] Instanciar una nave por jugador.
- [x] Marcar visualmente la nave local.
- [x] Mover solo la nave local.
- [x] Limitar movimiento al area de juego.
- [x] Mantener naves remotas estaticas.
- [x] No modificar backend.

Criterios de aceptacion:

- [x] Host crea sala.
- [x] Guest entra y marca `READY`.
- [x] Host presiona `START GAME`.
- [x] Ambos clientes ven una nave por jugador.
- [x] Cada cliente puede mover su propia nave.
- [x] La nave no sale del area visible de juego.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

### Siguiente Corte - Player Movement Sync

Spec: [Player Movement Sync Spec](player-movement-sync-spec.md)

- [x] Agregar mensaje `player_position`.
- [x] Validar payload de posicion.
- [x] Guardar posicion por jugador en backend.
- [x] Incluir posicion en `room_state`.
- [x] Enviar posicion local desde Godot.
- [x] Limitar envio a 10 updates por segundo.
- [x] Actualizar naves remotas al recibir estado.
- [x] Evitar duplicar naves en cada update.
- [x] Mantener coverage backend 100%.

Criterios de aceptacion:

- [x] Al mover P1, P2 ve moverse la nave de P1.
- [x] Al mover P2, P1 ve moverse la nave de P2.
- [x] La nave local sigue respondiendo inmediatamente.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

### Siguiente Corte - Remote Movement Smoothing

Spec: [Remote Movement Smoothing Spec](remote-movement-smoothing-spec.md)

- [x] Subir frecuencia de envio local a `20 updates por segundo`.
- [x] Agregar target remoto en `PlayerShip`.
- [x] Suavizar naves remotas con `lerp`.
- [x] Mantener control local inmediato.
- [x] Mantener remotas sin input local.
- [x] Mantener clamp al area de juego.
- [x] No modificar backend.
- [x] No modificar protocolo.

Criterios de aceptacion:

- [x] Al mover P1, P2 ve movimiento remoto mas fluido.
- [x] Al mover P2, P1 ve movimiento remoto mas fluido.
- [x] La nave local sigue respondiendo inmediatamente.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

### Siguiente Corte - Local Shooting

Spec: [Local Shooting Spec](local-shooting-spec.md)

- [x] Crear `Projectile.tscn`.
- [x] Crear `projectile.gd`.
- [x] Agregar layer de proyectiles en `GameScreen`.
- [x] Agregar `shoot_requested` en `PlayerShip`.
- [x] Detectar disparo con `Space` y `Enter`.
- [x] Aplicar cooldown simple.
- [x] Spawn de proyectil desde nave local.
- [x] Mover proyectil hacia arriba.
- [x] Destruir proyectil al salir del area.
- [x] No modificar backend.

Criterios de aceptacion:

- [x] La nave local dispara con `Space`.
- [x] La nave local dispara con `Enter`.
- [x] El proyectil sale desde la nave local.
- [x] El proyectil se mueve hacia arriba.
- [x] El proyectil desaparece al salir del area.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

### Siguiente Corte - Shooting Sync

Spec: [Shooting Sync Spec](shooting-sync-spec.md)

- [x] Agregar mensaje `player_shot`.
- [x] Validar payload `player_shot`.
- [x] Backend broadcast de disparo con `playerId`.
- [x] Agregar `RoomSocket.send_player_shot`.
- [x] Agregar senal `player_shot_received`.
- [x] Godot envia disparo local.
- [x] Godot recibe disparos remotos.
- [x] Godot ignora broadcast propio.
- [x] Godot instancia proyectil remoto.
- [x] Mantener coverage backend 100%.

Criterios de aceptacion:

- [x] P1 dispara y P2 ve el proyectil.
- [x] P2 dispara y P1 ve el proyectil.
- [x] El cliente local no duplica su propio proyectil.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

### Siguiente Corte - Enemy Wave Placeholder

Spec: [Enemy Wave Placeholder Spec](enemy-wave-placeholder-spec.md)

- [x] Crear `Enemy.tscn`.
- [x] Crear `enemy.gd`.
- [x] Crear visual de OVNI arcade.
- [x] Agregar `EnemiesLayer` en `GameScreen`.
- [x] Exportar `enemy_scene`.
- [x] Spawnear 12 enemigos.
- [x] Usar layout deterministico.
- [x] Mover oleada lateralmente.
- [x] Rebotar dentro del area visible.
- [x] Evitar duplicar oleada con updates de sala.
- [x] No modificar backend.
- [x] No agregar colisiones.

Criterios de aceptacion:

- [x] Ambos clientes ven la oleada.
- [x] La oleada aparece en la parte superior.
- [x] La oleada se mueve lateralmente.
- [x] La oleada rebota dentro del area visible.
- [x] Los disparos siguen funcionando.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

### Siguiente Corte - Projectile Enemy Collision

Spec: [Projectile Enemy Collision Spec](projectile-enemy-collision-spec.md)

- [ ] Convertir `Projectile` en nodo con deteccion de area.
- [ ] Agregar shape de colision al proyectil.
- [ ] Convertir `Enemy` en nodo con deteccion de area.
- [ ] Agregar shape de colision al enemigo.
- [ ] Definir layers/masks simples para proyectiles y enemigos.
- [ ] Detectar impacto desde el proyectil.
- [ ] Remover enemigo impactado.
- [ ] Remover proyectil que impacta.
- [ ] Mantener proyectiles saliendo del area como hasta ahora.
- [ ] No modificar backend.

Criterios de aceptacion:

- [ ] Al disparar contra un enemigo, el proyectil desaparece.
- [ ] Al disparar contra un enemigo, el enemigo desaparece.
- [ ] Disparar sin impactar sigue eliminando el proyectil al salir del area.
- [ ] La oleada sigue moviendose lateralmente.
- [ ] Los disparos sincronizados siguen visibles entre clientes.
- [ ] Godot carga sin errores con `godot --headless --path game --quit`.

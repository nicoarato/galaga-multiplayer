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

- [x] Convertir `Projectile` en nodo con deteccion de area.
- [x] Agregar shape de colision al proyectil.
- [x] Convertir `Enemy` en nodo con deteccion de area.
- [x] Agregar shape de colision al enemigo.
- [x] Definir layers/masks simples para proyectiles y enemigos.
- [x] Detectar impacto desde el proyectil.
- [x] Remover enemigo impactado.
- [x] Remover proyectil que impacta.
- [x] Mantener proyectiles saliendo del area como hasta ahora.
- [x] No modificar backend.

Criterios de aceptacion:

- [x] Al disparar contra un enemigo, el proyectil desaparece.
- [x] Al disparar contra un enemigo, el enemigo desaparece.
- [x] Disparar sin impactar sigue eliminando el proyectil al salir del area.
- [x] La oleada sigue moviendose lateralmente.
- [x] Los disparos sincronizados siguen visibles entre clientes.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

### Siguiente Corte - Enemy Destroy Sync

Spec: [Enemy Destroy Sync Spec](enemy-destroy-sync-spec.md)

- [x] Agregar `enemyId` a `Enemy`.
- [x] Guardar enemigos por `enemyId` en `GameScreen`.
- [x] Emitir destruccion local desde `Projectile`.
- [x] Conectar destruccion local en `GameScreen`.
- [x] Agregar `enemy_destroyed` en `RoomSocket`.
- [x] Parsear `enemy_destroyed` en backend.
- [x] Validar que `enemyId` sea string no vacio.
- [x] Broadcast de `enemy_destroyed` desde backend.
- [x] Recibir `enemy_destroyed` en Godot.
- [x] Remover enemigo remoto por `enemyId`.
- [x] Ignorar eventos duplicados sin error visual.
- [x] Mantener coverage backend 100%.

Criterios de aceptacion:

- [x] P1 destruye un OVNI y desaparece en P1.
- [x] P1 destruye un OVNI y desaparece en P2.
- [x] P2 destruye un OVNI y desaparece en P1.
- [x] Un `enemy_destroyed` duplicado no rompe la partida.
- [x] Los disparos sincronizados siguen funcionando.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.
- [x] Backend mantiene lint, typecheck y coverage 100%.

### Siguiente Corte - Playfield Layout Balance

Spec: [Playfield Layout Balance Spec](playfield-layout-balance-spec.md)

- [x] Reducir altura visual del header de partida.
- [x] Remover placeholder de implementacion del HUD.
- [x] Aumentar alto minimo del playfield.
- [x] Definir margen superior/inferior proporcional del area jugable.
- [x] Reposicionar naves locales/remotas mas abajo.
- [x] Reposicionar oleada mas arriba.
- [x] Mantener clamp de movimiento visible.
- [x] Mantener rebote lateral de la oleada.
- [x] No modificar backend.

Criterios de aceptacion:

- [x] La distancia entre oleada y naves es claramente mayor que en el corte anterior.
- [x] En ventana ancha/baja, la nave no aparece pegada a la oleada.
- [x] La oleada sigue apareciendo completa dentro del area visible.
- [x] Las naves siguen moviendose sin salir del plano.
- [x] Disparos, colisiones y destruccion sincronizada siguen funcionando.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

## Gameplay Systems Pendientes

### Player Health and Ship Stats

Design: [Player Health and Ship Stats Design](player-health-and-ship-stats-design.md)

Spec: [Player Health UI and Regen Spec](player-health-ui-and-regen-spec.md)

- [x] Mostrar energia/vida de jugadores en la parte superior.
- [x] Definir tipos de nave con stats distintos.
- [x] Hacer que el daño de proyectiles dependa del tipo de nave.
- [x] Agregar vida a los enemigos y destruirlos al llegar a cero.
- [x] Agregar regeneracion despues de `4 segundos` sin disparar.
- [x] Cortar regeneracion al disparar.
- [x] Definir si recibir daño tambien corta regeneracion.
- [x] Mantener backend como autoridad final para vida y daño en multiplayer.

### Corte Completado - Player Damage and Server Health

Spec: [Player Damage and Server Health Spec](player-damage-and-server-health-spec.md)

- [x] Agregar mensaje `enemy_hit_player`.
- [x] Validar daño y jugador objetivo en el backend.
- [x] Mantener vida y estado derrotado en `RoomStore`.
- [x] Agregar mensaje `player_health`.
- [x] Replicar cambios de vida a todos los clientes.
- [x] Generar proyectiles enemigos periódicos.
- [x] Detectar impactos contra naves de jugadores.
- [x] Aplicar daño recibido en el backend.
- [x] Mover regeneración y sus reglas al backend.
- [x] Actualizar HUD con el estado autoritativo.
- [x] Bloquear disparos de jugadores derrotados.
- [x] Mantener lint, typecheck y 100% de coverage backend.

Criterios de aceptación:

- [x] Un impacto enemigo reduce la vida en ambas pantallas.
- [x] La regeneración respeta el retraso de 4 segundos.
- [x] La vida nunca sale del rango `0..maxHealth`.
- [x] Un jugador derrotado no puede disparar.
- [x] Godot carga sin errores con `godot --headless --path game --rendering-method gl_compatibility --quit`.

### Corte Completado - Projectile Range

Spec: [Projectile Range Spec](projectile-range-spec.md)

- [x] Agregar alcance máximo a proyectiles de jugador.
- [x] Agregar alcance máximo a proyectiles enemigos.
- [x] Medir distancia desde el punto de spawn.
- [x] Destruir proyectiles al alcanzar el límite.
- [x] Mantener colisiones y salida del área existentes.
- [x] Validar carga headless de Godot.

Criterios de aceptación:

- [x] Los proyectiles de jugador no cruzan todo el escenario.
- [x] Los proyectiles enemigos no alcanzan a las naves desde cualquier posición.
- [x] Los impactos siguen funcionando.
- [x] Godot carga sin errores con `godot --headless --path game --rendering-method gl_compatibility --quit`.

### Corte Completado - Ship Projectile Stats

Spec: [Ship Projectile Stats Spec](ship-projectile-stats-spec.md)

- [x] Agregar `projectile_range` a cada clase de nave.
- [x] Mostrar `PWR` en el HUD.
- [x] Agregar `range` a `player_shot`.
- [x] Validar y retransmitir `range` en backend.
- [x] Aplicar rango local y remoto a proyectiles de jugador.
- [x] Mantener alcance de proyectiles enemigos.
- [x] Mantener lint, typecheck y 100% de coverage backend.

Criterios de aceptación:

- [x] Cada modelo de nave tiene power y alcance distintos.
- [x] Ambos clientes ven el mismo alcance por disparo.
- [x] Godot carga sin errores con `godot --headless --path game --rendering-method gl_compatibility --quit`.

### Corte Completado - Projectile Damage and Enemy Health

Spec: [Projectile Damage and Enemy Health Spec](projectile-damage-and-enemy-health-spec.md)

- [x] Agregar `damage` al mensaje `player_shot`.
- [x] Validar `damage` en el backend.
- [x] Replicar el daño a los clientes remotos.
- [x] Aplicar daño según la clase de nave.
- [x] Agregar vida máxima y actual a los enemigos.
- [x] Destruir enemigos únicamente al llegar a cero.
- [x] Mantener sincronización de `enemy_destroyed`.
- [x] Mantener lint, typecheck y 100% de coverage backend.

Criterios de aceptación:

- [x] Un proyectil no destruye automáticamente un enemigo con vida restante.
- [x] P1 y P2 aplican daños distintos según su clase.
- [x] Ambos clientes ven la misma eliminación de enemigos.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

### Enemy Variety

Design: [Enemy Variety Design](enemy-variety-design.md)

- [ ] Crear catalogo inicial de 10 tipos de OVNI.
- [ ] Agregar `enemyTypeId` estable a enemigos.
- [ ] Preparar stats por tipo: HP, puntaje, velocidad y patron.

### Future Backlog - Power-ups and Ship Progression

- [ ] Diseñar drops de items al destruir tipos específicos de enemigos.
- [ ] Definir pickups para velocidad de proyectil, movimiento y regeneración de vida.
- [ ] Definir niveles, duración y límites de cada mejora.
- [ ] Sincronizar aparición, recolección y efectos a través del backend.
- [ ] Agregar indicadores visuales de mejoras activas en el HUD.
- [ ] Preparar assets/variantes visuales por tipo.
- [ ] Permitir que nuevas variantes se agreguen sin reescribir oleadas.
- [ ] Definir si los 10 tipos aparecen desde el inicio o progresivamente.

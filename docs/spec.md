# Galaga Multiplayer - Spec Inicial

## 1. Vision

Crear un arcade shooter inspirado en Galaga, jugable desde navegador, donde una persona crea una partida y comparte un link para que otros jugadores se sumen sin instalar nada.

El producto debe sentirse inmediato: abrir link, elegir nombre, entrar a la sala y jugar. La primera version prioriza una partida cooperativa simple y estable antes que contenido complejo.

## 2. Objetivos

- Permitir crear una sala con un link unico.
- Permitir que otros jugadores entren a la sala desde ese link.
- Ejecutar una partida cooperativa en tiempo real.
- Mantener controles simples y responsivos.
- Soportar un MVP jugable en navegador.
- Diseñar la arquitectura para que luego pueda crecer a rankings, progresion, skins, modos versus y salas publicas.

## 3. No Objetivos Iniciales

- No copiar assets, nombres comerciales, sprites ni audio originales de Galaga.
- No construir una economia, cuentas de usuario o inventario en el MVP.
- No soportar mobile tactil en la primera version, salvo que el layout no lo impida.
- No crear matchmaking competitivo global en la primera iteracion.
- No implementar anti-cheat fuerte en MVP.

## 4. Plataforma y Stack

### Cliente

- Motor: Godot 4.7.
- Target principal: Web export.
- Vista: 2D.
- Lenguaje: GDScript.
- Resolucion logica recomendada: 1280x720 con escalado responsive.

### Red

La experiencia de "compartir link y sumarse" necesita una capa web externa a Godot para coordinar salas.

Opcion recomendada para MVP:

- Cliente Godot Web export.
- Servidor Node.js o Deno para:
  - Crear salas.
  - Resolver links de invitacion.
  - Mantener estado de lobby.
  - Coordinar signaling si se usa WebRTC.
- Transporte multiplayer:
  - WebRTC peer-to-peer con signaling server para partidas chicas.
  - Alternativa posterior: servidor autoritativo WebSocket si necesitamos mas control, anticheat o estabilidad cross-network.

Decision inicial propuesta:

- MVP con servidor autoritativo WebSocket si el objetivo es menor riesgo tecnico.
- MVP con WebRTC si el objetivo principal es baja latencia peer-to-peer y menor costo de servidor.

Recomendacion pragmatica: empezar con WebSocket autoritativo para el MVP. Es mas simple de depurar, evita problemas de NAT/WebRTC al principio y da una fuente unica de verdad para enemigos, balas, score y oleadas.

## 5. Experiencia de Usuario

### Crear partida

1. El jugador abre la URL principal.
2. Ve pantalla de inicio con:
   - Nombre de jugador.
   - Boton "Crear partida".
   - Campo opcional "Unirse con codigo".
3. Al crear partida, el backend devuelve un `room_id`.
4. La URL cambia a `/room/{room_id}`.
5. La pantalla muestra:
   - Lista de jugadores conectados.
   - Link copiable.
   - Boton "Empezar" visible para host.

### Unirse con link

1. El invitado abre `/room/{room_id}`.
2. Ingresa nombre si no lo tenia.
3. Entra al lobby si la sala existe y acepta jugadores.
4. Cuando el host empieza, todos cargan la escena de juego.

### Durante la partida

- Cada jugador controla una nave.
- Los jugadores comparten objetivo: sobrevivir y sumar puntos.
- Si un jugador muere, queda fuera hasta la siguiente oleada o hasta que todos pierdan, segun la regla elegida para MVP.
- La partida termina cuando todos los jugadores quedan sin vidas.

## 6. Gameplay MVP

### Jugadores

- 1 a 4 jugadores por sala.
- Cada nave tiene:
  - Movimiento horizontal.
  - Disparo principal.
  - Energia/vida.
  - Estado vivo/muerto.
- Los tipos de nave pueden tener distinta vida maxima, daño por proyectil, cadencia, velocidad y regeneracion.
- Si una nave no dispara durante `4 segundos`, debe empezar a regenerar energia hasta el `100%`.
- Disparar reinicia el timer de regeneracion.
- Los jugadores no se empujan entre si en MVP.

Detalle de diseño: [Player Health and Ship Stats Design](player-health-and-ship-stats-design.md).

### Controles

- Movimiento: flechas o `A/D`.
- Disparo: barra espaciadora o click/tap primario.
- Pausa: `Esc`, solo host en MVP.

### Enemigos

- Enemigos entran desde la parte superior.
- Formaciones simples por oleada.
- El juego debe comenzar con 10 tipos distintos de OVNI.
- La arquitectura de enemigos debe permitir agregar mas tipos en el futuro sin cambiar la logica central.
- Patrones MVP:
  - Descenso lineal.
  - Zig-zag.
  - Ataque en picada hacia jugadores.
- Cada enemigo tiene:
  - Tipo estable (`enemyTypeId`).
  - HP.
  - Puntaje.
  - Patron de movimiento.

Detalle de diseño: [Enemy Variety Design](enemy-variety-design.md).

### Disparos

- Balas de jugador viajan hacia arriba.
- Balas enemigas viajan hacia abajo.
- El daño de una bala de jugador debe depender del tipo de nave que la disparo.
- Colisiones:
  - Bala jugador contra enemigo.
  - Bala enemiga contra jugador.
  - Enemigo contra jugador.

### Oleadas

- La partida avanza por oleadas.
- Cada oleada aumenta dificultad:
  - Mas enemigos.
  - Mayor velocidad.
  - Mayor frecuencia de disparo.
- MVP: 5 oleadas y luego loop con dificultad incremental.

### Score

- Score compartido de equipo.
- Score individual opcional desde el primer modelo de datos, aunque no se muestre en MVP.

## 7. Modelo de Red

### Estado autoritativo

El servidor mantiene:

- Salas.
- Jugadores conectados.
- Estado de lobby.
- Estado de partida.
- Posiciones autoritativas de enemigos.
- Spawn de oleadas.
- Score.
- Vidas.
- Eventos de muerte.

El cliente envia:

- Input local.
- Ping/heartbeat.
- Solicitud de disparo.
- Ready/start si corresponde.

El servidor envia:

- Snapshot del mundo.
- Eventos: jugador unido, jugador salio, partida inicio, oleada inicio, enemigo destruido, jugador murio, partida termino.

### Frecuencia sugerida

- Input client -> server: 30 Hz.
- Snapshot server -> client: 20 Hz.
- Interpolacion visual en cliente.

### Prediccion

MVP:

- Prediccion local solo para la nave propia.
- Interpolacion para otros jugadores y enemigos.

Despues:

- Reconciliacion de input si la latencia se siente mal.

## 8. Backend MVP

### Endpoints HTTP

- `POST /api/rooms`
  - Crea una sala.
  - Devuelve `{ room_id, join_url }`.

- `GET /api/rooms/{room_id}`
  - Devuelve metadata publica de sala.

### WebSocket

- `WS /ws/rooms/{room_id}`

Mensajes client -> server:

- `join_room`
- `leave_room`
- `set_ready`
- `start_game`
- `input`
- `shoot`
- `ping`

Mensajes server -> client:

- `room_state`
- `game_started`
- `world_snapshot`
- `game_event`
- `error`
- `pong`

## 9. Escenas Godot Propuestas

- `Main.tscn`
  - Bootstrap, ruteo inicial y conexion.
- `ui/HomeScreen.tscn`
  - Crear/unirse a partida.
- `ui/LobbyScreen.tscn`
  - Lista de jugadores, copiar link, ready/start.
- `game/GameWorld.tscn`
  - Mundo de juego.
- `game/PlayerShip.tscn`
  - Nave del jugador.
- `game/Enemy.tscn`
  - Enemigo base.
- `game/Projectile.tscn`
  - Bala de jugador/enemigo.
- `game/HUD.tscn`
  - Score, vidas, oleada, estado de conexion.

## 10. Estructura de Carpetas Propuesta

```text
galaga-multiplayer/
  docs/
    spec.md
  scenes/
    Main.tscn
    ui/
    game/
  scripts/
    net/
    ui/
    game/
  assets/
    sprites/
    audio/
    fonts/
  backend/
    src/
    tests/
```

## 11. Modelo de Datos Inicial

### Room

```json
{
  "id": "abc123",
  "status": "lobby",
  "host_player_id": "p1",
  "players": [],
  "created_at": "2026-08-02T00:00:00Z"
}
```

### Player

```json
{
  "id": "p1",
  "name": "Nico",
  "color": "#4cc9f0",
  "ready": false,
  "connected": true,
  "lives": 3,
  "score": 0
}
```

### Input

```json
{
  "seq": 120,
  "left": false,
  "right": true,
  "shoot": false,
  "timestamp": 1785628800000
}
```

## 12. Criterios de Aceptacion MVP

- Una persona puede crear una sala desde navegador.
- El sistema genera un link compartible.
- Otra persona puede abrir el link y aparecer en el lobby.
- El host puede iniciar la partida.
- Dos jugadores pueden ver sus naves en la misma partida.
- Los inputs de cada jugador se reflejan en todos los clientes.
- Enemigos aparecen, se mueven y pueden ser destruidos.
- El score se sincroniza.
- La partida termina cuando todos pierden sus vidas.
- El juego puede reiniciarse o volver al lobby.

## 13. Riesgos Tecnicos

- Export web de Godot y compatibilidad con WebSocket en navegadores.
- Latencia perceptible si el servidor esta lejos.
- Drift entre fisica cliente y servidor si se simula demasiado en ambos lados.
- Reconexiones y jugadores que cierran la pestaña.
- Hosting de backend y frontend bajo el mismo dominio.

Mitigaciones:

- Mantener servidor autoritativo.
- Usar snapshots simples e interpolacion.
- Limitar salas a 4 jugadores.
- Agregar heartbeat y timeout.
- Evitar fisica compleja en MVP.

## 14. Roadmap

### Fase 0 - Base del Proyecto

- Crear estructura de carpetas.
- Crear escena `Main`.
- Configurar resolucion y export web.
- Crear cliente WebSocket basico.
- Crear backend minimo con healthcheck.

### Fase 1 - Lobby Compartible

- Crear sala via HTTP.
- Generar URL `/room/{room_id}`.
- Unirse a sala por link.
- Sincronizar lista de jugadores.
- Implementar start game para host.

### Fase 2 - Multiplayer Basico

- Sincronizar input.
- Renderizar varias naves.
- Snapshot de posiciones.
- Manejar desconexion.

### Fase 3 - Gameplay MVP

- Movimiento de jugador.
- Disparos.
- Enemigos.
- Colisiones.
- Score.
- Vidas.
- Game over.

### Fase 4 - Pulido Jugable

- HUD.
- Sonidos.
- Feedback visual.
- Menu post-partida.
- Balance inicial de oleadas.

### Fase 5 - Deploy

- Export web.
- Servir cliente estatico.
- Deploy backend.
- Configurar dominio.
- Prueba con link real entre dos navegadores.

## 15. Preguntas Abiertas

- Cantidad maxima final de jugadores: 2, 4 u 8?
- Cooperativo puro o tambien modo versus?
- Se apunta primero a desktop browser o mobile tambien?
- El servidor va a vivir en un VPS, serverless o plataforma tipo Fly.io/Render?
- Queremos arte placeholder programatico o assets custom desde el inicio?
- El juego debe llamarse finalmente "Galaga Multiplayer" o conviene elegir nombre propio para evitar problemas de marca?

## 16. Siguiente Paso Recomendado

Implementar Fase 0 y Fase 1 con la menor cantidad de gameplay posible:

1. Crear backend WebSocket/HTTP.
2. Crear pantalla Home y Lobby en Godot.
3. Crear flujo real de crear sala, copiar link y entrar desde otra pestaña.
4. Recien despues agregar naves y gameplay.

Este orden valida primero la promesa central del producto: compartir un link y sumarse a una partida.

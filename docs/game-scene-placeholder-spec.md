# Game Scene Placeholder Spec

Spec del siguiente corte: crear la primera pantalla de juego despues de `game_started`, sin gameplay real todavia.

## Objetivo

Cuando el host inicia la partida y todos los clientes reciben `game_started`, Godot debe cambiar desde Lobby a una pantalla de juego placeholder.

```text
Lobby -> START GAME -> game_started -> GameScreen
```

Este corte valida la transicion de lobby a partida. No implementa movimiento, disparos, enemigos ni sincronizacion de gameplay.

## Alcance

Incluye:

- generar/agregar un fondo pixel art de espacio;
- crear `GameScreen.tscn`;
- crear `game_screen.gd`;
- mostrar estado de partida placeholder;
- mostrar room id;
- mostrar jugadores conectados;
- cambiar de `LobbyScreen` a `GameScreen` al recibir `game_started`;
- mantener la conexion WebSocket abierta.

No incluye:

- naves jugables;
- input de movimiento;
- disparos;
- enemigos;
- score;
- vidas;
- game over;
- reinicio de partida.

## Asset de Fondo

Primer asset esperado:

```text
game/assets/backgrounds/game_space_bg_1280x720.png
```

Requisitos:

- formato PNG;
- dimension `1280x720`;
- aspect ratio `16:9`;
- pixel art sci-fi arcade;
- sin texto;
- sin naves grandes;
- buen contraste para ver futuras naves/disparos;
- area central/inferior relativamente legible;
- peso razonable para web.

Prompt base si se genera con IA:

```text
Pixel art 16-bit arcade sci-fi space background, 1280x720, deep purple black space, distant stars, subtle magenta nebula, cyan highlights, no text, no ships, no planets in foreground, high contrast center area for gameplay readability.
```

## GameScreen

Escena propuesta:

```text
game/scenes/game/GameScreen.tscn
game/scripts/game/game_screen.gd
```

Contenido inicial:

- fondo;
- titulo `GAME STARTED`;
- room id;
- lista de jugadores;
- estado `Waiting for gameplay implementation`;
- boton placeholder `BACK TO LOBBY` o `END PLACEHOLDER`.

Nota: el boton puede existir solo como placeholder visual. No debe cerrar la conexion ni crear comportamiento complejo si eso abre otro corte.

## Cambios Tecnicos Esperados

### Godot

Actualizar `Main`:

- instanciar `GameScreen`;
- ocultar Home/Lobby cuando llega `game_started`;
- pasar `room` a `GameScreen`;
- mantener `RoomSocket` conectado.

Actualizar `GameScreen`:

- `set_room(room: Dictionary)`;
- renderizar room id;
- renderizar jugadores;
- mostrar estado placeholder.

### Backend

No se esperan cambios.

El backend ya emite:

```json
{
  "type": "game_started",
  "room": {
    "status": "in_game"
  }
}
```

## Checklist

- [x] Crear fondo `game_space_bg_1280x720.png`.
- [x] Importar fondo en Godot.
- [x] Crear `GameScreen.tscn`.
- [x] Crear `game_screen.gd`.
- [x] Mostrar fondo en `GameScreen`.
- [x] Mostrar `GAME STARTED`.
- [x] Mostrar room id.
- [x] Mostrar jugadores.
- [x] Cambiar de Lobby a GameScreen al recibir `game_started`.
- [x] Mantener WebSocket abierto.
- [x] No modificar backend.
- [x] Godot carga sin errores.
- [x] Backend mantiene lint/typecheck/coverage OK.

## Criterios de Aceptacion

- [x] Host crea sala.
- [x] Guest entra.
- [x] Guest marca `READY`.
- [x] Host presiona `START GAME`.
- [x] Host cambia a `GameScreen`.
- [x] Guest cambia a `GameScreen`.
- [x] `GameScreen` muestra fondo.
- [x] `GameScreen` muestra room id.
- [x] `GameScreen` muestra jugadores.
- [x] `godot --headless --path game --quit` pasa.
- [x] `npm run lint` pasa.
- [x] `npm run typecheck` pasa.
- [x] `npm run coverage` pasa con 100%.

# Player Ship Local Spec

Spec del siguiente corte: mostrar naves en la pantalla de juego y permitir mover localmente la nave del cliente actual.

## Objetivo

Cuando la partida entra en `GameScreen`, cada jugador debe ver una nave por jugador conectado. Solo la nave del cliente local debe responder al input.

```text
game_started -> GameScreen -> player ships visible -> local ship movement
```

Este corte valida el primer gameplay visual local. No implementa sincronizacion de posicion por red todavia.

## Alcance

Incluye:

- crear una escena reutilizable `PlayerShip.tscn`;
- crear `player_ship.gd`;
- agregar un asset simple de nave pixel art local;
- instanciar una nave por jugador en `GameScreen`;
- identificar visualmente la nave local;
- mover la nave local con teclado;
- limitar movimiento al area de juego;
- mantener las naves remotas visibles pero estaticas;
- mantener el WebSocket abierto sin agregar protocolo nuevo.

No incluye:

- sincronizar posiciones por red;
- disparos;
- enemigos;
- colisiones;
- vidas;
- score;
- seleccion de nave;
- animaciones avanzadas.

## Controles

Input esperado para la nave local:

```text
Arrow Left / A  -> mover izquierda
Arrow Right / D -> mover derecha
Arrow Up / W    -> mover arriba
Arrow Down / S  -> mover abajo
```

La nave debe quedar limitada al area visible de juego y preferentemente arrancar en la zona inferior.

## Assets

Primer asset esperado:

```text
game/assets/ships/player_ship_placeholder.png
```

Requisitos:

- formato PNG;
- pixel art arcade;
- fondo transparente;
- legible sobre el fondo de espacio;
- tamano chico para gameplay;
- sin texto;
- sin UI embebida.

## Escenas y Scripts

Archivos propuestos:

```text
game/scenes/game/PlayerShip.tscn
game/scripts/game/player_ship.gd
```

`PlayerShip` debe exponer metodos simples:

```gdscript
set_player_name(player_name: String) -> void
set_local_player(is_local_player: bool) -> void
set_play_area(play_area: Rect2) -> void
set_start_position(start_position: Vector2) -> void
```

## Cambios Tecnicos Esperados

### Godot

Actualizar `GameScreen`:

- recibir `local_player_id` junto con el `room`;
- limpiar naves anteriores al cambiar de sala;
- crear una nave por jugador;
- ubicar naves con una distribucion simple por indice;
- pasar nombre e indicador local a cada nave;
- calcular limites desde el area de juego;
- actualizar lista de jugadores como hasta ahora.

Actualizar `Main`:

- pasar `_local_player_id` a `GameScreen`.

### Backend

No se esperan cambios.

## Checklist

- [ ] Crear spec `docs/player-ship-local-spec.md`.
- [ ] Actualizar `docs/milestones.md`.
- [ ] Crear asset `player_ship_placeholder.png`.
- [ ] Importar asset en Godot.
- [ ] Crear `PlayerShip.tscn`.
- [ ] Crear `player_ship.gd`.
- [ ] Instanciar naves desde `GameScreen`.
- [ ] Mostrar una nave por jugador.
- [ ] Marcar visualmente la nave local.
- [ ] Mover solo la nave local.
- [ ] Limitar movimiento al area de juego.
- [ ] Mantener naves remotas estaticas.
- [ ] No modificar backend.
- [ ] Godot carga sin errores.
- [ ] Backend mantiene lint/typecheck/coverage OK.

## Criterios de Aceptacion

- [ ] Host crea sala.
- [ ] Guest entra y marca `READY`.
- [ ] Host presiona `START GAME`.
- [ ] Ambos clientes cambian a `GameScreen`.
- [ ] Ambos clientes ven una nave por jugador.
- [ ] Cada cliente puede mover su propia nave.
- [ ] La nave remota no se mueve localmente.
- [ ] La nave no sale del area visible de juego.
- [ ] `godot --headless --path game --quit` pasa.
- [ ] `npm run lint` pasa.
- [ ] `npm run typecheck` pasa.
- [ ] `npm run coverage` pasa con 100%.

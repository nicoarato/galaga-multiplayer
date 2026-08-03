# Local Shooting Spec

Spec del siguiente corte: agregar disparo local de proyectiles desde la nave del jugador.

## Objetivo

Cuando el jugador esta en `GameScreen`, debe poder disparar proyectiles locales desde su nave.

```text
Space / Enter -> PlayerShip shoot_requested -> GameScreen spawns Projectile
```

Este corte valida el primer loop de accion arcade. No sincroniza disparos por red todavia.

## Alcance

Incluye:

- input de disparo local;
- cooldown simple para evitar spam;
- escena `Projectile.tscn`;
- script `projectile.gd`;
- proyectiles visuales pixel/arcade;
- spawn del proyectil desde la posicion de la nave local;
- movimiento vertical hacia arriba;
- limpieza automatica al salir del area visible;
- mantener movimiento y sync de naves existentes.

No incluye:

- sincronizar disparos por red;
- colisiones;
- enemigos;
- daño;
- score;
- sonidos;
- efectos de impacto;
- power-ups;
- municion limitada.

## Controles

Input esperado:

```text
Space / Enter -> disparar
```

El disparo debe salir desde el frente de la nave local.

## Decision Tecnica

Usar `PlayerShip` para detectar input local y emitir una senal `shoot_requested(position)`.

Motivos:

- el input pertenece a la nave local;
- `GameScreen` mantiene la responsabilidad de instanciar objetos de gameplay;
- evita que `PlayerShip` conozca escenas de proyectiles;
- mantiene el backend fuera del corte.

## Escenas y Scripts

Archivos propuestos:

```text
game/scenes/game/Projectile.tscn
game/scripts/game/projectile.gd
```

`Projectile` debe:

- moverse hacia arriba;
- aceptar `set_play_area(play_area: Rect2)`;
- destruirse al salir del area;
- no depender de backend.

## Cambios Esperados

### Godot

Actualizar `PlayerShip`:

- agregar senal `shoot_requested(spawn_position: Vector2)`;
- detectar `Space` o `Enter`;
- aplicar cooldown local;
- emitir disparos solo si `_is_local_player`.

Actualizar `GameScreen`:

- exportar `projectile_scene`;
- agregar un layer de proyectiles;
- conectar la nave local a `shoot_requested`;
- instanciar proyectiles en el layer;
- pasar area de juego a cada proyectil.

### Backend

No se esperan cambios.

## Checklist

- [x] Crear spec `docs/local-shooting-spec.md`.
- [x] Actualizar `docs/milestones.md`.
- [x] Crear `Projectile.tscn`.
- [x] Crear `projectile.gd`.
- [x] Agregar layer de proyectiles en `GameScreen`.
- [x] Agregar `shoot_requested` en `PlayerShip`.
- [x] Detectar disparo con `Space`.
- [x] Detectar disparo con `Enter`.
- [x] Aplicar cooldown simple.
- [x] Spawn de proyectil desde nave local.
- [x] Mover proyectil hacia arriba.
- [x] Destruir proyectil al salir del area.
- [x] No modificar backend.
- [x] Godot carga sin errores.
- [x] Backend mantiene lint/typecheck/coverage OK.

## Criterios de Aceptacion

- [x] Host crea sala.
- [x] Guest entra y marca `READY`.
- [x] Host presiona `START GAME`.
- [x] La nave local dispara con `Space`.
- [x] La nave local dispara con `Enter`.
- [x] El proyectil sale desde la nave local.
- [x] El proyectil se mueve hacia arriba.
- [x] El proyectil desaparece al salir del area.
- [x] Las naves remotas no disparan por input local.
- [x] `godot --headless --path game --quit` pasa.
- [x] `npm run lint` pasa.
- [x] `npm run typecheck` pasa.
- [x] `npm run coverage` pasa con 100%.

## Observaciones de Validacion

- El disparo local funciona con `Space` y `Enter`.
- Los proyectiles son locales y todavia no se sincronizan por red.
- Colisiones, enemigos y score quedan fuera de este corte.

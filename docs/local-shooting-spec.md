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

- [ ] Crear spec `docs/local-shooting-spec.md`.
- [ ] Actualizar `docs/milestones.md`.
- [ ] Crear `Projectile.tscn`.
- [ ] Crear `projectile.gd`.
- [ ] Agregar layer de proyectiles en `GameScreen`.
- [ ] Agregar `shoot_requested` en `PlayerShip`.
- [ ] Detectar disparo con `Space`.
- [ ] Detectar disparo con `Enter`.
- [ ] Aplicar cooldown simple.
- [ ] Spawn de proyectil desde nave local.
- [ ] Mover proyectil hacia arriba.
- [ ] Destruir proyectil al salir del area.
- [ ] No modificar backend.
- [ ] Godot carga sin errores.
- [ ] Backend mantiene lint/typecheck/coverage OK.

## Criterios de Aceptacion

- [ ] Host crea sala.
- [ ] Guest entra y marca `READY`.
- [ ] Host presiona `START GAME`.
- [ ] La nave local dispara con `Space`.
- [ ] La nave local dispara con `Enter`.
- [ ] El proyectil sale desde la nave local.
- [ ] El proyectil se mueve hacia arriba.
- [ ] El proyectil desaparece al salir del area.
- [ ] Las naves remotas no disparan por input local.
- [ ] `godot --headless --path game --quit` pasa.
- [ ] `npm run lint` pasa.
- [ ] `npm run typecheck` pasa.
- [ ] `npm run coverage` pasa con 100%.

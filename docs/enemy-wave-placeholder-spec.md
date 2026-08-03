# Enemy Wave Placeholder Spec

Spec del siguiente corte: mostrar una primera oleada de enemigos en la pantalla de juego.

## Objetivo

Cuando la partida entra en `GameScreen`, ambos clientes deben ver una oleada inicial de enemigos moviendose en la parte superior del area de juego.

```text
game_started -> GameScreen -> enemy wave visible -> lateral movement
```

Este corte agrega objetivos visuales al gameplay, pero todavia no implementa colisiones ni score.

## Alcance

Incluye:

- crear una escena `Enemy.tscn`;
- crear `enemy.gd`;
- crear un sprite/shape simple de OVNI;
- agregar layer de enemigos en `GameScreen`;
- spawnear una oleada inicial deterministica;
- mover la oleada lateralmente;
- mantener enemigos dentro del area visible;
- renderizar la misma formacion en ambos clientes.

No incluye:

- colisiones con proyectiles;
- destruccion de enemigos;
- score;
- vidas;
- daño al jugador;
- sincronizacion backend de enemigos;
- IA compleja;
- oleadas multiples;
- sonidos;
- efectos de explosion.

## Decision Tecnica

Usar una oleada deterministica generada en Godot.

Motivos:

- ambos clientes ya entran al mismo `GameScreen`;
- no necesitamos backend hasta que haya colisiones/destruccion;
- el movimiento puede ser identico si parte de la misma formacion;
- mantiene el corte chico y visualmente verificable.

Tradeoff aceptado:

- si un cliente se desfasa en FPS, la posicion puede no ser exactamente identica;
- como no hay colisiones todavia, ese desfase no afecta gameplay;
- cuando haya destruccion/sync de enemigos, evaluaremos autoridad de backend.

## Enemigo

Archivos propuestos:

```text
game/scenes/game/Enemy.tscn
game/scripts/game/enemy.gd
```

Visual esperado:

- OVNI pixel/arcade;
- legible sobre el fondo;
- color distinto de las naves;
- tamaño chico/medio;
- sin texto;
- sin comportamiento propio complejo.

## Oleada

Primer layout:

```text
2 filas x 6 columnas = 12 enemigos
```

Reglas:

- ubicarlos en la mitad superior del playfield;
- separacion horizontal estable;
- separacion vertical estable;
- movimiento lateral ida/vuelta;
- margen de rebote dentro del area visible;
- no bajar hacia el jugador todavia.

## Cambios Esperados

### Godot

Actualizar `GameScreen`:

- exportar `enemy_scene`;
- agregar `EnemiesLayer`;
- spawnear enemigos al iniciar partida;
- mover la oleada en `_process`;
- invertir direccion al llegar a margenes;
- evitar duplicar oleada cuando llega `room_state`.

Crear `Enemy`:

- escena visual simple;
- script minimo;
- metodo opcional `set_enemy_index(index: int)` para variar color/tono.

### Backend

No se esperan cambios.

## Checklist

- [x] Crear spec `docs/enemy-wave-placeholder-spec.md`.
- [x] Actualizar `docs/milestones.md`.
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
- [x] Godot carga sin errores.
- [x] Backend mantiene lint/typecheck/coverage OK.

## Criterios de Aceptacion

- [x] Host crea sala.
- [x] Guest entra y marca `READY`.
- [x] Host presiona `START GAME`.
- [x] Ambos clientes ven la oleada.
- [x] La oleada aparece en la parte superior.
- [x] La oleada se mueve lateralmente.
- [x] La oleada rebota dentro del area visible.
- [x] No se duplican enemigos al recibir updates.
- [x] Los disparos siguen funcionando.
- [x] No hay colisiones ni score en este corte.
- [x] `godot --headless --path game --quit` pasa.
- [x] `npm run lint` pasa.
- [x] `npm run typecheck` pasa.
- [x] `npm run coverage` pasa con 100%.

## Observaciones de Validacion

- Ambos clientes muestran los 12 enemigos.
- La oleada se mueve lateralmente como placeholder.
- Colisiones, destruccion y score quedan para cortes posteriores.

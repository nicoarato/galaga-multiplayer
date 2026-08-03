# Remote Movement Smoothing Spec

Spec del siguiente corte: reducir la percepcion de delay/jitter en el movimiento remoto de naves.

## Objetivo

Cuando un jugador mueve su nave, los otros clientes ya reciben la posicion por red. Este corte busca que ese movimiento remoto se vea mas fluido.

```text
room_state position update -> remote ship target position -> smooth movement
```

Este corte no cambia el modelo de red. Solo mejora la presentacion visual en Godot.

## Alcance

Incluye:

- suavizar movimiento de naves remotas hacia su ultima posicion recibida;
- mantener control local inmediato;
- subir frecuencia de envio local de `10` a `20 updates por segundo`;
- mantener naves remotas sin input local;
- mantener posiciones limitadas al area de juego;
- documentar que prediccion/rollback siguen fuera de alcance.

No incluye:

- prediccion cliente;
- rollback;
- reconciliacion servidor/cliente;
- timestamps de servidor;
- interpolacion con buffer historico;
- extrapolacion;
- cambios de backend;
- cambios de protocolo;
- disparos.

## Decision Tecnica

Usar suavizado simple con `lerp` sobre la nave remota.

Motivos:

- mantiene el algoritmo simple;
- evita modificar backend;
- reduce saltos visuales entre updates;
- es suficiente para validar gameplay cooperativo local.

Tradeoff aceptado:

- puede quedar una pequena cola visual respecto de la posicion real;
- si luego necesitamos mayor precision, haremos un corte especifico con timestamps/interpolacion por buffer.

## Cambios Esperados

### Godot

Actualizar `PlayerShip`:

- guardar `_remote_target_position`;
- mover naves remotas hacia ese target en `_process`;
- mantener movimiento local como esta;
- `set_remote_position(position)` no debe teletransportar salvo primera posicion;
- clamp de target y posicion al area de juego.

Actualizar `GameScreen`:

- cambiar `POSITION_SEND_INTERVAL` de `0.1` a `0.05`;
- seguir enviando solo si la posicion local cambio;
- seguir manteniendo naves por `player_id`.

### Backend

No se esperan cambios.

## Checklist

- [x] Crear spec `docs/remote-movement-smoothing-spec.md`.
- [x] Actualizar `docs/milestones.md`.
- [x] Subir frecuencia de envio local a `20 updates por segundo`.
- [x] Agregar target remoto en `PlayerShip`.
- [x] Suavizar naves remotas con `lerp`.
- [x] Mantener naves locales con input inmediato.
- [x] Mantener remotas sin input local.
- [x] Mantener clamp al area de juego.
- [x] No modificar backend.
- [x] No modificar protocolo.
- [x] Godot carga sin errores.
- [x] Backend mantiene lint/typecheck/coverage OK.

## Criterios de Aceptacion

- [x] Host crea sala.
- [x] Guest entra y marca `READY`.
- [x] Host presiona `START GAME`.
- [x] Al mover P1, P2 ve movimiento remoto mas fluido.
- [x] Al mover P2, P1 ve movimiento remoto mas fluido.
- [x] La nave local sigue respondiendo inmediatamente.
- [x] No se duplican naves.
- [x] No hay saltos grandes visibles en movimiento remoto normal.
- [x] `godot --headless --path game --quit` pasa.
- [x] `npm run lint` pasa.
- [x] `npm run typecheck` pasa.
- [x] `npm run coverage` pasa con 100%.

## Observaciones de Validacion

- El movimiento remoto se percibe mas fluido con envio a `20 updates por segundo`.
- El control local sigue respondiendo inmediatamente.
- No se modificaron backend ni protocolo en este corte.

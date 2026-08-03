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

- [ ] Crear spec `docs/remote-movement-smoothing-spec.md`.
- [ ] Actualizar `docs/milestones.md`.
- [ ] Subir frecuencia de envio local a `20 updates por segundo`.
- [ ] Agregar target remoto en `PlayerShip`.
- [ ] Suavizar naves remotas con `lerp`.
- [ ] Mantener naves locales con input inmediato.
- [ ] Mantener remotas sin input local.
- [ ] Mantener clamp al area de juego.
- [ ] No modificar backend.
- [ ] No modificar protocolo.
- [ ] Godot carga sin errores.
- [ ] Backend mantiene lint/typecheck/coverage OK.

## Criterios de Aceptacion

- [ ] Host crea sala.
- [ ] Guest entra y marca `READY`.
- [ ] Host presiona `START GAME`.
- [ ] Al mover P1, P2 ve movimiento remoto mas fluido.
- [ ] Al mover P2, P1 ve movimiento remoto mas fluido.
- [ ] La nave local sigue respondiendo inmediatamente.
- [ ] No se duplican naves.
- [ ] No hay saltos grandes visibles en movimiento remoto normal.
- [ ] `godot --headless --path game --quit` pasa.
- [ ] `npm run lint` pasa.
- [ ] `npm run typecheck` pasa.
- [ ] `npm run coverage` pasa con 100%.

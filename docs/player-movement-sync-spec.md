# Player Movement Sync Spec

Spec del siguiente corte: sincronizar posiciones de naves entre clientes conectados.

## Objetivo

Cuando un jugador mueve su nave local, el resto de clientes de la misma sala debe ver esa posicion actualizada.

```text
PlayerShip local move -> WebSocket player_position -> backend -> game_state -> remote ships update
```

Este corte valida multiplayer visible en tiempo real. No busca movimiento perfecto de arcade competitivo todavia.

## Decision Tecnica

Para este MVP vamos a sincronizar posicion, no input.

Motivos:

- es mas simple de implementar y probar;
- permite ver resultado inmediato entre dos clientes;
- evita agregar prediccion, rollback o reconciliacion antes de necesitarlo;
- mantiene el backend como fuente simple de broadcast.

Tradeoff aceptado:

- el cliente que mueve su nave sigue teniendo control local inmediato;
- los otros clientes ven actualizaciones discretas;
- si se siente tosco, la interpolacion queda para un corte posterior.

## Alcance

Incluye:

- agregar mensaje WebSocket `player_position`;
- validar payload de posicion;
- guardar posicion por jugador en la sala;
- emitir estado de gameplay con posiciones;
- actualizar naves remotas en Godot al recibir posiciones;
- enviar posicion local con frecuencia limitada;
- mantener movimiento local inmediato;
- mantener limites de movimiento del cliente;
- tests backend con coverage 100%.

No incluye:

- prediccion cliente;
- interpolacion suave;
- reconciliacion cliente/servidor;
- deteccion de cheating;
- colisiones;
- disparos;
- enemigos;
- persistencia de partida;
- cambios de hosting/deploy.

## Protocolo

Nuevo mensaje cliente -> servidor:

```json
{
  "type": "player_position",
  "position": {
    "x": 320,
    "y": 240
  }
}
```

Reglas:

- solo se acepta si el jugador ya hizo `join_room`;
- solo se acepta si la sala esta `in_game`;
- `x` e `y` deben ser numeros finitos;
- el backend no necesita aplicar fisica todavia;
- el backend debe guardar la ultima posicion conocida del jugador.

Mensaje servidor -> clientes:

Opcion de este corte: agregar posiciones al `room_state` existente para evitar un segundo canal de estado.

```json
{
  "type": "room_state",
  "room": {
    "players": [
      {
        "id": "player-id",
        "name": "nico",
        "ready": true,
        "position": {
          "x": 320,
          "y": 240
        }
      }
    ]
  }
}
```

Nota: si despues el gameplay crece, podemos separar esto a `game_state`.

## Godot

Actualizar `PlayerShip`:

- emitir una senal cuando cambia la posicion local;
- exponer `set_remote_position(position: Vector2)`;
- no interpolar todavia;
- no emitir cambios para naves remotas.

Actualizar `GameScreen`:

- mantener naves por `player_id`;
- no recrear todas las naves si solo cambia posicion;
- conectar la nave local con callback de posicion;
- actualizar naves remotas cuando llega `room_state`.

Actualizar `RoomSocket`:

- agregar `send_player_position(position: Vector2)`;
- serializar mensaje `player_position`.

Actualizar `Main`:

- reenviar posiciones locales desde `GameScreen` a `RoomSocket`;
- cuando llega `room_state` en estado `game`, actualizar `GameScreen` sin volver al lobby.

## Backend

Actualizar store/protocolo:

- aceptar posicion por jugador;
- guardar `position` dentro de player state;
- incluir `position` en serializacion de sala;
- broadcast del `room_state` actualizado.

## Frecuencia de Envio

Primer valor:

```text
10 updates por segundo
```

Reglas:

- enviar solo si la posicion cambio;
- no enviar mas de una vez cada `0.1s`;
- no enviar posiciones antes de `game_started`.

## Checklist

- [ ] Crear spec `docs/player-movement-sync-spec.md`.
- [ ] Actualizar `docs/milestones.md`.
- [ ] Agregar tipo/mensaje `player_position`.
- [ ] Validar payload `player_position`.
- [ ] Guardar posicion en backend por jugador.
- [ ] Incluir posicion en `room_state`.
- [ ] Agregar tests backend de mensaje.
- [ ] Agregar tests backend de store.
- [ ] Mantener coverage 100%.
- [ ] Agregar `RoomSocket.send_player_position`.
- [ ] Emitir posicion local desde `PlayerShip`.
- [ ] Limitar envio a 10 updates por segundo.
- [ ] Mantener naves por `player_id` en `GameScreen`.
- [ ] Actualizar naves remotas al recibir `room_state`.
- [ ] Evitar recrear naves en cada update de posicion.
- [ ] Mantener movimiento local inmediato.
- [ ] Godot carga sin errores.

## Criterios de Aceptacion

- [ ] Host crea sala.
- [ ] Guest entra y marca `READY`.
- [ ] Host presiona `START GAME`.
- [ ] Ambos clientes ven dos naves.
- [ ] Al mover P1, P2 ve moverse la nave de P1.
- [ ] Al mover P2, P1 ve moverse la nave de P2.
- [ ] La nave local sigue respondiendo inmediatamente.
- [ ] No se duplican naves al recibir updates.
- [ ] `godot --headless --path game --quit` pasa.
- [ ] `npm run lint` pasa.
- [ ] `npm run typecheck` pasa.
- [ ] `npm run coverage` pasa con 100%.

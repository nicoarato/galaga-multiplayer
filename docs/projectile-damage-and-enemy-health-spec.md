# Projectile Damage and Enemy Health Spec

## Objetivo

Hacer que el combate tenga una diferencia visible entre las clases de nave: cada proyectil debe aplicar el daño de su nave y los enemigos deben resistir más de un impacto cuando corresponda.

## Alcance

- Agregar `damage` al payload `player_shot`.
- Usar el daño definido por la clase de nave local y replicarlo a los demás clientes.
- Agregar vida máxima y vida actual a cada enemigo.
- Remover un enemigo únicamente cuando su vida llegue a cero.
- Mantener un enemigo determinista por índice para que ambos clientes apliquen los mismos impactos.
- Mantener el mensaje `enemy_destroyed` existente para sincronizar la eliminación.

## Balance inicial

| Clase | Daño | Vida enemiga base | Impactos aproximados |
| --- | ---: | ---: | ---: |
| Scout | 18 | 48 | 3 |
| Fighter | 24 | 48 | 2 |
| Tank | 16 | 48 | 3 |
| Striker | 32 | 48 | 2 |

El balance es inicial y queda preparado para ajustarse sin cambiar el protocolo nuevamente.

## Contrato de red

```json
{
  "type": "player_shot",
  "shot": { "x": 320, "y": 560, "damage": 24 }
}
```

El backend valida que `damage` sea un número finito positivo y lo retransmite junto con el `playerId`.

## Criterios de aceptación

- [x] El backend valida y retransmite el daño del disparo.
- [x] P1 y P2 generan proyectiles con el daño de su clase.
- [x] Un impacto reduce la vida del enemigo sin destruirlo prematuramente.
- [x] El enemigo desaparece al llegar a cero vida.
- [x] Ambos clientes muestran la misma eliminación de enemigos.
- [x] Se mantienen lint, typecheck y 100% de coverage del backend.
- [x] Godot carga sin errores en modo headless.

## Fuera de alcance

- Daño de enemigos hacia los jugadores.
- Vida autoritativa en backend.
- Barras de vida visibles sobre cada OVNI.
- Drops, puntuación y combos.

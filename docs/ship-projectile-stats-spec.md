# Ship Projectile Stats Spec

## Objetivo

Hacer que cada clase de nave tenga un perfil propio de proyectil, usando `power` como daño y `range` como alcance máximo.

## Alcance

- Renombrar visualmente `DMG` como `PWR` en el HUD para expresar el poder del proyectil.
- Mantener `damage` como nombre interno y valor enviado al backend.
- Agregar `projectile_range` a cada clase de nave.
- Incluir `range` en el mensaje `player_shot`.
- Validar y retransmitir `range` desde el backend.
- Aplicar el rango local y remoto al proyectil correspondiente.
- Mantener el rango fijo de los proyectiles enemigos en este corte.

## Balance inicial

| Clase | Power / daño | Alcance | Perfil |
| --- | ---: | ---: | --- |
| Scout | 18 | 440 px | Ágil, corto alcance |
| Fighter | 24 | 520 px | Equilibrado |
| Tank | 16 | 680 px | Menor daño, alcance sostenido |
| Striker | 32 | 400 px | Alto impacto, corto alcance |

## Contrato de red

```json
{
  "type": "player_shot",
  "shot": { "x": 320, "y": 560, "damage": 24, "range": 520 }
}
```

El backend valida que `range` sea un número finito positivo y lo retransmite sin modificarlo. La autoridad de daño sigue siendo el backend; el alcance sincroniza la vida visual del proyectil en ambos clientes.

## Criterios de aceptación

- [ ] Cada clase tiene `damage` y `projectile_range` explícitos.
- [ ] El HUD muestra el power de cada jugador.
- [ ] El backend valida `shot.range`.
- [ ] P1 y P2 ven el mismo alcance para cada disparo remoto.
- [ ] El Scout, Fighter, Tank y Striker usan sus rangos definidos.
- [ ] Los proyectiles enemigos conservan 360 px de alcance.
- [ ] Se mantienen lint, typecheck y 100% de coverage del backend.
- [ ] Godot carga sin errores en modo headless.

## Fuera de alcance

- Mejoras temporales de power o alcance.
- Proyectiles con daño variable por distancia.
- Cambios al daño autoritativo de enemigos.

# Player Health and Ship Stats Design

## Objetivo

Agregar profundidad al gameplay con vida/energia visible, tipos de nave con stats distintos y regeneracion de vida por inactividad ofensiva, tomando como referencia la sensacion de recuperacion fuera de combate de juegos como Brawl Stars.

Este documento define reglas de producto para futuros cortes. No reemplaza specs implementados ni implica que el sistema ya exista en juego.

## Reglas Base

- Cada nave de jugador tiene `health` y `maxHealth`.
- La UI debe mostrar energia/vida en la parte superior del HUD.
- Cada tipo de nave puede tener distinto:
  - Vida maxima.
  - Daño por proyectil.
  - Velocidad de disparo.
  - Velocidad de movimiento.
  - Velocidad de regeneracion.
- Los proyectiles deben transportar el daño de la nave que los disparo.
- La vida nunca puede superar el `100%`.
- Si una nave llega a `0 health`, queda destruida o fuera de combate segun el modo definido para ese corte.

## Regeneracion

- Si una nave de jugador no dispara durante `4 segundos`, empieza a regenerar vida.
- Disparar reinicia el timer de regeneracion.
- La regeneracion se detiene al disparar.
- La regeneracion sube gradualmente hasta `maxHealth`.
- Regla recomendada para futuros cortes: recibir daño tambien debe cortar la regeneracion, porque el objetivo es sanar fuera de combate.

## Stats Iniciales Propuestos

| Tipo | Vida Maxima | Daño | Regeneracion | Intencion |
| --- | ---: | ---: | --- | --- |
| Scout | 80 | 18 | Rapida | Nave agil, fragil, recupera rapido |
| Fighter | 100 | 24 | Normal | Nave balanceada |
| Tank | 140 | 16 | Lenta | Mucha vida, menor daño |
| Striker | 90 | 32 | Normal | Alto daño, menor margen de error |

Estos valores son punto de partida. Deben balancearse con pruebas de juego, no tratarse como constantes definitivas.

## UI Esperada

- Mostrar energia de jugadores en la parte superior de la pantalla.
- En multiplayer, cada jugador debe poder distinguir:
  - Su propia energia.
  - Energia de aliados.
  - Tipo/color de nave.
- La vida tambien puede mostrarse sobre la nave en una barra compacta si no ensucia la lectura.
- Evitar texto explicativo dentro de la pantalla de juego; priorizar barras, iconos y colores.

## Red y Autoridad

Decision recomendada:

- El backend debe ser autoridad final para vida, daño y muerte cuando el sistema afecte multiplayer real.
- El cliente puede previsualizar feedback local, pero el estado confirmado debe llegar desde backend.
- Los mensajes futuros deberian evitar depender de nombres visuales de nave; usar IDs o tipos estables.

Eventos/mensajes probables:

- `player_stats`
- `player_damaged`
- `player_healed`
- `player_defeated`
- `projectile_spawned` con `damage`

## Cortes Sugeridos

### Player Health UI

- Crear modelo local de `health/maxHealth`.
- Mostrar barras de energia arriba.
- No aplicar daño real todavia.

### Ship Stats

- Definir `shipClass`.
- Asignar stats por tipo de nave.
- Mostrar tipo/color diferenciado.

### Projectile Damage

- El proyectil lleva `damage`.
- El daño depende del `shipClass`.
- Preparar protocolo para daño sincronizado.

### Health Regeneration

- Trackear ultimo disparo.
- Activar regeneracion despues de `4 segundos`.
- Cortar regeneracion al disparar.
- Mantener clamp a `maxHealth`.

### Player Damage and Defeat

- Aplicar daño a jugadores.
- Emitir eventos sincronizados.
- Definir regla de derrota y respawn.

## Decisiones Pendientes

- Si recibir daño corta regeneracion desde el primer corte o desde el corte de daño real.
- Si todos los jugadores eligen nave antes de la partida o si se asignan clases automaticamente.
- Si la barra de vida vive solo en HUD superior o tambien sobre cada nave.
- Si la vida se mide como puntos enteros o porcentaje normalizado.
- Que pasa cuando un jugador muere en cooperativo: espera siguiente oleada, respawn con cooldown o fin de partida si todos caen.

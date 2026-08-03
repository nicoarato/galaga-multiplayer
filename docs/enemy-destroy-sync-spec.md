# Enemy Destroy Sync Spec

## Objetivo

Sincronizar entre clientes la destruccion de enemigos cuando un proyectil impacta.

El corte mantiene autoridad simple: el cliente que detecta el impacto avisa al backend y el backend retransmite el `enemyId` destruido a todos los jugadores de la sala. La validacion autoritativa de impactos queda fuera de alcance hasta tener estado de partida en servidor.

## Alcance

- Asignar `enemyId` deterministico a cada enemigo de la oleada.
- Emitir una senal local cuando un proyectil destruye un enemigo.
- Enviar `enemy_destroyed` desde Godot al backend.
- Validar payload `enemy_destroyed` en backend.
- Broadcast de `enemy_destroyed` a todos los clientes de la sala.
- Remover el enemigo recibido por `enemyId` en cada cliente.
- Ignorar destrucciones duplicadas de forma segura.

## Fuera de Alcance

- Puntaje.
- Vida de enemigos.
- Autoridad de servidor para validar impacto.
- Respawn de oleadas.
- Persistencia de estado de enemigos en `room_state`.
- Reconciliacion para clientes que entran tarde a una partida ya iniciada.

## Checklist

- [ ] Agregar `enemyId` a `Enemy`.
- [ ] Guardar enemigos por `enemyId` en `GameScreen`.
- [ ] Emitir destruccion local desde `Projectile`.
- [ ] Conectar destruccion local en `GameScreen`.
- [ ] Agregar `enemy_destroyed` en `RoomSocket`.
- [ ] Parsear `enemy_destroyed` en backend.
- [ ] Validar que `enemyId` sea string no vacio.
- [ ] Broadcast de `enemy_destroyed` desde backend.
- [ ] Recibir `enemy_destroyed` en Godot.
- [ ] Remover enemigo remoto por `enemyId`.
- [ ] Ignorar eventos duplicados sin error visual.
- [ ] Mantener coverage backend 100%.

## Criterios de Aceptacion

- [ ] P1 destruye un OVNI y desaparece en P1.
- [ ] P1 destruye un OVNI y desaparece en P2.
- [ ] P2 destruye un OVNI y desaparece en P1.
- [ ] Un `enemy_destroyed` duplicado no rompe la partida.
- [ ] Los disparos sincronizados siguen funcionando.
- [ ] Godot carga sin errores con `godot --headless --path game --quit`.
- [ ] Backend mantiene lint, typecheck y coverage 100%.

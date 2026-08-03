# Enemy Movement Patterns Spec

## Objetivo

Dar identidad mecánica inicial a los tipos de OVNI mediante movimiento determinista y visible, manteniendo la sincronización actual sin mensajes de red nuevos.

## Alcance

- Mantener el desplazamiento lateral y rebote de toda la oleada.
- Agregar una oscilación local determinista por enemigo, según `enemyTypeId`.
- Aplicar patrones solo a las variantes preparadas para ello.
- Mantener las posiciones dentro del área superior de combate.
- Preservar IDs, HP, colisiones, disparos y destrucción sincronizada.

## Patrones iniciales

| Tipo | Patrón |
| --- | --- |
| `drone`, `tank`, `shooter`, `shield`, `support`, `elite` | Formación estable |
| `zigzag` | Oscilación horizontal corta |
| `sprinter` | Oscilación horizontal rápida y amplia |
| `diver` | Oscilación vertical suave, sin picada |
| `splitter` | Pulsación vertical corta |

Los patrones se calculan con tiempo global y un desfase derivado de `enemyId`; por lo tanto, ambos clientes obtienen el mismo movimiento sin sincronizar cada frame.

## Criterios de aceptación

- [ ] Zigzag y Sprinter se mueven lateralmente de forma distinguible.
- [ ] Diver y Splitter tienen movimiento vertical visible sin abandonar la formación.
- [ ] Los demás tipos mantienen formación estable.
- [ ] La oleada completa continúa rebotando lateralmente.
- [ ] Los enemigos siguen recibiendo impactos en sus posiciones visibles.
- [ ] Ambos clientes ven la misma composición y movimiento.
- [ ] Godot carga sin errores en modo headless.

## Fuera de alcance

- Picadas hacia jugadores.
- Pathfinding o IA reactiva.
- Proyectiles por tipo.
- Spawn de nuevas oleadas.
- Autoridad de posiciones de enemigos desde backend.

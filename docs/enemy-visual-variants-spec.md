# Enemy Visual Variants Spec

## Objetivo

Dar una silueta pixel-art distintiva a cada tipo de OVNI usando como guía la referencia visual incluida en el repositorio.

## Referencia

Fuente de inspiración: `game/assets/reference/gemini_galaga_reference.png`.

La imagen de referencia no se usará como sprite dentro del juego. Se crearán assets propios y consistentes para evitar recortes de la lámina compuesta y mantener una licencia/identidad visual clara del proyecto.

## Mapeo de tipos

| enemyTypeId | Referencia visual |
| --- | --- |
| `drone` | Platillo clásico |
| `zigzag` | Dreadnought |
| `tank` | Mothership |
| `sprinter` | Probe |
| `shooter` | Anomalous |
| `splitter` | Shard |
| `shield` | Orber |
| `diver` | Inorganic |
| `support` | Obelisk |
| `elite` | Phantom |

## Alcance

- Crear una hoja de sprites propia con 10 OVNIs pixel-art.
- Mantener un tamaño de celda consistente y transparente.
- Mapear cada sprite por `enemyTypeId` en el catálogo central.
- Reemplazar los polígonos placeholder por sprites.
- Mantener el color/escala de gameplay cuando no afecte la lectura del sprite.
- Mantener colisiones, HP, movimiento y sincronización actuales.

## Criterios de aceptación

- [ ] Existe una hoja de sprites propia con 10 variantes de OVNI.
- [ ] Cada `enemyTypeId` muestra su sprite correcto.
- [ ] Las siluetas son distinguibles durante la partida.
- [ ] Los sprites respetan transparencia y pixel art nítido.
- [ ] No se usan recortes de la imagen de referencia como assets finales.
- [ ] La oleada, colisiones y destrucción sincronizada siguen funcionando.
- [ ] Godot carga sin errores en modo headless.

## Fuera de alcance

- Animaciones por frame.
- Variantes de daño o destrucción.
- Rediseño de las naves de jugadores.
- Patrones de movimiento exclusivos.

# Enemy Type Catalog Spec

## Objetivo

Convertir la oleada de OVNIs genéricos en una composición determinista de tipos de enemigo, con identidad estable, vida propia y diferencias visuales simples.

## Alcance

- Crear un catálogo central de los 10 `enemyTypeId` definidos en el diseño.
- Asignar un tipo estable a cada enemigo de la oleada inicial.
- Aplicar HP por tipo desde el catálogo.
- Exponer `enemy_type_id` en la entidad `Enemy`.
- Ajustar color y escala visual según el tipo, sin assets nuevos.
- Mantener los IDs de instancia (`enemy-0` a `enemy-11`) y la sincronización de destrucción existentes.
- Mantener el movimiento lateral común de la oleada.

## Catálogo inicial

| ID | HP | Escala | Intención |
| --- | ---: | ---: | --- |
| `drone` | 36 | 0.85 | Básico y frágil |
| `zigzag` | 44 | 0.95 | Ágil |
| `tank` | 80 | 1.25 | Resistente |
| `sprinter` | 28 | 0.75 | Frágil |
| `shooter` | 52 | 1.00 | Preparado para disparar |
| `splitter` | 48 | 1.05 | Preparado para dividirse |
| `shield` | 72 | 1.20 | Defensivo |
| `diver` | 40 | 0.90 | Preparado para picada |
| `support` | 46 | 1.00 | Preparado para soporte |
| `elite` | 96 | 1.30 | Mayor desafío |

La primera oleada usará los 10 tipos una vez y repetirá `drone` y `sprinter` para completar sus 12 posiciones.

## Criterios de aceptación

- [x] Existe un catálogo central con los 10 tipos.
- [x] Cada enemigo recibe `enemyTypeId` de forma determinista.
- [x] Los HP provienen del tipo y no de un valor fijo.
- [x] Los tipos muestran diferencias de color y escala.
- [x] La destrucción sincronizada por `enemyId` sigue funcionando.
- [x] Los proyectiles de jugadores aplican daño sin regresiones.
- [x] Godot carga sin errores en modo headless.

## Fuera de alcance

- Patrones de movimiento específicos por tipo.
- Puntuación.
- Drops y power-ups.
- Ataques exclusivos por tipo.
- Autoridad de enemigos completa en backend.

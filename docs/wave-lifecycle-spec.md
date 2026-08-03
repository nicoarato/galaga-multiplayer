# Wave Lifecycle Spec

## Objetivo

Convertir la oleada inicial en una secuencia de juego continua: al derrotar a todos los enemigos aparece una oleada nueva, ligeramente más difícil.

## Alcance

- Mostrar el número de oleada actual.
- Detectar cuándo no quedan enemigos activos.
- Mostrar una transición breve de 2 segundos.
- Crear una nueva oleada de 12 enemigos.
- Usar IDs de enemigo únicos por oleada para ignorar mensajes retrasados de destrucción.
- Aumentar HP y velocidad de formación por oleada.
- Rotar la composición de tipos para que la distribución cambie sin introducir tipos nuevos.
- Mantener el modelo actual de destrucción sincronizada.

## Progresión inicial

| Propiedad | Oleada 1 | Por oleada adicional |
| --- | ---: | ---: |
| Cantidad de enemigos | 12 | 12 |
| Multiplicador de HP | 1.00 | +0.15 |
| Multiplicador de velocidad | 1.00 | +0.10 |
| Transición | 2 s | 2 s |

Ejemplo: la oleada 3 usa `1.30x` HP y `1.20x` velocidad de formación.

## Sincronización

Cada cliente conoce el mismo catálogo y elimina enemigos por ID. Una oleada se genera solo cuando el conjunto local queda vacío. Los IDs incluyen el número de oleada, por ejemplo `wave-2-enemy-4`, para que un evento tardío de la oleada anterior no afecte la nueva.

## Criterios de aceptación

- [x] El HUD muestra la oleada actual.
- [x] Al destruir el último enemigo aparece un estado de transición.
- [x] Una nueva oleada aparece luego de 2 segundos.
- [x] Los IDs de enemigos no se reutilizan entre oleadas.
- [x] El HP y velocidad aumentan según la tabla.
- [x] Las oleadas siguientes conservan variantes y patrones por tipo.
- [x] Ambos clientes ven la misma oleada al avanzar.
- [x] Godot carga sin errores en modo headless.

## Fuera de alcance

- Fin de partida o victoria final.
- Límites de oleadas.
- Cambios de fondo por nivel.
- Drops y power-ups.
- Spawns autoritativos desde backend.

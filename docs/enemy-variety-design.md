# Enemy Variety Design

## Objetivo

Hacer que las oleadas sean mas entretenidas incorporando variedad visual y mecanica de OVNIs.

La decision de producto es empezar con `10` tipos distintos de OVNI y dejar el sistema preparado para agregar mas en el futuro sin reescribir la logica principal de oleadas, colisiones o sincronizacion.

## Reglas Base

- El juego debe iniciar con 10 tipos de OVNI diferentes.
- Cada tipo debe tener un `enemyTypeId` estable.
- Los tipos deben poder variar por:
  - Visual/silueta.
  - Color.
  - Vida.
  - Puntaje.
  - Velocidad.
  - Patron de movimiento.
  - Cadencia de disparo futura.
  - Comportamiento especial futuro.
- Las oleadas deben referenciar tipos por ID, no por nombre visual.
- Agregar nuevos tipos no debe romper partidas existentes ni tests.

## Tipos Iniciales Propuestos

| ID | Nombre Interno | Intencion |
| --- | --- | --- |
| `drone` | Drone | Enemigo basico, baja vida |
| `zigzag` | Zigzag | Movimiento lateral mas marcado |
| `tank` | Tank | Mas vida, mas lento |
| `sprinter` | Sprinter | Rapido, fragil |
| `shooter` | Shooter | Preparado para disparo enemigo |
| `splitter` | Splitter | Futuro comportamiento al morir |
| `shield` | Shield | Resistente o con defensa frontal futura |
| `diver` | Diver | Ataque en picada futuro |
| `support` | Support | Puede buffear oleada en el futuro |
| `elite` | Elite | Mayor puntaje y dificultad |

Estos nombres son internos y pueden cambiar visualmente sin afectar la estructura.

## Escalabilidad

- Los stats deberian vivir en una tabla/configuracion central.
- Los assets visuales deberian mapearse por `enemyTypeId`.
- Las oleadas deberian definir una lista de enemigos con:
  - `enemyId`
  - `enemyTypeId`
  - posicion inicial
  - patron o parametros del patron
- El backend deberia terminar siendo autoridad sobre `enemyId`, `enemyTypeId`, HP y destruccion.

## Fuera de Alcance Inicial

- Bosses.
- Enemigos con multiples fases.
- IA compleja.
- Loot o drops.
- Balance final de dificultad.

## Cortes Sugeridos

### Enemy Type Catalog

- Crear catalogo de 10 tipos iniciales.
- Mantener visual placeholder si todavia no hay assets finales.
- Asignar `enemyTypeId` a cada enemigo.

### Enemy Stats

- Agregar HP y puntaje por tipo.
- Permitir que proyectiles reduzcan HP en vez de destruir todo de un golpe.

### Enemy Visual Variants

- Crear diferencias visuales claras entre tipos.
- Evitar que todo dependa solo del color.

### Wave Composition

- Definir oleadas mezclando tipos.
- Aumentar variedad por numero de oleada.

## Decisiones Pendientes

- Si los 10 tipos aparecen desde la primera oleada o se desbloquean progresivamente.
- Si todos los tipos tienen comportamiento distinto desde el principio o algunos empiezan solo como variantes visuales.
- Si los assets se generan en pixel art dentro del repo o se importan desde una herramienta externa.
- Como balancear HP/puntaje frente al sistema de daño por tipo de nave.

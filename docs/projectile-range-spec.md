# Projectile Range Spec

## Objetivo

Limitar el alcance de los proyectiles de jugadores y enemigos para evitar disparos que atraviesen todo el escenario desde su punto de origen.

## Alcance

- Medir la distancia recorrida desde el spawn de cada proyectil.
- Destruir el proyectil cuando llegue a su alcance máximo.
- Mantener la destrucción existente por colisión y por salida del área de juego.
- Aplicar el mismo criterio a proyectiles aliados y enemigos.
- Configurar el alcance mediante constantes simples por tipo de proyectil.

## Decisión de diseño

El alcance se mide por distancia y no por tiempo. La velocidad de proyectil solo modifica cuánto tarda en alcanzar su límite; no aumenta automáticamente el rango. Esto permite que futuros power-ups de velocidad mantengan un comportamiento claro y predecible.

## Balance inicial

| Proyectil | Velocidad | Alcance máximo |
| --- | ---: | ---: |
| Jugador | 720 px/s | 520 px |
| Enemigo | 220 px/s | 360 px |

## Criterios de aceptación

- [x] Un proyectil de jugador desaparece tras recorrer 520 px si no impacta.
- [x] Un proyectil enemigo desaparece tras recorrer 360 px si no impacta.
- [x] Un impacto todavía elimina el proyectil inmediatamente.
- [x] Los proyectiles siguen desapareciendo al salir del área de juego.
- [x] El comportamiento es visualmente igual en ambos clientes.
- [x] Godot carga sin errores en modo headless.

## Fuera de alcance

- Power-ups de alcance.
- Alcances distintos por clase de nave.
- Caída balística, rebotes u obstáculos.

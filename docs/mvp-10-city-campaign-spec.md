# MVP 10 City Campaign Spec

## Objetivo

Convertir las oleadas en una campaña MVP de 10 niveles-ciudad. Cada ciudad dura tres oleadas y aporta una identidad visual inmediata mediante nombre, paleta y velocidad de parallax.

## Alcance del corte

- Crear un catálogo central de 10 niveles-ciudad.
- Mostrar ciudad, nivel y oleada en el HUD.
- Avanzar de ciudad cada tres oleadas.
- Aplicar una paleta y velocidad de parallax por ciudad.
- Limitar la campaña a 30 oleadas.
- Mostrar estado `MVP COMPLETE` tras la última oleada.
- Reutilizar el fondo espacial actual y el sistema de parallax como infraestructura.

## Ciudades iniciales

| Nivel | Ciudad | Oleadas | Ambientación inicial |
| ---: | --- | ---: | --- |
| 1 | Buenos Aires | 1-3 | Violeta y cian nocturno |
| 2 | Nueva York | 4-6 | Azul eléctrico y magenta |
| 3 | París | 7-9 | Índigo y dorado |
| 4 | Tokio | 10-12 | Neón rosa y turquesa |
| 5 | Ciudad de México | 13-15 | Verde jade y ámbar |
| 6 | Río de Janeiro | 16-18 | Azul profundo y esmeralda |
| 7 | El Cairo | 19-21 | Oro y violeta oscuro |
| 8 | Estambul | 22-24 | Azul zafiro y cobre |
| 9 | Seúl | 25-27 | Cyan nocturno y fucsia |
| 10 | Londres | 28-30 | Azul grisáceo y rojo |

## Progresión

- Tres oleadas por ciudad.
- La dificultad conserva los multiplicadores globales de HP y velocidad por oleada.
- El número de ciudad se calcula desde la oleada global, por lo que ambos clientes llegan al mismo nivel sin mensajes nuevos.
- Tras limpiar la oleada 30, no aparece una oleada 31.

## Criterios de aceptación

- [ ] El HUD muestra el nombre de ciudad, nivel y oleada.
- [ ] La ciudad cambia cada tres oleadas.
- [ ] Cada ciudad aplica su paleta y velocidad de parallax.
- [ ] La campaña termina después de 30 oleadas.
- [ ] El gameplay conserva oleadas, enemigos, patrones y sincronización.
- [ ] Ambos clientes muestran la misma ciudad para una oleada dada.
- [ ] Godot carga sin errores en modo headless.

## Fuera de alcance

- Fondos pixel-art exclusivos por ciudad.
- Selección manual de nivel.
- Guardado de progreso.
- Cinemáticas.
- Bosses de ciudad.

## Siguiente corte de arte

Generar e integrar un fondo pixel-art propio por ciudad usando el mismo catálogo de nivel. La estructura de este corte evita cambios a gameplay cuando se agreguen esos assets.

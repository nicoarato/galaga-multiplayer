# Projectile Enemy Collision Spec

## Objetivo

Agregar la primera interaccion de combate: cuando un proyectil toca un enemigo, ambos desaparecen.

Este corte mantiene la logica simple y local para validar sensacion de juego antes de introducir puntaje, vida, autoridad de servidor o sincronizacion de enemigos destruidos.

## Alcance

- Agregar areas de colision a `Projectile`.
- Agregar areas de colision a `Enemy`.
- Detectar impacto proyectil-enemigo en Godot.
- Destruir el proyectil al impactar.
- Destruir el enemigo al impactar.
- Mantener disparos locales y remotos funcionando.
- Mantener la oleada deterministica existente.

## Fuera de Alcance

- Puntaje.
- Vida de enemigos.
- Efectos de explosion.
- Sonido.
- Sincronizacion backend de enemigos destruidos.
- Autoridad de servidor para impactos.
- Nuevos endpoints o mensajes WebSocket.

## Checklist

- [x] Convertir `Projectile` en nodo con deteccion de area.
- [x] Agregar shape de colision al proyectil.
- [x] Convertir `Enemy` en nodo con deteccion de area.
- [x] Agregar shape de colision al enemigo.
- [x] Definir layers/masks simples para proyectiles y enemigos.
- [x] Detectar impacto desde el proyectil.
- [x] Remover enemigo impactado.
- [x] Remover proyectil que impacta.
- [x] Mantener proyectiles saliendo del area como hasta ahora.
- [x] No modificar backend.

## Criterios de Aceptacion

- [x] Al disparar contra un enemigo, el proyectil desaparece.
- [x] Al disparar contra un enemigo, el enemigo desaparece.
- [x] Disparar sin impactar sigue eliminando el proyectil al salir del area.
- [x] La oleada sigue moviendose lateralmente.
- [x] Los disparos sincronizados siguen visibles entre clientes.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

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

- [ ] Convertir `Projectile` en nodo con deteccion de area.
- [ ] Agregar shape de colision al proyectil.
- [ ] Convertir `Enemy` en nodo con deteccion de area.
- [ ] Agregar shape de colision al enemigo.
- [ ] Definir layers/masks simples para proyectiles y enemigos.
- [ ] Detectar impacto desde el proyectil.
- [ ] Remover enemigo impactado.
- [ ] Remover proyectil que impacta.
- [ ] Mantener proyectiles saliendo del area como hasta ahora.
- [ ] No modificar backend.

## Criterios de Aceptacion

- [ ] Al disparar contra un enemigo, el proyectil desaparece.
- [ ] Al disparar contra un enemigo, el enemigo desaparece.
- [ ] Disparar sin impactar sigue eliminando el proyectil al salir del area.
- [ ] La oleada sigue moviendose lateralmente.
- [ ] Los disparos sincronizados siguen visibles entre clientes.
- [ ] Godot carga sin errores con `godot --headless --path game --quit`.

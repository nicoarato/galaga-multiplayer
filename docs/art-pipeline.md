# Art Pipeline

Este documento define como vamos a manejar arte, referencias y sprites para el MVP.

## Objetivo

Construir una direccion visual pixel art sci-fi arcade, consistente con la idea de un shooter de naves multiplayer en navegador.

Los assets deben permitir avanzar rapido en gameplay sin bloquear el desarrollo, pero manteniendo una base ordenada para reemplazar placeholders por arte final.

## Referencia Visual

Referencia actual:

```text
game/assets/reference/gemini_galaga_reference.png
```

La imagen se usa como referencia de estilo y catalogo inicial de unidades:

- 4 aviones jugables.
- 10 tipos de ovnis/enemigos.
- Fondo espacial pixel art.
- UI/titulos con estilo arcade.

La referencia no define nombres finales de producto ni obliga a copiar assets exactos. Se debe usar para orientar silueta, escala, paleta y tono visual.

## Portada

Portada inicial generada para el proyecto:

```text
game/assets/cover/invasion_26_cover.png
```

Titulo visual tentativo:

```text
INVASION '26
```

Uso previsto:

- README / presentacion publica del proyecto.
- Futuro hero de landing page.
- Referencia de tono para menus.

La portada es un asset del repo. No debe depender de rutas externas ni de archivos generados fuera del workspace.

## Reglas de Originalidad

- No copiar sprites, audio, nombres comerciales ni contenido propietario de Galaga u otros juegos.
- Los sprites finales deben ser originales o tener licencia compatible con el proyecto.
- Si se usa generacion asistida por IA, los outputs deben revisarse y guardarse como assets propios del proyecto.
- Cualquier asset externo debe documentar origen y licencia.
- La referencia visual puede vivir en `assets/reference`, pero no debe usarse directamente como sprite de gameplay.

## Carpetas

```text
game/assets/
  cover/
    invasion_26_cover.png
  reference/
    gemini_galaga_reference.png
  sprites/
    ships/
    enemies/
    projectiles/
    effects/
```

## Assets MVP

### Aviones Jugables

Se necesitan 4 variantes para permitir seleccion visual de jugador o asignacion por color/rol.

| ID | Nombre de trabajo | Uso inicial |
| --- | --- | --- |
| `fighter` | Fighter | Nave base rapida |
| `interceptor` | Interceptor | Nave balanceada |
| `stealth` | Stealth | Nave angosta/precisa |
| `escort_bomber` | Escort Bomber | Nave pesada |

### Enemigos

Se necesitan 10 tipos de enemigos para oleadas y progresion visual.

| ID | Nombre de trabajo | Rol inicial |
| --- | --- | --- |
| `classic_saucer` | Platillo clasico | Enemigo basico |
| `dreadnought` | Dreadnought | Enemigo resistente |
| `orber` | Orber | Enemigo esferico |
| `mothership` | Mothership | Mini boss / carrier |
| `ovni` | Ovni | Enemigo estandar alternativo |
| `anomalous` | Anomalous | Enemigo erratico |
| `shard` | Shard | Enemigo cristalino |
| `inorganic` | Inorganic | Enemigo organico/alien |
| `obelisk` | Obelisk | Enemigo vertical resistente |
| `probe` | Probe | Enemigo chico de enjambre |
| `phantom` | Phantom | Enemigo evasivo |

Nota: la referencia dice "10 tipos de ovnis", pero enumera 11 etiquetas visibles si se cuenta `phantom`. Para MVP podemos implementar 10 y dejar `phantom` como variante posterior, o mantener los 11 si el costo de assets es bajo. La decision final se toma al implementar oleadas.

### Proyectiles y Efectos

Assets minimos:

| ID | Uso |
| --- | --- |
| `projectile_player_primary` | Bala principal de jugador |
| `projectile_enemy_primary` | Bala enemiga |
| `explosion_small` | Explosion de enemigo chico |
| `explosion_medium` | Explosion de enemigo mediano |
| `hit_flash` | Feedback de impacto |

## Tamanos Base

Los tamanos pueden ajustarse despues de probar en Godot, pero el primer set debe respetar cajas consistentes.

| Tipo | Tamano recomendado |
| --- | --- |
| Avion jugador | `128x128` |
| Enemigo chico | `64x64` |
| Enemigo mediano | `96x96` |
| Enemigo grande | `160x96` |
| Boss / mothership | `192x128` |
| Proyectil | `16x32` |
| Explosion chica | `64x64` |
| Explosion mediana | `96x96` |

## Convenciones de Nombre

Usar snake_case.

```text
game/assets/sprites/ships/player_fighter.png
game/assets/sprites/ships/player_interceptor.png
game/assets/sprites/ships/player_stealth.png
game/assets/sprites/ships/player_escort_bomber.png

game/assets/sprites/enemies/enemy_classic_saucer.png
game/assets/sprites/enemies/enemy_dreadnought.png
game/assets/sprites/enemies/enemy_orber.png
game/assets/sprites/enemies/enemy_mothership.png
```

Para variantes:

```text
enemy_probe_a.png
enemy_probe_b.png
player_fighter_blue.png
player_fighter_red.png
```

## Placeholder vs Arte Final

### Placeholder

Un asset es placeholder si:

- Existe solo para validar gameplay.
- Puede tener menor detalle.
- Puede cambiar sin migracion.
- No define identidad visual final.

Debe tener nombre claro si no es final:

```text
placeholder_player_fighter.png
placeholder_enemy_probe.png
```

### Arte Final

Un asset pasa a final cuando:

- Tiene fondo transparente.
- Esta recortado correctamente.
- Tiene escala consistente con el resto.
- Se ve bien en Godot a resolucion logica.
- Tiene licencia/origen validado.
- No requiere edicion manual inmediata para gameplay.

## Checklist de Importacion en Godot

Para cada sprite:

- Guardar como PNG con transparencia.
- Verificar que no tenga fondo solido accidental.
- Mantener pixel art nítido.
- Revisar import settings de Godot para evitar blur.
- Probar escala en escena.
- Confirmar que el pivote/centro visual sea correcto.
- Verificar contraste contra fondo espacial.

## Orden de Trabajo

1. Mantener la referencia en `game/assets/reference/`.
2. Crear primer set de placeholders/generados.
3. Importar en Godot.
4. Conectar sprites a naves y enemigos.
5. Ajustar escala visual en gameplay.
6. Reemplazar placeholders por arte final sin cambiar logica.

## Decision Inicial

Para no bloquear el milestone de lobby, los assets no son prerequisito para el backend ni para el flujo de sala compartible.

El primer uso de arte debe apuntar al milestone de gameplay basico:

```text
Naves visibles -> movimiento -> disparos -> enemigos -> colisiones
```

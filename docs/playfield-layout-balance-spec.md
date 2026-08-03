# Playfield Layout Balance Spec

## Objetivo

Mejorar la distribucion visual de la partida para que la oleada y las naves tengan mas distancia util entre si.

Este corte prepara la pantalla para sistemas de combate mas entretenidos, como vida/energia, regeneracion y daño por tipo de nave, sin mezclar todavia reglas nuevas de gameplay.

## Alcance

- Reducir el espacio vertical ocupado por el HUD superior.
- Remover texto placeholder que no aporta a la partida.
- Dar mas alto minimo al `Playfield`.
- Calcular posiciones iniciales con proporciones del area visible.
- Mantener las naves dentro del area jugable.
- Mantener la oleada en la parte superior.
- Mantener disparos, colisiones y sync actuales.

## Fuera de Alcance

- Vida/energia de jugadores.
- Stats por tipo de nave.
- Regeneracion.
- Daño recibido por jugadores.
- Nuevos mensajes de backend.
- Cambios de arte.

## Checklist

- [x] Reducir altura visual del header de partida.
- [x] Remover placeholder de implementacion del HUD.
- [x] Aumentar alto minimo del playfield.
- [x] Definir margen superior/inferior proporcional del area jugable.
- [x] Reposicionar naves locales/remotas mas abajo.
- [x] Reposicionar oleada mas arriba.
- [x] Mantener clamp de movimiento visible.
- [x] Mantener rebote lateral de la oleada.
- [x] No modificar backend.

## Criterios de Aceptacion

- [x] La distancia entre oleada y naves es claramente mayor que en el corte anterior.
- [x] En ventana ancha/baja, la nave no aparece pegada a la oleada.
- [x] La oleada sigue apareciendo completa dentro del area visible.
- [x] Las naves siguen moviendose sin salir del plano.
- [x] Disparos, colisiones y destruccion sincronizada siguen funcionando.
- [x] Godot carga sin errores con `godot --headless --path game --quit`.

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

- [ ] Reducir altura visual del header de partida.
- [ ] Remover placeholder de implementacion del HUD.
- [ ] Aumentar alto minimo del playfield.
- [ ] Definir margen superior/inferior proporcional del area jugable.
- [ ] Reposicionar naves locales/remotas mas abajo.
- [ ] Reposicionar oleada mas arriba.
- [ ] Mantener clamp de movimiento visible.
- [ ] Mantener rebote lateral de la oleada.
- [ ] No modificar backend.

## Criterios de Aceptacion

- [ ] La distancia entre oleada y naves es claramente mayor que en el corte anterior.
- [ ] En ventana ancha/baja, la nave no aparece pegada a la oleada.
- [ ] La oleada sigue apareciendo completa dentro del area visible.
- [ ] Las naves siguen moviendose sin salir del plano.
- [ ] Disparos, colisiones y destruccion sincronizada siguen funcionando.
- [ ] Godot carga sin errores con `godot --headless --path game --quit`.

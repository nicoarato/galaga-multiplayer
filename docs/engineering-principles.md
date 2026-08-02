# Engineering Principles

Este documento define los criterios tecnicos minimos del proyecto. Cualquier cambio de codigo debe respetarlos desde el inicio.

## Objetivo

Mantener el proyecto simple, testeable y portable mientras evoluciona hacia un juego multiplayer realtime. La prioridad es poder avanzar rapido sin acumular deuda tecnica innecesaria.

## Reglas Generales

- El codigo debe tener una razon concreta para existir.
- No se deja codigo muerto, helpers sin uso, archivos placeholder sin contenido util ni abstracciones "por si acaso".
- Los algoritmos deben ser simples y explicitos.
- Se prefiere codigo directo y testeable antes que patrones complejos.
- Las responsabilidades deben estar separadas por dominio.
- Las decisiones tecnicas relevantes deben quedar documentadas en `docs/`.
- Los commits deben ser chicos, coherentes y verificables.

## Calidad Obligatoria

Antes de mergear o pushear cambios funcionales, el proyecto debe pasar:

- Lint.
- Typecheck cuando aplique.
- Tests unitarios.
- Coverage.

Para backend y paquetes compartidos, el objetivo es:

```text
100% unit test coverage
```

El 100% aplica al codigo propio testeable. Archivos de wiring, bootstrap o adaptadores externos pueden excluirse solo si la exclusion esta justificada y es explicita en la configuracion de coverage.

## Backend

El backend debe mantenerse portable entre hosting providers. No debe depender innecesariamente de APIs especificas de Render, Railway, Fly.io, Netlify, Cloudflare u otro proveedor.

Reglas:

- Usar variables de entorno para configuracion.
- Escuchar en `0.0.0.0`.
- Leer el puerto desde `PORT`.
- Mantener la logica de salas separada del servidor HTTP/WebSocket.
- Mantener el protocolo de mensajes documentado y testeado.
- No guardar estado importante en disco local.
- Para MVP, las salas pueden vivir en memoria porque son efimeras.

Estructura esperada:

```text
backend/
  src/
    server.ts
    rooms/
    protocol/
  tests/
```

## Godot

El cliente Godot debe priorizar claridad de escenas y scripts.

Reglas:

- Mantener scripts chicos y con responsabilidad clara.
- Separar logica pura de nodos/escenas cuando sea razonable.
- Evitar estado global salvo para configuracion o servicios compartidos claros.
- La URL del backend debe ser configurable.
- No hardcodear endpoints en multiples scripts.
- Mantener assets originales o con licencia valida.

El coverage unitario completo en Godot puede no ser practico al inicio. La expectativa inicial es mantener la logica del cliente simple y validar los flujos criticos manualmente. Si la logica crece, se evaluara agregar un framework de tests para Godot.

## Protocolo

Los mensajes entre cliente y backend deben ser:

- JSON.
- Versionables.
- Documentados.
- Validados en el backend.
- Cubiertos por tests unitarios cuando formen parte de reglas propias.

No se deben introducir cambios incompatibles en el protocolo sin actualizar la documentacion correspondiente.

## Testing

Los tests deben cubrir comportamiento, no detalles internos innecesarios.

Buenas practicas:

- Testear reglas de salas como funciones/servicios puros.
- Testear validacion de mensajes.
- Testear errores esperados.
- Evitar tests fragiles basados en timing real.
- Usar datos deterministas.
- Mantener tests legibles y chicos.

## CI

El CI debe ejecutar como minimo:

```text
lint
typecheck
test
coverage
```

El proyecto no debe aceptar cambios que rompan esos checks una vez que el tooling este configurado.

## Definicion de Done

Un cambio esta terminado cuando:

- Cumple el comportamiento pedido.
- No introduce codigo muerto.
- Mantiene algoritmos simples.
- Tiene tests suficientes para el riesgo del cambio.
- Mantiene o mejora el coverage requerido.
- Actualiza documentacion si cambia arquitectura, protocolo, setup o comportamiento esperado.
- Pasa los checks locales disponibles.

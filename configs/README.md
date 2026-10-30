# Configuraciones entregadas

| Archivo | Procedencia |
|---|---|
| [R1-AAA.rsc](R1-AAA.rsc) | Export real del router, recibido el 30 de octubre de 2026 |
| [SW1-AAA.rsc](SW1-AAA.rsc) | Export real del switch, recibido el 30 de octubre de 2026 |
| [nps-politicas-documentadas.json](nps-politicas-documentadas.json) | Especificación documental de las políticas de AD/NPS |

Los dos .rsc conservan los comandos, las marcas de tiempo y los system id recibidos; solo se retiraron los prompts de terminal que rodeaban las salidas. Son exports de la configuración activa de RouterOS para documentar las running-configs de la práctica. No se sustituyeron los valores de configuración ni se eliminó la excepción require-message-auth=no.

Los exports omiten secretos y las altas de cuentas locales. No son copias completas de las VM ni scripts idempotentes. Para reconstrucción, revisar interfaces y objetos existentes y crear las cuentas y claves privadas de forma local. No importarlos directamente sobre el montaje que ya funciona.

El JSON de NPS no es un export nativo XML del servidor ni contiene claves compartidas. Los datos se reconstruyeron a partir del procedimiento y de las correcciones confirmadas. La validación del servidor se documenta en [scripts/04-validar-servidor.ps1](../scripts/04-validar-servidor.ps1), y el manual en [docs/ad-y-nps.md](../docs/ad-y-nps.md).

# Scripts y comandos de la práctica

| Archivo | Finalidad |
|---|---|
| [01-roles-y-bosque.ps1](01-roles-y-bosque.ps1) | Instalación de roles y creación del bosque, para reconstrucción |
| [02-grupos-y-usuarios.ps1](02-grupos-y-usuarios.ps1) | OU, grupos y usuarios de prueba de AD |
| [03-clientes-radius.ps1](03-clientes-radius.ps1) | Clientes RADIUS, firewall y auditoría del servidor |
| [04-validar-servidor.ps1](04-validar-servidor.ps1) | Consultas del estado de red, dominio, servicios, grupos y NPS |
| [05-diagnostico-radius.ps1](05-diagnostico-radius.ps1) | Consulta de eventos y diagnóstico de solicitudes RADIUS |
| [verificar-nas.rsc](verificar-nas.rsc) | Consultas de RouterOS para verificar los NAS |
| [COMANDOS-UTILIZADOS.md](COMANDOS-UTILIZADOS.md) | Registro del procedimiento y comandos usados durante la práctica |
| [generar-diagramas.py](generar-diagramas.py) | Generación documental de los diagramas PNG/SVG con Matplotlib |
| [requirements-diagramas.txt](requirements-diagramas.txt) | Dependencias del generador de diagramas |

Los scripts PowerShell son versiones reutilizables de los comandos de la sesión. Se revisaron de forma estática; no se verificó su ejecución completa como scripts. Los scripts de instalación modifican la infraestructura; en el laboratorio ya terminado se comienza por validación. Las contraseñas se solicitan de forma interactiva y no se incluyen en los archivos.

Los exports reales de los equipos se encuentran en [configs](../configs/README.md).

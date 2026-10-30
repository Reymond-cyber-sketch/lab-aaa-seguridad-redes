# Configuración del router y del switch

## Enrutamiento y conmutación

R1 tiene la LAN 10.24.96.1/24 en ether2, un cliente DHCP en ether1 y NAT masquerade para la red 10.24.96.0/24 al salir por ether1. SW1 integra ether1, ether2 y ether3 en BR-AAA, tiene la dirección de gestión 10.24.96.2/24 en ese bridge y usa 10.24.96.1 como gateway.

Las configuraciones exactas recibidas se conservan en [R1-AAA.rsc](../configs/R1-AAA.rsc) y [SW1-AAA.rsc](../configs/SW1-AAA.rsc). Los puertos del cableado están en [topología](topologia.md).

## Usuarios y autorización

Se observaron admin y admin-local como usuarios locales de ambos equipos. admin pertenece al grupo full; admin-local, a gestion-local. El grupo gestion-local incluye los permisos local, ssh, reboot, read, write, policy, test, password y sensitive. Las credenciales se gestionan de forma privada y no forman parte del repositorio.

Los grupos de dominio se autorizan mediante nivel0, nivel5 y nivel10, con los permisos descritos en [roles y pruebas](roles-y-pruebas.md). sin-acceso se utiliza como grupo predeterminado sin permisos. exclude-groups contiene full, read, write y gestion-local para impedir asignar esos grupos mediante RADIUS.

## Clientes RADIUS

| Parámetro | R1 | SW1 |
|---|---|---|
| Servidor | 10.24.96.138 | 10.24.96.138 |
| Dirección de origen | 10.24.96.1 | 10.24.96.2 |
| Servicio | login | login |
| Timeout | 3 segundos | 3 segundos |
| Grupo predeterminado | sin-acceso | sin-acceso |
| Actualización de accounting | 1 minuto | 1 minuto |
| require-message-auth del export | no; excepción temporal | no; excepción temporal |

use-radius=yes se conserva en ambos exports. accounting=yes se observó mediante /user aaa print durante la configuración; para validar valores efectivos se utiliza esa consulta, porque el export compacto omite valores predeterminados. Las claves deben coincidir en cada pareja NAS/NPS y no se publican.

## Servicios y SSH

SSH se habilitó para orígenes 10.24.96.0/24 con strong-crypto=yes. Se deshabilitaron los servicios de gestión indicados en los exports y el acceso mediante MAC server y MAC WinBox. La sesión SSH hacia R1 se demostró con admin y la de SW1 con admin-local; las cuentas de dominio carecen de permiso ssh.

## Registros y límites

En ambos equipos se añadió logging radius,!packet con prefijo AAA-RADIUS. Los mensajes añadidos se guardan en memoria y se complementan con los eventos de NPS. No se demostró persistencia de cada comando denegado. CHR no aporta AUX independiente en este montaje. El [alcance y las limitaciones](alcance-y-limitaciones.md) documentan estos puntos y el cierre pendiente de la protección de respuestas RADIUS.

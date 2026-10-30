# Alcance, limitaciones y cierre de seguridad

## Adaptación de la plataforma

Se utilizaron dos MikroTik CHR con RouterOS 7.23.7 porque eran las imágenes disponibles. SW1 cumple la función de conmutación mediante el bridge BR-AAA; R1 cumple la función de enrutamiento y NAT. Los niveles 0, 5 y 10 son nombres de roles definidos para este laboratorio, no los niveles numéricos nativos de Cisco IOS.

Las cuentas de dominio reciben grupos de RouterOS con permiso local y sin ssh. La sesión de consola fue el canal usado en las pruebas de dominio. La administración SSH se demostró con cuentas locales.

CHR expone en este montaje serial0 y una consola virtual; no se aportó un puerto AUX independiente. Por tanto, la exigencia literal de consola y auxiliar queda parcialmente cubierta. Tampoco se configuraron listas AAA independientes por línea: RouterOS usa AAA de login global y permisos de acceso por grupo. La restricción de SSH para el dominio es una autorización de RouterOS; no significa que NPS disponga de una lista AAA exclusiva para cada puerto físico.

## Excepción temporal de RADIUS

Los dos exports contienen require-message-auth=no. Se aplicó después de que el router descartara respuestas del NPS con el mensaje «rx packet with missing message auth, dropping». La versión inicial observada del servidor fue Windows Server 2022, build 20348.587; se iniciaron actualizaciones, pero no se confirmó una compilación final actualizada.

Esta configuración permitió continuar la práctica y reduce la protección frente a respuestas RADIUS falsificadas. No debe presentarse como el estado de máxima seguridad ni como una configuración de producción terminada. La validación de solicitudes en los clientes de NPS se configuró con AuthAttributeRequired=True; esa validación es distinta de la exigencia de firma en las respuestas que recibe el NAS.

Para cerrar la excepción:

1. Completar las actualizaciones de seguridad de Windows Server/NPS.
2. Comprobar que las respuestas al NAS incluyen un Message-Authenticator válido.
3. Manteniendo una sesión local de recuperación, restaurar en cada MikroTik:

~~~routeros
/radius set [find where address=10.24.96.138] require-message-auth=yes-for-request-resp
~~~

4. Repetir los accesos de los tres roles y verificar que aumentan accepts sin nuevos bad-replies.
5. Obtener exports nuevos y sustituir las evidencias anteriores. La mera instalación de una actualización no sustituye esa comprobación.

## Registros y autorización

Los exports añaden logging de radius,!packet con el prefijo AAA-RADIUS. No contienen una acción de logging a disco ni un servidor syslog remoto. El registro añadido es en memoria; no se documenta persistencia del registro de RouterOS tras un reinicio.

NPS tenía auditoría Success and Failure habilitada y se observaron eventos 6272 y 6273, además de errores de comunicación en System. Esos eventos documentan decisiones de acceso. Las denegaciones de comandos de nivel 5 se demostraron en la consola; no se aportó un registro persistente de cada comando denegado. El accounting de sesiones y la autorización de cada comando son funciones diferentes.

El ajuste interim-update=1m figura en ambos exports. El parámetro accounting=yes se observó en las consultas previas de AAA; al ser un export compacto, deben comprobarse los valores efectivos con /user aaa print. Falta adjuntar una muestra final de accounting de sesión de ambos NAS si se desea demostrar ese punto de extremo a extremo.

## Controles no acreditados por estos archivos

- El cambio final de todas las contraseñas locales y compartidas no puede comprobarse a partir de un export que omite secretos. Se solicitó sustituir las contraseñas temporales antes de grabar o publicar.
- Los exports no contienen reglas de firewall filter de RouterOS. Sí contienen restricción de origen para SSH, desactivación de servicios de gestión indicados y desactivación de acceso MAC. No se afirma que exista una política general de filtrado WAN.
- La configuración final de NPS no se recibió como un export nativo. La tabla de políticas recoge el procedimiento y la corrección confirmada, con las comprobaciones finales indicadas en el manual.
- No se verificó sincronización de hora entre Windows y los NAS. Las marcas de tiempo se conservan tal como fueron entregadas; se debe comprobar fecha, hora y zona al grabar.

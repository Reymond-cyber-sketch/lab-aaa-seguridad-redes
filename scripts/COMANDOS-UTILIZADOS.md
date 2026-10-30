# Comandos utilizados y manejo de credenciales

Los exports de configs conservan el estado real entregado. Los archivos de scripts son versiones reutilizables de los comandos de la sesión, con comprobaciones y entrada privada de claves. No representan una nueva ejecución sobre la topología.

## Instalación de roles y bosque

En Windows Server, PowerShell como administrador:

~~~powershell
Install-WindowsFeature AD-Domain-Services,DNS,NPAS -IncludeManagementTools
Install-ADDSForest -DomainName "seguridad.test" -DomainNetbiosName "SEGURIDAD" -InstallDNS -CreateDnsDelegation:$false -Force
~~~

La promoción solicita una contraseña DSRM y reinicia el servidor. Solo corresponde a una VM preparada para crear ese bosque; en el servidor actual se realiza validación. Una clave DSRM débil fue rechazada durante el primer intento y se sustituyó.

## Red estática del servidor

Estos comandos se ejecutaron inicialmente desde la consola del servidor, después de instalar los roles. El índice 4 corresponde a la NIC de este montaje. Reemplazaron su direccionamiento anterior; se conservan como registro del procedimiento, no como una validación de solo lectura.

~~~powershell
Set-NetIPInterface -InterfaceIndex 4 -AddressFamily IPv4 -Dhcp Disabled
Get-NetRoute -InterfaceIndex 4 -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue |
    Remove-NetRoute -Confirm:$false
Get-NetIPAddress -InterfaceIndex 4 -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Remove-NetIPAddress -Confirm:$false
New-NetIPAddress -InterfaceIndex 4 -IPAddress 10.24.96.138 -PrefixLength 24 -DefaultGateway 10.24.96.1
Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses 10.24.96.138
Set-DnsServerForwarder -IPAddress 1.1.1.1,8.8.8.8
~~~

Las cuentas de laboratorio se crearon deshabilitadas, se les asignó contraseña mediante Read-Host -AsSecureString y Set-ADAccountPassword, se habilitaron y se añadieron a sus grupos. El script de cuentas conserva ese comportamiento para cuentas nuevas y evita sustituir contraseñas de cuentas ya habilitadas.

## Clientes y auditoría

Se utilizaron New-NpsRadiusClient y Set-NpsRadiusClient con nombre, IP, clave privada, Enabled=True y AuthAttributeRequired=True, además de New-NetFirewallRule para UDP 1812/1813. Las claves reales se sustituyen por entrada interactiva en los scripts.

~~~powershell
auditpol /set /subcategory:"Network Policy Server" /success:enable /failure:enable
Restart-Service IAS
Get-NpsRadiusClient | Format-Table Name,Address,Enabled
Get-Service IAS
Get-NetUDPEndpoint -LocalPort 1812,1813
~~~

El registro de NPS en AD también se revisó mediante la pertenencia del equipo al grupo RAS and IAS Servers. Las políticas y sus atributos se configuraron en la consola nps.msc, como detalla el manual.

## Diagnóstico

~~~powershell
pktmon filter add AAA-SW1 -i 10.24.96.2 -t UDP -p 1812
pktmon start --capture --counters-only --comp nics
# Realizar un intento de acceso desde SW1.
pktmon counters
pktmon stop
pktmon filter remove AAA-SW1
~~~

Se consultaron eventos Security 6272/6273/6274 y eventos del proveedor NPS en System. El diagnóstico reutilizable conserva esos filtros y evita capturar el contenido de paquetes.

## RouterOS

Las direcciones, interfaces, NAT, servicios, grupos, AAA, RADIUS y logging utilizados están en los exports reales. Las claves RADIUS se configuraron localmente con /radius set; los valores privados no se reproducen. La compatibilidad temporal require-message-auth=no figura expresamente en los archivos y en las limitaciones.

Se utilizaron /user active print, /ip address print y una escritura de identity para las pruebas de permisos. Se documenta una variante que conserva automáticamente el nombre actual del dispositivo.

También se utilizaron estas consultas y exportaciones:

~~~routeros
/radius monitor 0 once
/user aaa print
/system console print
/port print
/system license print
/export
~~~

En SW1 se comprobó la conectividad del origen RADIUS con:

~~~routeros
/ping 10.24.96.138 src-address=10.24.96.2 count=4
/ip arp print where address=10.24.96.138
~~~

## SSH desde Windows Server

~~~powershell
ssh -o StrictHostKeyChecking=accept-new admin@10.24.96.1
ssh admin-local@10.24.96.2
~~~

Tras comprobar la sesión mediante /user active print, /password permite cambiar la contraseña de la cuenta conectada. Nunca grabar ni publicar claves introducidas como argumentos en comandos. Las credenciales locales y de dominio son diferentes de la clave compartida RADIUS.

## Reconstrucción

Un .rsc compacto no es una imagen completa de la VM ni un script idempotente. Estos exports omiten secretos y no contienen los comandos de alta de las cuentas locales observadas. Una reconstrucción requiere crear esas cuentas con claves privadas y restaurar las claves NAS/NPS de forma local. No se debe importar el export sobre el equipo funcionando sin revisar conflictos de interfaces y objetos existentes.

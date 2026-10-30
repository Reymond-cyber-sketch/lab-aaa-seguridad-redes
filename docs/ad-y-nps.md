# Instalación y configuración de Active Directory y NPS

## Estado identificado

El servidor utilizado es Windows Server 2022 Standard Evaluation, no Windows Server 2019. El nombre de equipo observado fue WIN-E4RSOHRPSJM. El dominio es seguridad.test, NetBIOS SEGURIDAD y la OU de laboratorio es LAB-AAA.

La NIC del montaje fue Ethernet0 2, índice 4, con dirección estática 10.24.96.138/24, gateway 10.24.96.1 y DNS 10.24.96.138. Los roles AD-Domain-Services, DNS y NPAS se instalaron con sus herramientas. La creación del bosque se ejecutó mediante Install-ADDSForest y una contraseña DSRM privada.

Los scripts de instalación y cuentas incluidos en la carpeta scripts son versiones reutilizables de los comandos aplicados. La revisión de esos archivos fue estática; no se verificó su ejecución completa como scripts. En el servidor ya configurado se comienza por el script de validación.

## Active Directory

En dsa.msc, dentro de seguridad.test:

1. Crear o verificar la OU LAB-AAA.
2. Verificar los grupos de seguridad global NIVEL-0, NIVEL-5 y NIVEL-10.
3. Verificar usuario0, usuario5 y usuario10, cada uno en su grupo de nivel correspondiente.
4. En Properties → Dial-in de cada cuenta, utilizar Control access through NPS Network Policy. La configuración final de usuario10 está acreditada por captura.
5. Mantener credenciales privadas y compatibles con el acceso NAS. Se desmarcó el cambio obligatorio de contraseña en el siguiente inicio para las cuentas de prueba.

No convertir estas cuentas en Domain Admins. Su nivel se determina por la política de NPS y los permisos del grupo de RouterOS.

## NPS y clientes RADIUS

Abrir nps.msc. Registrar NPS en Active Directory mediante la opción Register server in Active Directory de NPS (Local), o verificar la pertenencia del equipo al grupo RAS and IAS Servers. El primer intento con netsh y el FQDN no completó el registro; la autenticación posterior de dominio sí quedó demostrada.

En RADIUS Clients and Servers → RADIUS Clients:

| Nombre | Dirección del NAS | Estado | Message-Authenticator de solicitudes |
|---|---|---|---|
| R1-AAA | 10.24.96.1 | Habilitado | Requerido |
| SW1-AAA | 10.24.96.2 | Habilitado | Requerido |

Usar una clave RADIUS privada idéntica en ambos extremos de cada relación NAS/NPS. La clave RADIUS no es la contraseña de usuario0, usuario5, usuario10 ni de las cuentas locales de administración.

En la práctica se utilizó una clave compartida común para ambos NAS. No se guarda en los exports ni en los scripts del paquete. Para mayor separación en una reconstrucción se pueden usar claves independientes, siempre coincidentes entre cada NAS y su cliente de NPS.

El firewall del servidor permitió UDP 1812 y 1813 desde 10.24.96.1 y 10.24.96.2. Se añadió además una regla limitada a SW1 durante el diagnóstico. No se deshabilitó el firewall completo.

## Políticas de solicitud y de red

La política de solicitud observada en los eventos fue Use Windows authentication for all users, con proveedor Windows y autenticación en el propio servidor.

En Policies → Network Policies, las tres políticas de concesión deben quedar antes de las reglas predeterminadas Connections…:

| Orden previsto | Política | Condición de Windows Groups | Permiso | Grupo devuelto |
|---|---|---|---|---|
| 1 | AAA-NIVEL-0 | SEGURIDAD\NIVEL-0 | Grant access | nivel0 |
| 2 | AAA-NIVEL-5 | SEGURIDAD\NIVEL-5 | Grant access | nivel5 |
| 3 | AAA-NIVEL-10 | SEGURIDAD\NIVEL-10 | Grant access | nivel10 |

En Overview: habilitar la política, Grant access y tipo de servidor Unspecified. Si se decide ignorar propiedades dial-in en una política, documentarlo de forma coherente; la corrección de la cuenta usuario10 utilizó Control access through NPS Network Policy.

En Conditions: dejar el grupo correcto de ese nivel y comprobar que no quede el grupo de la política que se copió. No añadir restricciones de puerto NAS que no estén presentes en las solicitudes de consola del montaje.

En Constraints → Authentication Methods: habilitar Microsoft Encrypted Authentication version 2 (MS-CHAP-v2). Los eventos de usuario5 acreditaron MS-CHAPv2. La configuración inicial también utilizó PAP/SPAP; falta una captura final que permita certificar qué métodos adicionales siguen habilitados y si existe un override en la política de solicitud. Para el cierre, verificar el método de las tres cuentas y retirar métodos que ya no se utilicen.

En Settings → RADIUS Attributes → Vendor Specific, configurar el atributo de fabricante:

| Campo | Valor |
|---|---|
| Atributo exterior | Vendor-Specific, tipo 26 |
| Vendor code | 14988 |
| Formato | Conforme a RFC |
| Tipo de atributo del fabricante | 3 |
| Formato del valor | String |
| Valor | nivel0, nivel5 o nivel10, según la política |

No confundir NIVEL-10, nombre de grupo de AD, con nivel10, nombre exacto del grupo local de RouterOS. Evitar arrastrar atributos de plantillas PPP/VPN que no correspondan a login; revisar Framed-Protocol y Service-Type si aparecen.

## Auditoría y evidencia

La auditoría de NPS se comprobó con:

~~~powershell
auditpol /get /subcategory:"Network Policy Server"
~~~

Se observó Success and Failure. El servicio IAS estaba Running y escuchaba en UDP 1812/1813. Las direcciones ::ffff:10.24.96.138 que mostró Get-NetUDPEndpoint son representaciones IPv4 mapeadas; no demostraban una escucha exclusivamente IPv6.

Los eventos Security 6272 y 6273 permiten revisar cuenta, cliente, política, método y motivo. Los eventos System de NPS 13 y 18 fueron útiles para clientes desconocidos y firmas inválidas. El evento 65 que apareció dentro de Reason Code de 6273 identificó una denegación dial-in.

Conservar una muestra final de concesión de cada nivel y cada NAS, y una denegación controlada. Mostrar registros del intento recién realizado para evitar atribuir un error antiguo a una configuración ya corregida.

## Datos de configuración entregados

La especificación JSON de políticas incluida es una reconstrucción documentada del procedimiento y de sus correcciones, no un export nativo de NPS. No se recibió un XML final del servidor. Un export nativo puede contener secretos; no debe incorporarse sin revisión al repositorio público.

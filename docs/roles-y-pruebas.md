# Usuarios, grupos y pruebas de permisos

| Cuenta de AD | Grupo de AD | Política NPS | Mikrotik-Group |
|---|---|---|---|
| usuario0@seguridad.test | NIVEL-0 | AAA-NIVEL-0 | nivel0 |
| usuario5@seguridad.test | NIVEL-5 | AAA-NIVEL-5 | nivel5 |
| usuario10@seguridad.test | NIVEL-10 | AAA-NIVEL-10 | nivel10 |

| Grupo de RouterOS | Permisos positivos configurados | Resultado esperado |
|---|---|---|
| nivel0 | local | Inicia consola; no consulta la configuración |
| nivel5 | local, read, test | Consulta y herramientas de prueba; no modifica la configuración |
| nivel10 | local, read, write, test | Consulta y modifica configuración general; no administra usuarios ni accede por SSH |
| gestion-local | local, ssh, reboot, read, write, policy, test, password, sensitive | Gestión local y SSH con una cuenta administrativa |
| sin-acceso | Ninguno | Grupo de reserva sin permisos |

Los grupos incorporados full, read y write, y el grupo gestion-local, figuran en exclude-groups de AAA para impedir su asignación mediante RADIUS. Los usuarios de dominio no se crearon como usuarios locales del NAS.

## Prueba por consola en cada NAS

Entrar con cada cuenta por la consola de GNS3, usando su contraseña privada. /quit cierra cada sesión.

Con usuario0:

~~~routeros
/ip address print
~~~

Resultado esperado: not enough permissions. Para demostrar su autenticación sin derechos de lectura, conservar el prompt de la cuenta y el evento 6272 correspondiente en el servidor.

Con usuario5:

~~~routeros
/user active print
/ip address print
/system identity set name=[/system identity get name]
~~~

Se espera la bandera R, lectura permitida y escritura denegada. La última orden intenta escribir el nombre que ya tiene el equipo; evita cambiar R1 por SW1 accidentalmente.

Con usuario10:

~~~routeros
/user active print
/ip address print
/system identity set name=[/system identity get name]
~~~

Se espera la bandera R, lectura permitida y regreso al prompt sin error en la escritura. El último comando conserva el nombre actual.

## Estado de las evidencias

Se confirmó el inicio de sesión de los niveles 0, 5 y 10 en ambos NAS. Las capturas de nivel 5 en R1 y SW1 muestran lectura permitida y escritura denegada. Los exports acreditan los permisos configurados de los tres grupos.

Se añadieron capturas de lectura denegada de nivel 0 en los dos NAS y de escritura aceptada de nivel 10 en R1. En la prueba histórica de R1 se escribió SW1-AAA; el nombre se corrigió después, como confirma el export final. La captura de nivel 10 de SW1 muestra la bandera R y la orden, pero corta la línea inferior: completar esa captura al grabar. El inventario enlaza los archivos originales.

Para comprobar la restricción remota, realizar una prueba controlada de SSH con una cuenta de dominio. El resultado previsto es una denegación por sus permisos; esa prueba negativa todavía no se aportó como evidencia.

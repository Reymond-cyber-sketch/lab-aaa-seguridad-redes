# Relación entre requisitos y entregables

## Repositorio

| Requisito | Archivo o ubicación | Estado |
|---|---|---|
| Un repositorio de GitHub | README.md y carpetas técnicas de LAB-AAA | Repositorio creado; carga inicial en curso |
| Documentación profesional | README.md y docs | Incluida |
| Video al principio del repositorio | Primera línea de README.md | Espacio reservado; enlace de YouTube pendiente |
| Imágenes | imagenes y docs/evidencias.md | Capturas originales incluidas |
| Diagramas | imagenes/topologia.png, imagenes/flujo-aaa.png; fuentes SVG, Mermaid y Python | Incluidos |
| Propósito del laboratorio | Sección Propósito del laboratorio en README.md | Incluido |
| Scripts utilizados | scripts y scripts/COMANDOS-UTILIZADOS.md | Incluidos sin credenciales |
| Running-configs | configs/R1-AAA.rsc y configs/SW1-AAA.rsc | Exports reales de RouterOS incluidos |

## Topología

| Requisito | Evidencia o documentación | Alcance |
|---|---|---|
| Router y switch como clientes RADIUS | Ambos .rsc, manual AD/NPS y capturas de sesiones con bandera R | Acceso de los tres roles confirmado en ambos NAS |
| Usuarios locales | evidencia/usuarios-locales-observados.txt y capturas SSH | Cuentas observadas; secretos omitidos |
| Autorización por nivel | docs/roles-y-pruebas.md y capturas | Lectura y escritura diferenciadas por grupo RouterOS |
| Acceso de dominio por consola y auxiliar | Grupos con permiso local y sin ssh | Consola demostrada; AUX independiente no disponible en CHR |
| Logs de autenticación, autorización y RADIUS | Logging de NAS y eventos NPS descritos | Acceso y RADIUS registrados; falta demostrar persistencia por comando denegado |
| SSH | Capturas de administración local en ambos NAS | R1 con admin; SW1 con admin-local |
| AD con grupos 0, 5 y 10 | docs/ad-y-nps.md y scripts/02-grupos-y-usuarios.ps1 | NIVEL-0, NIVEL-5 y NIVEL-10 |
| Servicio NPS | docs/ad-y-nps.md y configs/nps-politicas-documentadas.json | Clientes y políticas documentados; JSON no es export nativo |

Los requisitos con cobertura parcial y la excepción require-message-auth=no se explican en [alcance y limitaciones](alcance-y-limitaciones.md). El [inventario de evidencias](evidencias.md) identifica las capturas finales todavía pendientes.

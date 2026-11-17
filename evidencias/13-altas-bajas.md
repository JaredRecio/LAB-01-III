# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL
_Gestión de seguridad y desempeño de bases de datos_

**Jesús Jared Recio Ozúa 4-3**

## Actividad 13 — Altas y bajas

**El cliente Pedro Ruiz ya no existe en clientes. ¿Dónde queda evidencia de que existió y de sus datos?**
En la tabla `auditoria.cambios_clientes`, específicamente en el campo `valores_despues` (durante su inserción) y `valores_antes` (durante su eliminación).

**¿Por qué ip_cliente está vacía en los eventos 2 y 3?**
Porque dichas operaciones fueron ejecutadas por el superusuario mediante una sesión de consola local orientada a sockets, canal que no utiliza direccionamiento IP de red.

**La política de retención de la Unidad II pedía eliminar datos cuando ya no fueran necesarios. ¿Qué conflicto aparece?**
Se genera una colisión normativa entre el derecho a la supresión de datos personales y la obligación legal de conservar evidencias inalterables de auditoría, dilema que debe resolver el comité de cumplimiento normativo de la organización.
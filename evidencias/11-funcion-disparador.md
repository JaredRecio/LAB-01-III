# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL
_Gestión de seguridad y desempeño de bases de datos_

**Jesús Jared Recio Ozúa 4-3**

## Actividad 11 — Crear la función y el disparador

**¿Por qué se ejecuta REVOKE ALL ON FUNCTION ... FROM PUBLIC si el disparador seguirá funcionando para app_ventas?**
Para aplicar el principio de mínimo privilegio. Por defecto, cualquier función nueva otorga permisos de ejecución al grupo público; restringirlo evita ejecuciones no autorizadas, mientras que el disparador opera de manera interna sin requerir privilegios explícitos del usuario final.

**¿Qué pasaría si la función no fuera SECURITY DEFINER?**
El disparador heredaría las restricciones de permisos del usuario que ejecuta la sentencia DML. Si el rol de aplicación careciera de privilegios sobre el esquema de auditoría, la transacción completa fallaría por denegación de acceso.

**Consulta dba.bitacora. ¿Quedó registrada la creación del esquema, la tabla, la función y el disparador?**
Sí, todas las sentencias DDL quedan consignadas de manera íntegra en la bitácora siempre que el nivel de registro de sentencias estructurales se encuentre activo.
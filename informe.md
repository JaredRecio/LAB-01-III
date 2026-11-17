# LAB-01 — Bitácoras y auditoría del dato en postgre
_Gestión de seguridad y desempeño de bases de datos_

**Jesus Jared Recio Ozua - Grupo 43** 

## INFORME

## 1. Despliegue y situación inicial
El servidor PostgreSQL se desplegó de manera local utilizando la base de datos `comercial`, incorporando los roles `app_ventas` y `soporte_ana`, apoyado por las herramientas psql y pgAdmin. Dado que el recolector de logs (`logging_collector`) ya se encontraba encendido, el motor se encargó de generar los archivos directamente en el directorio `log`. Para facilitar la lectura de estos registros mediante SQL, se implementó la vista `dba.bitacora` apuntando al log actual.

En su estado inicial, la configuración de auditoría era prácticamente nula: `log_connections` y `log_disconnections` estaban apagados, `log_statement` en `none`, y el `log_line_prefix` únicamente marcaba el tiempo (`%t`). Bajo estas condiciones era imposible determinar quién había modificado el RFC de un cliente o conocer su estado previo. La sentencia `UPDATE` lanzada con el usuario `app_ventas` se ejecutó correctamente mostrando `UPDATE 1`, pero no generó ningún rastro en los registros. Las únicas evidencias visibles fueron fallos de autenticación carentes de IP y errores de sintaxis propios. No existía manera de diferenciar las acciones de `app_ventas`, de `soporte_ana` o de cualquier intruso.

## 2. Configuración aplicada
Los ajustes se realizaron mediante comandos `ALTER SYSTEM` y se aplicaron en caliente utilizando `SELECT pg_reload_conf();`, evitando así el reinicio del servicio. Se habilitaron `log_connections` y `log_disconnections` para rastrear los inicios de sesión, los orígenes y la duración de cada conexión. El prefijo de línea (`log_line_prefix`) se actualizó a `'%m [%p] user=%u db=%d app=%a client=%h '`, garantizando que cada registro capturara la estampa de tiempo detallada, el PID, el usuario, la base conectada, la aplicación y la IP de origen. Sin esta modificación, la trazabilidad era inviable.

Respecto al nivel de registro de sentencias (`log_statement`), se configuró primero en `'ddl'` para monitorear alteraciones estructurales y de permisos (como `GRANT`, `REVOKE`, `ALTER`). Posteriormente se elevó a `'mod'` para capturar manipulaciones de datos (`INSERT`, `UPDATE`, `DELETE`). Se descartó la opción `'all'` para evitar la saturación de los archivos de log y la exposición innecesaria de información sensible. La recarga de la configuración fue suficiente para aplicar estos cambios, a diferencia de `logging_collector`, el cual exige reiniciar el servicio completo (paso que se omitió por estar ya encendido).

## 3. Eventos observados
*   **Autenticaciones fallidas:** Se registran con un nivel `FATAL`, indicando el intento de acceso (ej. `user=app_ventas db=comercial client=127.0.0.1`) con credenciales inválidas. Aunque muestra el usuario intentado, no garantiza que provenga de la aplicación real, ya que este campo es inyectado por el cliente. Aparece con `app=[desconocido]` porque el proceso se aborta antes de establecer dicho parámetro.
*   **Conexiones exitosas:** Generan múltiples entradas agrupadas por el mismo PID, abarcando la recepción de la conexión, la autenticación (vía `scram-sha-256`) y la autorización final. Al terminar, se loguea la desconexión junto con el tiempo de sesión, ya mostrando el nombre `app-ventas-web`.
*   **Ajustes de configuración:** Son reportados directamente por el proceso central del servidor bajo el formato `parameter ... changed to ...`, careciendo de un usuario o base de datos asociados.
*   **Cambios estructurales o de privilegios:** Aparecen ligados al superusuario `postgres` (ej. `REVOKE UPDATE ON clientes FROM soporte_ana`). Documentan con precisión la acción, el autor y el origen.
*   **Errores de autorización:** Se observaron cuando `app_ventas` intentó eliminar la tabla de auditoría o modificar el disparador, devolviendo mensajes como `permission denied for schema auditoria`.
*   **Modificaciones de datos:** Con el parámetro en `'mod'`, los cambios arrojan un registro tipo `statement: UPDATE clientes SET ...`, evidenciando usuario, aplicación y cliente.

## 4. Auditoría del dato
Para solventar la incapacidad de la bitácora de retener estados previos, se construyó la tabla `auditoria.cambios_clientes`. Esta estructura almacena el `momento` exacto (con zona horaria), el usuario de conexión, el usuario efectivo, IP, aplicación, tipo de operación, ID del cliente afectado, y los estados de los datos en formato JSONB (`valores_antes` y `valores_despues`). El uso de JSONB permite guardar la fila entera sin depender rígidamente del esquema de la tabla `clientes`, facilitando la reversión de los datos.

La función `registrar_cambio_cliente()` encargada de alimentar esta tabla se definió como `SECURITY DEFINER`. Esto significa que corre con los permisos de su creador, evitando que el usuario `app_ventas` requiera permisos directos de escritura en la tabla de auditoría (y por ende, bloqueando posibles manipulaciones). El campo `usuario_sesion` captura la identidad real, mientras que `usuario_efectivo` refleja el rol con el que se ejecuta el trigger.
Durante la simulación del incidente, el sistema auditó exitosamente que `app_ventas` modificó el RFC del cliente 3 de `GAMA780912XYZ` a `GAMA780912ZZZ`, reteniendo la evidencia necesaria en `valores_antes` para generar la sentencia de restauración.

## 5. Limitaciones
El modelo actual no documenta las operaciones de lectura simple. Cuando el rol `soporte_ana` consultó un RFC, la acción pasó desapercibida, ya que no existen disparadores para sentencias `SELECT` y el nivel `'mod'` las ignora. Implementar esto requeriría elevar el nivel a `'all'` o usar extensiones como `pgaudit`, introduciendo penalizaciones de rendimiento.
Otro factor crítico es la volumetría. Una sentencia `UPDATE` masiva sin filtros se traduce en una única línea de texto en el log del servidor, pero desencadenaría miles o millones de inserciones en la tabla de auditoría (cada una con pesadas copias JSONB de la fila).
Finalmente, la vulnerabilidad del superusuario persiste. Al utilizar el rol `postgres`, fue posible apagar el disparador, alterar el RFC y encenderlo nuevamente sin dejar rastro en la tabla de auditoría. Este hueco de seguridad obliga a externalizar los registros del servidor a una plataforma independiente.

## 6. Riesgos de la bitácora
La principal amenaza radica en la exposición accidental de secretos. Sentencias como `CREATE ROLE ... PASSWORD` quedan escritas en texto plano en los archivos de registro. Para mitigar esto, se empleó el metacomando `\password` y se sanitizó la bitácora exportada reemplazando las claves con `<REDACTED>`. No obstante, el archivo original conserva la vulnerabilidad.
Adicionalmente, debido a que tanto los logs como las tablas de auditoría almacenan información confidencial (como los RFCs), su acceso debe estar estrictamente restringido. Deben clasificarse con la misma sensibilidad que los datos de origen, otorgando permisos de solo lectura (`SELECT`) a un rol exclusivo de auditoría.

## 7. Cronología y conclusión
El análisis cronológico de los eventos del 6 de noviembre de 2026 expone claramente la línea temporal: alteraciones de privilegios por parte de `postgres` (22:03 - 22:04), intentos denegados de eliminación por `soporte_ana` (22:26), la alteración del RFC capturada por el disparador (22:59) y la manipulación silenciosa hecha por el superusuario burlando el trigger.

Bajo la configuración por defecto del laboratorio, rastrear la alteración de un registro crítico era imposible. Con la infraestructura de auditoría implementada, es completamente viable identificar anomalías generadas por cuentas de aplicación (como `app_ventas`). Sin embargo, es vital recordar que la tabla registra usuarios de base de datos, direcciones IP y nombres de software, pero no identidades humanas reales. De todos estos metadatos, el nombre de la aplicación conectada es el eslabón más débil y sencillo de falsificar.
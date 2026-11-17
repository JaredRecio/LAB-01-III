# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL
_Gestión de seguridad y desempeño de bases de datos_

**Jesus Jared Recio Ozua - Grupo 43**

## Preguntas de reflexión

## 1. ¿Por qué la auditoría no puede configurarse después de un incidente para investigarlo?
Debido a que tanto las bitácoras como los disparadores (triggers) tienen un comportamiento estrictamente reactivo hacia el futuro; no tienen la capacidad de registrar eventos de forma retroactiva. En la práctica, cuando se realizó la primera modificación del RFC, el parámetro `log_statement` estaba configurado en `none` y no había ningún disparador activo. En consecuencia, no quedó rastro de la consulta, el usuario que la ejecutó, ni el valor previo del dato. Habilitar la auditoría tras un incidente no recupera esa información perdida, por lo cual debe estar implementada de forma preventiva.

## 2. ¿Por qué conviene que la bitácora la administre el propio servidor y no el mecanismo de despliegue?
Al mantener activo el recolector nativo (`logging_collector`), es el motor de PostgreSQL quien se encarga de definir la ubicación, nombrar los archivos y gestionar la rotación, garantizando un comportamiento estandarizado sin importar el entorno de instalación. Esto permite consultar los registros directamente mediante SQL y gestionar los accesos. Si se delega esta tarea al mecanismo de despliegue (como Docker, systemd o pg_ctl), la retención de los logs queda sujeta a la herramienta externa, existiendo el riesgo de que la evidencia se pierda si, por ejemplo, se elimina un contenedor.

## 3. ¿Por qué el prefijo de línea es tan importante como el nivel de log_statement?
Mientras que el nivel de `log_statement` determina *qué* acciones se van a registrar, el prefijo de línea define si dicha información es útil para rastrear la responsabilidad (*quién* y *desde dónde*). Usando el prefijo por defecto (que solo incluye la hora), un `UPDATE` registrado indicaría la acción y el momento, pero omitiría la identidad del usuario, su dirección de origen o la aplicación utilizada. Al configurar un prefijo detallado (que incluya usuario, base de datos, aplicación, IP del cliente y PID), es posible atribuir cada evento y agrupar todas las consultas pertenecientes a una misma sesión.

## 4. ¿Qué diferencia práctica hay entre registrar la sentencia y registrar el cambio en el dato?
El registro de sentencias a través de la bitácora únicamente captura el texto del `UPDATE` con el nuevo valor insertado, pero no proporciona el valor anterior, la cantidad de filas que resultaron afectadas, ni garantiza si la transacción llegó a confirmarse (commit). Además, un `UPDATE` masivo sin cláusula `WHERE` generaría una sola línea de log. En contraste, registrar el cambio a nivel de dato mediante un disparador permite almacenar la fila exacta antes y después de la modificación por cada registro afectado, incluyendo el usuario y la IP. Esto otorga la seguridad necesaria para revertir cambios, aunque implica un mayor consumo de almacenamiento y procesamiento.

## 5. ¿Qué evidencia ofrece pg_stat_activity que no ofrece la bitácora, y viceversa?
La vista `pg_stat_activity` proporciona una radiografía en tiempo real del servidor: muestra las sesiones activas, su estado actual y el tiempo que llevan ejecutando una consulta (como se observó con la función `pg_sleep(90)`). Sin embargo, carece de historial; al cerrarse una sesión, su registro desaparece instantáneamente. Por otro lado, la bitácora funciona como un archivo histórico que retiene las conexiones, desconexiones, tiempos de sesión, errores y comandos (según el nivel configurado), pero no permite monitorear el estado en vivo de una transacción.

## 6. Si el administrador puede cambiar log_statement a none y desactivar el disparador, ¿quién audita al administrador?
Desde el interior del propio motor de base de datos, nadie. Durante la práctica se demostró esto al desactivar el disparador utilizando el rol `postgres`, modificar el RFC y volver a activarlo; la tabla de auditoría no se enteró y el evento solo quedó plasmado en la bitácora, la cual también está bajo el control del administrador. Para mitigar esto, se requiere implementar controles externos, tales como exportar los logs a un servidor gestionado por un departamento de seguridad distinto, aplicar segregación de funciones, requerir autorizaciones para modificar las reglas de auditoría y auditar constantemente la paridad entre los logs y las tablas de control.
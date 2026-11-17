# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL
_Gestión de seguridad y desempeño de bases de datos_

**Jesús Jared Recio Ozúa 4-3**

## Actividad 2 — Que el servidor administre su propia bitácora

**¿Por qué logging_collector requiere reinicio y log_statement solo recarga?**
El colector de bitácoras opera mediante un proceso daemon secundario que se inicializa al arrancar el motor para capturar los descriptores de `stderr`. Modificar esta arquitectura estructural exige un reinicio completo del servicio. En contraste, `log_statement` es una variable evaluada de forma dinámica por cada sesión activa al procesar sentencias, bastando una señal de recarga asíncrona (`pg_reload_conf()`).

**¿Qué ventaja tiene que la bitácora se lea con SQL y no con una herramienta del sistema operativo o del contenedor? ¿Qué riesgo introduce?**
Permite un análisis centralizado y ágil directamente desde el motor mediante consultas relacionales, sin requerir privilegios de consola o acceso físico al servidor host. No obstante, introduce un riesgo de seguridad considerable, ya que las funciones de lectura de archivos exigen privilegios elevados de superusuario, exponiendo potencialmente información confidencial del sistema operativo si no se restringen adecuadamente.

**¿Quién debería poder consultar dba.bitacora?**
Únicamente cuentas especializadas con funciones de auditoría o administración estricta, limitadas a permisos de lectura (`SELECT`). Quedan totalmente excluidos los roles operativos o aplicaciones cotidianas, garantizando que la evidencia permanezca segregada e incorruptible.
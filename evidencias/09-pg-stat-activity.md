# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL
_Gestión de seguridad y desempeño de bases de datos_

**Jesús Jared Recio Ozúa 4-3**

## Actividad 9 — Sesiones activas con pg_stat_activity

**¿Qué columna permite relacionar una sesión con sus líneas de bitácora?**
El identificador de proceso (`pid`), el cual coincide exactamente con la marca de proceso incorporada en el prefijo de las líneas de log (`%p`).

**Después de que termina el reporte, ¿qué fuente conserva evidencia de que existió?**
Únicamente la bitácora histórica del servidor. `pg_stat_activity` es una vista dinámica y volátil que se actualiza en tiempo real, por lo que deshecha la información de las sesiones una vez concluyen.

**¿Por qué client_addr aparece vacío en la sesión del administrador?**
Debido a que las conexiones administrativas locales suelen establecerse mediante sockets de dominio Unix o bucle local optimizado, omitiendo las interfaces de red IP tradicionales.
# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL
_Gestión de seguridad y desempeño de bases de datos_

**Jesús Jared Recio Ozúa 4-3**

## Actividad 1 — Revisar la configuración de registro por defecto

**Con esta configuración, ¿se registra quién se conecta?**
No. El parámetro `log_connections` se encuentra inactivo (`off`) por defecto, lo que omite por completo el almacenamiento de eventos de inicio o cierre de sesión de los usuarios.

**¿Se registran las sentencias UPDATE?**
Tampoco. Como `log_statement` está configurado en `none`, ninguna instrucción de manipulación de datos o consultas queda almacenada en el registro por el simple hecho de ejecutarse.

**¿La línea de bitácora incluye el usuario o la dirección IP del cliente?**
No. El patrón por defecto en `log_line_prefix` es `%m [%p]`, el cual aporta únicamente la marca de tiempo de alta precisión y el identificador de proceso (PID), careciendo de contexto sobre la procedencia de red o la identidad autenticada.

**¿En qué zona horaria se registran los eventos? ¿Por qué importa al reconstruir una cronología?**
Operan bajo el huso horario configurado en `log_timezone` (típicamente UTC o la hora local del sistema). Su correcta identificación es crucial al cotejar la bitácora con otros orígenes externos (como sistemas operativos o servicios web), evitando saltos temporales erróneos al auditar incidentes.

**Con logging_collector = off, ¿quién decide dónde termina la bitácora: PostgreSQL o el mecanismo con que se desplegó el servidor?**
La gestión recae enteramente en el entorno de despliegue y el sistema operativo. Al no estar activo el colector interno, el motor se limita a volcar la salida estándar de errores (`stderr`), siendo interceptada por demonios del sistema como `systemd` o contenedores, fuera del control directo de PostgreSQL.
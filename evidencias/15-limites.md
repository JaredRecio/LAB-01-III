# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL
_Gestión de seguridad y desempeño de bases de datos_

**Jesús Jared Recio Ozúa 4-3**

## Actividad 15 — Límites: lecturas y volumen

**Si clientes tuviera un millón de registros, ¿qué ocurriría con la auditoría tras un UPDATE sin WHERE?**
Se dispararía la ejecución masiva del disparador por cada fila afectada, generando un consumo extremo de recursos de almacenamiento, degradación severa del rendimiento y posible saturación del espacio en disco.

**Propón quién podría autorizar la depuración de auditoria.cambios_clientes.**
Un comité multidisciplinario conformado por el responsable de seguridad de la información, el oficial de cumplimiento normativo y la dirección legal de la empresa.

**¿Por qué log_statement = 'all' puede convertir la bitácora en un nuevo depósito de datos sensibles?**
Porque al registrar de manera íntegra cada sentencia ejecutada, se capturan parámetros, credenciales y datos personales en formato de texto plano dentro de los archivos de log, propagando información confidencial fuera de los perímetros seguros de la base de datos.
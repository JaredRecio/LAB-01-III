# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL
_Gestión de seguridad y desempeño de bases de datos_

**Jesús Jared Recio Ozúa 4-3**

## Actividad 4 — Configurar la bitácora

**¿Por qué el proceso que registra el cambio es el principal y no tu sesión?**
Porque la instrucción `ALTER SYSTEM` únicamente actualiza de forma persistente el fichero `postgresql.auto.conf`. El encargado de interpretar dicha modificación y aplicar los nuevos valores en tiempo de ejecución es el proceso supervisor principal (PID 1 / postmaster) al recibir la señal de recarga, operando a un nivel sistémico superior al de las conexiones individuales.

**¿Qué pasaría si alguien ejecutara ALTER SYSTEM SET log_statement = 'none'? ¿Quedaría rastro?**
La orden en sí misma quedaría grabada en el log (siempre que el nivel previo de registro lo permitiera), y posteriormente el proceso principal registraría el cambio de parámetro. Sin embargo, se perdería el detalle individual de las operaciones subsiguientes, dificultando la rendición de cuentas sobre quién ordenó desactivar la auditoría.

**¿Por qué no se recomienda editar postgresql.auto.conf a mano?**
Manipular directamente los archivos de configuración omite las validaciones sintácticas y de rango que realiza el motor mediante comandos SQL. Además, la edición manual a nivel de sistema operativo elude el registro de auditoría, impidiendo trazar qué operador modificó los parámetros del servidor.
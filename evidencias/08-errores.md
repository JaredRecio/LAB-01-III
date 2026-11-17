# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL
_Gestión de seguridad y desempeño de bases de datos_

**Jesús Jared Recio Ozúa 4-3**

## Actividad 8 — Errores y operaciones rechazadas

**¿El intento de soporte_ana causó algún daño? ¿Por qué debe auditarse de todos modos?**
No generó alteración en los datos, ya que el motor bloqueó la acción. Sin embargo, su auditoría es indispensable porque revela comportamientos anómalos, intentos de saltarse restricciones de rol o posibles brechas en las credenciales asignadas.

**¿Qué diferencia hay entre un error de autorización (esta actividad) y uno de autenticación (Actividad 5)?**
* Autenticación: Corresponde a la validación de identidad (credenciales incorrectas), abortando la conexión en una etapa previa (`FATAL`).
* Autorización: Ocurre con una sesión ya establecida donde el usuario carece de privilegios suficientes para ejecutar una acción específica sobre un objeto (`ERROR: permission denied`).

**¿Qué indica el error de DROP ROLE sobre el orden correcto para dar de baja a un usuario?**
Demuestra que la eliminación de una identidad requiere una depuración previa: revocar todos sus permisos explícitos y reasignar o eliminar los objetos de su propiedad en el esquema.
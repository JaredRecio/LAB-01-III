# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL
_Gestión de seguridad y desempeño de bases de datos_

**Jesús Jared Recio Ozúa 4-3**

## Actividad 14 — Intentar manipular la auditoría

**¿Qué evidencia permite detectar que hubo un cambio sin auditar?**
Las líneas de la bitácora del servidor que registran la desactivación y reactivación del disparador (`DISABLE/ENABLE TRIGGER`), evidenciando una maniobra administrativa sobre los controles de integridad.

**¿Qué control administrativo (no técnico) reduciría este riesgo?**
La implementación de flujos formales de control de cambios, auditorías cruzadas independientes y políticas estrictas de segregación de funciones operativas.

**Relaciona esta actividad con el principio de separación de funciones.**
Demuestra que un usuario con privilegios totales sobre la base de datos puede eludir los controles locales. Por ello, la custodia de las bitácoras debe recaer en sistemas y equipos de trabajo totalmente ajenos a la administración directa de los datos.
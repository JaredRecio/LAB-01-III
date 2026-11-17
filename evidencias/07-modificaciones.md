# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL
_Gestión de seguridad y desempeño de bases de datos_

**Jesús Jared Recio Ozúa 4-3**

## Actividad 7 — Modificaciones de datos: ddl frente a mod

**¿Qué nivel habría registrado la lectura del RFC? ¿Qué costo tendría en un servidor con miles de consultas por minuto?**
Solo el nivel exhaustivo `log_statement = 'all'` permitiría capturar operaciones de lectura (`SELECT`). Su habilitación en entornos de alta transaccionalidad colapsaría el almacenamiento e impactaría severamente el rendimiento general debido al volumen masivo de texto generado.

**¿Qué le falta a esta bitácora para revertir el cambio con certeza?**
Carece por completo del estado anterior del registro (`OLD`). La bitácora almacena la instrucción ejecutada y su valor resultante, pero no proporciona los datos previos necesarios para restaurar la tupla a su condición original de forma infalible.
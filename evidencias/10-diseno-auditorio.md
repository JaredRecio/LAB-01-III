# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL
_Gestión de seguridad y desempeño de bases de datos_

**Jesús Jared Recio Ozúa 4-3**

## Actividad 10 — Diseñar y crear el registro de auditoría

| Campo propuesto | Tipo | ¿Qué pregunta responde? | ¿Puede ser nulo? ¿Por qué? |
| --- | --- | --- | --- |
| `id_evento` | BIGSERIAL | ¿Cuál es el orden secuencial del suceso? | No. Clave primaria autoincremental única. |
| `momento` | TIMESTAMPTZ | ¿En qué instante exacto ocurrió? | No. Sello temporal obligatorio con zona horaria. |
| `usuario_sesion` | TEXT | ¿Qué identidad autenticó la conexión? | No. Toda sesión válida posee un usuario origen. |
| `usuario_efectivo` | TEXT | ¿Qué privilegios operaron el cambio? | No. Refleja el contexto de privilegios vigentes. |
| `aplicacion` | TEXT | ¿Qué software cliente intervino? | Sí. Depende de la declaración opcional de la app. |
| `ip_cliente` | INET | ¿Desde qué nodo de red se originó? | Sí. Nulo en conexiones puramente locales por socket. |
| `operacion` | TEXT | ¿Qué tipo de sentencia DML se aplicó? | No. Define claramente si fue INSERT, UPDATE o DELETE. |
| `id_cliente` | BIGINT | ¿Qué registro exacto fue impactado? | No. Identifica la tupla afectada en la tabla base. |
| `valores_antes` | JSONB | ¿Cuál era el estado previo de los datos? | Sí. Inexistente en operaciones de alta (INSERT). |
| `valores_despues` | JSONB | ¿Cuál fue el resultado posterior de los datos? | Sí. Inexistente en operaciones de baja (DELETE). |

**¿Por qué momento usa TIMESTAMPTZ y non TIMESTAMP?**
Porque incorpora de forma nativa la compensación de zona horaria, garantizando una correlación cronológica inequívoca entre diferentes servidores y sistemas de bitácora.

**¿Por qué se guarda el registro completo en JSONB y no solo la columna que cambió?**
Permite conservar una instantánea integral del contexto relacional, facilitando la reversión exacta de la tupla y garantizando resiliencia ante futuras modificaciones en la estructura de la tabla principal.

**La tabla de auditoría también contendrá RFC. ¿Qué implica eso para su clasificación y su control de acceso?**
Almacena datos de carácter personal sensible (PII). Por ende, debe heredarse una política estricta de protección, cifrado y control de acceso limitado exclusivamente a perfiles de auditoría.
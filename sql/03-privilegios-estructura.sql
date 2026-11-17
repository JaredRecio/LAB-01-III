-- # LAB-01 – Bitácoras y auditoría del dato en PostgreSQL
-- Gestión de seguridad y desempeño de bases de datos
-- Jesús Jared Recio Ozúa 4-3

-- Filtrar bitácora de accesos
SELECT linea FROM dba.bitacora WHERE linea LIKE '%client=127.0.0.1%' ORDER BY num;

CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    rfc VARCHAR(13)
);

-- Actividad 6 – Cambios de privilegios y de estructura
REVOKE UPDATE ON clientes FROM soporte_ana;
GRANT UPDATE ON clientes TO app_ventas;
ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20);

-- Crear rol temporal y eliminarlo
CREATE ROLE rol_temporal LOGIN PASSWORD '<REDACTED>';
DROP ROLE rol_temporal;

-- Consultar sentencias en la bitácora
SELECT linea FROM dba.bitacora WHERE linea LIKE '%statement:%' ORDER BY num;

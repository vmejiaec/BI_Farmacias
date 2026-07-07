-- 04_postgresql_carga_historial_2_anios.sql
-- Carga adicional para PostgreSQL, esquema gestion.
-- Objetivo: ampliar metas mensuales, clientes corporativos y encuestas desde julio 2024 hasta julio 2026.
-- Incluye julio 2026 como mes en curso para comparar contra julio 2025.
-- Script idempotente: actualiza metas existentes y elimina/recrea solo encuestas marcadas como Histórico BI.

SET search_path TO gestion, public;

-- Clientes corporativos adicionales. Se insertan solo si no existen.
INSERT INTO cliente
    (documento, nombres, ciudad, fecha_nacimiento, sexo, codigo_segmento, fecha_registro, correo, activo)
SELECT
    '17250000' || LPAD(g::text, 2, '0') AS documento,
    CASE MOD(g, 6)
        WHEN 0 THEN 'Roberto Almeida'
        WHEN 1 THEN 'Teresa Salazar'
        WHEN 2 THEN 'Sofía Torres'
        WHEN 3 THEN 'Carlos Benítez'
        WHEN 4 THEN 'Lucía Andrade'
        ELSE 'Mateo Zambrano'
    END AS nombres,
    CASE MOD(g, 4)
        WHEN 0 THEN 'Quito'
        WHEN 1 THEN 'Sangolquí'
        WHEN 2 THEN 'Cumbayá'
        ELSE 'quito '
    END AS ciudad,
    DATE '1975-01-01' + (g * 313) AS fecha_nacimiento,
    CASE MOD(g, 2) WHEN 0 THEN 'M' ELSE 'F' END AS sexo,
    CASE MOD(g, 4)
        WHEN 0 THEN 'NUEVO'
        WHEN 1 THEN 'FREC'
        WHEN 2 THEN 'VIP'
        ELSE 'INACT'
    END AS codigo_segmento,
    DATE '2024-07-01' + (g * 23) AS fecha_registro,
    'cliente_hist_' || g || '@correo.com' AS correo,
    TRUE AS activo
FROM generate_series(1, 20) AS g
WHERE NOT EXISTS (
    SELECT 1
    FROM cliente c
    WHERE c.documento = '17250000' || LPAD(g::text, 2, '0')
);

-- Metas mensuales desde julio 2024 hasta julio 2026.
WITH meses AS (
    SELECT generate_series(DATE '2024-07-01', DATE '2026-07-01', INTERVAL '1 month')::date AS periodo
), sucursales AS (
    SELECT codigo_sucursal
    FROM sucursal
    WHERE codigo_sucursal IN ('NORTE', 'CENTRO', 'SUR', 'VALLE')
), metas AS (
    SELECT
        s.codigo_sucursal,
        m.periodo,
        ROUND((
            CASE s.codigo_sucursal
                WHEN 'NORTE' THEN 2600
                WHEN 'CENTRO' THEN 1800
                WHEN 'SUR' THEN 1500
                WHEN 'VALLE' THEN 2200
            END
            * CASE EXTRACT(MONTH FROM m.periodo)::int
                WHEN 1 THEN 0.92
                WHEN 2 THEN 0.96
                WHEN 3 THEN 1.02
                WHEN 4 THEN 1.00
                WHEN 5 THEN 1.05
                WHEN 6 THEN 1.08
                WHEN 7 THEN 1.12
                WHEN 8 THEN 1.06
                WHEN 9 THEN 1.03
                WHEN 10 THEN 1.10
                WHEN 11 THEN 1.18
                WHEN 12 THEN 1.28
            END
            * CASE EXTRACT(YEAR FROM m.periodo)::int
                WHEN 2024 THEN 0.88
                WHEN 2025 THEN 0.96
                ELSE 1.08
            END
        )::numeric, 2) AS meta_ventas,
        ROUND((
            CASE s.codigo_sucursal
                WHEN 'NORTE' THEN 120
                WHEN 'CENTRO' THEN 90
                WHEN 'SUR' THEN 80
                WHEN 'VALLE' THEN 100
            END
            * CASE EXTRACT(YEAR FROM m.periodo)::int
                WHEN 2024 THEN 0.90
                WHEN 2025 THEN 1.00
                ELSE 1.08
            END
        )::numeric, 0)::integer AS meta_clientes
    FROM meses m
    CROSS JOIN sucursales s
)
INSERT INTO meta_mensual (codigo_sucursal, periodo, meta_ventas, meta_clientes)
SELECT codigo_sucursal, periodo, meta_ventas, meta_clientes
FROM metas
ON CONFLICT (codigo_sucursal, periodo)
DO UPDATE SET
    meta_ventas = EXCLUDED.meta_ventas,
    meta_clientes = EXCLUDED.meta_clientes;

-- Encuestas históricas para análisis de satisfacción y calidad de servicio.
DELETE FROM encuesta_satisfaccion
WHERE comentario LIKE 'Histórico BI%';

INSERT INTO encuesta_satisfaccion
    (fecha, codigo_sucursal, documento_cliente, puntuacion, tiempo_espera_minutos, comentario)
SELECT
    (m.periodo + ((n * 6 + EXTRACT(MONTH FROM m.periodo)::int) % 27) * INTERVAL '1 day')::date AS fecha,
    s.codigo_sucursal,
    CASE MOD(n + EXTRACT(MONTH FROM m.periodo)::int, 12)
        WHEN 0 THEN '1712345601'
        WHEN 1 THEN '1712345602'
        WHEN 2 THEN '1712345603'
        WHEN 3 THEN '1712345610 '
        WHEN 4 THEN '171-234-5615'
        WHEN 5 THEN '9999999999'
        ELSE '17123456' || LPAD((1 + MOD(n + EXTRACT(MONTH FROM m.periodo)::int + EXTRACT(YEAR FROM m.periodo)::int, 30))::text, 2, '0')
    END AS documento_cliente,
    CASE
        WHEN s.codigo_sucursal = 'SUR' AND MOD(n + EXTRACT(MONTH FROM m.periodo)::int, 5) = 0 THEN 2
        WHEN s.codigo_sucursal = 'CENTRO' THEN 5
        WHEN MOD(n + EXTRACT(YEAR FROM m.periodo)::int, 7) = 0 THEN 3
        ELSE 4
    END AS puntuacion,
    CASE s.codigo_sucursal
        WHEN 'CENTRO' THEN 3 + MOD(n * 2 + EXTRACT(MONTH FROM m.periodo)::int, 9)
        WHEN 'NORTE' THEN 7 + MOD(n * 3 + EXTRACT(MONTH FROM m.periodo)::int, 15)
        WHEN 'VALLE' THEN 8 + MOD(n * 4 + EXTRACT(MONTH FROM m.periodo)::int, 18)
        ELSE 16 + MOD(n * 5 + EXTRACT(MONTH FROM m.periodo)::int, 30)
    END AS tiempo_espera_minutos,
    CASE
        WHEN s.codigo_sucursal = 'SUR' THEN 'Histórico BI - oportunidad de mejora en atención y stock'
        WHEN s.codigo_sucursal = 'CENTRO' THEN 'Histórico BI - atención rápida'
        WHEN s.codigo_sucursal = 'NORTE' THEN 'Histórico BI - buena atención'
        ELSE 'Histórico BI - local cómodo'
    END AS comentario
FROM generate_series(DATE '2024-07-01', DATE '2026-07-01', INTERVAL '1 month') AS m(periodo)
CROSS JOIN (VALUES ('NORTE'), ('CENTRO'), ('SUR'), ('VALLE')) AS s(codigo_sucursal)
CROSS JOIN generate_series(1, 3) AS n;

-- Un registro problemático adicional para mantener el caso de calidad de datos.
INSERT INTO encuesta_satisfaccion
    (fecha, codigo_sucursal, documento_cliente, puntuacion, tiempo_espera_minutos, comentario)
VALUES
    (DATE '2025-07-15', 'SUR', '1712345608', 7, 115, 'Histórico BI - registro importado con valores inválidos');

-- Comprobaciones sugeridas
SELECT
    TO_CHAR(periodo, 'YYYY-MM') AS periodo,
    COUNT(*) AS metas_cargadas,
    SUM(meta_ventas) AS meta_total
FROM meta_mensual
GROUP BY TO_CHAR(periodo, 'YYYY-MM')
ORDER BY periodo;

SELECT
    TO_CHAR(fecha, 'YYYY-MM') AS periodo,
    codigo_sucursal,
    COUNT(*) AS encuestas,
    ROUND(AVG(puntuacion)::numeric, 2) AS satisfaccion_promedio,
    ROUND(AVG(tiempo_espera_minutos)::numeric, 2) AS espera_promedio
FROM encuesta_satisfaccion
WHERE comentario LIKE 'Histórico BI%'
GROUP BY TO_CHAR(fecha, 'YYYY-MM'), codigo_sucursal
ORDER BY periodo, codigo_sucursal;

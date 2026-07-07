-- 04_mysql_carga_historial_2_anios.sql
-- Carga adicional para la base MySQL farmacia_db.
-- Objetivo: ampliar ventas y detalle de ventas desde julio 2024 hasta julio 2026.
-- Incluye julio 2026 como mes en curso para comparar contra julio 2025.
-- Script idempotente: elimina y vuelve a crear solo las ventas históricas con prefijo VH.

USE farmacia_db;

SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM detalle_venta WHERE numero_venta LIKE 'VH%';
DELETE FROM venta WHERE numero_venta LIKE 'VH%';
SET FOREIGN_KEY_CHECKS = 1;

DROP PROCEDURE IF EXISTS sp_cargar_historial_bi_mysql;

DELIMITER $$

CREATE PROCEDURE sp_cargar_historial_bi_mysql()
BEGIN
    DECLARE v_mes DATE DEFAULT '2024-07-01';
    DECLARE v_fin DATE DEFAULT '2026-07-01';
    DECLARE i INT DEFAULT 1;
    DECLARE linea SMALLINT DEFAULT 1;
    DECLARE ventas_mes INT DEFAULT 0;
    DECLARE dias_mes INT DEFAULT 0;
    DECLARE v_numero VARCHAR(15);
    DECLARE v_fecha DATE;
    DECLARE v_fecha_hora DATETIME;
    DECLARE v_sucursal VARCHAR(60);
    DECLARE v_documento VARCHAR(25);
    DECLARE v_forma_pago VARCHAR(30);
    DECLARE v_descuento DECIMAL(10,2);
    DECLARE v_estado VARCHAR(20);
    DECLARE v_observacion VARCHAR(200);
    DECLARE v_codigo_med VARCHAR(15);
    DECLARE v_cantidad INT;

    WHILE v_mes <= v_fin DO
        SET ventas_mes = CASE WHEN v_mes = '2026-07-01' THEN 18 ELSE 32 END;
        SET dias_mes = DAY(LAST_DAY(v_mes));
        SET i = 1;

        WHILE i <= ventas_mes DO
            SET v_numero = CONCAT('VH', DATE_FORMAT(v_mes, '%Y%m'), LPAD(i, 3, '0'));
            SET v_fecha = DATE_ADD(v_mes, INTERVAL MOD(i * 7 + MONTH(v_mes), dias_mes) DAY);
            SET v_fecha_hora = TIMESTAMP(v_fecha, MAKETIME(8 + MOD(i * 3, 12), MOD(i * 11, 60), 0));

            SET v_sucursal = CASE MOD(i + MONTH(v_mes), 12)
                WHEN 0 THEN 'FARMACIA NORTE'
                WHEN 1 THEN 'Sucursal Norte'
                WHEN 2 THEN 'NORTE '
                WHEN 3 THEN 'FARMACIA CENTRO'
                WHEN 4 THEN 'CENTRO'
                WHEN 5 THEN 'Farmacia Sur'
                WHEN 6 THEN 'SUR'
                WHEN 7 THEN 'Sucursal Valle'
                WHEN 8 THEN 'VALLE'
                WHEN 9 THEN 'FARMACIA NORTE'
                WHEN 10 THEN 'FARMACIA CENTRO'
                ELSE 'Farmacia Sur'
            END;

            SET v_documento = CASE MOD(i * 5 + MONTH(v_mes), 38)
                WHEN 0 THEN NULL
                WHEN 1 THEN ''
                WHEN 2 THEN ' 1712345603'
                WHEN 3 THEN '1712345601 '
                WHEN 4 THEN '171-234-5602'
                WHEN 5 THEN '9999999999'
                WHEN 6 THEN '1720000001'
                WHEN 7 THEN '1720000002'
                ELSE CONCAT('17123456', LPAD(1 + MOD(i + MONTH(v_mes) + YEAR(v_mes), 30), 2, '0'))
            END;

            SET v_forma_pago = CASE MOD(i + MONTH(v_mes), 4)
                WHEN 0 THEN 'EFECTIVO'
                WHEN 1 THEN 'tarjeta'
                WHEN 2 THEN 'TRANSFERENCIA'
                ELSE 'TARJETA'
            END;

            SET v_descuento = CASE MOD(i, 8)
                WHEN 0 THEN 2.00
                WHEN 1 THEN 0.50
                WHEN 2 THEN 1.00
                ELSE 0.00
            END;

            SET v_estado = CASE WHEN MOD(i * MONTH(v_mes), 19) = 0 THEN 'ANULADA' ELSE 'COMPLETADA' END;
            SET v_observacion = CASE
                WHEN v_mes = '2026-07-01' THEN 'Carga histórica BI - mes en curso'
                WHEN v_estado = 'ANULADA' THEN 'Carga histórica BI - venta anulada'
                ELSE 'Carga histórica BI'
            END;

            INSERT INTO venta
                (numero_venta, fecha_hora, sucursal_origen, documento_cliente, forma_pago, descuento, estado, observacion)
            VALUES
                (v_numero, v_fecha_hora, v_sucursal, v_documento, v_forma_pago, v_descuento, v_estado, v_observacion);

            SET linea = 1;
            WHILE linea <= 1 + MOD(i, 3) DO
                SET v_codigo_med = CONCAT('MED', LPAD(1 + MOD(i + linea + MONTH(v_mes) + YEAR(v_mes), 14), 3, '0'));
                SET v_cantidad = CASE
                    WHEN MOD(i + linea + MONTH(v_mes), 97) = 0 THEN 12
                    ELSE 1 + MOD(i + linea, 3)
                END;

                INSERT INTO detalle_venta
                    (numero_venta, linea, codigo_medicamento, cantidad, precio_unitario)
                SELECT
                    v_numero,
                    linea,
                    v_codigo_med,
                    v_cantidad,
                    precio_venta
                FROM medicamento
                WHERE codigo_medicamento = v_codigo_med;

                SET linea = linea + 1;
            END WHILE;

            SET i = i + 1;
        END WHILE;

        SET v_mes = DATE_ADD(v_mes, INTERVAL 1 MONTH);
    END WHILE;
END$$

DELIMITER ;

CALL sp_cargar_historial_bi_mysql();
DROP PROCEDURE IF EXISTS sp_cargar_historial_bi_mysql;

-- Comprobaciones sugeridas
SELECT
    DATE_FORMAT(fecha_hora, '%Y-%m') AS periodo,
    COUNT(*) AS ventas,
    SUM(CASE WHEN estado = 'COMPLETADA' THEN 1 ELSE 0 END) AS ventas_completadas,
    SUM(CASE WHEN estado = 'ANULADA' THEN 1 ELSE 0 END) AS ventas_anuladas
FROM venta
WHERE numero_venta LIKE 'VH%'
GROUP BY DATE_FORMAT(fecha_hora, '%Y-%m')
ORDER BY periodo;

SELECT
    DATE_FORMAT(v.fecha_hora, '%Y-%m') AS periodo,
    SUM(CASE WHEN v.estado = 'COMPLETADA' THEN d.cantidad * d.precio_unitario ELSE 0 END) AS total_ventas
FROM venta v
JOIN detalle_venta d ON d.numero_venta = v.numero_venta
WHERE v.numero_venta LIKE 'VH%'
GROUP BY DATE_FORMAT(v.fecha_hora, '%Y-%m')
ORDER BY periodo;

-- 05_mysql_agregar_clientes_v2.sql
-- Maestro local de clientes del sistema operacional MySQL.
-- Se diseñó deliberadamente con una estructura distinta de gestion.cliente
-- en PostgreSQL para representar un sistema heredado desarrollado en otra época.
--
-- Diferencias principales frente a PostgreSQL:
--   * clave primaria numérica asignada por el sistema, no IDENTITY;
--   * nombres y apellidos separados;
--   * documento llamado cedula_ruc;
--   * ubicación almacenada como dirección libre, sin ciudad normalizada;
--   * dos teléfonos en columnas diferentes;
--   * estado almacenado como CHAR(1), no BOOLEAN;
--   * categoría comercial local, sin FK hacia segmentos corporativos;
--   * fecha de alta con hora;
--   * campos propios del sistema de caja, como crédito y observaciones.

USE farmacia_db;

DROP TABLE IF EXISTS cliente;

CREATE TABLE cliente (
    codigo_cliente INT NOT NULL,
    cedula_ruc VARCHAR(20),
    apellido1 VARCHAR(40),
    apellido2 VARCHAR(40),
    nombres VARCHAR(70) NOT NULL,
    direccion VARCHAR(180),
    telefono_principal VARCHAR(20),
    telefono_alterno VARCHAR(20),
    email_contacto VARCHAR(120),
    fecha_alta DATETIME,
    tipo_cliente CHAR(1) NOT NULL DEFAULT 'N',
    permite_credito CHAR(1) NOT NULL DEFAULT 'N',
    estado_registro CHAR(1) NOT NULL DEFAULT 'A',
    observaciones VARCHAR(250),
    PRIMARY KEY (codigo_cliente)
);

CREATE INDEX idx_cliente_cedula_ruc ON cliente(cedula_ruc);
CREATE INDEX idx_cliente_apellidos ON cliente(apellido1, apellido2);

INSERT INTO cliente
(codigo_cliente, cedula_ruc, apellido1, apellido2, nombres, direccion,
 telefono_principal, telefono_alterno, email_contacto, fecha_alta,
 tipo_cliente, permite_credito, estado_registro, observaciones)
VALUES
(1001, '1712345601', 'Rodriguez', NULL, 'Paola', 'Quito - La Magdalena', '0991000001', NULL, 'paola.rodriguez@gmail.com', '2024-04-25 09:10:00', 'F', 'N', 'A', NULL),
(1002, '1712345602', 'Mena', NULL, 'Elena', 'Quito, sector Centro', '0991000002', NULL, 'elena.mena@gmail.com', '2025-06-15 15:22:00', 'N', 'N', 'A', NULL),
(1003, '1712345603', 'Gomez', NULL, 'Camila', 'Sangolqui / San Rafael', '0991000003', NULL, 'camila.gomez@gmail.com', '2025-04-04 11:08:00', 'F', 'N', 'A', NULL),
(1004, '1712345604', 'Rodriguez', NULL, 'Andrea', 'Quito', '0991000004', NULL, 'andrea.rodriguez@gmail.com', '2025-12-15 13:42:00', 'N', 'N', 'A', NULL),
(1005, '1712345605', 'Ortiz', NULL, 'Jose', 'Quito Norte', '0991000005', NULL, 'jose.ortiz@gmail.com', '2025-03-23 10:15:00', 'F', 'S', 'A', 'Cliente frecuente de la sucursal Norte'),
(1006, '1712345606', 'Gomez', NULL, 'Jorge', 'Quito - Cotocollao', NULL, NULL, 'jorge.gomez@gmail.com', '2025-05-28 17:31:00', 'N', 'N', 'A', 'No registra teléfono'),
(1007, '1712345607', 'Rodriguez', NULL, 'Daniela', 'Quito', '0991000007', NULL, NULL, '2024-04-26 08:55:00', 'N', 'N', 'I', 'Registro inactivo en caja'),
(1008, '1712345608', 'Perez', NULL, 'Jorge', 'Quito Centro', '0991000008', NULL, 'jperez@farmacia.local', '2026-03-20 12:18:00', 'E', 'S', 'A', 'Cuenta empresarial creada manualmente'),
(1009, '1712345609', 'Gomez', NULL, 'Valeria', 'Quito', '0991000009', NULL, 'valeria.gomez@gmail.com', '2025-10-03 14:29:00', 'N', 'N', 'A', NULL),
(1010, '1712345610', 'Mena', NULL, 'Daniela', 'Cumbaya, cerca del parque', '0991000010', NULL, 'daniela.mena@gmail.com', '2026-01-19 09:45:00', 'N', 'N', 'A', NULL),
(1011, '1712345611', 'Rodriguez', NULL, 'Daniela', 'Quito', '0991000011', NULL, 'daniela.r@gmail.com', '2025-03-06 16:02:00', 'F', 'N', 'A', NULL),
(1012, '1712345612', 'Torres', NULL, 'Luis', 'Quito Sur', '0991000012', NULL, 'luis.torres@gmail.com', '2026-01-09 10:27:00', 'N', 'N', 'A', NULL),
(1013, '1712345613', 'Vega', NULL, 'Daniela', 'Sangolqui', '0991000013', NULL, 'daniela.vega@gmail.com', '2026-03-06 11:11:00', 'N', 'N', 'A', NULL),
(1014, '1712345614', 'Ortiz', NULL, 'Elena', 'Cumbaya', '0991000014', NULL, 'elena.ortiz@gmail.com', '2024-02-02 08:35:00', 'F', 'N', 'A', NULL),
(1015, '1712345615', 'Ortiz', NULL, 'Elena', 'Quito', '0991000015', NULL, 'elena.ortiz2@gmail.com', '2026-01-10 18:06:00', 'N', 'N', 'A', 'No confundir con cliente 1014'),
(1016, '1712345616', 'Vega', NULL, 'Elena', 'Quito', '0991000016', NULL, 'elena.vega@gmail.com', '2026-01-06 09:38:00', 'N', 'N', 'A', NULL),
(1017, '1712345617', 'Cevallos', NULL, 'Jorge', 'Quito', '0991000017', NULL, 'jorge.cevallos@gmail.com', '2026-06-24 15:54:00', 'N', 'N', 'A', NULL),
(1018, '1712345618', 'Mena', NULL, 'Fernando', 'Quito', '0991000018', NULL, 'fernando.mena@gmail.com', '2025-02-09 13:21:00', 'F', 'S', 'A', NULL),
(1019, '1712345619', 'Torres', NULL, 'Jorge', 'Quito', '0991000019', NULL, 'jorge.torres@gmail.com', '2025-04-28 10:05:00', 'N', 'N', 'A', NULL),
(1020, '1712345620', 'Rodriguez', NULL, 'Valeria', 'Quito', '0991000020', NULL, 'valeria.rodriguez@gmail.com', '2024-08-17 14:17:00', 'F', 'N', 'A', NULL),
(1021, '1712345621', 'Ruiz', NULL, 'Jorge', 'Quito', '0991000021', NULL, 'jorge.ruiz@gmail.com', '2024-04-19 11:48:00', 'N', 'N', 'A', NULL),
(1022, '1712345622', 'Perez', NULL, 'Luis', 'Quito', '0991000022', NULL, 'luis.perez@gmail.com', '2024-02-14 09:03:00', 'F', 'N', 'A', NULL),
(1023, '1712345623', 'Vega', NULL, 'Daniela', 'Cumbaya', '0991000023', NULL, 'daniela.vega2@gmail.com', '2026-01-07 12:33:00', 'N', 'N', 'A', NULL),
(1024, '1712345624', 'Castro', NULL, 'Luis', 'Quito', '0991000024', NULL, 'luis.castro@gmail.com', '2025-10-22 17:19:00', 'N', 'N', 'A', NULL),
(1025, '1712345625', 'Gomez', NULL, 'Miguel', 'Quito', '0991000025', NULL, 'miguel.gomez@gmail.com', '2025-03-07 10:52:00', 'F', 'N', 'A', NULL),
(1026, '1712345626', 'Castro', NULL, 'Miguel', 'Quito', '0991000026', NULL, 'miguel.castro@gmail.com', '2025-08-17 15:09:00', 'N', 'N', 'A', NULL),
(1027, '1712345627', 'Rodriguez', NULL, 'Jorge', 'Sangolqui', '0991000027', NULL, 'jorge.rodriguez@gmail.com', '2026-01-27 13:14:00', 'N', 'N', 'A', NULL),
(1028, '1712345628', 'Ortiz', NULL, 'Maria', 'Quito', '0991000028', NULL, 'maria.ortiz@gmail.com', '2025-08-27 09:49:00', 'F', 'N', 'A', NULL),
(1029, '1712345629', 'Mena', NULL, 'Andrea', 'Quito', '0991000029', NULL, 'andrea.mena@gmail.com', '2026-01-21 16:44:00', 'N', 'N', 'A', NULL),
(1030, '1712345630', 'Ortiz', NULL, 'Andrea', 'Quito', '0991000030', NULL, 'andrea.ortiz@gmail.com', '2026-01-06 08:26:00', 'N', 'N', 'A', NULL),

-- Clientes existentes solo en el sistema de caja MySQL.
(1031, '1720000001', 'Almeida', NULL, 'Roberto', 'Machachi', '0992000001', NULL, 'roberto.almeida@gmail.com', '2025-05-10 10:00:00', 'N', 'N', 'A', 'No migrado al sistema corporativo'),
(1032, '1720000002', 'Salazar', NULL, 'Teresa', 'Quito', '0992000002', NULL, 'teresa.salazar@gmail.com', '2025-11-03 15:30:00', 'N', 'N', 'A', 'No migrada al sistema corporativo'),

-- Registros problemáticos deliberados: posibles duplicados o formatos incompatibles.
(1033, '171-234-5602', 'Mena', NULL, 'Elena', 'Quito Centro', '0991000002', NULL, 'elena.mena@gmail.com', '2025-06-16 09:14:00', 'N', 'N', 'A', 'Documento registrado con guiones'),
(1034, ' 1712345603', 'GOMEZ', NULL, 'CAMILA', 'SANGOLQUI', NULL, NULL, 'camila.gomez@gmail.com', '2025-04-05 12:41:00', 'N', 'N', 'A', 'Documento con espacio inicial'),
(1035, '1712345601 ', 'Rodriguez', NULL, 'Paola R.', 'Quito ', '0991000001', NULL, 'paola.rodriguez@correo.com', '2024-04-26 10:20:00', 'F', 'N', 'A', 'Documento con espacio final y correo diferente'),
(1036, '9999999999', 'NO IDENTIFICADO', NULL, 'CLIENTE', 'Quito', NULL, NULL, NULL, '2026-01-01 00:00:00', 'N', 'N', 'A', 'Registro genérico creado por un operador'),
(1037, NULL, 'FINAL', NULL, 'CONSUMIDOR', NULL, NULL, NULL, NULL, '2026-01-01 00:00:00', 'N', 'N', 'A', 'Cliente genérico para ventas sin identificación');

-- No se crea una foreign key desde venta.documento_cliente hacia cliente.cedula_ruc.
-- La omisión es deliberada: las ventas incluyen documentos con espacios, guiones,
-- valores vacíos, NULL y documentos no presentes en este maestro local.

-- Consultas de comprobación:
-- SELECT COUNT(*) AS clientes_mysql FROM cliente;
-- SELECT cedula_ruc, COUNT(*) FROM cliente GROUP BY cedula_ruc HAVING COUNT(*) > 1;
-- SELECT codigo_cliente, CONCAT_WS(' ', nombres, apellido1, apellido2) AS nombre_completo
-- FROM cliente ORDER BY codigo_cliente;
-- SELECT v.numero_venta, v.documento_cliente, c.codigo_cliente,
--        CONCAT_WS(' ', c.nombres, c.apellido1, c.apellido2) AS cliente_mysql
-- FROM venta v
-- LEFT JOIN cliente c ON v.documento_cliente = c.cedula_ruc
-- WHERE c.codigo_cliente IS NULL;

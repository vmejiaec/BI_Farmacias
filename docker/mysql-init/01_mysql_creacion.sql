-- 01_mysql_creacion.sql
-- Base operacional de ventas e inventario para la demostración de BI
-- Docker Compose ya crea la base farmacia_db.

CREATE DATABASE IF NOT EXISTS farmacia_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE farmacia_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS venta;
DROP TABLE IF EXISTS inventario;
DROP TABLE IF EXISTS medicamento;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS laboratorio;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE laboratorio (
    codigo_laboratorio VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    pais VARCHAR(60),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE categoria (
    codigo_categoria VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    descripcion VARCHAR(200)
);

CREATE TABLE medicamento (
    codigo_medicamento VARCHAR(15) PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    codigo_categoria VARCHAR(10),
    codigo_laboratorio VARCHAR(10),
    presentacion VARCHAR(80),
    costo DECIMAL(10,2),
    precio_venta DECIMAL(10,2),
    requiere_receta BOOLEAN,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_med_categoria FOREIGN KEY (codigo_categoria)
        REFERENCES categoria(codigo_categoria),
    CONSTRAINT fk_med_laboratorio FOREIGN KEY (codigo_laboratorio)
        REFERENCES laboratorio(codigo_laboratorio)
);

CREATE TABLE venta (
    numero_venta VARCHAR(15) PRIMARY KEY,
    fecha_hora DATETIME NOT NULL,
    sucursal_origen VARCHAR(60) NOT NULL,
    documento_cliente VARCHAR(25),
    forma_pago VARCHAR(30),
    descuento DECIMAL(10,2) DEFAULT 0,
    estado VARCHAR(20) NOT NULL DEFAULT 'COMPLETADA',
    observacion VARCHAR(200)
    -- No hay FK de cliente ni sucursal porque esos maestros están en PostgreSQL.
);

CREATE TABLE detalle_venta (
    numero_venta VARCHAR(15) NOT NULL,
    linea SMALLINT NOT NULL,
    codigo_medicamento VARCHAR(15),
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2),
    PRIMARY KEY (numero_venta, linea),
    CONSTRAINT fk_det_venta FOREIGN KEY (numero_venta)
        REFERENCES venta(numero_venta),
    CONSTRAINT fk_det_medicamento FOREIGN KEY (codigo_medicamento)
        REFERENCES medicamento(codigo_medicamento)
);

CREATE TABLE inventario (
    sucursal_origen VARCHAR(60) NOT NULL,
    codigo_medicamento VARCHAR(15) NOT NULL,
    stock_actual INT,
    stock_minimo INT,
    fecha_ultima_entrada DATE,
    fecha_ultimo_movimiento DATE,
    PRIMARY KEY (sucursal_origen, codigo_medicamento),
    CONSTRAINT fk_inv_medicamento FOREIGN KEY (codigo_medicamento)
        REFERENCES medicamento(codigo_medicamento)
);

CREATE INDEX idx_venta_fecha ON venta(fecha_hora);
CREATE INDEX idx_venta_sucursal ON venta(sucursal_origen);
CREATE INDEX idx_venta_cliente ON venta(documento_cliente);
CREATE INDEX idx_det_medicamento ON detalle_venta(codigo_medicamento);

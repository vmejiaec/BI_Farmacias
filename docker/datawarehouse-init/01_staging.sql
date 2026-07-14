-- Preparar staging 
SET client_encoding = 'UTF8';

DROP SCHEMA IF EXISTS stg CASCADE;
CREATE SCHEMA stg;
-- Staging Ventas
CREATE TABLE IF NOT EXISTS stg.mysql_laboratorio (
    codigo_laboratorio VARCHAR(20),
    nombre_laboratorio VARCHAR(150),
    pais VARCHAR(100),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.mysql_categoria (
    codigo_categoria VARCHAR(20),
    nombre_categoria VARCHAR(150),
    descripcion TEXT,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.mysql_medicamento (
    codigo_medicamento VARCHAR(30),
    nombre_medicamento VARCHAR(200),
    presentacion VARCHAR(150),
    codigo_categoria VARCHAR(20),
    codigo_laboratorio VARCHAR(20),
    requiere_receta BOOLEAN,
    activo BOOLEAN,
    costo_referencia NUMERIC(14,2),
    precio_venta_referencia NUMERIC(14,2),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.mysql_cliente (
    codigo_cliente VARCHAR(30),
    documento VARCHAR(30),
    nombres VARCHAR(150),
    apellido1 VARCHAR(100),
    apellido2 VARCHAR(100),
    sexo VARCHAR(20),
    fecha_nacimiento DATE,
    ciudad VARCHAR(100),
    correo VARCHAR(200),
    fecha_alta DATE,
    activo BOOLEAN,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.mysql_venta (
    numero_venta VARCHAR(30),
    fecha_hora TIMESTAMP,
    sucursal_origen VARCHAR(150),
    documento_cliente VARCHAR(30),
    forma_pago VARCHAR(50),
    descuento NUMERIC(14,2),
    estado VARCHAR(30),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.mysql_detalle_venta (
    numero_venta VARCHAR(30),
    linea INTEGER,
    codigo_medicamento VARCHAR(30),
    cantidad INTEGER,
    precio_unitario NUMERIC(14,2),
    subtotal NUMERIC(14,2),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.mysql_inventario (
    sucursal_origen VARCHAR(150),
    codigo_medicamento VARCHAR(30),
    stock_actual INTEGER,
    stock_minimo INTEGER,
    fecha_ultima_entrada DATE,
    fecha_ultimo_movimiento DATE,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Staging Gestión
CREATE TABLE IF NOT EXISTS stg.pg_zona (
    codigo_zona VARCHAR(20),
    nombre_zona VARCHAR(100),
    responsable VARCHAR(150),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.pg_sucursal (
    codigo_sucursal VARCHAR(20),
    nombre_sucursal VARCHAR(150),
    codigo_zona VARCHAR(20),
    ciudad VARCHAR(100),
    direccion VARCHAR(250),
    latitud NUMERIC(12,8),
    longitud NUMERIC(12,8),
    fecha_apertura DATE,
    activa BOOLEAN,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.pg_segmento_cliente (
    codigo_segmento VARCHAR(20),
    nombre_segmento VARCHAR(100),
    descripcion TEXT,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.pg_cliente (
    documento VARCHAR(30),
    nombres VARCHAR(150),
    ciudad VARCHAR(100),
    sexo VARCHAR(20),
    fecha_nacimiento DATE,
    codigo_segmento VARCHAR(20),
    fecha_registro DATE,
    correo VARCHAR(200),
    activo BOOLEAN,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.pg_meta_mensual (
    codigo_sucursal VARCHAR(20),
    periodo DATE,
    meta_ventas NUMERIC(14,2),
    meta_clientes INTEGER,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.pg_encuesta_satisfaccion (
    id_encuesta_origen BIGINT,
    fecha DATE,
    codigo_sucursal VARCHAR(20),
    documento_cliente VARCHAR(30),
    puntuacion INTEGER,
    tiempo_espera_minutos INTEGER,
    comentario TEXT,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--Staging Compras

CREATE TABLE IF NOT EXISTS stg.excel_compras (
    id_compra VARCHAR(30),
    numero_orden VARCHAR(50),
    factura_distribuidor VARCHAR(50),
    fecha_compra DATE,
    fecha_estimada_entrega DATE,
    fecha_vencimiento DATE,
    codigo_sucursal VARCHAR(20),
    codigo_medicamento VARCHAR(30),
    codigo_distribuidor VARCHAR(30),
    numero_lote VARCHAR(50),
    cantidad_comprada INTEGER,
    costo_unitario NUMERIC(14,4),
    subtotal_bruto NUMERIC(14,2),
    porcentaje_descuento NUMERIC(8,4),
    valor_descuento NUMERIC(14,2),
    valor_neto NUMERIC(14,2),
    estado_recepcion VARCHAR(30),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.excel_distribuidores (
    codigo_distribuidor VARCHAR(30),
    nombre_distribuidor VARCHAR(200),
    contacto_ventas VARCHAR(150),
    telefono_contacto VARCHAR(50),
    correo_contacto VARCHAR(200),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.excel_medicamentos (
    codigo_medicamento VARCHAR(30),
    nombre_medicamento VARCHAR(200),
    codigo_categoria VARCHAR(150),
    codigo_laboratorio VARCHAR(150),
    presentacion VARCHAR(150),
    costo_base NUMERIC(14,4),
    precio_venta NUMERIC(14,4),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.excel_puntos_entrega (
    codigo_sucursal VARCHAR(20),
    nombre_sucursal VARCHAR(150),
    zona VARCHAR(100),
    ciudad VARCHAR(100),
    direccion VARCHAR(250),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE dw.dim_fecha (
    fecha_key          INTEGER PRIMARY KEY,
    fecha              DATE NOT NULL UNIQUE,
    anio               INTEGER NOT NULL,
    semestre           INTEGER NOT NULL,
    trimestre          INTEGER NOT NULL,
    numero_mes         INTEGER NOT NULL,
    nombre_mes         VARCHAR(15) NOT NULL,
    anio_mes           VARCHAR(7) NOT NULL,
    numero_semana      INTEGER NOT NULL,
    dia_mes            INTEGER NOT NULL,
    numero_dia_semana  INTEGER NOT NULL,
    nombre_dia         VARCHAR(15) NOT NULL,
    es_fin_semana      BOOLEAN NOT NULL
);

create view dw.dim_tiempo as 
SELECT
    TO_CHAR(fecha, 'YYYYMMDD')::INTEGER AS fecha_key,
    fecha::DATE AS fecha,
    EXTRACT(YEAR FROM fecha)::INTEGER AS anio,
    CASE
        WHEN EXTRACT(MONTH FROM fecha) <= 6 THEN 1
        ELSE 2
    END AS semestre,
    EXTRACT(QUARTER FROM fecha)::INTEGER AS trimestre,
    EXTRACT(MONTH FROM fecha)::INTEGER AS numero_mes,
    CASE EXTRACT(MONTH FROM fecha)::INTEGER
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END AS nombre_mes,
    TO_CHAR(fecha, 'YYYY-MM') AS anio_mes,
    EXTRACT(WEEK FROM fecha)::INTEGER AS numero_semana,
    EXTRACT(DAY FROM fecha)::INTEGER AS dia_mes,
    EXTRACT(ISODOW FROM fecha)::INTEGER AS numero_dia_semana,
    CASE EXTRACT(ISODOW FROM fecha)::INTEGER
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo'
    END AS nombre_dia,
    CASE
        WHEN EXTRACT(ISODOW FROM fecha)::INTEGER IN (6, 7)
        THEN TRUE
        ELSE FALSE
    END AS es_fin_semana
FROM generate_series(
    DATE '2025-01-01',
    DATE '2027-12-31',
    INTERVAL '1 day'
) AS calendario(fecha)
ORDER BY fecha;

CREATE TABLE dw.dim_medicamento (
    medicamento_key          BIGSERIAL PRIMARY KEY,
    codigo_medicamento       VARCHAR(20) NOT NULL UNIQUE,
    medicamento              VARCHAR(150) NOT NULL,
    codigo_categoria         VARCHAR(20),
    categoria                VARCHAR(100),
    codigo_laboratorio       VARCHAR(20),
    laboratorio              VARCHAR(120),
    presentacion             VARCHAR(120),
    costo_base_referencia    NUMERIC(12,2),
    precio_venta_referencia  NUMERIC(12,2),
    requiere_receta          BOOLEAN,
    activo                   BOOLEAN
);

CREATE TABLE dw.dim_distribuidor (
    distribuidor_key       BIGSERIAL PRIMARY KEY,
    codigo_distribuidor    VARCHAR(20) NOT NULL UNIQUE,
    distribuidor           VARCHAR(150) NOT NULL,
    ruc                    VARCHAR(30),
    ciudad                 VARCHAR(80),
    contacto_ventas        VARCHAR(120),
    telefono               VARCHAR(30),
    correo                 VARCHAR(150),
    condicion_pago         VARCHAR(80),
    descuento_base_pct     NUMERIC(6,2),
    dias_entrega_promedio  INTEGER
);

CREATE TABLE dw.dim_sucursal (
    sucursal_key       BIGSERIAL PRIMARY KEY,
    codigo_sucursal    VARCHAR(20) NOT NULL UNIQUE,
    sucursal           VARCHAR(150) NOT NULL,
    zona               VARCHAR(30),
    ciudad             VARCHAR(80),
    direccion          VARCHAR(200),
    bodega_principal   VARCHAR(100)
);

CREATE TABLE dw.dim_estado_recepcion (
    estado_recepcion_key  SMALLSERIAL PRIMARY KEY,
    estado_recepcion      VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE dw.fact_compras (
    compra_key BIGSERIAL PRIMARY KEY,

    fecha_compra_key       INTEGER NOT NULL,
    fecha_entrega_key      INTEGER,
    fecha_vencimiento_key  INTEGER,

    medicamento_key        BIGINT NOT NULL,
    distribuidor_key       BIGINT NOT NULL,
    sucursal_key           BIGINT NOT NULL,
    estado_recepcion_key   SMALLINT NOT NULL,

    id_compra_origen       INTEGER,
    orden_compra           VARCHAR(40) NOT NULL,
    factura_distribuidor   VARCHAR(50),
    lote                   VARCHAR(50),
    bodega_entrega         VARCHAR(100),
    observacion            TEXT,

    cantidad_comprada          NUMERIC(14,2) NOT NULL,
    costo_unitario_lista       NUMERIC(14,4),
    descuento_pct              NUMERIC(7,2),
    costo_unitario_descuento   NUMERIC(14,4),
    subtotal_bruto             NUMERIC(16,2),
    valor_descuento            NUMERIC(16,2),
    valor_neto                 NUMERIC(16,2),
    dias_entrega               INTEGER,
    dias_hasta_vencimiento     INTEGER,

    CONSTRAINT fk_compra_fecha
        FOREIGN KEY (fecha_compra_key)
        REFERENCES dw.dim_fecha(fecha_key),

    CONSTRAINT fk_entrega_fecha
        FOREIGN KEY (fecha_entrega_key)
        REFERENCES dw.dim_fecha(fecha_key),

    CONSTRAINT fk_vencimiento_fecha
        FOREIGN KEY (fecha_vencimiento_key)
        REFERENCES dw.dim_fecha(fecha_key),

    CONSTRAINT fk_compra_medicamento
        FOREIGN KEY (medicamento_key)
        REFERENCES dw.dim_medicamento(medicamento_key),

    CONSTRAINT fk_compra_distribuidor
        FOREIGN KEY (distribuidor_key)
        REFERENCES dw.dim_distribuidor(distribuidor_key),

    CONSTRAINT fk_compra_sucursal
        FOREIGN KEY (sucursal_key)
        REFERENCES dw.dim_sucursal(sucursal_key),

    CONSTRAINT fk_compra_estado
        FOREIGN KEY (estado_recepcion_key)
        REFERENCES dw.dim_estado_recepcion(estado_recepcion_key)
);
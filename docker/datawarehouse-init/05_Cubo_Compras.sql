CREATE SCHEMA IF NOT EXISTS dw;

/* =========================================================
   DIMENSIÓN TIEMPO
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_tiempo (
    fecha_key INTEGER PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    anio INTEGER NOT NULL,
    semestre SMALLINT NOT NULL,
    trimestre SMALLINT NOT NULL,
    numero_mes SMALLINT NOT NULL,
    nombre_mes VARCHAR(15) NOT NULL,
    anio_mes VARCHAR(7) NOT NULL,
    numero_semana SMALLINT NOT NULL,
    dia_mes SMALLINT NOT NULL,
    numero_dia_semana SMALLINT NOT NULL,
    nombre_dia VARCHAR(15) NOT NULL,
    es_fin_semana BOOLEAN NOT NULL,

    CONSTRAINT ck_dim_tiempo_semestre
        CHECK (semestre BETWEEN 1 AND 2),

    CONSTRAINT ck_dim_tiempo_trimestre
        CHECK (trimestre BETWEEN 1 AND 4),

    CONSTRAINT ck_dim_tiempo_mes
        CHECK (numero_mes BETWEEN 1 AND 12),

    CONSTRAINT ck_dim_tiempo_dia_semana
        CHECK (numero_dia_semana BETWEEN 1 AND 7)
);


/* =========================================================
   DIMENSIÓN MEDICAMENTO
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_medicamento (
    medicamento_key BIGSERIAL PRIMARY KEY,
    codigo_medicamento VARCHAR(30) NOT NULL,
    nombre_medicamento VARCHAR(200) NOT NULL,
    codigo_categoria VARCHAR(20),
    categoria VARCHAR(100),
    codigo_laboratorio VARCHAR(150),
    presentacion VARCHAR(150),
    costo_base NUMERIC(14,4),
    precio_venta NUMERIC(14,4),
    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_dim_medicamento_codigo
        UNIQUE (codigo_medicamento),

    CONSTRAINT ck_dim_medicamento_costo
        CHECK (costo_base IS NULL OR costo_base >= 0),

    CONSTRAINT ck_dim_medicamento_precio
        CHECK (precio_venta IS NULL OR precio_venta >= 0)
);


/* =========================================================
   DIMENSIÓN DISTRIBUIDOR
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_distribuidor (
    distribuidor_key BIGSERIAL PRIMARY KEY,
    codigo_distribuidor VARCHAR(30) NOT NULL,
    nombre_distribuidor VARCHAR(200) NOT NULL,
    contacto_ventas VARCHAR(150),
    telefono_contacto VARCHAR(50),
    correo_contacto VARCHAR(200),
    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_dim_distribuidor_codigo
        UNIQUE (codigo_distribuidor)
);


/* =========================================================
   DIMENSIÓN SUCURSAL
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_sucursal (
    sucursal_key BIGSERIAL PRIMARY KEY,
    codigo_sucursal VARCHAR(20) NOT NULL,
    nombre_sucursal VARCHAR(150) NOT NULL,
    zona VARCHAR(100),
    ciudad VARCHAR(100),
    direccion VARCHAR(250),
    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_dim_sucursal_codigo
        UNIQUE (codigo_sucursal)
);


/* =========================================================
   DIMENSIÓN ESTADO DE RECEPCIÓN
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_estado_recepcion (
    estado_recepcion_key SMALLSERIAL PRIMARY KEY,
    estado_recepcion VARCHAR(30) NOT NULL,
    categoria VARCHAR(40) NOT NULL,
    es_final BOOLEAN NOT NULL,
    color_semaforo VARCHAR(20),
    orden_visualizacion SMALLINT NOT NULL,
    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_dim_estado_recepcion
        UNIQUE (estado_recepcion),

    CONSTRAINT uq_dim_estado_orden
        UNIQUE (orden_visualizacion),

    CONSTRAINT ck_dim_estado_orden
        CHECK (orden_visualizacion > 0)
);


/* =========================================================
   TABLA DE HECHOS COMPRAS
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.fact_compras (
    compra_key BIGSERIAL PRIMARY KEY,

    fecha_compra_key INTEGER NOT NULL,
    fecha_estimada_entrega_key INTEGER,
    fecha_vencimiento_key INTEGER,

    medicamento_key BIGINT NOT NULL,
    distribuidor_key BIGINT NOT NULL,
    sucursal_key BIGINT NOT NULL,
    estado_recepcion_key SMALLINT NOT NULL,

    id_compra VARCHAR(30) NOT NULL,
    numero_orden VARCHAR(50) NOT NULL,
    factura_distribuidor VARCHAR(50),
    numero_lote VARCHAR(50),

    cantidad_comprada INTEGER NOT NULL,
    costo_unitario NUMERIC(14,4) NOT NULL,
    subtotal_bruto NUMERIC(14,2) NOT NULL,
    porcentaje_descuento NUMERIC(8,4) NOT NULL DEFAULT 0,
    valor_descuento NUMERIC(14,2) NOT NULL DEFAULT 0,
    valor_neto NUMERIC(14,2) NOT NULL,

    dias_estimados_entrega INTEGER,
    dias_hasta_vencimiento INTEGER,

    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_fact_compras_id_origen
        UNIQUE (id_compra),

    CONSTRAINT fk_fact_compras_fecha_compra
        FOREIGN KEY (fecha_compra_key)
        REFERENCES dw.dim_tiempo(fecha_key),

    CONSTRAINT fk_fact_compras_fecha_entrega
        FOREIGN KEY (fecha_estimada_entrega_key)
        REFERENCES dw.dim_tiempo(fecha_key),

    CONSTRAINT fk_fact_compras_fecha_vencimiento
        FOREIGN KEY (fecha_vencimiento_key)
        REFERENCES dw.dim_tiempo(fecha_key),

    CONSTRAINT fk_fact_compras_medicamento
        FOREIGN KEY (medicamento_key)
        REFERENCES dw.dim_medicamento(medicamento_key),

    CONSTRAINT fk_fact_compras_distribuidor
        FOREIGN KEY (distribuidor_key)
        REFERENCES dw.dim_distribuidor(distribuidor_key),

    CONSTRAINT fk_fact_compras_sucursal
        FOREIGN KEY (sucursal_key)
        REFERENCES dw.dim_sucursal(sucursal_key),

    CONSTRAINT fk_fact_compras_estado
        FOREIGN KEY (estado_recepcion_key)
        REFERENCES dw.dim_estado_recepcion(estado_recepcion_key),

    CONSTRAINT ck_fact_compras_cantidad
        CHECK (cantidad_comprada > 0),

    CONSTRAINT ck_fact_compras_costo
        CHECK (costo_unitario >= 0),

    CONSTRAINT ck_fact_compras_subtotal
        CHECK (subtotal_bruto >= 0),

    CONSTRAINT ck_fact_compras_porcentaje_descuento
        CHECK (
            porcentaje_descuento BETWEEN 0 AND 100
        ),

    CONSTRAINT ck_fact_compras_valor_descuento
        CHECK (valor_descuento >= 0),

    CONSTRAINT ck_fact_compras_valor_neto
        CHECK (valor_neto >= 0)
);


/* =========================================================
   ÍNDICES
   ========================================================= */

CREATE INDEX IF NOT EXISTS idx_fact_compras_fecha_compra
    ON dw.fact_compras(fecha_compra_key);

CREATE INDEX IF NOT EXISTS idx_fact_compras_fecha_entrega
    ON dw.fact_compras(fecha_estimada_entrega_key);

CREATE INDEX IF NOT EXISTS idx_fact_compras_fecha_vencimiento
    ON dw.fact_compras(fecha_vencimiento_key);

CREATE INDEX IF NOT EXISTS idx_fact_compras_medicamento
    ON dw.fact_compras(medicamento_key);

CREATE INDEX IF NOT EXISTS idx_fact_compras_distribuidor
    ON dw.fact_compras(distribuidor_key);

CREATE INDEX IF NOT EXISTS idx_fact_compras_sucursal
    ON dw.fact_compras(sucursal_key);

CREATE INDEX IF NOT EXISTS idx_fact_compras_estado
    ON dw.fact_compras(estado_recepcion_key);

CREATE INDEX IF NOT EXISTS idx_fact_compras_numero_orden
    ON dw.fact_compras(numero_orden);

CREATE INDEX IF NOT EXISTS idx_fact_compras_numero_lote
    ON dw.fact_compras(numero_lote);
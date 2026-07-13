# Proyecto de Inteligencia de Negocios para una Cadena de Farmacias

## Implementación con Pentaho Data Integration, PostgreSQL, R y Power BI

---

## 1. Nombre del proyecto

**Sistema de Inteligencia de Negocios para la Gestión Integral de una Cadena de Farmacias**

El proyecto integra tres fuentes de datos heterogéneas, construye un Data Warehouse mediante **Pentaho Data Integration**, aplica un modelo de pronóstico de series de tiempo mediante **R** y utiliza **Power BI únicamente para el modelado semántico ligero, las medidas DAX y la visualización**.

---

## 2. Fuentes de datos

### 2.1. MySQL: sistema operacional de farmacia

Archivo:

```text
01_mysql_recrear_farmacia_bi_100_medicamentos_2025_2026.sql
```

Principales entidades:

- `laboratorio`
- `categoria`
- `medicamento`
- `cliente`
- `venta`
- `detalle_venta`
- `inventario`

Información disponible:

- Medicamentos, categorías y laboratorios.
- Clientes registrados en el sistema de ventas.
- Ventas y detalle de cada venta.
- Formas de pago y descuentos.
- Inventario por sucursal.
- Costos y precios de referencia.

---

### 2.2. PostgreSQL: sistema corporativo de gestión

Archivo:

```text
01_postgresql_recrear_gestion_bi_100_clientes_2025_2026.sql
```

Esquema operacional:

```text
gestion
```

Principales entidades:

- `zona`
- `sucursal`
- `segmento_cliente`
- `cliente`
- `meta_mensual`
- `encuesta_satisfaccion`

Información disponible:

- Zonas y sucursales.
- Ubicación geográfica.
- Segmentación corporativa de clientes.
- Metas mensuales por sucursal.
- Encuestas de satisfacción.
- Tiempo de espera del cliente.

---

### 2.3. Excel: sistema de compras

Archivo:

```text
compras_medicamentos_tercera_fuente_bi_2025_2026.xlsx
```

Hojas disponibles:

- `Compras_2025_2026`
- `Distribuidores`
- `Medicamentos`
- `Puntos_Entrega`
- `Resumen_Mensual`

Información disponible:

- Compras de medicamentos.
- Distribuidores.
- Lotes y fechas de vencimiento.
- Cantidades compradas.
- Costos y descuentos.
- Valor neto comprado.
- Puntos de entrega.
- Estado de recepción.
- Resúmenes mensuales.

---

## 3. Situación problemática

La cadena de farmacias administra sus datos mediante varios sistemas independientes:

- MySQL contiene ventas e inventario.
- PostgreSQL contiene clientes corporativos, sucursales, metas y encuestas.
- Excel contiene compras y proveedores.
- Los códigos, nombres y formatos no siempre coinciden entre las fuentes.
- No existe un Data Warehouse que consolide la información.
- La gerencia no dispone de una visión integrada de ventas, compras, rentabilidad, inventario, metas y satisfacción.
- No existe un mecanismo para pronosticar las ventas futuras.
- Tampoco existe un control formal de calidad y ejecución de los procesos ETL.

Como resultado, la organización tiene dificultades para responder preguntas como:

- ¿Qué sucursales son más rentables?
- ¿Qué medicamentos generan más ventas y margen?
- ¿Cuánto se compra en comparación con lo que se vende?
- ¿Qué productos presentan riesgo de desabastecimiento o sobrestock?
- ¿Qué sucursales cumplen sus metas?
- ¿Existe relación entre satisfacción y desempeño comercial?
- ¿Qué proveedores ofrecen mejores condiciones?
- ¿Qué ventas podrían esperarse en los próximos meses?
- ¿Qué procesos ETL presentan errores, rechazos o retrasos?

---

## 4. Pregunta guía

> **¿Cómo puede una cadena de farmacias integrar sus datos de ventas, compras, inventario, clientes, metas y satisfacción para mejorar la rentabilidad, el abastecimiento, la experiencia del cliente y la planificación futura?**

---

## 5. Objetivo general

**Diseñar e implementar una solución de Inteligencia de Negocios que integre información de ventas, compras, inventario, clientes, metas y satisfacción mediante Pentaho Data Integration, consolide los datos en un Data Warehouse, aplique R para pronosticar una serie de tiempo y utilice Power BI para construir dashboards que apoyen la toma de decisiones.**

---

## 6. Objetivos específicos

1. Analizar la estructura y calidad de las tres fuentes de datos.
2. Definir requerimientos analíticos, procesos de negocio y KPIs.
3. Diseñar un modelo dimensional para el Data Warehouse.
4. Construir procesos ETL en Pentaho Data Integration.
5. Limpiar, transformar y homologar clientes, medicamentos, sucursales y fechas.
6. Cargar dimensiones y tablas de hechos en PostgreSQL.
7. Registrar el estado, duración y calidad de cada ejecución ETL.
8. Aplicar R para analizar y pronosticar una serie temporal de ventas.
9. Almacenar los pronósticos generados por R dentro del Data Warehouse.
10. Conectar Power BI al Data Warehouse para crear medidas y visualizaciones.
11. Formular conclusiones y recomendaciones basadas en los resultados.

---

## 7. Alcance del proyecto

El proyecto cubrirá seis procesos analíticos:

| Proceso | Fuente principal |
|---|---|
| Ventas de medicamentos | MySQL |
| Compras de medicamentos | Excel |
| Inventario por sucursal | MySQL |
| Metas comerciales | PostgreSQL |
| Satisfacción del cliente | PostgreSQL |
| Pronóstico de ventas | R sobre datos del Data Warehouse |

El proyecto incluirá:

- Integración de tres fuentes.
- Área de staging.
- Data Warehouse dimensional.
- ETL mediante Pentaho.
- Control de calidad y auditoría ETL.
- Pronóstico de series de tiempo con R.
- Visualización en Power BI.

No se utilizará Power BI como herramienta principal de limpieza o integración. Las transformaciones relevantes se realizarán en Pentaho antes de que los datos lleguen a Power BI.

---

## 8. Arquitectura propuesta

```text
┌──────────────────────────┐
│ MySQL farmacia_db        │
│ Ventas e inventario      │
└────────────┬─────────────┘
             │
┌────────────▼─────────────┐
│ Pentaho Data Integration │
│ Extracción y staging     │
└────────────▲─────────────┘
             │
┌────────────┴─────────────┐
│ PostgreSQL gestion       │
│ Clientes, metas,         │
│ sucursales y encuestas   │
└──────────────────────────┘

┌──────────────────────────┐
│ Excel de compras         │
│ Proveedores, lotes,      │
│ costos y recepción       │
└────────────┬─────────────┘
             │
             ▼
┌────────────────────────────────────┐
│ Pentaho Data Integration           │
│                                    │
│ - Perfilamiento                    │
│ - Limpieza                         │
│ - Homologación                     │
│ - Validación                       │
│ - Manejo de errores                │
│ - Carga dimensional                │
│ - Auditoría ETL                    │
└────────────────┬───────────────────┘
                 ▼
┌────────────────────────────────────┐
│ PostgreSQL Data Warehouse          │
│ Esquemas: stg, dw y audit          │
└──────────────┬─────────────┬───────┘
               │             │
               │             ▼
               │     ┌──────────────────────┐
               │     │ R                    │
               │     │ Serie de tiempo      │
               │     │ Pronóstico de ventas │
               │     └──────────┬───────────┘
               │                │
               │                ▼
               │     ┌──────────────────────┐
               │     │ Tabla de pronósticos │
               │     │ en el Data Warehouse │
               │     └──────────┬───────────┘
               │                │
               └────────────────┴───────────────┐
                                                ▼
                                   ┌────────────────────────┐
                                   │ Power BI               │
                                   │ Medidas y visualización│
                                   └────────────────────────┘
```

---

## 9. Responsabilidad de cada herramienta

### Pentaho Data Integration

Pentaho será responsable de:

- Conectarse a MySQL.
- Conectarse a PostgreSQL.
- Leer el archivo Excel.
- Extraer los datos.
- Cargar tablas de staging.
- Limpiar y transformar los datos.
- Homologar claves de negocio.
- Detectar y separar registros inválidos.
- Generar claves sustitutas.
- Cargar dimensiones.
- Cargar tablas de hechos.
- Registrar auditoría y errores.
- Ejecutar o invocar el proceso de R.
- Programar el flujo completo mediante jobs.

### PostgreSQL

PostgreSQL será utilizado como:

- Base del sistema corporativo operacional.
- Motor del Data Warehouse.
- Repositorio de staging.
- Repositorio dimensional.
- Repositorio de auditoría ETL.
- Repositorio de los resultados del pronóstico.

### R

R será utilizado para:

- Preparar una serie temporal agregada.
- Explorar tendencia y estacionalidad.
- Ajustar un modelo de pronóstico.
- Evaluar el modelo.
- Generar predicciones futuras.
- Guardar los resultados en PostgreSQL.

### Power BI

Power BI será utilizado para:

- Conectarse al Data Warehouse.
- Crear medidas DAX.
- Definir jerarquías y formatos.
- Diseñar dashboards.
- Comparar datos reales y pronosticados.
- Presentar KPIs.
- Facilitar la exploración interactiva.

---

## 10. Esquemas recomendados en PostgreSQL

```sql
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dw;
CREATE SCHEMA IF NOT EXISTS audit;
```

### Esquema `stg`

Contendrá copias temporales o normalizadas de las fuentes:

```text
stg_mysql_venta
stg_mysql_detalle_venta
stg_mysql_medicamento
stg_mysql_cliente
stg_mysql_inventario

stg_pg_sucursal
stg_pg_zona
stg_pg_cliente
stg_pg_segmento
stg_pg_meta
stg_pg_encuesta

stg_excel_compras
stg_excel_distribuidores
stg_excel_medicamentos
stg_excel_puntos_entrega
```

### Esquema `dw`

Contendrá dimensiones, hechos y pronósticos:

```text
dim_fecha
dim_medicamento
dim_sucursal
dim_cliente
dim_distribuidor
dim_forma_pago
dim_estado_recepcion

fact_ventas
fact_compras
fact_inventario
fact_metas
fact_satisfaccion
fact_pronostico_ventas
```

### Esquema `audit`

Contendrá información de control:

```text
etl_ejecucion
etl_detalle
etl_error
etl_rechazo
```

---

## 11. Modelo dimensional

## 11.1. Dimensión fecha

```text
fecha_key
fecha
anio
semestre
trimestre
numero_mes
nombre_mes
anio_mes
numero_semana
dia_mes
nombre_dia
es_fin_semana
```

Debe utilizarse para:

- Fecha de venta.
- Fecha de compra.
- Fecha estimada de entrega.
- Fecha de vencimiento.
- Fecha de encuesta.
- Periodo de metas.
- Periodo del pronóstico.

---

## 11.2. Dimensión medicamento

```text
medicamento_key
codigo_medicamento
nombre_medicamento
presentacion
codigo_categoria
categoria
codigo_laboratorio
laboratorio
pais_laboratorio
requiere_receta
activo
costo_referencia
precio_venta_referencia
```

Fuente maestra recomendada:

```text
MySQL
```

La información del Excel se utilizará para validar y complementar códigos, nombres y presentaciones.

---

## 11.3. Dimensión sucursal

```text
sucursal_key
codigo_sucursal
nombre_sucursal
codigo_zona
zona
responsable_zona
ciudad
direccion
latitud
longitud
fecha_apertura
activa
```

Fuente maestra recomendada:

```text
PostgreSQL gestion.sucursal
```

Los nombres operacionales de MySQL y los puntos de entrega del Excel deberán homologarse con el código corporativo.

---

## 11.4. Dimensión cliente

```text
cliente_key
documento_normalizado
nombres
ciudad
sexo
fecha_nacimiento
grupo_edad
codigo_segmento
segmento
fecha_registro
correo
activo
origen_cliente
estado_integracion
```

Valores posibles para `estado_integracion`:

- Integrado.
- Solo MySQL.
- Solo PostgreSQL.
- Duplicado probable.
- Documento inválido.
- Consumidor final.

---

## 11.5. Dimensión distribuidor

```text
distribuidor_key
codigo_distribuidor
nombre_distribuidor
contacto_ventas
telefono_contacto
correo_contacto
```

Fuente:

```text
Hoja Distribuidores del Excel
```

---

## 11.6. Dimensión forma de pago

```text
forma_pago_key
forma_pago
```

---

## 11.7. Dimensión estado de recepción

```text
estado_recepcion_key
estado_recepcion
```

---

## 12. Tablas de hechos

## 12.1. Hecho ventas

**Granularidad:** una fila por medicamento incluido en una venta.

```text
venta_key
numero_venta
linea
fecha_key
sucursal_key
cliente_key
medicamento_key
forma_pago_key
cantidad
precio_unitario
importe_bruto
descuento_asignado
importe_neto
costo_estimado
margen_estimado
estado_venta
```

Medidas:

- Cantidad vendida.
- Venta bruta.
- Descuento.
- Venta neta.
- Costo estimado.
- Margen.
- Número de transacciones.

---

## 12.2. Hecho compras

**Granularidad:** una fila por medicamento y lote incluido en una compra.

```text
compra_key
numero_orden
fecha_compra_key
fecha_entrega_key
fecha_vencimiento_key
sucursal_key
medicamento_key
distribuidor_key
estado_recepcion_key
numero_lote
cantidad_comprada
costo_unitario
subtotal_bruto
porcentaje_descuento
valor_descuento
valor_neto
dias_entrega
dias_hasta_vencimiento
```

---

## 12.3. Hecho inventario

**Granularidad:** una fila por medicamento y sucursal para la fecha de corte.

```text
inventario_key
fecha_corte_key
sucursal_key
medicamento_key
stock_actual
stock_minimo
exceso_stock
deficit_stock
valor_inventario
fecha_ultimo_movimiento
```

---

## 12.4. Hecho metas

**Granularidad:** una fila por sucursal y mes.

```text
meta_key
periodo_key
sucursal_key
meta_ventas
meta_clientes
```

Los valores reales se calcularán a partir de `fact_ventas`.

---

## 12.5. Hecho satisfacción

**Granularidad:** una fila por encuesta.

```text
encuesta_key
id_encuesta_origen
fecha_key
sucursal_key
cliente_key
puntuacion
tiempo_espera_minutos
comentario
es_satisfaccion_positiva
es_satisfaccion_negativa
```

---

## 12.6. Hecho pronóstico de ventas

**Granularidad:** una fila por periodo, sucursal y nivel de pronóstico.

```text
pronostico_key
fecha_key
sucursal_key
tipo_serie
modelo
valor_pronosticado
limite_inferior_80
limite_superior_80
limite_inferior_95
limite_superior_95
fecha_generacion
horizonte
mae_validacion
rmse_validacion
mape_validacion
```

`tipo_serie` puede contener:

- Venta total mensual.
- Venta mensual por sucursal.
- Unidades mensuales.
- Venta mensual por categoría.

Para el curso se recomienda comenzar con:

```text
Venta neta mensual total
```

Como ampliación se puede pronosticar por sucursal.

---

## 13. Esquema lógico simplificado

```text
DimCliente ───────────────┐
DimSucursal ──────────────┤
DimMedicamento ───────────┤
DimFormaPago ─────────────┤
DimFecha ─────────────────┴── FactVentas

DimDistribuidor ──────────┐
DimEstadoRecepcion ───────┤
DimSucursal ──────────────┤
DimMedicamento ───────────┤
DimFecha ─────────────────┴── FactCompras

DimSucursal ──────────────┐
DimMedicamento ───────────┤
DimFecha ─────────────────┴── FactInventario

DimSucursal ──────────────┐
DimFecha ─────────────────┴── FactMetas

DimCliente ───────────────┐
DimSucursal ──────────────┤
DimFecha ─────────────────┴── FactSatisfaccion

DimSucursal ──────────────┐
DimFecha ─────────────────┴── FactPronosticoVentas
```

---

## 14. Flujo ETL en Pentaho

## 14.1. Etapa de extracción

Transformaciones sugeridas:

```text
tr_01_extraer_mysql_ventas.ktr
tr_02_extraer_mysql_inventario.ktr
tr_03_extraer_mysql_maestros.ktr

tr_04_extraer_postgresql_gestion.ktr

tr_05_extraer_excel_compras.ktr
tr_06_extraer_excel_maestros.ktr
```

Pasos habituales:

- Table Input.
- Microsoft Excel Input.
- Select Values.
- String Operations.
- Data Validator.
- Table Output.
- Write to Log.

---

## 14.2. Etapa de perfilamiento

Transformaciones sugeridas:

```text
tr_10_perfilar_clientes.ktr
tr_11_perfilar_medicamentos.ktr
tr_12_perfilar_sucursales.ktr
tr_13_perfilar_compras.ktr
tr_14_perfilar_ventas.ktr
```

Controles:

- Total de filas.
- Valores nulos.
- Valores distintos.
- Duplicados.
- Rangos de fechas.
- Valores máximos y mínimos.
- Integridad referencial.
- Valores fuera de rango.

---

## 14.3. Etapa de limpieza

Operaciones:

- Eliminar espacios iniciales y finales.
- Normalizar mayúsculas y minúsculas.
- Corregir tipos de datos.
- Convertir fechas de Excel.
- Validar documentos.
- Estandarizar ciudades.
- Estandarizar sucursales.
- Estandarizar estados.
- Separar registros válidos e inválidos.
- Registrar errores.

Transformaciones sugeridas:

```text
tr_20_limpiar_clientes.ktr
tr_21_limpiar_medicamentos.ktr
tr_22_limpiar_sucursales.ktr
tr_23_limpiar_compras.ktr
tr_24_limpiar_ventas.ktr
tr_25_limpiar_encuestas.ktr
```

---

## 14.4. Homologación de clientes

Regla inicial:

```text
documento_normalizado =
TRIM(documento)
→ eliminar guiones
→ eliminar espacios internos
→ conservar solo dígitos
→ validar longitud
```

El proceso deberá:

1. Normalizar documento.
2. Comparar clientes de MySQL y PostgreSQL.
3. Identificar coincidencias exactas.
4. Identificar duplicados probables.
5. Clasificar registros no integrados.
6. Conservar trazabilidad del origen.

---

## 14.5. Homologación de sucursales

Se recomienda una tabla de equivalencias:

```text
dw.map_sucursal
```

Ejemplo:

| valor_origen | sistema_origen | codigo_sucursal |
|---|---|---|
| Farmacia Norte | MySQL | NORTE |
| NORTE | Excel | NORTE |
| Farmacia Centro Histórico | MySQL | CENTRO |
| CENTRO | Excel | CENTRO |
| Farmacia del Sur | MySQL | SUR |
| SUR | Excel | SUR |
| Farmacia Valle de los Chillos | MySQL | VALLE |
| VALLE | Excel | VALLE |

Pentaho puede resolver la correspondencia mediante:

- Database Lookup.
- Stream Lookup.
- Merge Join.

---

## 14.6. Carga de dimensiones

Orden recomendado:

```text
1. dim_fecha
2. dim_medicamento
3. dim_sucursal
4. dim_cliente
5. dim_distribuidor
6. dim_forma_pago
7. dim_estado_recepcion
```

Pasos de Pentaho recomendados:

- Dimension Lookup/Update.
- Database Lookup.
- Combination Lookup/Update.
- Insert/Update.
- Table Output.

Para fines didácticos puede aplicarse:

- SCD tipo 1 para correcciones simples.
- SCD tipo 2 como ampliación para conservar historia.

---

## 14.7. Carga de hechos

Transformaciones sugeridas:

```text
tr_40_cargar_fact_ventas.ktr
tr_41_cargar_fact_compras.ktr
tr_42_cargar_fact_inventario.ktr
tr_43_cargar_fact_metas.ktr
tr_44_cargar_fact_satisfaccion.ktr
```

Cada transformación deberá:

1. Leer datos limpios.
2. Resolver claves sustitutas.
3. Calcular medidas derivadas.
4. Validar campos obligatorios.
5. Separar errores.
6. Insertar registros.
7. Registrar cantidad procesada.

---

## 15. Jobs de Pentaho

## 15.1. Job principal

```text
jb_00_carga_dw_farmacia.kjb
```

Secuencia:

```text
Inicio
  ↓
Crear registro de ejecución
  ↓
Extraer MySQL
  ↓
Extraer PostgreSQL
  ↓
Extraer Excel
  ↓
Validar staging
  ↓
Cargar dimensiones
  ↓
Cargar hechos
  ↓
Generar agregados para R
  ↓
Ejecutar script de R
  ↓
Cargar pronósticos
  ↓
Actualizar auditoría
  ↓
Fin correcto
```

Ruta alternativa de error:

```text
Error de transformación
  ↓
Registrar detalle del error
  ↓
Marcar ejecución como fallida
  ↓
Finalizar job
```

---

## 15.2. Job de dimensiones

```text
jb_10_cargar_dimensiones.kjb
```

---

## 15.3. Job de hechos

```text
jb_20_cargar_hechos.kjb
```

---

## 15.4. Job de pronóstico

```text
jb_30_pronostico_r.kjb
```

Pasos:

1. Ejecutar consulta de agregación.
2. Exportar CSV temporal o preparar tabla de entrada.
3. Ejecutar script R.
4. Validar archivo o tabla de salida.
5. Cargar resultados en `dw.fact_pronostico_ventas`.
6. Registrar métricas del modelo.

---

## 16. Auditoría ETL

## 16.1. Tabla de ejecución

```sql
CREATE TABLE audit.etl_ejecucion (
    id_ejecucion BIGSERIAL PRIMARY KEY,
    nombre_job VARCHAR(150) NOT NULL,
    fecha_hora_inicio TIMESTAMP NOT NULL,
    fecha_hora_fin TIMESTAMP,
    estado VARCHAR(20) NOT NULL,
    registros_leidos BIGINT DEFAULT 0,
    registros_validos BIGINT DEFAULT 0,
    registros_rechazados BIGINT DEFAULT 0,
    registros_cargados BIGINT DEFAULT 0,
    duracion_segundos NUMERIC(12,2),
    mensaje TEXT
);
```

## 16.2. Tabla de detalle

```sql
CREATE TABLE audit.etl_detalle (
    id_detalle BIGSERIAL PRIMARY KEY,
    id_ejecucion BIGINT REFERENCES audit.etl_ejecucion(id_ejecucion),
    nombre_transformacion VARCHAR(150),
    fuente VARCHAR(80),
    tabla_destino VARCHAR(120),
    fecha_hora_inicio TIMESTAMP,
    fecha_hora_fin TIMESTAMP,
    registros_leidos BIGINT,
    registros_rechazados BIGINT,
    registros_cargados BIGINT,
    estado VARCHAR(20),
    mensaje TEXT
);
```

## 16.3. Tabla de rechazos

```sql
CREATE TABLE audit.etl_rechazo (
    id_rechazo BIGSERIAL PRIMARY KEY,
    id_ejecucion BIGINT REFERENCES audit.etl_ejecucion(id_ejecucion),
    fuente VARCHAR(80),
    entidad VARCHAR(80),
    clave_origen VARCHAR(150),
    tipo_error VARCHAR(80),
    descripcion_error TEXT,
    datos_origen TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 17. Aplicación de R a una serie de tiempo

## 17.1. Serie seleccionada

Para mantener el proyecto manejable se recomienda utilizar:

> **Ventas netas mensuales de toda la cadena**

La serie se obtiene agregando `fact_ventas`:

```sql
SELECT
    DATE_TRUNC('month', f.fecha)::date AS periodo,
    SUM(v.importe_neto) AS ventas_netas
FROM dw.fact_ventas v
JOIN dw.dim_fecha f
    ON f.fecha_key = v.fecha_key
GROUP BY DATE_TRUNC('month', f.fecha)
ORDER BY periodo;
```

Como ampliación se pueden crear series por:

- Sucursal.
- Categoría.
- Laboratorio.
- Medicamento.
- Unidades vendidas.

---

## 17.2. Objetivo analítico

Pronosticar las ventas de los próximos:

```text
3 meses
```

o, si la cantidad de observaciones lo permite:

```text
6 meses
```

El ejercicio debe permitir al estudiante:

- Identificar tendencia.
- Analizar posible estacionalidad.
- Separar entrenamiento y validación.
- Comparar valores reales y pronosticados.
- Interpretar intervalos de confianza.
- Evaluar el error del modelo.

---

## 17.3. Flujo de datos hacia R

Opción recomendada:

```text
Pentaho → PostgreSQL → R → PostgreSQL → Power BI
```

Secuencia:

1. Pentaho carga `fact_ventas`.
2. Pentaho genera una tabla agregada mensual.
3. R consulta la tabla agregada desde PostgreSQL.
4. R ajusta el modelo.
5. R inserta los pronósticos en el Data Warehouse.
6. Power BI consulta los datos reales y pronosticados.

Tabla intermedia sugerida:

```text
dw.serie_ventas_mensuales
```

Campos:

```text
periodo
sucursal_key
ventas_netas
unidades_vendidas
numero_transacciones
```

---

## 17.4. Modelos recomendados

Para el nivel del curso se recomienda comparar:

- Promedio móvil como línea base.
- Suavizamiento exponencial ETS.
- ARIMA automático.

Modelo principal recomendado:

```text
ETS o ARIMA
```

La selección final puede basarse en:

- MAE.
- RMSE.
- MAPE.
- Comportamiento de los residuos.

---

## 17.5. Paquetes de R

```r
install.packages(c(
  "DBI",
  "RPostgres",
  "dplyr",
  "lubridate",
  "forecast",
  "ggplot2"
))
```

---

## 17.6. Script base de R

```r
library(DBI)
library(RPostgres)
library(dplyr)
library(lubridate)
library(forecast)

conexion <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("DW_HOST"),
  port = as.integer(Sys.getenv("DW_PORT")),
  dbname = Sys.getenv("DW_DATABASE"),
  user = Sys.getenv("DW_USER"),
  password = Sys.getenv("DW_PASSWORD")
)

serie <- dbGetQuery(
  conexion,
  "
  SELECT periodo, ventas_netas
  FROM dw.serie_ventas_mensuales
  WHERE sucursal_key IS NULL
  ORDER BY periodo
  "
)

serie$periodo <- as.Date(serie$periodo)

anio_inicio <- year(min(serie$periodo))
mes_inicio <- month(min(serie$periodo))

ventas_ts <- ts(
  serie$ventas_netas,
  start = c(anio_inicio, mes_inicio),
  frequency = 12
)

modelo_ets <- ets(ventas_ts)
pronostico <- forecast(modelo_ets, h = 3, level = c(80, 95))

periodos_futuros <- seq(
  from = floor_date(max(serie$periodo), "month") %m+% months(1),
  by = "month",
  length.out = 3
)

resultado <- data.frame(
  periodo = periodos_futuros,
  tipo_serie = "VENTA_NETA_MENSUAL",
  modelo = "ETS",
  valor_pronosticado = as.numeric(pronostico$mean),
  limite_inferior_80 = as.numeric(pronostico$lower[, "80%"]),
  limite_superior_80 = as.numeric(pronostico$upper[, "80%"]),
  limite_inferior_95 = as.numeric(pronostico$lower[, "95%"]),
  limite_superior_95 = as.numeric(pronostico$upper[, "95%"]),
  fecha_generacion = Sys.time(),
  horizonte = 1:3
)

dbWriteTable(
  conexion,
  Id(schema = "stg", table = "pronostico_ventas_r"),
  resultado,
  overwrite = TRUE,
  row.names = FALSE
)

dbDisconnect(conexion)
```

Pentaho deberá leer `stg.pronostico_ventas_r`, resolver las claves de fecha y cargar `dw.fact_pronostico_ventas`.

---

## 17.7. Evaluación del modelo

Se recomienda reservar los últimos tres meses conocidos como conjunto de validación.

Métricas:

```text
MAE  = error absoluto medio
RMSE = raíz del error cuadrático medio
MAPE = error porcentual absoluto medio
```

El modelo deberá considerarse útil cuando:

- Supere a una línea base simple.
- No presente errores extremos.
- Los residuos no muestren patrones evidentes.
- El pronóstico sea coherente con el contexto del negocio.

Debe aclararse que una serie con pocos periodos limita la confiabilidad del pronóstico. El objetivo académico es aplicar el proceso completo y evaluar críticamente sus limitaciones.

---

## 18. Integración de R con Pentaho

Pentaho puede ejecutar R mediante una entrada de job como:

```text
Shell
```

Ejemplo conceptual:

```bash
Rscript pronostico_ventas.R
```

El job debe:

1. Establecer variables de conexión.
2. Ejecutar el script.
3. Verificar el código de salida.
4. Comprobar que se generaron resultados.
5. Cargar los pronósticos.
6. Registrar éxito o error en auditoría.

Variables recomendadas:

```text
DW_HOST
DW_PORT
DW_DATABASE
DW_USER
DW_PASSWORD
```

No se deben guardar contraseñas directamente dentro del script R ni en el repositorio público.

---

## 19. Indicadores del proyecto

## 19.1. Ventas

- Ventas brutas.
- Ventas netas.
- Unidades vendidas.
- Número de transacciones.
- Ticket promedio.
- Descuento total.
- Costo estimado.
- Margen bruto estimado.
- Margen porcentual.
- Clientes distintos.

## 19.2. Compras

- Valor bruto comprado.
- Valor neto comprado.
- Unidades compradas.
- Descuento obtenido.
- Costo promedio por unidad.
- Compras por distribuidor.
- Compras pendientes.
- Tiempo estimado de entrega.

## 19.3. Inventario

- Stock total.
- Valor del inventario.
- Medicamentos bajo mínimo.
- Déficit de unidades.
- Exceso de stock.
- Productos sin movimiento.
- Cobertura estimada.

## 19.4. Metas

- Meta mensual.
- Venta real.
- Cumplimiento porcentual.
- Brecha frente a meta.
- Meta de clientes.
- Clientes atendidos.

## 19.5. Satisfacción

- Puntuación promedio.
- Tiempo promedio de espera.
- Número de encuestas.
- Porcentaje de satisfacción positiva.
- Porcentaje de satisfacción negativa.

## 19.6. Pronóstico

- Venta pronosticada.
- Diferencia entre real y pronosticado.
- Crecimiento esperado.
- Límite inferior.
- Límite superior.
- MAE.
- RMSE.
- MAPE.

## 19.7. ETL

- Registros leídos.
- Registros válidos.
- Registros rechazados.
- Porcentaje de calidad.
- Duración del proceso.
- Fuentes cargadas correctamente.
- Transformaciones fallidas.
- Última fecha de actualización.

---

## 20. Medidas DAX sugeridas

Power BI se conectará a las tablas ya transformadas del Data Warehouse.

### Ventas

```DAX
Ventas netas =
SUM(fact_ventas[importe_neto])
```

```DAX
Unidades vendidas =
SUM(fact_ventas[cantidad])
```

```DAX
Número de ventas =
DISTINCTCOUNT(fact_ventas[numero_venta])
```

```DAX
Ticket promedio =
DIVIDE(
    [Ventas netas],
    [Número de ventas],
    0
)
```

```DAX
Margen bruto =
SUM(fact_ventas[margen_estimado])
```

```DAX
Margen porcentual =
DIVIDE(
    [Margen bruto],
    [Ventas netas],
    0
)
```

### Compras

```DAX
Valor neto comprado =
SUM(fact_compras[valor_neto])
```

```DAX
Unidades compradas =
SUM(fact_compras[cantidad_comprada])
```

### Metas

```DAX
Meta de ventas =
SUM(fact_metas[meta_ventas])
```

```DAX
Cumplimiento de ventas =
DIVIDE(
    [Ventas netas],
    [Meta de ventas],
    0
)
```

```DAX
Brecha frente a meta =
[Ventas netas] - [Meta de ventas]
```

### Pronóstico

```DAX
Venta pronosticada =
SUM(fact_pronostico_ventas[valor_pronosticado])
```

```DAX
Desviación frente al pronóstico =
[Ventas netas] - [Venta pronosticada]
```

```DAX
Desviación porcentual =
DIVIDE(
    [Desviación frente al pronóstico],
    [Venta pronosticada],
    0
)
```

### Calidad ETL

```DAX
Porcentaje de registros válidos =
DIVIDE(
    SUM(etl_ejecucion[registros_validos]),
    SUM(etl_ejecucion[registros_leidos]),
    0
)
```

---

## 21. Dashboards en Power BI

## 21.1. Página 1: resumen ejecutivo

Tarjetas:

- Ventas netas.
- Margen bruto.
- Valor comprado.
- Cumplimiento de meta.
- Satisfacción promedio.
- Productos bajo stock.
- Venta pronosticada del siguiente mes.

Visualizaciones:

- Ventas y compras por mes.
- Cumplimiento por sucursal.
- Margen por categoría.
- Mapa de sucursales.
- Indicador de calidad ETL.

---

## 21.2. Página 2: ventas

- Evolución mensual.
- Ventas por sucursal.
- Ventas por categoría.
- Top 10 medicamentos.
- Ventas por laboratorio.
- Ticket promedio.
- Forma de pago.
- Ventas por segmento.

---

## 21.3. Página 3: compras y proveedores

- Compras mensuales.
- Valor neto por distribuidor.
- Descuento por proveedor.
- Unidades compradas.
- Estado de recepción.
- Lotes próximos a vencer.
- Comparación de costos.

---

## 21.4. Página 4: rentabilidad

- Venta neta por medicamento.
- Costo estimado.
- Margen.
- Margen porcentual.
- Productos de alta venta y bajo margen.
- Productos de baja venta y alto costo.
- Matriz ventas frente a margen.

---

## 21.5. Página 5: inventario

- Stock actual.
- Stock mínimo.
- Déficit.
- Exceso.
- Valor del inventario.
- Stock por sucursal.
- Compras frente a ventas.
- Semáforo de abastecimiento.

---

## 21.6. Página 6: metas y sucursales

- Venta real frente a meta.
- Cumplimiento.
- Brecha.
- Clientes reales frente a meta.
- Ranking de sucursales.
- Evolución mensual.
- Cumplimiento por zona.

---

## 21.7. Página 7: clientes y satisfacción

- Clientes por segmento.
- Clientes activos.
- Puntuación promedio.
- Tiempo de espera.
- Satisfacción por sucursal.
- Satisfacción frente a ventas.
- Comentarios negativos.

---

## 21.8. Página 8: pronóstico de ventas

Visualizaciones:

- Línea de ventas históricas.
- Línea de ventas pronosticadas.
- Banda de confianza.
- Venta real frente a pronóstico.
- Error del modelo.
- Pronóstico por sucursal, como ampliación.
- Tabla de periodos futuros.

Preguntas:

- ¿Qué nivel de ventas se espera?
- ¿Cuál es el rango probable?
- ¿La tendencia esperada es creciente o decreciente?
- ¿Qué sucursales requieren ajustar compras o metas?
- ¿Qué tan preciso ha sido el modelo?

---

## 21.9. Página 9: monitoreo ETL

- Última ejecución.
- Estado del job.
- Duración total.
- Registros procesados.
- Registros rechazados.
- Calidad por fuente.
- Transformaciones fallidas.
- Tabla de errores.
- Histórico de duración de cargas.

---

## 22. Problemas de calidad que deben analizarse

### Clientes

- Documentos con espacios o guiones.
- Registros duplicados.
- Clientes presentes en una sola fuente.
- Nombres con formatos diferentes.
- Correos diferentes para la misma persona.
- Documentos inválidos.
- Valores nulos.

### Ciudades

Ejemplos:

```text
Quito
quito
Quito 
QUITO
```

Reglas:

- Trim.
- Formato título.
- Tabla de equivalencias.
- Separación entre ciudad y sector.

### Sucursales

- Nombre operacional frente a código corporativo.
- Diferencias entre MySQL, PostgreSQL y Excel.
- Puntos de entrega sin correspondencia.

### Medicamentos

- Códigos inexistentes.
- Nombres distintos para el mismo código.
- Presentaciones inconsistentes.
- Costos superiores a precios.
- Medicamentos inactivos con transacciones.

### Fechas

- Fechas de Excel interpretadas como números.
- Fechas fuera del periodo esperado.
- Fechas de vencimiento anteriores a la compra.
- Fechas de entrega anteriores a la orden.

### Encuestas

- Puntuaciones fuera del rango 1 a 5.
- Tiempo de espera negativo.
- Cliente inexistente.
- Sucursal inexistente.

---

## 23. Requerimientos funcionales

El sistema debe permitir:

1. Consultar ventas por periodo, sucursal, medicamento y categoría.
2. Comparar ventas con metas.
3. Analizar compras por proveedor.
4. Calcular descuentos.
5. Comparar unidades compradas y vendidas.
6. Detectar medicamentos bajo mínimo.
7. Identificar lotes próximos a vencer.
8. Analizar margen estimado.
9. Analizar satisfacción y tiempo de espera.
10. Consultar clientes por segmento.
11. Identificar inconsistencias entre fuentes.
12. Monitorear procesos ETL.
13. Visualizar ventas pronosticadas.
14. Comparar valores reales y pronosticados.
15. Filtrar dashboards por fecha, sucursal, producto y proveedor.

---

## 24. Requerimientos no funcionales

- El ETL debe implementarse en Pentaho.
- El Data Warehouse debe almacenarse en PostgreSQL.
- El modelo debe ser dimensional.
- Las relaciones deben ser principalmente uno a muchos.
- Las claves de las dimensiones deben ser sustitutas.
- Los datos rechazados deben conservarse.
- Cada ejecución debe generar auditoría.
- El script R debe ser reproducible.
- Las credenciales no deben almacenarse en código.
- Power BI no debe repetir transformaciones ya realizadas en Pentaho.
- Los dashboards no deben exponer documentos, teléfonos o correos completos.
- Los gráficos deben tener títulos, unidades y contexto.
- El proceso debe poder ejecutarse nuevamente sin duplicar información.

---

## 25. Distribución por unidades del curso

## Unidad 1: fundamentos y planificación

Producto:

```text
Documento de definición del proyecto
```

Contenido:

- Problema.
- Objetivos.
- Alcance.
- Usuarios.
- Preguntas de negocio.
- Fuentes.
- KPIs.
- Arquitectura.
- Boceto del dashboard.
- Riesgos.

---

## Unidad 2: preparación, minería y serie de tiempo

Producto:

```text
Informe de calidad y análisis predictivo inicial
```

Actividades:

- Perfilamiento.
- Limpieza.
- Transformación.
- Selección de atributos.
- Identificación de valores atípicos.
- Construcción de la serie mensual.
- Exploración de tendencia.
- Aplicación inicial de R.
- Evaluación del modelo.

---

## Unidad 3: Data Warehouse y Pentaho

Producto:

```text
Data Warehouse y procesos ETL
```

Actividades:

- Definición de granularidad.
- Diseño dimensional.
- Creación de staging.
- Creación de dimensiones.
- Creación de hechos.
- Transformaciones Pentaho.
- Jobs de carga.
- Auditoría.
- Manejo de errores.
- Integración del script R.

---

## Unidad 4: visualización en Power BI

Producto:

```text
Reporte final de Power BI
```

Debe incluir:

- Modelo conectado al Data Warehouse.
- Medidas DAX.
- Indicadores.
- Dashboards.
- Pronósticos.
- Panel ETL.
- Conclusiones.
- Recomendaciones.

---

## 26. Entregables

### Entregable 1: planificación

Documento con:

- Problema.
- Objetivos.
- Alcance.
- Arquitectura.
- Fuentes.
- KPIs.
- Cronograma.

### Entregable 2: perfilamiento

- Diccionario de datos.
- Problemas detectados.
- Reglas de limpieza.
- Evidencias.
- Registros rechazados.

### Entregable 3: modelo dimensional

- Diagrama estrella.
- Granularidad.
- Dimensiones.
- Hechos.
- Relaciones.
- Justificación.

### Entregable 4: Pentaho

- Archivos `.ktr`.
- Archivos `.kjb`.
- Variables de ambiente de ejemplo.
- Evidencias de ejecución.
- Auditoría.
- Manejo de errores.

### Entregable 5: R

- Script `.R`.
- Consulta o tabla de entrada.
- Modelo aplicado.
- Métricas de evaluación.
- Pronósticos.
- Interpretación.

### Entregable 6: Power BI

- Archivo `.pbix`.
- Al menos seis páginas analíticas.
- Página de pronóstico.
- Página de monitoreo ETL.
- Medidas DAX.
- Segmentadores.
- Navegación.

### Entregable 7: informe ejecutivo

- Hallazgos.
- Conclusiones.
- Recomendaciones.
- Limitaciones.
- Lecciones aprendidas.

---

## 27. Estructura de carpetas recomendada

```text
proyecto_bi_farmacia/
│
├── 01_fuentes/
│   ├── mysql/
│   ├── postgresql/
│   └── excel/
│
├── 02_sql_dw/
│   ├── crear_esquemas.sql
│   ├── crear_dimensiones.sql
│   ├── crear_hechos.sql
│   └── crear_auditoria.sql
│
├── 03_pentaho/
│   ├── transformaciones/
│   ├── jobs/
│   └── parametros/
│
├── 04_r/
│   ├── pronostico_ventas.R
│   └── README.md
│
├── 05_powerbi/
│   └── farmacia_bi.pbix
│
├── 06_documentacion/
│   ├── diccionario_datos.md
│   ├── reglas_calidad.md
│   ├── modelo_dimensional.md
│   └── informe_final.md
│
└── README.md
```

---

## 28. Cronograma técnico resumido

| Fase | Actividad | Herramienta |
|---|---|---|
| 1 | Análisis del negocio | Documentación |
| 2 | Perfilamiento de fuentes | Pentaho y SQL |
| 3 | Diseño dimensional | PostgreSQL |
| 4 | Construcción de staging | Pentaho |
| 5 | Limpieza y homologación | Pentaho |
| 6 | Carga de dimensiones | Pentaho |
| 7 | Carga de hechos | Pentaho |
| 8 | Auditoría ETL | Pentaho y PostgreSQL |
| 9 | Serie temporal | SQL y R |
| 10 | Pronóstico | R |
| 11 | Carga de pronósticos | Pentaho |
| 12 | Dashboards | Power BI |
| 13 | Validación | Todas |
| 14 | Informe final | Documentación |

---

## 29. Decisiones que debería apoyar

- Incrementar o reducir compras.
- Redistribuir inventario entre sucursales.
- Negociar con proveedores.
- Identificar proveedores con retrasos.
- Promocionar productos de alto margen.
- Revisar productos de alta venta y bajo margen.
- Ajustar metas.
- Mejorar atención en sucursales con altos tiempos de espera.
- Depurar clientes duplicados.
- Planificar abastecimiento con base en el pronóstico.
- Corregir problemas recurrentes de calidad.
- Optimizar la duración de los jobs ETL.

---

## 30. Recomendación metodológica

El proyecto debe desarrollarse como un único caso incremental:

```text
Unidad 1 → comprender el negocio y planificar
Unidad 2 → perfilar, limpiar, analizar y pronosticar
Unidad 3 → integrar, modelar y cargar con Pentaho
Unidad 4 → visualizar e interpretar con Power BI
```

La separación de responsabilidades será:

```text
Pentaho = integración y ETL
PostgreSQL = staging, Data Warehouse y auditoría
R = análisis de serie temporal y pronóstico
Power BI = medidas, visualización e interpretación
```

Esta arquitectura permite que los estudiantes comprendan un flujo BI completo y evita utilizar Power BI como sustituto del proceso ETL.

---

## 31. Resultado final esperado

Al finalizar el proyecto, el estudiante habrá construido una solución que:

1. Integra MySQL, PostgreSQL y Excel.
2. Ejecuta procesos ETL mediante Pentaho.
3. Almacena información en un Data Warehouse dimensional.
4. Registra calidad, errores y duración de las cargas.
5. Aplica R para pronosticar ventas.
6. Almacena los pronósticos dentro del Data Warehouse.
7. Presenta KPIs y dashboards en Power BI.
8. Formula recomendaciones para la toma de decisiones.

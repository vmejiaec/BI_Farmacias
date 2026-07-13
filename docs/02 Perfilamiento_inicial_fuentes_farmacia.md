# Perfilamiento inicial de fuentes

## Proyecto BI para una cadena de farmacias

**Fecha del perfilamiento:** 11 de julio de 2026  
**Método:** análisis estático de los scripts SQL y lectura directa del libro Excel.  
**Fuentes analizadas:**

1. `01_mysql_recrear_farmacia_bi_100_medicamentos_2025_2026.sql`
2. `01_postgresql_recrear_gestion_bi_100_clientes_2025_2026.sql`
3. `compras_medicamentos_tercera_fuente_bi_2025_2026.xlsx`

> Este documento presenta los resultados contenidos en los archivos fuente. Los conteos se obtuvieron de las sentencias `INSERT` y de las filas efectivas del libro Excel, sin requerir la ejecución previa de los motores MySQL y PostgreSQL.

---

# 1. Resumen ejecutivo

| Fuente | Entidad principal | Registros | Periodo principal | Resultado general |
|---|---|---:|---|---|
| MySQL | Ventas | 4.102 | 2025-01-01 a 2026-12-31 | Datos completos, con necesidad de homologar sucursales, formas de pago y clientes sin documento |
| MySQL | Detalle de ventas | 12.306 | 2025-2026 | Integridad referencial correcta |
| MySQL | Inventario | 400 | Corte durante 2026 | 12 registros bajo mínimo y 172 fechas de entrada posteriores al último movimiento |
| PostgreSQL | Clientes corporativos | 100 filas, 99 documentos únicos | Registros 2024-2026 | Un documento duplicado y 16 ciudades nulas |
| PostgreSQL | Metas mensuales | 96 | 2025-01 a 2026-12 | Cobertura completa: 4 sucursales × 24 meses |
| PostgreSQL | Encuestas | 1.460 | 2025-01-01 a 2026-12-31 | 3 puntuaciones fuera de rango y 28 clientes sin correspondencia |
| Excel | Compras | 874 | 2025-01-01 a 2026-12-31 | Sin claves duplicadas, nulos ni errores aritméticos detectados |
| Excel | Medicamentos | 100 | Maestro | Coincidencia total con el maestro de MySQL |
| Excel | Puntos de entrega | 4 | Maestro | Coincidencia total con las sucursales de PostgreSQL |

## Conclusión inicial

Las tres fuentes son utilizables para construir el proyecto BI. Los principales trabajos de calidad deberán concentrarse en:

- homologación de nombres de sucursales en MySQL;
- estandarización de formas de pago;
- tratamiento de ventas sin documento de cliente;
- resolución del documento duplicado en PostgreSQL;
- normalización de ciudades;
- validación de encuestas;
- revisión de consistencia temporal del inventario;
- tratamiento de fechas posteriores al momento de ejecución del proyecto.

---

# 2. Fuente MySQL: sistema operacional de farmacia

## 2.1. Base y tablas

**Base definida:** `farmacia_db`

| Tabla | Registros | Clave primaria | Nulos relevantes |
|---|---:|---|---|
| `laboratorio` | 12 | `codigo_laboratorio` | 0 |
| `categoria` | 12 | `codigo_categoria` | 0 |
| `medicamento` | 100 | `codigo_medicamento` | 0 |
| `cliente` | 100 | `codigo_cliente` | `apellido2`: 100; `telefono_alterno`: 100; `observaciones`: 100 |
| `venta` | 4.102 | `numero_venta` | `documento_cliente`: 100 NULL; `observacion`: 4.102 |
| `detalle_venta` | 12.306 | `numero_venta`, `linea` | 0 |
| `inventario` | 400 | `sucursal_origen`, `codigo_medicamento` | 0 |

## 2.2. Rangos de fechas

| Entidad | Campo | Fecha mínima | Fecha máxima |
|---|---|---|---|
| Cliente | `fecha_alta` | 2024-01-01 | 2026-11-26 |
| Venta | `fecha_hora` | 2025-01-01 09:07 | 2026-12-31 18:34 |
| Inventario | `fecha_ultima_entrada` | 2026-01-01 | 2026-12-25 |
| Inventario | `fecha_ultimo_movimiento` | 2026-01-04 | 2026-12-26 |

## 2.3. Integridad y duplicados

- No se detectaron claves primarias duplicadas en ninguna tabla.
- No existen detalles de venta sin cabecera de venta.
- No existen detalles asociados a medicamentos inexistentes.
- No existen medicamentos asociados a categorías o laboratorios inexistentes.
- Los 100 documentos de la tabla `cliente` tienen 10 dígitos y son únicos.

## 2.4. Calidad de ventas

### Documentos de cliente

- 100 ventas contienen `documento_cliente = NULL`.
- 108 ventas adicionales contienen una cadena vacía.
- Total de ventas sin documento utilizable: **208**.
- Los documentos no vacíos corresponden a clientes existentes en el maestro MySQL.

### Sucursales encontradas

Se detectaron 12 variantes textuales para cuatro sucursales corporativas:

| Valor de origen | Registros |
|---|---:|
| `NORTE` | 522 |
| `Sucursal Norte` | 248 |
| `FARMACIA NORTE` | 246 |
| `CENTRO` | 339 |
| `Farmacia Centro` | 373 |
| `FARMACIA CENTRO` | 327 |
| `SUR` | 361 |
| `Farmacia Sur` | 340 |
| `FARMACIA SUR` | 332 |
| `VALLE` | 332 |
| `Sucursal Valle` | 346 |
| `FARMACIA VALLE` | 336 |

**Acción ETL requerida:** mapear todas las variantes a los códigos `NORTE`, `CENTRO`, `SUR` y `VALLE`.

### Formas de pago

| Valor original | Registros |
|---|---:|
| `TARJETA` | 821 |
| `tarjeta` | 820 |
| `TRANSFERENCIA` | 821 |
| `Efectivo` | 820 |
| `EFECTIVO` | 820 |

**Acción ETL requerida:** convertir a mayúsculas y consolidar en `EFECTIVO`, `TARJETA` y `TRANSFERENCIA`.

### Estado de ventas

| Estado | Registros |
|---|---:|
| `COMPLETADA` | 4.025 |
| `ANULADA` | 77 |

Las ventas anuladas deben conservarse para trazabilidad, pero excluirse de las medidas comerciales netas cuando corresponda.

## 2.5. Calidad de medicamentos

- 100 medicamentos.
- 2 medicamentos inactivos.
- No existen costos menores o iguales a cero.
- No existen precios menores o iguales a cero.
- No se detectaron medicamentos cuyo costo sea mayor o igual al precio de venta.
- La integridad con categoría y laboratorio es completa.

## 2.6. Calidad de inventario

- 400 registros: 4 sucursales × 100 medicamentos.
- 12 registros tienen `stock_actual < stock_minimo`.
- No existen existencias negativas.
- No existen mínimos negativos.
- En 172 registros, `fecha_ultima_entrada` es posterior a `fecha_ultimo_movimiento`.

**Interpretación:** la última entrada debería constituir un movimiento. La regla temporal debe revisarse o el campo `fecha_ultimo_movimiento` debe actualizarse tomando la mayor fecha entre ambos campos.

## 2.7. Problemas detectados en MySQL

| Código | Problema | Registros afectados | Severidad | Tratamiento |
|---|---|---:|---|---|
| MY-01 | Ventas sin documento de cliente | 208 | Media | Asignar miembro “Consumidor final/Desconocido” |
| MY-02 | Variantes de nombres de sucursal | 4.102 | Alta | Aplicar tabla de homologación |
| MY-03 | Variantes de forma de pago | 1.640 requieren normalización de mayúsculas | Media | `TRIM` + `UPPER` |
| MY-04 | Fechas inconsistentes en inventario | 172 | Alta | Validar y corregir regla de fecha |
| MY-05 | Productos bajo mínimo | 12 | Informativa | Mantener como indicador de abastecimiento |
| MY-06 | Fechas posteriores al 11-07-2026 | Parte de clientes, ventas e inventario | Media | Marcar como datos simulados futuros |

---

# 3. Fuente PostgreSQL: sistema corporativo de gestión

## 3.1. Esquema y tablas

**Esquema definido:** `gestion`

| Tabla | Registros | Clave esperada | Nulos relevantes |
|---|---:|---|---|
| `zona` | 4 | `codigo_zona` | 0 |
| `sucursal` | 4 | `codigo_sucursal` | 0 |
| `segmento_cliente` | 4 | `codigo_segmento` | 0 |
| `cliente` | 100 | `documento` | `ciudad`: 16 |
| `meta_mensual` | 96 | `codigo_sucursal`, `periodo` | 0 |
| `encuesta_satisfaccion` | 1.460 | Identificador generado por la tabla | 0 |

## 3.2. Rangos de fechas

| Entidad | Campo | Fecha mínima | Fecha máxima |
|---|---|---|---|
| Sucursal | `fecha_apertura` | 2020-08-15 | 2024-04-20 |
| Cliente | `fecha_nacimiento` | 1968-01-27 | 2005-10-01 |
| Cliente | `fecha_registro` | 2024-01-01 | 2026-11-26 |
| Meta mensual | `periodo` | 2025-01-01 | 2026-12-01 |
| Encuesta | `fecha` | 2025-01-01 | 2026-12-31 |

## 3.3. Calidad de clientes

- 100 filas.
- 99 documentos únicos.
- Documento duplicado: **`1712345605`**.
- El documento duplicado pertenece a dos personas diferentes:
  - Carlos Torres.
  - Camila Almeida.
- Existe un documento de MySQL que no aparece como registro único en PostgreSQL: **`1712345666`**.
- 16 clientes tienen ciudad nula.
- Valores de ciudad:
  - `Quito`: 33.
  - `quito`: 17.
  - `Sangolquí`: 17.
  - `Cumbayá`: 17.
  - NULL: 16.
- 16 clientes poseen `fecha_registro` posterior al 11 de julio de 2026.

**Acciones ETL requeridas:**

1. Resolver el duplicado mediante revisión del registro correcto.
2. Normalizar ciudad con `TRIM` y formato título.
3. Asignar “No especificada” a ciudades nulas, conservando una bandera de calidad.
4. Etiquetar los registros futuros como datos simulados.

## 3.4. Calidad de sucursales, zonas y segmentos

- No existen códigos duplicados.
- Las cuatro sucursales tienen una zona válida.
- Los clientes utilizan segmentos existentes.
- No se detectaron claves foráneas huérfanas.

## 3.5. Calidad de metas

- 96 registros.
- Cobertura esperada completa:
  - 4 sucursales.
  - 24 meses.
  - Periodo de enero de 2025 a diciembre de 2026.
- No existen metas de ventas negativas o iguales a cero.
- No existen metas de clientes negativas o iguales a cero.
- No existen sucursales inexistentes en las metas.

## 3.6. Calidad de encuestas

- 1.460 encuestas.
- 3 puntuaciones se encuentran fuera del rango permitido de 1 a 5.
- No existen tiempos de espera negativos.
- Todas las sucursales existen.
- 28 encuestas hacen referencia a documentos que no aparecen en el maestro de clientes PostgreSQL.
- Distribución de comentarios prácticamente uniforme, con valores como:
  - `Faltó medicamento solicitado`: 184.
  - `Excelente servicio`: 183.
  - `Demasiada espera`: 183.
  - `Poca información al cliente`: 182.
  - `Local cómodo`: 182.
  - `Proceso ágil`: 182.
  - `Pocos productos disponibles`: 182.
  - `Atención rápida`: 182.

## 3.7. Problemas detectados en PostgreSQL

| Código | Problema | Registros afectados | Severidad | Tratamiento |
|---|---|---:|---|---|
| PG-01 | Documento duplicado asignado a personas diferentes | 2 filas | Crítica | Corregir antes de integrar clientes |
| PG-02 | Cliente de MySQL ausente en PostgreSQL | 1 documento | Media | Clasificar como “Solo MySQL” |
| PG-03 | Ciudad nula | 16 | Media | Asignar valor desconocido y bandera |
| PG-04 | Diferencia entre `Quito` y `quito` | 17 | Baja | Normalizar texto |
| PG-05 | Puntuaciones fuera de 1 a 5 | 3 | Alta | Rechazar o corregir mediante regla |
| PG-06 | Encuestas con cliente inexistente | 28 | Alta | Cargar cliente desconocido o enviar a rechazo |
| PG-07 | Registros futuros | 16 clientes y datos de 2026 posteriores al corte | Media | Etiquetar como simulados |

---

# 4. Fuente Excel: compras de medicamentos

## 4.1. Hojas y dimensiones

| Hoja | Filas de datos | Columnas | Nulos |
|---|---:|---:|---:|
| `Compras_2025_2026` | 874 | 29 | 0 |
| `Distribuidores` | 8 | 10 | 0 |
| `Medicamentos` | 100 | 11 | 0 |
| `Puntos_Entrega` | 4 | 6 | 0 |
| `Resumen_Mensual` | 24 | 10 | 24 celdas, correspondientes principalmente a la columna separadora |

## 4.2. Compras

### Rangos

| Campo | Mínimo | Máximo |
|---|---|---|
| `fecha_compra` | 2025-01-01 | 2026-12-31 |
| `fecha_vencimiento` | 2026-01-12 | 2028-04-03 |

### Claves y duplicados

- 0 identificadores `id_compra` duplicados.
- 0 órdenes de compra duplicadas.
- 0 facturas de distribuidor duplicadas.
- 0 lotes con fechas anteriores a la compra.
- 0 entregas estimadas anteriores a la fecha de compra.

### Integridad referencial

- 0 compras con distribuidor inexistente.
- 0 compras con medicamento inexistente.
- 0 compras con sucursal de entrega inexistente.

### Valores numéricos

- 0 cantidades menores o iguales a cero.
- 0 costos menores o iguales a cero.
- 0 descuentos fuera del rango 0 % a 100 %.
- 0 inconsistencias en el cálculo de:
  - subtotal bruto;
  - valor del descuento;
  - costo unitario con descuento;
  - valor neto.

### Estado de recepción

| Estado | Registros |
|---|---:|
| `RECIBIDO` | 860 |
| `PENDIENTE` | 14 |

Las 14 compras pendientes deben mantenerse para medir órdenes abiertas y cumplimiento de proveedores.

## 4.3. Distribuidores

- 8 distribuidores.
- Códigos únicos.
- Sin campos nulos.
- Sin duplicados de clave.
- Contienen datos suficientes para construir `dim_distribuidor`.

## 4.4. Medicamentos

- 100 medicamentos.
- Códigos únicos.
- Sin campos nulos.
- Coincidencia total con el maestro de medicamentos MySQL en:
  - código;
  - nombre;
  - categoría;
  - laboratorio;
  - presentación;
  - costo base;
  - precio de venta.

**Resultado:** MySQL puede mantenerse como fuente maestra y Excel como fuente de validación.

## 4.5. Puntos de entrega

- 4 puntos.
- Códigos únicos.
- Sin nulos.
- Coincidencia total con las sucursales PostgreSQL en:
  - código;
  - nombre;
  - zona;
  - ciudad;
  - dirección.

**Resultado:** PostgreSQL puede mantenerse como fuente maestra de sucursales.

## 4.6. Resumen mensual

La hoja contiene 24 periodos y dos bloques de resumen separados visualmente. Debido a la repetición de encabezados (`Año`, `Mes`, `Valor neto`) y a una columna vacía separadora, no debe utilizarse como fuente transaccional principal.

**Uso recomendado:** validación de totales mensuales calculados desde `Compras_2025_2026`.

## 4.7. Problemas detectados en Excel

| Código | Problema | Registros afectados | Severidad | Tratamiento |
|---|---|---:|---|---|
| XL-01 | Fechas representadas internamente como serial de Excel | 874 compras | Normal | Convertir a fecha durante ETL |
| XL-02 | Hoja `Resumen_Mensual` con encabezados repetidos | 24 filas | Baja | No cargar directamente; usar solo para control |
| XL-03 | Compras pendientes | 14 | Informativa | Mantener como estado analítico |
| XL-04 | Datos posteriores al 11-07-2026 | Parte del periodo 2026 | Media | Identificar como datos simulados futuros |

---

# 5. Comparación e integración entre fuentes

## 5.1. Medicamentos: MySQL frente a Excel

| Validación | Resultado |
|---|---|
| Códigos presentes en ambas fuentes | 100 |
| Solo en MySQL | 0 |
| Solo en Excel | 0 |
| Diferencias de nombre | 0 |
| Diferencias de categoría | 0 |
| Diferencias de laboratorio | 0 |
| Diferencias de presentación | 0 |
| Diferencias de costo | 0 |
| Diferencias de precio | 0 |

**Decisión:** usar MySQL como fuente maestra de `dim_medicamento`.

## 5.2. Sucursales: PostgreSQL frente a Excel

| Validación | Resultado |
|---|---|
| Códigos presentes en ambas fuentes | 4 |
| Solo en PostgreSQL | 0 |
| Solo en Excel | 0 |
| Diferencias de nombre | 0 |
| Diferencias de zona | 0 |
| Diferencias de ciudad | 0 |
| Diferencias de dirección | 0 |

**Decisión:** usar PostgreSQL como fuente maestra de `dim_sucursal`.

## 5.3. Clientes: MySQL frente a PostgreSQL

| Validación | Resultado |
|---|---:|
| Clientes MySQL | 100 |
| Filas de clientes PostgreSQL | 100 |
| Documentos únicos PostgreSQL | 99 |
| Documentos coincidentes | 99 |
| Solo en MySQL | 1 |
| Solo en PostgreSQL | 0 |
| Documento duplicado PostgreSQL | `1712345605` |
| Documento solo MySQL | `1712345666` |

**Decisión:** integrar por documento normalizado y crear estados:

- `Integrado`.
- `Solo MySQL`.
- `Solo PostgreSQL`.
- `Duplicado probable`.
- `Documento inválido`.
- `Consumidor final`.

## 5.4. Homologación propuesta para sucursales MySQL

| Valor MySQL | Código corporativo |
|---|---|
| `NORTE` | `NORTE` |
| `Sucursal Norte` | `NORTE` |
| `FARMACIA NORTE` | `NORTE` |
| `CENTRO` | `CENTRO` |
| `Farmacia Centro` | `CENTRO` |
| `FARMACIA CENTRO` | `CENTRO` |
| `SUR` | `SUR` |
| `Farmacia Sur` | `SUR` |
| `FARMACIA SUR` | `SUR` |
| `VALLE` | `VALLE` |
| `Sucursal Valle` | `VALLE` |
| `FARMACIA VALLE` | `VALLE` |

---

# 6. Reglas iniciales de limpieza y validación

## 6.1. Texto

```text
TRIM
UPPER o formato título según el atributo
eliminación de espacios dobles
normalización de tildes solo para comparación, no para presentación
```

## 6.2. Documentos

```text
eliminar espacios
eliminar guiones y caracteres no numéricos
validar longitud de 10 dígitos
identificar duplicados
asignar clave desconocida a ventas sin documento
```

## 6.3. Fechas

```text
convertir seriales de Excel a DATE
validar fecha_vencimiento >= fecha_compra
validar fecha_estimada_entrega >= fecha_compra
validar fecha_ultimo_movimiento >= fecha_ultima_entrada
marcar fechas posteriores a la fecha de corte como simuladas
```

## 6.4. Valores numéricos

```text
cantidad > 0
costo_unitario > 0
precio_venta > costo
0 <= descuento_pct <= 100
1 <= puntuacion_encuesta <= 5
tiempo_espera_minutos >= 0
stock_actual >= 0
stock_minimo >= 0
```

## 6.5. Integridad

```text
medicamento debe existir en maestro
sucursal debe existir en maestro
distribuidor debe existir en maestro
cliente debe existir o resolverse como desconocido
segmento y zona deben existir
```

---

# 7. Registros que deben enviarse a rechazo o revisión

| Origen | Regla | Cantidad |
|---|---|---:|
| PostgreSQL clientes | Documento duplicado con personas diferentes | 2 filas |
| PostgreSQL encuestas | Puntuación fuera de 1 a 5 | 3 |
| PostgreSQL encuestas | Cliente sin correspondencia | 28 |
| MySQL inventario | Fecha de entrada posterior al último movimiento | 172 |
| MySQL ventas | Documento NULL o vacío | 208; no se rechazan, se asignan a cliente desconocido |
| MySQL ventas | Estado `ANULADA` | 77; no se rechazan, se excluyen de ventas efectivas |
| Excel compras | Inconsistencias estructurales o aritméticas | 0 |

---

# 8. Evaluación general por fuente

| Fuente | Completitud | Unicidad | Integridad | Consistencia | Evaluación |
|---|---|---|---|---|---|
| MySQL | Alta | Alta | Alta | Media por sucursales, pagos y fechas de inventario | Apta con transformación |
| PostgreSQL | Media-alta | Media por duplicado de cliente | Media-alta | Media por ciudades y encuestas | Apta con depuración |
| Excel | Muy alta | Alta | Alta | Alta | Apta para carga |

---

# 9. Próximo paso recomendado

Después de aprobar este perfilamiento se debe:

1. crear los esquemas `stg`, `dw` y `audit`;
2. crear tablas de equivalencia para sucursales y formas de pago;
3. definir el miembro desconocido de cada dimensión;
4. implementar en Pentaho las extracciones hacia staging;
5. separar registros válidos, rechazados y sujetos a revisión;
6. cargar primero las dimensiones;
7. cargar después las tablas de hechos;
8. registrar métricas de calidad en `audit.etl_ejecucion`, `audit.etl_detalle` y `audit.etl_rechazo`.

---

# 10. Criterio de aceptación de la fase de perfilamiento

La fase se considera completa cuando:

- los conteos de cada fuente han sido verificados;
- las reglas de calidad han sido aprobadas;
- el duplicado de cliente está identificado;
- las 12 variantes de sucursal tienen equivalencia;
- las formas de pago están normalizadas;
- los registros de encuesta inválidos tienen tratamiento definido;
- las fechas futuras se reconocen como parte del conjunto simulado;
- el equipo acepta MySQL como maestro de medicamentos y PostgreSQL como maestro de sucursales.

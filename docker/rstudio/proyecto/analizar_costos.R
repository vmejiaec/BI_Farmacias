library(DBI)
library(RPostgres)

# 1. Conexión a PostgreSQL staging
conexion <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("DW_HOST"),
  port = as.integer(Sys.getenv("DW_PORT")),
  dbname = Sys.getenv("DW_DATABASE"),
  user = Sys.getenv("DW_USER"),
  password = Sys.getenv("DW_PASSWORD")
)

compras <- dbGetQuery(
  conexion,
  "
  SELECT fecha_compra, costo_unitario
  FROM stg.excel_compras
  WHERE codigo_medicamento = 'MED014'
  ORDER BY fecha_compra
  "
)

dbDisconnect(conexion)

compras$fecha_compra <- as.Date(compras$fecha_compra)

compras$tiempo <- as.numeric(
  compras$fecha_compra - min(compras$fecha_compra)
)

modelo <- lm(costo_unitario ~ tiempo, data = compras)

plot(compras$fecha_compra, compras$costo_unitario)

orden <- order(compras$fecha_compra)

lines(
  compras$fecha_compra[orden],
  predict(modelo)[orden],
  lwd = 2
)

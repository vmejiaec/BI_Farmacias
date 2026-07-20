import pandas as pd
import matplotlib.pyplot as plt

from sqlalchemy import create_engine
from sklearn.linear_model import LinearRegression


# 1. Conexión a PostgreSQL
conexion = create_engine(
    "postgresql+psycopg://victor:victor123@staging:5432/datawarehouse"
)


# 2. Consultar datos de compras
sql = """
SELECT fecha_compra, costo_unitario
FROM stg.excel_compras
WHERE codigo_medicamento='MED014'
ORDER BY fecha_compra
"""

compras = pd.read_sql(sql, conexion)


# 3. Preparar los datos
compras["fecha_compra"] = pd.to_datetime(compras["fecha_compra"])

compras["dias"] = (
    compras["fecha_compra"] - compras["fecha_compra"].min()
).dt.days


# 4. Variables del modelo
X = compras[["dias"]]
y = compras["costo_unitario"]


# 5. Crear y entrenar el modelo
modelo = LinearRegression()

modelo.fit(X, y)


# 6. Calcular predicciones
compras["costo_estimado"] = modelo.predict(X)


# 7. Mostrar resultados
print("Intercepto:", modelo.intercept_)
print("Pendiente:", modelo.coef_[0])


# 8. Graficar
plt.scatter(
    compras["fecha_compra"],
    compras["costo_unitario"],
    label="Costo real"
)

plt.plot(
    compras["fecha_compra"],
    compras["costo_estimado"],
    linewidth=2,
    label="Regresión"
)

plt.xlabel("Fecha de compra")
plt.ylabel("Costo unitario")
plt.title("Regresión del costo unitario")
plt.legend()

# Guardar el gráfico en un archivo
plt.savefig(
    "/app/resultados/regresion.png",
    dpi=150,
    bbox_inches="tight"
)

plt.close()

print("Gráfico guardado en resultados/regresion.png")
create or replace view ventas as
SELECT
    v.numero_venta,
    DATE(v.fecha_hora) AS fecha,
    YEAR(v.fecha_hora) AS anio,
    MONTH(v.fecha_hora) AS mes,
    v.sucursal_origen,
    TRIM(REPLACE(v.documento_cliente, '-', '')) AS documento_cliente_limpio,
    v.forma_pago,
    UPPER(v.estado) AS estado,
    d.codigo_medicamento,
    d.cantidad,
    d.precio_unitario,
    d.cantidad * d.precio_unitario AS subtotal,
    m.nombre AS medicamento,
    c.nombre AS categoria,
    l.nombre AS laboratorio
FROM venta v
JOIN detalle_venta d ON v.numero_venta = d.numero_venta
LEFT JOIN medicamento m ON d.codigo_medicamento = m.codigo_medicamento
LEFT JOIN categoria c ON m.codigo_categoria = c.codigo_categoria
LEFT JOIN laboratorio l ON m.codigo_laboratorio = l.codigo_laboratorio;
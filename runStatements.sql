-- [01] Producto más vendido por mes el 2021.
WITH VentasPorMes AS (
    SELECT
        EXTRACT(
            MONTH
            FROM
                v.fechaventa
        ) AS mes,
        p.nombreproducto AS nombreproducto,
        COUNT(*) AS cantidadvendida
    FROM
        venta v
        JOIN producto_venta pv ON v.idventa = pv.idventa
        JOIN producto p ON p.idproducto = pv.idproducto
    WHERE
        EXTRACT(
            YEAR
            FROM
                v.fechaventa
        ) = 2021
    GROUP BY
        mes,
        p.nombreproducto
)
SELECT
    mes,
    nombreproducto,
    cantidadvendida
FROM
    (
        SELECT
            mes,
            nombreproducto,
            cantidadvendida,
            RANK() OVER(
                PARTITION BY mes
                ORDER BY
                    cantidadvendida DESC
            ) AS ranking
        FROM
            VentasPorMes
    ) AS RankingProductoVentasPorMes
WHERE
    ranking = 1;

-- EXTRACT: Extrae un campo especifico (dia, mes, horas, minutos, etc) de un valor de fecha u hora
-- OVER [PARTITION BY | ORDER BY]: Distribuye las filas del conjunto de resultados en grupos 
-- RANK: Asigna un clasificacion a cada fila dentro de un partidicon de un conjunto de resultados
-- RANK VS ROW_NUMBER: La primera permite asignar el mismo rango a multiples filas
-- [02] Producto más económico por tienda.
SELECT
    PT.IdTienda,
    PT.IdProducto,
    PT.PrecioProducto
FROM
    Producto_Tienda PT
    INNER JOIN (
        SELECT
            IdTienda,
            MIN(PrecioProducto) AS PrecioMinimo
        FROM
            Producto_Tienda
        GROUP BY
            IdTienda
    ) AS MinPrecios ON PT.IdTienda = MinPrecios.IdTienda
    AND PT.PrecioProducto = MinPrecios.PrecioMinimo;

-- [03] Ventas por mes, separadas entre Boletas y Facturas.
SELECT
    EXTRACT(
        MONTH
        FROM
            v.FechaVenta
    ) AS Mes,
    CASE
        WHEN td.TipoDocumento = 1 THEN 'Boleta'
        WHEN td.TipoDocumento = 0 THEN 'Factura'
    END AS Tipo_Documento,
    COUNT(v.IdVenta) AS Total_Ventas
FROM
    Venta v
    INNER JOIN TipoDocumento td ON v.IdTipoDocumento = td.IdTipoDocumento
GROUP BY
    EXTRACT(
        MONTH
        FROM
            v.FechaVenta
    ),
    td.TipoDocumento;

-- [04] Empleado que ganó más por tienda en 2020, indicando la comuna donde vive y el cargo que tiene en la empresa.
-- [05] La tienda que tiene menos empleados.
--Incluye tiendas sin empleados
SELECT
    Tienda.NombreTienda,
    COUNT(Empleado.IdEmpleado) AS TotalEmpleados
FROM
    Tienda
    LEFT JOIN Empleado ON Tienda.idTienda = Empleado.IdTienda
GROUP BY
    Tienda.idTienda
ORDER BY
    TotalEmpleados ASC
LIMIT
    1;

--Solo son tiendas con por lo menos un empleado
SELECT
    Tienda.NombreTienda,
    COUNT(Empleado.IdEmpleado) AS TotalEmpleados
FROM
    Tienda,
    Empleado
WHERE
    Tienda.idTienda = Empleado.IdTienda
GROUP BY
    Tienda.idTienda
ORDER BY
    TotalEmpleados ASC
LIMIT
    1;

-- [06] El vendedor con más ventas por mes.
-- [07] El vendedor que ha recaudado más dinero para la tienda por año.
-- [08] El vendedor con más productos vendidos por tienda.
SELECT
    t.IdTienda,
    t.NombreTienda,
    e.IdEmpleado,
    CONCAT(e.NombreEmpleado, ' ', e.ApellidoPatEmpleado) AS NombreVendedor,
    SUM(pv.CantidadVendida) AS TotalProductosVendidos
FROM
    Venta v
    JOIN Tienda t ON v.IdTienda = t.IdTienda
    JOIN Venta_Vendedor vv ON v.IdVenta = vv.IdVenta
    JOIN Vendedor ven ON vv.IdVendedor = ven.IdVendedor
    JOIN Empleado e ON ven.IdEmpleado = e.IdEmpleado
    JOIN Producto_Venta pv ON v.IdVenta = pv.IdVenta
GROUP BY
    t.IdTienda,
    e.IdEmpleado
ORDER BY
    t.IdTienda,
    SUM(pv.CantidadVendida) DESC;

-- [09] El empleado con mayor sueldo por mes.
WITH SueldosPorMes AS (
    SELECT
        EXTRACT(
            YEAR
            FROM
                Sueldo.FechaPago
        ) AS año,
        EXTRACT(
            MONTH
            FROM
                Sueldo.FechaPago
        ) AS mes,
        Empleado.NombreEmpleado AS nombreempleado,
        Sueldo.MontoSueldo,
        RANK() OVER (
            PARTITION BY EXTRACT(
                YEAR
                FROM
                    Sueldo.FechaPago
            ),
            EXTRACT(
                MONTH
                FROM
                    Sueldo.FechaPago
            )
            ORDER BY
                Sueldo.MontoSueldo DESC
        ) AS ranking
    FROM
        Empleado
        JOIN Sueldo ON Empleado.IdEmpleado = Sueldo.IdEmpleado
)
SELECT
    año,
    mes,
    nombreempleado,
    MontoSueldo
FROM
    SueldosPorMes
WHERE
    ranking = 1;

-- [10] La tienda con menor recaudación por mes.
WITH RecaudacionPorMeses AS (
    SELECT
        t.nombretienda AS nombretienda,
        EXTRACT(
            YEAR
            FROM
                v.fechaventa
        ) AS ano,
        EXTRACT(
            MONTH
            FROM
                v.fechaventa
        ) AS mes,
        SUM(v.montoventa) AS cantidadrecaudada
    FROM
        tienda t
        LEFT JOIN venta v ON t.idtienda = v.idtienda
    GROUP BY
        t.nombretienda,
        ano,
        mes
)
SELECT
    nombretienda,
    ano,
    mes,
    cantidadrecaudada
FROM
    (
        SELECT
            nombretienda,
            ano,
            mes,
            cantidadrecaudada,
            RANK() OVER(
                PARTITION BY ano,
                mes
                ORDER BY
                    cantidadrecaudada
            ) AS ranking
        FROM
            RecaudacionPorMeses
    ) AS RankingRecaudacionPorMeses
WHERE
    ranking = 1;

-- Falta probar esta consulta
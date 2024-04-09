-- [01] Producto más vendido por mes el 2021.

WITH VentasPorMes AS (
    SELECT EXTRACT(MONTH FROM v.fechaventa) AS mes, p.nombreproducto AS nombreproducto, SUM(pv.cantidadvendida) AS cantidadvendida
    FROM venta v
    JOIN producto_venta pv ON v.idventa = pv.idventa
    JOIN producto p ON p.idproducto = pv.idproducto
    WHERE EXTRACT(YEAR FROM v.fechaventa) = 2021
    GROUP BY mes, p.nombreproducto
)
SELECT mes, nombreproducto, cantidadvendida
FROM (
    SELECT mes, nombreproducto, cantidadvendida, RANK() OVER(PARTITION BY mes ORDER BY cantidadvendida DESC) AS ranking
    FROM VentasPorMes
) AS RankingProductoVentasPorMes
WHERE ranking = 1;

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
        WHEN td.TipoDocumento = 1 THEN 'Factura'
        WHEN td.TipoDocumento = 0 THEN 'Boleta'
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

WITH SueldosPorEmpleado AS (
    SELECT 
        t.nombretienda AS tienda, 
        EXTRACT(MONTH FROM s.fechapago) AS mes, 
        e.nombreempleado AS nombreempleado, 
        s.montosueldo AS sueldo, 
        c.nombrecomuna AS comuna, 
        e.cargoempleado AS cargo, 
        RANK() OVER(PARTITION BY t.IdTienda, EXTRACT(MONTH FROM s.fechapago) ORDER BY s.MontoSueldo DESC) AS ranking
    FROM empleado e
        JOIN sueldo s ON e.idempleado = s.idempleado
        JOIN comuna c ON e.idcomuna = c.idcomuna
        JOIN tienda_empleado te ON e.idempleado = te.idempleado
        JOIN tienda t ON t.idtienda = te.idtienda
    WHERE EXTRACT(YEAR FROM s.fechapago) = 2020
)
SELECT tienda, mes, nombreempleado, sueldo, comuna, cargo
FROM SueldosPorEmpleado
WHERE ranking = 1;

-- [05] La tienda que tiene menos empleados.

-- Incluye tiendas sin empleados
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

-- Solo son tiendas con por lo menos un empleado
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

WITH VentasRankeadas AS (
    SELECT T.IdTienda, E.IdEmpleado, E.NombreEmpleado, E.ApellidoPatEmpleado, E.ApellidoMatEmpleado, EXTRACT(YEAR FROM V.FechaVenta) AS Año, EXTRACT(MONTH FROM V.FechaVenta) AS Mes, COUNT(V.IdVenta) AS NumeroDeVentas, RANK() OVER (PARTITION BY T.IdTienda,EXTRACT(YEAR FROM V.FechaVenta), EXTRACT(MONTH FROM V.FechaVenta) ORDER BY COUNT(V.IdVenta) DESC) AS Rango
    FROM Venta V
        JOIN Tienda T ON V.IdTienda = T.IdTienda
        JOIN Vendedor VE ON V.IdVendedor = VE.IdVendedor
        JOIN Empleado E ON VE.IdEmpleado = E.IdEmpleado
    GROUP BY T.IdTienda, E.IdEmpleado, EXTRACT(YEAR FROM V.FechaVenta), EXTRACT(MONTH FROM V.FechaVenta)
)
SELECT
    IdTienda,
    IdEmpleado,
    NombreEmpleado,
    ApellidoPatEmpleado,
    ApellidoMatEmpleado,
    Año,
    Mes,
    NumeroDeVentas,
    Rango
FROM
    VentasRankeadas
WHERE
    Rango = 1
ORDER BY
    IdTienda,
    Año,
    Mes,
    Rango;

-- [07] El vendedor que ha recaudado más dinero para la tienda por año.

SELECT
    T.IdTienda,
    T.NombreTienda,
    E.IdEmpleado,
    E.NombreEmpleado,
    E.ApellidoPatEmpleado,
    E.ApellidoMatEmpleado,
    EXTRACT(
        YEAR
        FROM
            V.FechaVenta
    ) AS Año,
    SUM(V.MontoVenta) AS TotalRecaudado
FROM
    Venta V
    JOIN Tienda T ON V.IdTienda = T.IdTienda
    JOIN Vendedor VE ON V.IdVendedor = VE.IdVendedor
    JOIN Empleado E ON VE.IdEmpleado = E.IdEmpleado
GROUP BY
    T.IdTienda,
    T.NombreTienda,
    E.IdEmpleado,
    E.NombreEmpleado,
    E.ApellidoPatEmpleado,
    E.ApellidoMatEmpleado,
    Año
ORDER BY
    t.IdTienda,
    Año,
    TotalRecaudado DESC;

-- [08] El vendedor con más productos vendidos por tienda.

SELECT
    V.IdTienda,
    VE.IdVendedor,
    E.NombreEmpleado,
    E.ApellidoPatEmpleado,
    E.ApellidoMatEmpleado,
    SUM(PV.CantidadVendida) AS TotalProductosVendidos
FROM
    Venta V
    JOIN Vendedor VE ON V.IdVendedor = VE.IdVendedor
    JOIN Empleado E ON VE.IdEmpleado = E.IdEmpleado
    JOIN Producto_Venta PV ON V.IdVenta = PV.IdVenta
GROUP BY
    V.IdTienda,
    VE.IdVendedor,
    E.NombreEmpleado,
    E.ApellidoPatEmpleado,
    E.ApellidoMatEmpleado
ORDER BY
    V.IdTienda,
    TotalProductosVendidos DESC;

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
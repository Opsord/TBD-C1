-- [01] Producto más vendido por mes el 2021.

WITH VentasPorMes AS (
    SELECT EXTRACT(MONTH FROM v.fechaventa) AS mes, p.nombreproducto AS nombreproducto, COUNT(*) AS cantidadvendida
    FROM venta v
    JOIN producto_venta pv ON v.idventa = pv.idventa
    JOIN productos p ON p.idproducto = pv.idproducto
    WHERE EXTRACT(YEAR FROM v.fechaventa) = 2021
    GROUP BY mes, p.nombreproducto
)
SELECT mes, nombreproducto, cantidadvendida
FROM (
    SELECT mes, nombreproducto, cantidadvendida, RANK() OVER(PARTITION BY mes ORDER BY cantidadvendida DESC) AS ranking
    FROM VentasPorMes
) AS RankingProductoVentasPorMes
WHERE ranking = 1;

-- EXTRACT: Extrae un campo especifico (dia, mes, horas, minutos, etc) de un valor de fecha u hora
-- OVER [PARTITION BY | ORDER BY]: Distribuye las filas del conjunto de resultados en grupos 
-- RANK: Asigna un clasificacion a cada fila dentro de un partidicon de un conjunto de resultados
-- RANK VS ROW_NUMBER: La primera permite asignar el mismo rango a multiples filas

-- [02] Producto más económico por tienda.

-- [03] Ventas por mes, separadas entre Boletas y Facturas.



-- [04] Empleado que ganó más por tienda en 2020, indicando la comuna donde vive y el cargo que tiene en la empresa.

-- [05] La tienda que tiene menos empleados.

--Incluye tiendas sin empleados

SELECT Tienda.NombreTienda, COUNT(Empleado.IdEmpleado) AS TotalEmpleados
FROM Tienda
LEFT JOIN Empleado ON Tienda.idTienda = Empleado.IdTienda
GROUP BY Tienda.idTienda
ORDER BY TotalEmpleados ASC
LIMIT 1;

--Solo son tiendas con por lo menos un empleado

SELECT Tienda.NombreTienda, COUNT(Empleado.IdEmpleado) AS TotalEmpleados
FROM Tienda, Empleado
WHERE Tienda.idTienda = Empleado.IdTienda
GROUP BY Tienda.idTienda
ORDER BY TotalEmpleados ASC
LIMIT 1;

-- [06] El vendedor con más ventas por mes.

-- [07] El vendedor que ha recaudado más dinero para la tienda por año.

-- [08] El vendedor con más productos vendidos por tienda.

-- [09] El empleado con mayor sueldo por mes.

WITH SueldosPorMes AS (
    SELECT EXTRACT(YEAR FROM Sueldo.FechaPago) AS año,
        EXTRACT(MONTH FROM Sueldo.FechaPago) AS mes,
        Empleado.NombreEmpleado AS nombreempleado, 
        Sueldo.MontoSueldo,
        RANK() OVER (PARTITION BY EXTRACT(YEAR FROM Sueldo.FechaPago), EXTRACT(MONTH FROM Sueldo.FechaPago) ORDER BY Sueldo.MontoSueldo DESC) AS ranking
    FROM Empleado 
    JOIN Sueldo ON Empleado.IdEmpleado = Sueldo.IdEmpleado
)
SELECT año, mes, nombreempleado, MontoSueldo
FROM SueldosPorMes
WHERE ranking = 1;

-- [10] La tienda con menor recaudación por mes.
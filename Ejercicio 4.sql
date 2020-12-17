/*
Ejercicio 4

Productos = (idProducto (PK), nombre, presentación, stock, stock mínimo, precioActual)
Empleados = (codigoEmp (PK), DNI, nombre, fn, dirección)
Clientes = (codigoCte (PK), DNI, nombre, dirección, telefono)
Ventas = (codVenta (PK), nroTicket, codigoEmp (FK), codigoCte (FK), fecha, montoTotal)
DetalleVentas = (codVenta (PK-FK), idProducto (PK-FK), cantidad, precioUnitario)
*/

/* 1. Reportar nombre, dirección y teléfono de clientes que compraron a todos los empleados que viven en su localidad. (Asumir dirección=localidad). */

SELECT nombre, dirección, telefono
FROM Clientes AS C
WHERE (NOT EXISTS (
	SELECT *
	FROM Empleados AS E
	WHERE (NOT EXISTS (
		SELECT *
		FROM Ventas AS V
		WHERE (V.codigoCte = C.codigoCte AND V.codigoEmp = C.codigoEmp AND E.dirección = C.dirección)))))

/* 2. Listar para cada empleado, la cantidad de ventas realizadas durante 2019. Reportar DNI, nombre, fn, dirección y cantidad de ventas. El listado debe estar ordenado por nombre y fn. */

SELECT DNI, nombre, fn, dirección, COUNT(*) AS cantVentas
FROM Empleados AS E
--INNER JOIN Ventas AS V ON (E.codigoEmp = V.codigoEmp) -- NO CUENTA EMPLEADOS QUE NO REALIZARON VENTAS (SIN IMPORTAR LA FECHA)
LEFT JOIN Ventas AS V ON (E.codigoEmp = V.codigoEmp)
WHERE (Year(V.fecha) = 2019)
GROUP BY DNI, nombre, fn, direccion, E.codigoEmp
ORDER BY nombre, fn

/* 3. Listar datos personales de los empleados que tengan ventas con más de 50 artículos diferentes. */

SELECT DNI, nombre, fn, dirección
FROM Empleados AS E
INNER JOIN Ventas AS V ON (E.codigoEmp = V.codigoEmp)
INNER JOIN DetalleVentas AS DV ON (V.codVenta = DV.codVenta)
GROUP BY DNI, nombre, fn, direccion, 
HAVING (COUNT(idProducto) > 50)

/* 4. Informar datos personales del mejor cliente. Aquel cuyo monto de ventas realizadas supera al resto de los clientes. */

-- NO USAR FUNCIONES DE AGREGACIÓN EN LA CLAÚSULA DEL WHERE
SELECT DNI, nombre, dirección, telefono
FROM Clientes AS C
INNER JOIN Ventas AS V ON (C.codigoCte = V.codigoCte)
GROUP BY DNI, nombre, dirección, telefono, C.codigoCte
HAVING (SUM(montoTotal) >= ALL ( -- EL MONTO TOTAL DEL CLIENTE ES MAYOR AL DE TODOS LOS DEMÁS? (SIN CONTARSE A SI MISMO)
	SELECT SUM(montoTotal)
	FROM Ventas AS V1
	GROUP BY V1.codigoCte))
-- OTRA OPCIÓN:
HAVING (SUM(montoTotal) = ( -- EL MONTO TOTAL DEL CLIENTE ES MAYOR AL DE TODOS LOS DEMÁS? (SIN CONTARSE A SI MISMO)
	SELECT MAX(SUM(montoTotal))
	FROM Ventas AS V1
	GROUP BY V1.codigoCte))

/* 5. Agregar una venta para el empleado Castelli Juan Manuel con nroTicket 1000 con la fecha y monto que desee para el cliente DNI 22369659. */

INSERT INTO Ventas (nroTicket, codigoEmp, codigoCte, fecha, montoTotal) 
VALUES 	(1000, 
		(SELECT codigoEmp FROM Empleado AS E WHERE (E.nombre = "Castelli Juan Manuel")), 
		(SELECT codigoCte FROM Cliente AS C WHERE (C.DNI = 22369659)),
		CURRENT_DATE,
		123456)

/* 6. Listar DNI, nombre, fn y dirección de empleados que realizaron ventas a todos los clientes.  */

SELECT DNI, nombre, fn, dirección
FROM Empleados AS E
WHERE (NOT EXISTS (
	SELECT *
	FROM Clientes AS C
	WHERE (NOT EXISTS (
		SELECT *
		FROM Ventas AS V
		WHERE (V.codigoCte = C.codigoCte AND V.codigoEmp = E.codigoEmp)))))

/* 7. Reportar información de ventas (nroTicket, empleado, cliente, fecha, montoTotal) que tengan monto total superior a 10000 y el cliente no sea de ´Tandil´. */

SELECT V.nroTicket, E.nombre, C.nombre, fecha, montoTotal
FROM Ventas AS V
INNER JOIN Clientes AS C ON (V.codigoCte = C.codigoCte)
INNER JOIN Empleados AS E ON (V.codigoEmp = E.codigoEmp)
WHERE (V.montoTotal > 10000 AND C.direccion <> "Tandil")

/* 8. Listar datos personales de clientes que realizaron compras en 2019 pero no realizaron compras durante 2020. */

/* VERSION <NOT EXISTS> */

SELECT DNI, nombre, direccion, telefono
FROM Clientes AS C
INNER JOIN Ventas AS V ON (V.codigoCte = C.codigoCte)
WHERE (Year(fecha) = 2019 AND NOT EXISTS (
	SELECT *
	FROM Ventas AS V1
	WHERE (V1.codigoCte = C.codigoCte AND Year(V1.fecha) = 2020)))
	
/* VERSION <NOT IN> */

SELECT DNI, nombre, direccion, telefono
FROM Clientes AS C
INNER JOIN Ventas AS V ON (V.codigoCte = C.codigoCte)
WHERE (Year(fecha) = 2019 AND codigoCte NOT IN (
	SELECT V1.codigoCte
	FROM Ventas AS V1
	WHERE (AND Year(V1.fecha) = 2020)))
	
/* VERSION EXCEPT */

(
SELECT DNI, nombre, direccion, telefono
FROM Clientes AS C
INNER JOIN Ventas AS V ON (V.codigoCte = C.codigoCte)
WHERE (Year(fecha) = 2019)
)
EXCEPT
(
SELECT DNI, nombre, direccion, telefono
FROM Clientes AS C
INNER JOIN Ventas AS V ON (V.codigoCte = C.codigoCte)
WHERE (Year(fecha) = 2020)
)

/* 9. Listar datos personales de empleados que participaron de ventas con algún producto con precioActual superior a 1000. */

SELECT DNI, nombre, fn, dirección
FROM Empleados AS E
INNER JOIN Ventas AS V ON (V.codigoEmp = E.codigoEmp)
INNER JOIN DetalleVentas AS DV ON (DV.codVenta = V.codVenta)
INNER JOIN Productos AS P ON (P.idProducto = DV.idProducto)
WHERE (precioActual > 1000)

/* 10. Listar los datos de los productos que no fueron vendidos durante 2020. */

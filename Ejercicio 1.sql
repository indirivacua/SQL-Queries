/*
Ejercicio 1

Cliente = (codCliente (PK), nombreYAp, DNI, telefono, direccion, sexo, edad)
Esteticista = (codEst (PK), nombre, apellido, DNI, fecha_nac, especialidad)
Producto = (codProd (PK), nombreP, descripcion, stock, precio)
ProductoAplicado = (nroAplicacion (PK), codProd (PK-FK), cantidad, precio) // precio del producto al momento de realizar la aplicación al cliente
Aplicacion = (nroAplicacion (PK), codEst (FK), codCliente (FK), costoTotal, fecha)
*/

/* 1. Listar datos personales de esteticistas que solo hayan atendido durante 2019, ordenar por nombre y apellidos y DNI ascendentemente. */

/* INCORRECTO */
/*
SELECT DISTINCT nombre, apellido, DNI, fecha_nac, especialidad
FROM Esteticista AS E, Aplicacion AS A
WHERE (E.codEst = A.codEst AND Year(A.fecha) = 2019 AND E.codEst NOT IN (
		SELECT E1.codEst
		FROM Esteticista AS E1
		WHERE (E1.codEst = A.codEst AND Year(A.fecha) <> 2019))) -- NO ES NECESARIO COMRPOBAR POR <E1.codEst = A.codEst> YA QUE <Aplicacion> YA TIENE <codEst>
ORDER BY nombre [ASC], apellido [ASC], DNI [ASC]
*/

/* VERSION <NOT IN> */
/* POR LO GENERAL EN EL <NOT IN> NO SE TIENE QUE HACER UN MACHEO EN LA SUBCONSULTA, O SEA, E.codEst = A1.codEst NO SERIA NECESARIO EN EL WHERE DE LA MISMA */

SELECT DISTINCT nombre, apellido, DNI, fecha_nac, especialidad
FROM Esteticista AS E, Aplicacion AS A
WHERE (E.codEst = A.codEst AND Year(A.fecha) = 2019 AND E.codEst NOT IN (
		SELECT A1.codEst
		FROM Aplicacion AS A1
		WHERE (Year(A1.fecha) <> 2019)))
ORDER BY nombre [ASC], apellido [ASC], DNI [ASC]

/* VERSION <INNER JOIN> & <NOT EXISTS> */
/* POR LO GENERAL EN EL <NOT EXISTS> SI SE TIENE QUE HACER UN MACHEO EN LA SUBCONSULTA, O SEA, E.codEst = A2.codEst SI ES NECESARIO EN EL WHERE DE LA MISMA */

SELECT DISTINCT nombre, apellido, DNI, fecha_nac, especialidad
FROM Esteticista AS E
INNER JOIN Aplicacion AS A ON (E.codEst = A.codEst)
WHERE (Year(A.fecha) = 2019 AND NOT EXISTS (
		SELECT *
		FROM Aplicacion AS A2
		WHERE (E.codEst = A2.codEst AND Year(A2.fecha) <> 2019)))
ORDER BY nombre [ASC], apellido [ASC], DNI [ASC]

/* 2. Listar promedio de edad de clientes tratados con productos que terminen con el String ‘ura’. */

SELECT AVG(edad) AS promedioEdad
FROM Cliente AS C, Aplicacion AS A, ProductoAplicado AS PA, Producto AS P
WHERE (C.codCliente = A.codCliente AND A.nroAplicacion = PA.nroAplicacion AND PA.codProd = P.codProd AND nombreP LIKE "%ura")

/* VERSION <INNER JOIN> */

SELECT AVG(edad) AS promedioEdad
FROM Cliente AS C
WHERE (EXISTS (
		SELECT *
		FROM Aplicacion AS A
		INNER JOIN ProductoAplicado AS PA ON (A.nroAplicacion = PA.nroAplicacion)
		INNER JOIN Producto AS P ON (PA.codProd = P.codProd)
		WHERE (C.codCliente = A.codCliente AND P.nombreP LIKE "%ura")))

/* 3. Listar para cada producto, la cantidad de aplicaciones en las que fue utilizado. Indicar nombre, descripción, stock, precio y cantidad de aplicaciones. Ordenar por cantidad de aplicaciones. */

SELECT nombreP, descripcion, stock, precio, COUNT(*) AS cantidad
FROM Producto AS P
--INNER JOIN ProductoAplicado AS PA ON (P.codProd = PA.codProd) -- NO CUENTA PRODUCTOS SIN APLICACIÓN
LEFT JOIN ProductoAplicado AS PA ON (P.codProd = PA.codProd) -- SI PODRUCTO NO MACHEA CON NINGUN PRODUCTO APLICADO <LEFT INNER> HACE QUE ESE PRODUCTO SE MUESTRE DE TODAS FORMAS -> PERMITE CONTAR PRODUCTOS SIN APLICACIÓN
GROUP BY nombreP, descripcion, stock, precio, P.codProd
-- ORDER BY cantidad -- NO SE PUEDE USAR UN ATRIBUTO RENOMBRADO PARA ORDENAR -> DOS OPCIONES (ELEGIR UNA):
ORDER BY * [ASC] -- ORDENO POR TODO
ORDER BY 5 [ASC] -- ORDENO POR NRO DE LA COLUMNA DE ESE ATRIBUTO

--OTRA FORMA: UNION -> EN LA SEGUNDA SUBCONSULTA SE FUERZA EL 0 YA QUE CORRESPONDE A LOS PRODUCTOS SIN APLICACIÓN
SELECT nombreP, COUNT(*) AS cantidad
FROM...
WHERE...
ORDER BY
UNION
SELECT nombreP, 0 AS cantidad
FROM...
WHERE...
ORDER BY

/* 4. Listar datos personales de esteticistas que no realizaron ninguna aplicación a clientes menores de 25 años. */

/* VERSION DIFERENCIA DE CONJUNTOS <EXCEPT> */

(
SELECT DISTINCT nombre, apellido, DNI, fecha_nac, especialidad
FROM Esteticista AS E
INNER JOIN Aplicacion AS A ON (E.codEst = A.codEst)
INNER JOIN Cliente AS C ON (A.codCliente = C.codCliente)
WHERE (C.edad > 25)
)
EXCEPT
(
SELECT DISTINCT nombre, apellido, DNI, fecha_nac, especialidad
FROM Esteticista AS E
INNER JOIN Aplicacion AS A ON (E.codEst = A.codEst)
INNER JOIN Cliente AS C ON (A.codCliente = C.codCliente)
WHERE (C.edad < 25)
)

/* VERSION NOT EXISTS */

-- SELECT DISTINCT nombre, apellido, DNI, fecha_nac, especialidad -- NO ES NECESARIO EL <DISTINCT> YA QUE EN LA CONSULTA PRINCIPAL SOLO USA UNA TABLA (POR LO QUE NO SE PUEDEN GENERAR REPETIDOS)
SELECT nombre, apellido, DNI, fecha_nac, especialidad
FROM Esteticista AS E
WHERE (NOT EXISTS (
		SELECT *
		FROM Aplicacion AS A
		INNER JOIN Cliente AS C ON (C.codCliente = A.codCliente)
		WHERE (A.codEst = E.codEst AND C.edad < 25)))

/* VERSION NOT IN */

SELECT nombre, apellido, DNI, fecha_nac, especialidad 
FROM Esteticista AS E
WHERE (E.codEst NOT IN (
		SELECT codEst
		FROM Aplicacion AS A
		INNER JOIN Cliente AS C ON (C.codCliente = A.codCliente)
		WHERE (C.edad < 25)))
		
/* 5. Actualizar el precio de los productos de nombre ‘tintura’ incrementando 20% su valor actual. */

UPDATE Producto
SET precio = precio * 1.20
WHERE (nombreP = "tintura")

/* 6. Listar datos personales de clientes que se realizaron alguna aplicación durante 2018 pero no se atendieron en 2019. */

SELECT DISTINCT nombreYAp, DNI, telefono, direccion, sexo, edad
FROM Cliente AS C
INNER JOIN Aplicacion AS A ON (C.codCliente = A.codCliente)
WHERE (Year(A.fecha) = 2018 AND NOT EXISTS (
		SELECT *
		FROM Aplicacion AS A2
		WHERE (A2.codCliente = C.codCliente AND Year(A2.fecha = 2019))))

/* 7. Reportar nombre, descripción, stock y precio de productos que se utilizaron en mujeres y que tengan alguna aplicación donde el precio al momento de la aplicación fue inferior a $500. */

SELECT DISTINCT nombre, descripcion, stock, precio
FROM Producto AS P
INNER JOIN ProductoAplicado AS PA ON (P.codProd = PA.codProd)
INNER JOIN Aplicacion AS A ON (PA.nroAplicacion = A.nroAplicacion)
INNER JOIN Cliente AS C ON (A.codCliente = C.codCliente)
WHERE (sexo = "mujer" AND precio = 500)

/* 8. Listar información de productos utilizados en las aplicaciones realizadas al cliente con DNI: 38329663. */

SELECT DISTINCT nombreP, descripcion, stock, precio
FROM Producto AS P
INNER JOIN ProductoAplicado AS PA ON (P.codProd = PA.codProd)
INNER JOIN Aplicacion AS A ON (PA.nroAplicacion = A.nroAplicacion)
INNER JOIN Cliente AS C ON (A.codCliente = C.codCliente)
WHERE (DNI = 383296663)

/* 9. Listar datos de productos utilizados por todos los esteticistas. */

/* % EQUIVALE A DOS NOT EXISTS (PAG. 348 LIBRO BERTONE) */
/*ALGORITMO:

"Listar datos de TABLA_1 utilizados por todos los TABLA_2."

CASO 1:

VER LIBRO.

CASO 2:

-- CASO GENERAL
SELECT attr_1, ..., attr_n
FROM TABLA_1 AS T1
WHERE (NOT EXISTS (	SELECT *
					FROM TABLA_2 AS T2
					WHERE NOT EXISTS (	SELECT *
										FROM ...  -- CONSEGUIR NUEVAMENTE IDENTIFICADORES DE T1 y T2 MEDIANTE CRUCES CON OTRAS TABLAS (USAR <INNER JOIN>)
										WHERE (T1.id_t1 = ?.id_t1 AND T2.id_t2 = ?.id_t2)
									 )
				 )
	  )

 */

SELECT nombreP, descripcion, stock, precio
FROM Producto AS P
WHERE NOT EXISTS (
	SELECT *
	FROM Esteticista AS E
	WHERE NOT EXISTS (
			SELECT *
			FROM ProductoAplicado AS PA
			INNER JOIN Aplicacion AS A ON (PA.nroAplicacion = A.nroAplicacion)
			WHERE (P.codProd = PA.codProd AND E.codEst = A.codEst)))

/* 10. Listar el/los cliente que gastaron más el peluquería (suma de costo total de sus aplicaciones). */

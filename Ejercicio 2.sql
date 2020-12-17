/*
Ejercicio 2

Vuelo = (codVuelo (PK), fecha, hora, cod_ciudad_origen (FK), cod_ciudad_destino (FK), cantidad_pasajes, codAerolinea (FK))
Pasaje = (codReserva (PK), asiento, codVuelo (FK), codCliente (FK), precio)
Aerolinea = (codAerolinea (PK), nombre, origen)
Cliente = (codCliente (PK), nombre, apellido, pasaporte, nacionalidad)
Ciudad = (codCiudad (PK), nombre, pais) // país string con el nombre del país correspondiente
*/

/* 1. Listar datos personales de clientes que viajaron con todas las aerolíneas. */

SELECT nombre, aplellido, pasaporte, nacionalidad
FROM Cliente AS C
WHERE (NOT EXISTS (	SELECT *
					FROM Aerolinea AS A
					WHERE NOT EXISTS (	SELECT *
										FROM Pasaje AS P
										INNER JOIN Vuelo AS V (V.codVuelo = P.codVuelo)
										WHERE (C.codCliente = P.codCliente AND A.codAerolinea = V.codAerolinea)
									 )
				 )
	  )

/*2. Reportar para cada cliente, la cantidad de vuelos realizados con destino buenos aires. Se debe informar datos personales del cliente y cantidad de vuelos. */

SELECT nombre, apellido, pasaporte, nacionalidad, COUNT(*) AS cantVuelosBSAS
FROM Cliente AS C
INNER JOIN Pasaje AS P ON (C.codCliente = P.codCliente)
INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
WHERE (V.cod_ciudad_destino = "BSAS")
GROUP BY nombre, apellido, pasaporte, nacionalidad, codCliente

/* 3. Listar información de vuelos sobrevendidos, vendió más pasajes que los disponibles para el vuelo. Indicar codVuelo, fecha, hora, ciudad desde donde sale el vuelo y la ciudad donde llega. */

SELECT DISTINCT codVuelo, fecha, hora, cod_ciudad_origen, cod_ciudad_destino
FROM Vuelo AS V
INNER JOIN Pasaje AS P ON (V.codVuelo = P.codVuelo)
GROUP BY codVuelo, fecha, hora, cod_ciudad_origen, cod_ciudad_destino
HAVING COUNT(*) > cantidad_pasajes

/* 4. Listar datos personales de clientes que solo hayan viajado durante 2018. Ordenar por apellido y nombre. */

/* VERSION <EXCEPT> */

(
SELECT DISTINCT nombre, apellido, pasaporte, nacionalidad
FROM Cliente AS C
INNER JOIN Pasaje AS P ON (C.codCliente = P.codCliente)
INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
WHERE (Year(fecha) = 2018)
)
EXCEPT
(
SELECT DISTINCT nombre, apellido, pasaporte, nacionalidad
FROM Cliente AS C
INNER JOIN Pasaje AS P ON (C.codCliente = P.codCliente)
INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
WHERE (Year(fecha) <> 2018)
)

/* VERSION <NOT EXISTS> */

SELECT DISTINCT nombre, apellido, pasaporte, nacionalidad
FROM Cliente AS C
INNER JOIN Pasaje AS P ON (C.codCliente = P.codCliente)
INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
WHERE (Year(fecha) = 2018 AND NOT EXISTS (
	SELECT *
	FROM Pasaje AS P1
	INNER JOIN Vuelo AS V1 ON (P1.codVuelo = V1.codVuelo)
	WHERE (C.codCliente = P1.codCliente AND Year(fecha) <> 2018))
ORDER BY apellido, nombre

/* VERSION <NOT IN> */

SELECT DISTINCT nombre, apellido, pasaporte, nacionalidad
FROM Cliente AS C
INNER JOIN Pasaje AS P ON (C.codCliente = P.codCliente)
INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
WHERE (Year(fecha) = 2018 AND codCliente NOT IN (
	SELECT codCliente
	FROM Pasaje AS P1
	INNER JOIN Vuelo AS V1 ON (P1.codVuelo = V1.codVuelo)
	WHERE (Year(fecha) <> 2018))

/* 5. Listar para cada ciudad la cantidad de pasajeros que llegaron durante 2018. Indicar nombre, país y cantidad de pasajeros. */

SELECT nombre, pais, SUM(cantidad_pasajes) AS cantPasajeros
FROM Ciudad AS C
INNER JOIN Vuelo AS V ON (C.codCiudad = V.cod_ciudad_destino)
WHERE (Year(fecha) = 2018)
GROUP BY nombre, pais, codCiudad
--HAVING (Year(fecha) = 2018)

codCiudad (PK), nombre, pais, codVuelo (PK), fecha, hora, cod_ciudad_origen (FK), cod_ciudad_destino (FK), cantidad_pasajes, codAerolinea (FK))
1								1			2018																	5
1								2			2018																	6
1								4			2000																	20
2								3			2018																	15

11
15

/* 6. Borrar el vuelo con código de vuelo LOM3524. */

DELETE FROM Pasaje WHERE (codVuelo = "LOM3524")
DELETE FROM Vuelo WHERE (codVuelo = "LOM3524")

/* 7. Listar datos personales de cliente que realizaron viajes con destino ‘Cancún’ durante 2018, pero no volaron durante 2019. */

/* VERSION <EXCEPT> */

(
SELECT DISTINCT C.nombre, C.apellido, C.pasaporte, C.nacionalidad
FROM Cliente AS C
INNER JOIN Pasaje AS P ON (C.codCliente = P.codCliente)
INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
INNER JOIN Ciudad AS CiD ON (V.cod_ciudad_destino = CiD.codCiudad)
WHERE (CiD.nombre = "Cancún" AND Year(fecha) = 2018)
)
EXCEPT
(
SELECT DISTINCT nombre, apellido, pasaporte, nacionalidad
FROM Cliente AS C
INNER JOIN Pasaje AS P ON (C.codCliente = P.codCliente)
INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
WHERE (Year(fecha) = 2019)
)

/* VERSION <NOT EXISTS> */

SELECT DISTINCT nombre, apellido, pasaporte, nacionalidad
FROM Cliente AS C
INNER JOIN Pasaje AS P ON (C.codCliente = P.codCliente)
INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
WHERE (cod_ciudad_destino = "Cancún" AND Year(fecha) = 2018 AND NOT EXISTS (
	SELECT *
	FROM Pasaje AS P1
	INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
	WHERE (C.codCliente = P.codCliente AND Year(fecha) <> 2018))

/* VERSION <NOT IN> */

SELECT DISTINCT nombre, apellido, pasaporte, nacionalidad
FROM Cliente AS C
INNER JOIN Pasaje AS P ON (C.codCliente = P.codCliente)
INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
WHERE (cod_ciudad_destino = "Cancún" AND Year(fecha) = 2018 AND codCliente NOT IN (
	SELECT codCliente
	FROM Pasaje AS P1
	INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
	WHERE (Year(fecha) <> 2018))

/* 8. Reportar información de vuelos con destino ‘Buenos Aires’ o que tengan pasajeros con nacionalidad ucraniana. */

SELECT DISTINCT V.fecha, V.hora, CiO.nombre, V.cantidad_pasajes, A.nombre, A.origen
FROM Vuelo AS V
INNER JOIN Pasaje AS P ON (V.codVuelo = P.codVuelo)
INNER JOIN Cliente AS C ON (P.codCliente = C.codCliente)
INNER JOIN Ciudad AS CiO ON (V.cod_ciudad_origen = CiO.codCiudad)
INNER JOIN Ciudad AS CiD ON (V.cod_ciudad_destino = CiD.codCiudad)
WHERE (CiD.nombre = "Buenos Aires" OR C.nacionalidad = "Ucraniane")

/* 9. Listar datos personales de clientes que volaron con destino ‘Salta’ y también realizaron vuelos con destino ‘Jujuy’. */

(
SELECT DISTINCT nombre, apellido, pasaporte, nacionalidad
FROM Clientes AS C
INNER JOIN Pasaje AS P ON (C.codCliente = P.codCliente)
INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
INNER JOIN Ciudad AS CiD ON (V.cod_ciudad_destino = CiD.codCiudad)
WHERE (CiD.nombre = "Salta")
)
INTERSECT
(
SELECT DISTINCT nombre, apellido, pasaporte, nacionalidad
FROM Clientes AS C
INNER JOIN Pasaje AS P ON (C.codCliente = P.codCliente)
INNER JOIN Vuelo AS V ON (P.codVuelo = V.codVuelo)
INNER JOIN Ciudad AS CiD ON (V.cod_ciudad_destino = CiD.codCiudad)
WHERE (CiD.nombre = "Jujuy")
)

/* 10. Listar información de aerolíneas que solo tengan vuelos con destino ‘Argentina’. Informar nombre y origen. */

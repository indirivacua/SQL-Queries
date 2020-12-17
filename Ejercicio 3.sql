/*
Ejercicio 3

Cine = (#codC (PK), nombreC, direccion)
Sala = (#codS (PK), nombreS, descripción, capacidad, #codC (PK))
Película = (#codP (PK), nombre, descripción, genero)
Funcion = (#codF (PK), #codS (PK), #codP (PK), fecha, hora, ocupación) //ocupación indica # de espectadores de la función
*/

/* 1. Reportar información de películas exhibidas en cines de ‘Avellanada’ y que posean funciones en cines de ‘La Plata’. */

SELECT DISTINCT nombre, descripción, genero
FROM Película AS P
INNER JOIN Funcion AS F ON (P.codP = F.codP)
INNER JOIN Sala AS S ON (F.codS = S.codS)
INNER JOIN Cine AS C ON (S.codC = C.codC)
WHERE (direccion = "Avellaneda" AND EXISTS (
	SELECT *
	FROM Funcion AS F1
	INNER JOIN Sala AS S ON (F.codS = S.codS)
	INNER JOIN Cine AS C ON (S.codC = C.codC)
	WHERE (P.codP = F1.codP AND direccion = "La Plata")))

/* 2. Reportar todas las películas que fueron exhibidas en funciones con menos de 30 espectadores. Ordenar por nombre de película. */

SELECT DISTINCT nombre, descripcion, genero
FROM Película AS P
INNER JOIN Funcion AS F ON (P.codP = F.codP)
WHERE (ocupacion < 30)
ORDER BY nombre

/* 3. Listar nombre y dirección de los cines que exhiban todas las películas. */

SELECT nombreC, direccion
FROM Cine AS C
WHERE (NOT EXISTS (
	SELECT *
	FROM Película AS P
	WHERE (NOT EXISTS (
		SELECT *
		FROM Funcion AS F
		INNER JOIN Sala AS S ON (F.codS = S.codS)
		WHERE (S.codC = C.codC AND F.codP = P.codP)))))

/* 4. Modificar el nombre a: ‘Sala Darin’, de la sala con código 1000. */

UPDATE Cine SET nombreS = "Sala Darin" WHERE codS = 1000

/* 5. Listar nombre y dirección de cines donde se exhiba la película: ‘007 Bond: Sin tiempo para morir’ o que tengan funciones con ocupación durante 2020. */

SELECT C.nombre, C.direccion
FROM Cine AS C
INNER JOIN Sala AS S ON (C.codC = S.codC)
INNER JOIN Funcion AS F ON (S.codS = F.codS)
INNER JOIN Película AS P ON (F.codP = P.codP)
WHERE (P.nombre = "007 Bond: Sin tiempo para morir" OR (Year(F.fecha) = 2020 AND F.ocupacion > 0))

/* 6. Reportar nombre, descripción y género de películas exhibidas en el Cine: ´Cine XXX´ pero que no tengan programadas funciones en dicho cine para el dia de hoy. */

SELECT nombre, descripción, género
FROM Película AS P
INNER JOIN Funcion AS F ON (P.codP = F.codP) -- Funciones de esas Películas
INNER JOIN Sala AS S ON (F.codS = S.codS) -- Salas donde se dan las Funciones de esas Películas
INNER JOIN Cine AS C ON (S.codC = C.codC) -- Cine donde se encuentran las Salas donde se dan las Funciones de esas Películas
WHERE (C.nombreC = "Cine XXX" AND F.fecha <> CURRENT_DATE)

/* 7. Reportar para cada cine la cantidad de espectadores por película durante 2020. Indicar nombre del cine, nombre de la película y cantidad de espectadores. Ordenar por cine y luego por película. */

SELECT C.nombreC, P.nombre, SUM(F.ocupacion) AS cantEspect
FROM Pelicula AS P
INNER JOIN Funcion AS F ON (P.codP = F.codP)
INNER JOIN Sala AS S ON (F.codS = S.codS)
INNER JOIN Cine AS C ON (S.codC = C.codC)
WHERE (Year(fecha) = 2020)
GROUP BY C.nombreC, P.nombre, C.codC, P.codP
ORDER BY C.nombreC, P.nombre

/* 8. Borrar el cine con nombre ‘Cine China Zorrilla’. */

DELETE FROM Funcion WHERE codS IN (
	SELECT codS
	FROM Sala AS S
	INNER JOIN Cine AS C (S.codC = C.codC)
	WHERE (nombreC = "Cine China Zorrilla"))

DELETE FROM Sala WHERE codC IN (
	SELECT codC
	FROM Cine AS C
	WHERE (nombreC = "Cine China Zorrilla"))

DELETE FROM Cine WHERE (nombre = "Cine China Zorrilla")

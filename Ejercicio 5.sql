/*
Ejercicio 5

Persona = (DNI (PK), Apellido, Nombre, Fecha_Nacimiento, Estado_Civil, Genero)
Alumno = (DNI (PK-FK), Legajo, Año_Ingreso)
Profesor = (DNI (PK-FK), Matricula, Nro_Expediente)
Titulo = (Cod_Titulo (PK), Nombre, Descripción)
Titulo-Profesor = (Cod_Titulo (PK-FK), DNI (PK-FK), Fecha)
Curso = (Cod_Curso (PK), Nombre, Descripción, Fecha_Creacion, Cantidad_Horas)
Alumno-Curso = (DNI (PK-FK), Cod_Curso (PK-FK), Año (PK), Desempeño, Calificación)
Profesor-Curso = (DNI (PK-FK), Cod_Curso (PK-FK), Fecha_Desde (PK), Fecha_Hasta)
*/

/* 1. Listar nombre, descripción y fecha de creación de los cursos que se encuentra inscripto el alumno con legajo 1089. Ordenar por nombre y fecha de creación descendentemente. */

SELECT Nombre, Descripción, Fecha_Creacion
FROM Curso AS C
INNER JOIN Alumno-Curso AS AC ON (C.Cod_Curso = AC.Cod_Curso)
INNER JOIN Alumno AS A ON (AC.DNI = A.DNI)
WHERE (A.Legajo = 1089)
ORDER BY Nombre DESC, Fecha_Creacion DESC

/* 2. Agregar un profesor con los datos que prefiera y con título ‘Licenciado en Sistemas’. */

INSERT INTO Persona (DNI, Apellido, Nombre, Fecha_Nacimiento, Estado_Civil, Genero) 
VALUE (123456789, Ramirez, Pedro, 1/1/1950, "Casado", "Hombre")

INSERT INTO Alumno (DNI (PK-FK), Matricula, Nro_Expediente) 
VALUE (123456789, 1, 1)

INSERT INTO Titulo-Profesor (Cod_Titulo (PK-FK), DNI (PK-FK), Fecha)
VALUES (SELECT Cod_Titulo FROM Titulo AS T WHERE (T.Nombre = "Licenciado en Sistemas"), 123456789, Date.Today)

/* 3. Listar el DNI, apellido, nombre y matrícula de aquellos profesores que posean menos de 5 títulos. Dicho listado deberá estar ordenado por apellido y nombre. */

SELECT DNI, apellido, nombre, matricula
FROM Profesor AS P
--INNER JOIN Titulo-Profesor AS TP ON (P.DNI = TP.DNI) -- NO CONTEMPLA NULOS
LEFT JOIN Titulo-Profesor AS TP ON (P.DNI = TP.DNI)
INNER JOIN Persona AS PP ON (P.DNI = PP.DNI)
GROUP BY Apellido, Nombre, Matricula, P.DNI
HAVING (COUNT(*) < 5)
ORDER BY Apellido, Nombre

/* 4. Listar el DNI, apellido, nombre y cantidad de horas que dicta cada profesor. */

SELECT DNI, Apellido, Nombre, SUM(Cantidad_Horas)
FROM Profesor AS P
INNER JOIN Profesor-Curso AS PC ON (P.DNI = PC.DNI)
INNER JOIN Persona AS PP ON (P.DNI = PP.DNI)
GROUP BY Apellido, Nombre, P.DNI

/* 5. Listar nombre,descripción del curso que posea más alumnos inscriptos y del que posea menos alumnos inscriptos durante 2016. */

SELECT Nombre, Descripción
FROM Curso AS C
INNER JOIN Alumno-Curso AS AC ON (C.Cod_Curso = AC.Cod_Curso)
WHERE (AC.Año = 2016)
GROUP BY Nombre, Descripción, C.Cod_Curso
HAVING (COUNT(*) >= ALL ( -- MAYOR O IGUAL POR SI HAY MÁS DE UN MÁXIMO
	SELECT COUNT(*) AS cantAlumnos
	FROM Alumno-Curso AS AC1
	WHERE (AC.Año = 2016)
	GROUP BY AC1.Cod_Curso)
	
	OR
	
	COUNT(*) <= ALL (
	SELECT COUNT(*) AS cantAlumnos
	FROM Alumno-Curso AS AC1
	WHERE (AC.Año = 2016)
	GROUP BY AC1.Cod_Curso))

/* 6. Listar el DNI, apellido, nombre, género y fecha de nacimiento de los alumnos inscriptos al curso con nombre “tuning de oracle” en 2019 y que no tengan calificación superior a 5 en ningún curso. */

/* 7. Listar el DNI, Apellido, Nombre, Legajo de alumnos que realizaron cursos durante 2018 pero no cursaron durante 2019. */

/* 8. Listar nombre, apellido, DNI, fecha de nacimiento, estado civil y género de profesores que tengan cursos activos actualmente o tengan de alumno al alumno DNI:34567487. */

/* 9. Dar de baja el alumno con DNI 38746662. Realizar todas las bajas necesarias para no dejar el conjunto de relaciones en estado inconsistente. */

/* 10. Listar para cada curso nombre y la cantidad de alumnos inscriptos en 2020. */

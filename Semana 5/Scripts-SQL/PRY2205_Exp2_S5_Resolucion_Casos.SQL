-- Semana 5 : SubConsultas

-- Caso 1 : Lista de Clientes dependientes (contador o vendedor) inscritos posterior al promedio de años de inscripcion de todos los clientes
SELECT TO_CHAR(c.numrun, 'FM99G999G999') || '-' || c.dvrun AS "RUT Cliente",
       INITCAP(c.pnombre) || ' ' || INITCAP(c.appaterno) AS "Nombre Cliente",
       UPPER(p.nombre_prof_ofic) AS "Profesión Cliente",
       TO_CHAR(c.fecha_inscripcion, 'DD/MM/YYYY') AS "Fecha de Inscripción",
       c.direccion AS "Dirección Cliente"
FROM cliente c
JOIN profesion_oficio p ON c.cod_prof_ofic = p.cod_prof_ofic
JOIN tipo_cliente t ON c.cod_tipo_cliente = t.cod_tipo_cliente
WHERE UPPER(t.nombre_tipo_cliente) = 'TRABAJADORES DEPENDIENTES'
AND c.cod_prof_ofic IN (13, 18)
AND EXTRACT(YEAR FROM c.fecha_inscripcion) >
    (SELECT ROUND(AVG(EXTRACT(YEAR FROM fecha_inscripcion)))
     FROM cliente)
ORDER BY c.numrun ASC;

-- Caso 2 : Crea una tabla con los cleintes cuyo cupo de compra es igual o mayor al maximo cupo disponible de las tarjetas
CREATE TABLE clientes_cupos_compra AS
SELECT TO_CHAR(c.numrun, 'FM99999999') || '-' || c.dvrun AS rut_cliente,
       TRUNC(MONTHS_BETWEEN(SYSDATE, c.fecha_nacimiento) / 12) AS edad,
       TO_CHAR(tc.cupo_disp_compra, '$9G999G999G999') AS cupo_disponible_compra,
       UPPER(t.nombre_tipo_cliente) AS tipo_cliente
FROM cliente c
JOIN tarjeta_cliente tc ON tc.numrun = c.numrun
JOIN tipo_cliente t ON t.cod_tipo_cliente = c.cod_tipo_cliente
WHERE tc.cupo_disp_compra >=
      (SELECT MAX(cupo_disp_compra)
       FROM tarjeta_cliente
       WHERE EXTRACT(YEAR FROM fecha_solic_tarjeta) = EXTRACT(YEAR FROM SYSDATE) - 1)
ORDER BY edad ASC;
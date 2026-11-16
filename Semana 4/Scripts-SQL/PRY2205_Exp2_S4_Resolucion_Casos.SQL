

-- Caso 1 : Listado de Trabajadores.
-- Listar a los trabajadores que posean un sueldo base entre $650.000 y 3.000.000 ordenado por ciudad y sueldo 

SELECT UPPER(t.nombre || ' ' || t.appaterno || ' ' || t.apmaterno) AS "Nombre Completo Trabajador",
       TO_CHAR(t.numrut, 'FM99G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') || '-' || t.dvrut AS "RUT Trabajador",
       tt.desc_categoria AS "Tipo Trabajador",
       cc.nombre_ciudad AS "Ciudad Trabajador",
       TO_CHAR(t.sueldo_base, 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Sueldo Base"
 FROM trabajador t
      JOIN tipo_trabajador tt ON t.id_categoria_t = tt.id_categoria
      JOIN comuna_ciudad cc ON t.id_ciudad = cc.id_ciudad
 WHERE t.sueldo_base BETWEEN 650000 AND 3000000
 ORDER BY cc.nombre_ciudad DESC, t.sueldo_base ASC;


-- Caso 2 : Listado de Cajeros.
-- Con la finalidad de tener una bitacora por trabajador que haya vendido tickets
-- Solo se listaran los trabajadores con rol de CAJERO cuyas ventas sumadas pasan de $50.000

SELECT TO_CHAR(t.numrut, 'FM99G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') || '-' || t.dvrut AS "RUT Trabajador",
       INITCAP(t.nombre) || ' ' || UPPER(t.appaterno) AS "Nombre Trabajador",
       COUNT(tc.nro_ticket) AS "Total Tickets",
       TO_CHAR(SUM(tc.monto_ticket), 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Total Vendido",
       TO_CHAR(SUM(NVL(ct.valor_comision, 0)), 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Comisión Total",
       tt.desc_categoria AS "Tipo Trabajador",
       cc.nombre_ciudad AS "Ciudad Trabajador"
 FROM trabajador t
      JOIN tickets_concierto tc ON t.numrut = tc.numrut_t
      LEFT JOIN comisiones_ticket ct ON tc.nro_ticket = ct.nro_ticket
      JOIN tipo_trabajador tt ON t.id_categoria_t = tt.id_categoria
      JOIN comuna_ciudad cc ON t.id_ciudad = cc.id_ciudad
 WHERE UPPER(tt.desc_categoria) = 'CAJERO'
 GROUP BY t.numrut, t.dvrut, t.nombre, t.appaterno, tt.desc_categoria, cc.nombre_ciudad
 HAVING SUM(tc.monto_ticket) > 50000
 ORDER BY SUM(tc.monto_ticket) DESC;


-- Caso 3 : Listado de Bonificaciones.
-- Es necesario saber el año de ingreso de cada trabajador para saber su antigüedad.
-- determinar si es asignable para una bonificacion por año de servicio
-- Excluyente: Fecha de termino de estado civil 

SELECT TO_CHAR(t.numrut, 'FM99G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "RUT Trabajador",
       INITCAP(t.nombre) || ' ' || INITCAP(t.appaterno) AS "Trabajador Nombre",
       EXTRACT(YEAR FROM t.fecing) AS "Año Ingreso",
       TRUNC(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12) AS "Años Antigüedad",
       COUNT(af.numrut_carga) AS "Num. Cargas Familiares",
       INITCAP(i.nombre_isapre) AS "Nombre Isapre",
       TO_CHAR(t.sueldo_base, 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Sueldo Base",
       CASE
            WHEN UPPER(i.nombre_isapre) = 'FONASA'
            THEN TO_CHAR(ROUND(t.sueldo_base * 0.01), 'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''')
            ELSE '0'
       END AS "Bono Fonasa",
       TO_CHAR(ROUND(t.sueldo_base * CASE
                                         WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12) <= 10 THEN 0.10
                                         ELSE 0.15
                                     END),
               'FM$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Bono Antigüedad",
       INITCAP(a.nombre_afp) AS "Nombre AFP",
       UPPER(ec.desc_estcivil) AS "Estado Civil"
 FROM trabajador t
      JOIN isapre i ON t.cod_isapre = i.cod_isapre
      JOIN afp a ON t.cod_afp = a.cod_afp
      LEFT JOIN asignacion_familiar af ON t.numrut = af.numrut_t
      JOIN est_civil e ON t.numrut = e.numrut_t
      JOIN estado_civil ec ON e.id_estcivil_est = ec.id_estcivil
 WHERE e.fecter_estcivil IS NULL
    OR e.fecter_estcivil > SYSDATE

 GROUP BY t.numrut, t.nombre, t.appaterno, t.fecing, t.sueldo_base,
          i.nombre_isapre, a.nombre_afp, ec.desc_estcivil
 ORDER BY t.numrut;

 
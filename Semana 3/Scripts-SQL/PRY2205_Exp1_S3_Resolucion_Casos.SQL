--
-- CASO 1
SELECT
    id_tipo_propiedad AS TIPO,
    COUNT(nro_propiedad) AS TOTAL_PROPIEDADES,
    TO_CHAR(MAX(valor_arriendo), '$999G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''') AS MAX_ARRIENDO,
    TO_CHAR(ROUND(AVG(valor_arriendo)), '$999G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''') AS PROMEDIO_ARRIENDO,
    TO_CHAR(MIN(valor_arriendo), '$999G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''') AS MIN_ARRIENDO,
    CASE
        WHEN MAX(valor_arriendo) <= 1000000 THEN 'ESTÁNDAR'
        ELSE 'PREMIUM'
    END AS CLASIFICACION,
    TO_CHAR(SUM(NVL(valor_gasto_comun, 0)), '$999G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''') AS TOTAL_GASTOS_COMUNES
FROM propiedad
GROUP BY id_tipo_propiedad
HAVING SUM(NVL(valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(NVL(valor_gasto_comun, 0)) DESC;

--
-- Caso 2
SELECT
    UPPER(nombre_emp || ' ' || appaterno_emp) AS "Nombre Empleado",
    TO_CHAR(sueldo_emp, '$999G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''') AS "Sueldo con Formato",
    CASE
        WHEN sueldo_emp > 2000000 THEN 'ALTO'
        ELSE 'MEDIO'
    END AS "Clasificación Sueldo",
    TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) AS "Años Antigüedad",
    'Corresponde bono '
      || LPAD(TO_CHAR(
           CASE
               WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) > 20 THEN 15
               WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) > 10 THEN 10
               ELSE 5
           END), 2)
      || '%: '
      || LPAD(TO_CHAR(ROUND(sueldo_emp *
           CASE
               WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) > 20 THEN 0.15
               WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) > 10 THEN 0.10
               ELSE 0.05
           END), '$999G999G999',
           'NLS_NUMERIC_CHARACTERS='',.'''), 12) AS BONO
FROM empleado
WHERE id_categoria_emp = 3
  AND MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12 > 5
  AND id_sucursal <> &CODIGO_SUCURSAL
ORDER BY sueldo_emp DESC;

--
-- Caso 3
SELECT
    CASE
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli >= 600000  THEN 'ALTA'
        WHEN renta_cli >= 300000  THEN 'MEDIA'
        ELSE 'BAJA'
    END AS CLASIFICACION_RENTA,
    COUNT(numrut_cli) AS CANTIDAD_CLIENTES,
    TO_CHAR(ROUND(AVG(renta_cli)), '$999G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''') AS RENTA_PROMEDIO,
    CASE
        WHEN COUNT(NVL(fonofijo_cli, celular_cli)) = 0
            THEN 'Clientes sin Teléfono'
        ELSE 'Clientes con Teléfono'
    END AS ESTADO_TELEFONO
FROM cliente
GROUP BY
    CASE
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli >= 600000  THEN 'ALTA'
        WHEN renta_cli >= 300000  THEN 'MEDIA'
        ELSE 'BAJA'
    END
HAVING AVG(renta_cli) > 200000;

--

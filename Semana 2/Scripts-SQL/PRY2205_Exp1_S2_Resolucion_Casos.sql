-- Caso 1 Facturas 

SELECT numfactura AS "N° Factura",
       TO_CHAR(fecha, 'DD "de" Month YYYY', 'NLS_DATE_LANGUAGE=SPANISH') AS "Fecha Emisión",
       LPAD(rutcliente, 10, '0') AS "RUT Cliente",
       TO_CHAR(neto, 'FM$999G999G999') AS "Monto Neto",
       TO_CHAR(iva, 'FM$999G999G999') AS "Monto Iva",
       TO_CHAR(total, 'FM$999G999G999') AS "Total Factura",
       CASE
         WHEN total <= 50000 THEN 'Bajo'
         WHEN total <= 100000 THEN 'Medio'
         ELSE 'Alto'
       END AS "Categoría Monto",
       CASE codpago
         WHEN 1 THEN 'EFECTIVO'
         WHEN 2 THEN 'TARJETA DEBITO'
         WHEN 3 THEN 'TARJETA CREDITO'
         ELSE 'CHEQUE'
       END AS "Forma de pago"
FROM factura
WHERE EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY fecha DESC, neto DESC;

-- Caso 2 Clasificacion de Clientes

SELECT LPAD(rutcliente, 12, '*') AS "RUT",
       INITCAP(nombre) AS "Cliente",
       NVL(TO_CHAR(telefono), 'Sin teléfono') AS "TELÉFONO",
       NVL(TO_CHAR(codcomuna), 'Sin comuna') AS "COMUNA",
       estado AS "ESTADO",
       CASE
         WHEN saldo / credito < 0.5 THEN 'Bueno (' || TO_CHAR(credito - saldo, '$9G999G999') || ')'
         WHEN saldo / credito <= 0.8 THEN 'Regular (' || TO_CHAR(saldo, '$9G999G999') || ')'
         ELSE 'Crítico'
       END AS "Estado Crédito",
       NVL(UPPER(SUBSTR(mail, INSTR(mail, '@') + 1)), 'Correo no registrado') AS "Dominio Correo"
FROM cliente
WHERE estado = 'A'
AND credito > 0
ORDER BY nombre ASC;

-- Caso 3 Stock de Productos

SELECT codproducto AS "ID",
       INITCAP(descripcion) AS "Descripción de Producto",
       NVL2(valorcompradolar, TO_CHAR(valorcompradolar) || ' USD', 'Sin registro') AS "Compra en USD",
       NVL2(valorcompradolar,
            TO_CHAR(ROUND(valorcompradolar * &&TIPOCAMBIO_DOLAR), 'FM$999G999G999') || ' PESOS',
            'Sin registro') AS "USD convertido",
       totalstock AS "Stock",
       CASE
         WHEN totalstock IS NULL THEN 'Sin datos'
         WHEN totalstock < &&UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
         WHEN totalstock <= &&UMBRAL_ALTO THEN '¡Reabastecer pronto!'
         ELSE 'OK'
       END AS "Alerta Stock",
       CASE
         WHEN totalstock > 80 THEN TO_CHAR(ROUND(vunitario * 0.9), 'FM$999G999G999')
         ELSE 'N/A'
       END AS "Precio Oferta"
FROM producto
WHERE UPPER(descripcion) LIKE '%ZAPATO%'
AND UPPER(procedencia) = 'I'
ORDER BY codproducto DESC;


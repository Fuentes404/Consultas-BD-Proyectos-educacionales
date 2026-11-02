# Consultas SQL con funciones en Oracle — Semana 2

Este proyecto corresponde a la actividad formativa de la **Semana 2** de la asignatura **PRY2205**. Consiste en consultar una base de datos de ventas en **Oracle Database**, usando funciones SQL (texto, números, fechas, conversión y condicionales) para generar informes.

## 📋 Descripción

Se trabaja sobre una base de datos de una empresa que vende productos a clientes mediante **boletas** y **facturas**. A partir de ella se resuelven tres casos:

- **Caso 1 – Facturas:** informe de las facturas emitidas el año anterior, con formato de fecha, RUT y montos, categoría según el total y forma de pago.
- **Caso 2 – Clasificación de clientes:** informe de clientes activos con su estado de crédito (Bueno, Regular o Crítico) y el dominio de su correo.
- **Caso 3 – Stock de productos:** informe de zapatos importados con alertas de stock, conversión de dólares a pesos y precio de oferta, usando variables de sustitución.

## 🧩 Tablas del modelo

`BANCO`, `FORMA_PAGO`, `PAIS`, `CIUDAD`, `COMUNA`, `CLIENTE`, `UNIDAD_MEDIDA`, `PRODUCTO`, `BOLETA`, `DETALLE_BOLETA`, `FACTURA`, `DETALLE_FACTURA`, `VENDEDOR`, `ESCOLARIDAD`, `TRAMO_ESCOLARIDAD`, `TRAMO_ANTIGUEDAD` y `REMUN_MENSUAL_VENDEDOR`.

## 🖼️ Modelo Relacional

<img width="6017" height="3246" alt="PRY2205_Exp1_S2_Anexo_page-0001" src="https://github.com/user-attachments/assets/6fa6713e-1df6-4f1f-8d59-467a8527f340" />


## 📂 Estructura del proyecto

```
Semana 2/
├── README.md
├── Documentos/
│   ├── PRY2205_Exp1_S2_Guia_aprendizaje_Uso_de_funciones_SQL.docx
│   ├── PRY2205_Exp1_S2_Instrucciones_específicas.docx
│   └── PRY2205_Exp1_S2_Pauta_evaluación_formativa.docx
├── Scripts-SQL/
│   ├── PRY2205_Exp1_S2_CreaEsquemaPoblado.sql.sql
│   ├── PRY2205_Exp1_S2_Resolucion_Casos.sql
│   └── PRY2205_Exp1_S2_script_crea_usuario.sql
└── Imagenes/
    └── PRY2205_Exp1_S2_Anexo_page-0001.jpg
```

## ▶️ Cómo ejecutar

1. Ejecutar como `SYS` o `SYSTEM` el script `PRY2205_Exp1_S2_script_crea_usuario.sql` (hay una versión para Oracle XE y otra para Oracle Cloud).
2. Crear una conexión en **Oracle SQL Developer** con el usuario `PRY2205_S2`.
3. Con ese usuario, ejecutar `PRY2205_Exp1_S2_CreaEsquemaPoblado.sql.sql` para crear y poblar las tablas.
4. Abrir `PRY2205_Exp1_S2_Resolucion_Casos.sql` y ejecutar cada caso por separado.
5. En el **Caso 3**, SQL Developer pedirá los valores de `TIPOCAMBIO_DOLAR`, `UMBRAL_BAJO` y `UMBRAL_ALTO`.

## 🛠️ Scripts por caso

### Caso 1 — Facturas

Facturas del año anterior, con fecha en texto, RUT con ceros a la izquierda, montos formateados, categoría según el total y forma de pago. Orden: fecha descendente y neto descendente.

```sql
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
```

### Caso 2 — Clasificación de clientes

Clientes activos con crédito, con su estado de crédito según la relación saldo-Crédito, el dominio del correo y valores por defecto cuando faltan datos. Orden: nombre ascendente.

```sql
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
```

### Caso 3 — Stock de productos

Zapatos importados, con valor en dólares y en pesos, alerta de stock según umbrales ingresados por el usuario y precio de oferta (10% de descuento) para productos con stock mayor a 80. Orden: código de producto descendente.

```sql
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
```

## 🧰 Herramientas utilizadas

- **Oracle SQL Developer** — escritura y ejecución de los scripts.
- **Oracle Database** — motor de base de datos.
- **GitHub** — repositorio de entrega.

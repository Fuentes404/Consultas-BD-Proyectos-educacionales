# Utilizando subconsultas para resolver requerimientos con Oracle — Semana 5

Este proyecto corresponde a la actividad formativa **"Utilizando subconsultas para resolver requerimientos"**. Se realizan consultas a la base de datos de **FinanCorp**, una empresa de gestión de cobranzas de tarjetas de crédito, usando **Oracle Database** y **Oracle SQL Developer**, con subconsultas, `JOIN` entre tablas, funciones de una fila y funciones de grupo.

## 📋 Descripción

A partir de la base de datos de clientes y transacciones de FinanCorp se resuelven dos casos:

- **Caso 1 – Listado de clientes:** clientes trabajadores dependientes con profesión contador o vendedor, cuyo año de inscripción es mayor al promedio redondeado de los años de inscripción de todos los clientes (calculado con una subconsulta). Orden: RUT ascendente.
- **Caso 2 – Aumento de crédito:** clientes con RUT, edad, cupo disponible de compra y tipo de cliente, cuyo cupo disponible es mayor o igual al máximo cupo disponible de las tarjetas solicitadas el año anterior (calculado con una subconsulta). El resultado se almacena en la tabla `CLIENTES_CUPOS_COMPRA`. Orden: edad ascendente.

## 🧩 Tablas del modelo

`CLIENTE`, `TARJETA_CLIENTE`, `TRANSACCION_TARJETA_CLIENTE`, `CUOTA_TRANSAC_TARJETA_CLIENTE`, `TIPO_CLIENTE`, `PROFESION_OFICIO`, `TIPO_TRANSACCION_TARJETA`, `PRODUCTO`, `SUCURSAL_RETAIL`, `COMUNA`, `PROVINCIA` y `REGION`.

## 📂 Estructura del proyecto

```
Semana 5/
├── README.md
├── Documentos/
│   ├── PRY2205_Exp2_S5_Guia_aprendizaje_Subconsultas.docx
│   ├── PRY2205_Exp2_S5_Instrucciones_específicas.docx
│   └── PRY2205_Exp2_S5_Pauta_evaluación_formativa.docx
├── Scripts-SQL/
│   ├── PRY2205_Exp2_S5_Script_crea_usuario.SQL
│   ├── PRY2205_Exp2_S5_CreaEsquemaPoblado.SQL
│   └── PRY2205_Exp2_S5_Resolucion_Casos.sql
└── Imagenes/
    └── PRY2205_Exp2_S5_Modelo_Relacional.pdf
```

## ▶️ Cómo ejecutar

1. Ejecutar como `SYS` o `SYSTEM` (o como `ADMIN` si se usa Oracle Cloud) el script `PRY2205_Exp2_S5_Script_crea_usuario.SQL`, que crea el usuario `PRY2205_S5`.
2. Crear una conexión en **Oracle SQL Developer** llamada `PRY2205_ACTIVIDAD_S5` con el usuario creado.
3. Con ese usuario, ejecutar `PRY2205_Exp2_S5_CreaEsquemaPoblado.SQL` para crear y poblar las tablas.
4. Ejecutar cada caso por separado.
5. Las consultas son paramétricas: usan `SYSDATE` y no tienen fechas fijas. Por eso las fechas y los resultados pueden diferir de los ejemplos del enunciado según el año de ejecución.

## 🛠️ Scripts por caso

### Caso 1 — Listado de clientes

Clientes dependientes (contador o vendedor) inscritos después del promedio de años de inscripción. Orden: RUT ascendente.

```sql
-- CASO 1: Listado de clientes dependientes (contador o vendedor) inscritos después del promedio de años de inscripción
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
```

### Caso 2 — Aumento de crédito

Clientes con cupo disponible de compra mayor o igual al máximo cupo del año anterior, almacenados en la tabla `CLIENTES_CUPOS_COMPRA`. Orden: edad ascendente.

```sql
-- CASO 2: Clientes para aumento de crédito, guardados en la tabla CLIENTES_CUPOS_COMPRA
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
```

## 🧰 Herramientas utilizadas

- **Oracle SQL Developer** — escritura y ejecución de los scripts.
- **Oracle Database** — motor de base de datos.
- **GitHub** — repositorio de entrega.

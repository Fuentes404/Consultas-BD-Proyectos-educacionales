# Funciones de agrupación en Oracle — Semana 3

Este proyecto corresponde a la actividad sumativa de la **Semana 3** de la asignatura **PRY2205**, llamada **"Aplicando funciones de agrupación"** (forma B). Consiste en consultar la base de datos de una empresa de arriendo de propiedades en **Oracle Database**, usando funciones de grupo, cláusulas `GROUP BY` / `HAVING` y funciones de una fila para generar informes.

## 📋 Descripción

Se trabaja sobre la base de datos de **ASOCIADOS**, una empresa que arrienda propiedades. A partir de ella se resuelven tres casos:

- **Caso 1 – Análisis de propiedades:** resumen por tipo de propiedad (cantidad, arriendo máximo, mínimo y promedio), con clasificación ESTÁNDAR/PREMIUM y total de gastos comunes. Solo muestra los tipos que superan un monto ingresado por el operador.
- **Caso 2 – Antigüedad de empleados:** Ejecutivos de Arriendo con más de 5 años en la empresa que no pertenecen a una sucursal ingresada por el operador, con nivel de sueldo (ALTO/MEDIO) y bono de antigüedad.
- **Caso 3 – Lista de clientes:** clasificación de clientes por renta (PREMIUM, ALTA, MEDIA, BAJA), con cantidad de clientes, renta promedio y estado de teléfono por segmento.

## 🧩 Tablas del modelo

`COMUNA`, `SUCURSAL`, `CATEGORIA_EMPLEADO`, `TIPO_PROPIEDAD`, `PROPIETARIO`, `CLIENTE`, `EMPLEADO`, `PROPIEDAD`, `ARRIENDO_PROPIEDAD`, `COMISION`, `EMPLEADOS_POR_SUCURSAL`, `HABERES`, `DESCUENTOS`, `RESUMEN_PAGOS_POR_SUCURSAL`, `DETALLE_PROP_ARRENDADAS` y `RESUMEN_PROP_ARRENDADAS`.

## 🖼️ Modelo Relacional

<img width="2402" height="1195" alt="Modelo_Relacional" src="https://github.com/user-attachments/assets/a4e9016f-cc20-496d-8aff-46da5d354f53" />


## 📂 Estructura del proyecto

```
Semana 3/
├── README.md
├── Documentos/
│   ├── PRY2205_Exp1_S3_Guia_aprendizaje_Funciones_de_agrupación.pdf
│   ├── PRY2205_Exp1_S3_Instrucciones_específicas__forma_B_.docx
│   └── PRY2205_Exp1_S3_Pauta_de_evaluacion_sumativa.pdf
├── Scripts-SQL/
│   ├── PRY2205_Exp1_S3_Script_crea_usuario (forma B).SQL
│   ├── PRY2205_Exp1_S3_CreaEsquemaPoblado__forma_B_.SQL
│   └── PRY2205_Exp1_S3_Resolucion_Casos.sql
└── Imagenes/
    └── Modelo_relacional.jpg
```

## ▶️ Cómo ejecutar

1. Ejecutar como `SYS` o `SYSTEM` el script `PRY2205_Exp1_S3_Script_crea_usuario (forma B).SQL`.
2. Crear una conexión en **Oracle SQL Developer** con el usuario creado.
3. Con ese usuario, ejecutar `PRY2205_Exp1_S3_CreaEsquemaPoblado__forma_B_.SQL` para crear y poblar las tablas.
4. Abrir `PRY2205_Exp1_S3_Resolucion_Casos.sql` y ejecutar cada caso por separado.
5. SQL Developer pedirá valores por variable de sustitución:
   - **Caso 1:** `VALOR_TOTAL_GASTO_COMUN` (valor de prueba: `100000`)
   - **Caso 2:** `CODIGO_SUCURSAL` (valor de prueba: `30`)

## 🛠️ Scripts por caso

### Caso 1 — Análisis de propiedades

Resumen por tipo de propiedad. Solo se muestran los tipos cuyo total de gastos comunes supera el valor ingresado. Orden: total de gastos comunes descendente.

```sql
-- CASO 1: Análisis de propiedades por tipo
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
```

### Caso 2 — Antigüedad de empleados

Ejecutivos de Arriendo (categoría 3) con más de 5 años de antigüedad, fuera de la sucursal ingresada. Bono: 5% de 5 a 10 años, 10% de 11 a 20 y 15% sobre 20. Orden: sueldo descendente.

```sql
-- CASO 2: Clasificación de sueldo y bono de antigüedad
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
```

### Caso 3 — Lista de clientes

Clientes agrupados por clasificación de renta. Solo se consideran los segmentos con renta promedio sobre $200.000.

```sql
-- CASO 3: Clasificación de clientes por renta
SELECT
    CASE
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli >= 600000 THEN 'ALTA'
        WHEN renta_cli >= 300000 THEN 'MEDIA'
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
        WHEN renta_cli >= 600000 THEN 'ALTA'
        WHEN renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END
HAVING AVG(renta_cli) > 200000;
```

## 🧰 Herramientas utilizadas

- **Oracle SQL Developer** — escritura y ejecución de los scripts.
- **Oracle Database** — motor de base de datos.
- **GitHub** — repositorio de entrega.


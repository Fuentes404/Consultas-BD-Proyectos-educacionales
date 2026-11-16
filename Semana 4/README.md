# Desarrollando JOINS en las tablas usando Oracle — Semana 4

Este proyecto corresponde a la actividad formativa, llamada **"Desarrollando JOINS en las tablas"**. En el cual se realizan Consultas a la base de datos de una empresa de venta de entradas para conciertos, lo abordaremos en **Oracle Database** y **Oracle developer** , usando `JOIN` entre tablas, funciones de una fila, funciones de grupo y cláusulas `GROUP BY` / `HAVING` para generar informes.

## 📋 Descripción

Se trabaja sobre la base de datos de **Conciertos Chile S.A.**, empresa dedicada a la organización y venta de tickets para eventos masivos, con trabajadores bajo distintos regímenes contractuales (planta, honorarios, plazo fijo). A partir de ella se resuelven tres casos:

- **Caso 1 – Listado de trabajadores:** trabajadores con sueldo base entre $650.000 y $3.000.000, con su tipo de contrato y ciudad. Orden: ciudad descendente y sueldo base ascendente.
- **Caso 2 – Listado de cajeros:** trabajadores con rol CAJERO, con cantidad de tickets vendidos, total vendido, comisión total y ciudad. Solo se muestran los que suman ventas sobre $50.000. Orden: total vendido descendente.
- **Caso 3 – Listado de bonificaciones:** antigüedad, cargas familiares, sistema de salud, bono Fonasa (1% del sueldo) y bono por antigüedad (10% con 10 años o menos, 15% con 11 o más). Solo considera el estado civil vigente. Orden: RUT ascendente.

## 🧩 Tablas del modelo

`TRABAJADOR`, `TIPO_TRABAJADOR`, `COMUNA_CIUDAD`, `EST_CIVIL`, `ESTADO_CIVIL`, `TICKETS_CONCIERTO`, `COMISIONES_TICKET`, `ASIGNACION_FAMILIAR`, `ISAPRE`, `AFP`, `BONO_ANTIGUEDAD`, `BONO_ESCOLAR` y `DETALLE_BONIFICACIONES_TRABAJADOR`.

## 🖼️ Modelo Relacional


<img width="1945" height="1128" alt="modelo relacional" src="https://github.com/user-attachments/assets/dc985437-8c48-43ae-bed2-4b6e379afd3d" />


## 📂 Estructura del proyecto

```
Semana 4/
├── README.md
├── Documentos/
│   ├── PRY2205_Exp2_S4_Guia_aprendizaje_JOINS.docx
│   ├── PRY2205_Exp2_S4_Instrucciones_específicas.docx
│   └── PRY2205_Exp2_S4_Pauta_evaluación_formativa.docx
├── Scripts-SQL/
│   ├── PRY2205_Exp2_S4_Script_crea_usuario_1.SQL
│   ├── PRY2205_Exp2_S4_CreaEsquemaPoblado_1.SQL
│   └── PRY2205_Exp2_S4_Resolucion_Casos.sql
└── Imagenes/
    └── PRY2205_Exp2_S4_Modelo_Relacional.jpg
```

## ▶️ Cómo ejecutar

1. Ejecutar como `SYS` o `SYSTEM` (o como `ADMIN` si se usa Oracle Cloud) el script `PRY2205_Exp2_S4_Script_crea_usuario_1.SQL`, que crea el usuario `PRY2205_S4`.
2. Crear una conexión en **Oracle SQL Developer** llamada `PRY2205_ACTIVIDAD_S4` con el usuario creado.
3. Con ese usuario, ejecutar `PRY2205_Exp2_S4_CreaEsquemaPoblado_1.SQL` para crear y poblar las tablas.
4. Abrir `PRY2205_Exp2_S4_Resolucion_Casos.sql` y ejecutar cada caso por separado.
5. Las consultas son paramétricas: usan `SYSDATE` y no tienen fechas fijas. Por eso los años de antigüedad y los bonos del Caso 3 dependen de la fecha de ejecución y pueden diferir de los ejemplos de las figuras del enunciado.

## 🛠️ Scripts por caso

### Caso 1 — Listado de trabajadores

Trabajadores con sueldo base entre $650.000 y $3.000.000. Orden: ciudad descendente y sueldo base ascendente.

```sql
-- CASO 1: Listado de trabajadores
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
```

### Caso 2 — Listado de cajeros

Cajeros con cantidad de tickets, total vendido y comisión total. Solo se muestran los que suman ventas sobre $50.000. Orden: total vendido descendente.

```sql
-- CASO 2: Listado de cajeros
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
```

### Caso 3 — Listado de bonificaciones

Antigüedad, cargas familiares, sistema de salud y bonos. Bono Fonasa: 1% del sueldo si pertenece a Fonasa. Bono por antigüedad: 10% con 10 años o menos y 15% con 11 o más. Solo se considera el estado civil vigente. Orden: RUT ascendente.

```sql
-- CASO 3: Listado de bonificaciones
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
```

## 🧰 Herramientas utilizadas

- **Oracle SQL Developer** — escritura y ejecución de los scripts.
- **Oracle Database** — motor de base de datos.
- **GitHub** — repositorio de entrega.

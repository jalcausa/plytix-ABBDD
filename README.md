# Plytix - Proyecto de Administración de Bases de Datos

Este repositorio contiene un proyecto académico de **Administración de Bases de Datos**, desarrollado **desde cero por el equipo**.

Incluye modelado E/R, scripts de nivel físico, seguridad/auditoría, paquetes PL/SQL y pruebas manuales en Oracle.

## Estructura del repositorio

```text
.
├── Entrega-Nivel-Físico-Parte-1/
│   ├── Version-1/
│   │   ├── Tarea-1.sql
│   │   └── Modelo_ER(.dmd)
│   ├── Version-2-[04-04-2025]/
│   │   ├── diagSQL.sql
│   │   └── Diagrama ER/
│   └── Version-3/
│       ├── ddl_v3.sql
│       ├── Tarea-1.txt
│       ├── Script_borrado.txt
│       └── ER_v3(.dmd)
├── Entrega-Nivel-Físico-Parte-2/
│   ├── v1.txt
│   ├── v2.txt
│   ├── v3.txt
│   └── v4.txt
├── Entrega-PL-SQL-1/
│   ├── PKG_ADMIN_PRODUCTOS.sql
│   ├── PKG_ADMIN_PRODUCTOS-Body.sql
│   └── Pruebas/ (prueba1.sql ... pruebas9.sql)
├── Entrega-PL-SQL-2/
│   ├── PKG_ADMIN_PRODUCTOS_AVANZADO.sql
│   ├── PKG_ADMIN_PRODUCTOS_AVANZADO-Body.sql
│   ├── Jobs/
│   │   ├── create_job_actualiza_productos.sql
│   │   └── create_job_limpia_traza.sql
│   ├── Paquetes/ (copias en .txt)
│   └── Pruebas/ (pruebas1.sql ... pruebas4.sql)
├── Seguridad/
│   └── Seguridad.txt
├── Version 2 [04-04-2025]/
│   └── Diagrama ER/ (diagLog.pdf, diagrama.dmd)
└── RubricaPlitix.xlsx
```

## Contenido por bloques

### 1) Nivel físico - Parte 1
- Evolución del esquema de base de datos en varias versiones.
- Scripts DDL y artefactos de modelado E/R.

### 2) Nivel físico - Parte 2 (seguridad y auditoría)
- Scripts/versiones centradas en seguridad, control de acceso y auditoría.
- Incluye el trabajo con cifrado y trazabilidad en las versiones `v1` a `v4`.

### 3) PL/SQL - Parte 1
- Paquete base `PKG_ADMIN_PRODUCTOS` (especificación + body).
- Pruebas manuales SQL para validar procedimientos y funciones del paquete.

### 4) PL/SQL - Parte 2
- Paquete avanzado `PKG_ADMIN_PRODUCTOS_AVANZADO` (spec + body).
- Scripts para creación de jobs automáticos.
- Pruebas manuales adicionales.

### 5) Seguridad
- Documento específico de seguridad en `Seguridad/Seguridad.txt`.

## Orden recomendado de revisión/ejecución

1. **Modelo y DDL base**: `Entrega-Nivel-Físico-Parte-1/` (preferiblemente `Version-3/ddl_v3.sql`).
2. **Seguridad y auditoría**: `Entrega-Nivel-Físico-Parte-2/` y `Seguridad/Seguridad.txt`.
3. **Paquete PL/SQL base**: `Entrega-PL-SQL-1/`.
4. **Paquete PL/SQL avanzado + jobs**: `Entrega-PL-SQL-2/`.
5. **Pruebas manuales**: scripts en `Pruebas/` de ambas entregas PL/SQL.

## Requisitos y forma de uso

- Proyecto orientado a **Oracle Database** (ejecución manual de scripts SQL/PLSQL).
- No hay pipeline de build/lint/test automatizado en el repositorio.
- Las validaciones se realizan ejecutando los scripts de prueba incluidos.

---

Si quieres, en una siguiente iteración se puede añadir una guía paso a paso de despliegue (orden exacto de scripts y prerequisitos Oracle) para dejarlo completamente reproducible.

# Plytix Database Administration Project

This repository contains a complete university project for the **Database Administration** subject.  
Everything here was designed and implemented **from scratch by our team**: data model, physical schema, PL/SQL business logic, security controls, auditing, and manual validation scripts.

## Project scope

The work covers the full lifecycle of an Oracle database project:

- Conceptual and E/R modeling
- Physical design and DDL evolution across multiple versions
- PL/SQL package development (base and advanced)
- Background automation with Oracle jobs
- Security hardening (roles, permissions, row-level controls, encryption, and auditing)
- Manual SQL-based testing

## Repository structure

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
│   ├── Paquetes/ (package copies in .txt)
│   └── Pruebas/ (pruebas1.sql ... pruebas4.sql)
├── Seguridad/
│   └── Seguridad.txt
├── Version 2 [04-04-2025]/
│   └── Diagrama ER/ (diagLog.pdf, diagrama.dmd)
└── RubricaPlitix.xlsx
```

## What each block teaches

### 1) Physical level - Part 1 (`Entrega-Nivel-Físico-Parte-1`)
This folder captures schema evolution from early drafts to a more mature DDL version.

Key learning outcomes:
- Turning E/R ideas into Oracle tables, constraints, and indexes
- Managing iterative schema versions and refactoring decisions
- Understanding the impact of physical design choices on maintainability

### 2) Physical level - Part 2 (`Entrega-Nivel-Físico-Parte-2`)
Contains extended scripts focused on security and audit-related requirements through different versions.

Key learning outcomes:
- Hardening a schema beyond basic DDL
- Versioning security-related database scripts
- Connecting administration tasks with compliance concerns

### 3) PL/SQL package foundations (`Entrega-PL-SQL-1`)
Defines `PKG_ADMIN_PRODUCTOS` (spec + body) and the first battery of manual tests.

What is practiced in this package:
- Business-oriented functions and procedures
- Permission checks at package level (`F_USUARIO_ACCESO_CUENTA`)
- Data validation and controlled updates/deletions
- Exception handling with custom exceptions
- Error traceability with the `TRAZA` table
- Account/product synchronization logic (`P_ACTUALIZAR_PRODUCTOS`)

### 4) Advanced PL/SQL and automation (`Entrega-PL-SQL-2`)
Adds `PKG_ADMIN_PRODUCTOS_AVANZADO`, scheduled jobs, and extra tests.

What is practiced in this block:
- Capacity control against account plans (`F_VALIDAR_PLAN_SUFICIENTE`)
- Category and attribute utilities (`F_LISTA_CATEGORIAS_PRODUCTO`, `P_REPLICAR_ATRIBUTOS`)
- Controlled migrations with transaction techniques (`SAVEPOINT`, rollback paths)
- Oracle job scheduling for recurrent maintenance:
  - `create_job_actualiza_productos.sql`
  - `create_job_limpia_traza.sql`

### 5) Security and auditing references (`Seguridad`)
`Seguridad/Seguridad.txt` includes examples such as:
- TDE-style encrypted columns (e.g., phone encryption)
- Audit policy creation and activation
- Querying audit records from `UNIFIED_AUDIT_TRAIL`

## Pedagogical summary: knowledge acquired in this project

By building this repository end-to-end, the team practiced:

1. **Database architecture thinking**  
   Designing entities, relationships, and constraints that support real business operations.

2. **From model to implementation**  
   Translating conceptual models into Oracle DDL and maintaining multiple script versions.

3. **Robust PL/SQL engineering**  
   Organizing logic in packages, documenting interfaces, validating inputs, and raising meaningful exceptions.

4. **Data integrity under change**  
   Updating, migrating, and deleting data safely while protecting referential consistency.

5. **Operational automation**  
   Using database jobs to run recurring maintenance tasks without manual intervention.

6. **Security by design**  
   Applying role-based permissions, controlled access patterns, and auditability in database workflows.

7. **Auditing and traceability**  
   Capturing runtime issues (`TRAZA`) and monitoring sensitive operations through Oracle auditing features.

8. **Professional validation habits**  
   Designing manual SQL test scripts to verify behavior and edge cases in each delivery.

## How this repository is validated

- Target platform: **Oracle Database**
- Execution model: manual SQL/PLSQL script execution
- Test assets: SQL scripts under:
  - `Entrega-PL-SQL-1/Pruebas/`
  - `Entrega-PL-SQL-2/Pruebas/`
- There is no automated CI/lint/build pipeline in this repository

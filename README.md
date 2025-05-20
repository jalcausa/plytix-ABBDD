# Revisión del Trabajo del Grupo

## 1. ¿Se han creado los siguientes objetos?

- ¿Se ha creado un esquema distinto para el trabajo? → <span style="color:red;">NO</span>
- ¿Se han creado índices en la base de datos? → <span style="color:green;">Sí</span>
- ¿Se han importado los datos a las tablas Cuentas, Planes, Usuarios, Productos...? → <span style="color:red;">NO</span>
- ¿Se ha añadido una tabla TRAZA...? → <span style="color:red;">NO</span>

## 2. Seguridad

- ¿Se ha añadido alguna columna como se indicaba...? → <span style="color:red;">NO</span>
- ¿Se ha aplicado seguridad...? → <span style="color:red;">NO</span>

## 3. Vistas

- V_PRODUCTO_PUBLICO → <span style="color:red;">NO</span>
- Materializada_VM_PRODUCTOS → <span style="color:red;">NO</span>

## 4. Permisos

- Gestión de Productos por Usuario Estándar → <span style="color:red;">NO</span>
- Gestión de Productos y Categorías → <span style="color:red;">NO</span>
- Gestión de Productos, Activos entre Productos → <span style="color:red;">NO</span>

## 5. Paquetes PL/SQL

- PKG_ADMIN_PRODUCTOS → <span style="color:red;">NO</span>

## 6. Procedimientos (dentro del paquete)

- F_OBTENER_PLAN_CUENTA → <span style="color:red;">NO</span>
- F_CONTAR_PRODUCTOS_CUENTA → <span style="color:red;">NO</span>
- F_VALIDAR_ATRIBUTOS_PRODUCTO → <span style="color:red;">NO</span>
- F_NUM_CATEGORIAS_CUENTA → <span style="color:red;">NO</span>
- P_ACTUALIZAR_NOMBRE_PRODUCTO → <span style="color:red;">NO</span>
- P_ASOCIAR_ACTIVO_A_PRODUCTO → <span style="color:red;">NO</span>
- P_ELIMINAR_PRODUCTO_Y_ASOCIACIONES → <span style="color:red;">NO</span>
- P_CREAR_USUARIO → <span style="color:red;">NO</span>
- P_ACTUALIZAR_PRODUCTOS → <span style="color:red;">NO</span>

## 7. Triggers

- TR_PRODUCTOS → <span style="color:red;">NO</span>

## 8. Transacciones

- ¿Se han controlado/deshecho las transacciones...? → <span style="color:red;">NO</span>

## 9. Excepciones

- ¿Se han controlado excepciones? → <span style="color:red;">NO</span>

## 10. ¿Se han probado todas las funcionalidades con datos coherentes?

- ¿Se han insertado datos coherentes? → <span style="color:red;">NO</span>

## 11. Seguridad

- ¿Se han creado roles adecuadamente? → <span style="color:red;">NO</span>
- ¿Se han asignado roles a los usuarios? → <span style="color:red;">NO</span>
- ¿Se han aplicado restricciones de forma restrictiva...? → <span style="color:red;">NO</span>
- ¿Se ha activado TDE y encriptado algunas...? → <span style="color:red;">NO</span>

---

## Opciones para subir la nota:

### 1. Paquetes adicionales

- PKG_ADMIN_PRODUCTOS_AVANZADO → <span style="color:red;">NO</span>
- F_VALIDAR_PLAN_SUFICIENTE → <span style="color:red;">NO</span>
- F_LISTA_CATEGORIAS_PRODUCTO → <span style="color:red;">NO</span>
- P_MIGRAR_PRODUCTOS_A_CATEGORIA → <span style="color:red;">NO</span>
- P_REPLICAR_ATRIBUTOS → <span style="color:red;">NO</span>
- J_LIMPIA_TRAZA → <span style="color:red;">NO</span>
- P_ACTUALIZA_PRODUCTOS → <span style="color:red;">NO</span>

### 2. JOBS

- Todos los indicados → <span style="color:red;">NO</span>

### 3. Diseño E/R

- ¿Se cumple con restricciones semánticas...? → <span style="color:red;">NO</span>

### 4. Auditoría

- ¿Se han creado restricciones NOT NULL / UNIQUE...? → <span style="color:red;">NO</span>
- ¿Se han hecho auditorías suficientes? → <span style="color:red;">NO</span>

### 5. Miscelánea

- ¿Se han implementado otras funcionalidades...? → <span style="color:red;">NO</span>

### 6. Contexto

- ¿Se han documentado correctamente...? → <span style="color:red;">NO</span>

---

**Nota total del grupo: 0,00**

# Revisión del Trabajo del Grupo

## 1. ¿Se han creado los siguientes objetos?

- ¿Se ha creado un esquema distinto para el trabajo? → <span style="color:red;">NO</span>
- ¿Se han creado índices en la base de datos? → <span style="color:green;">SÍ</span>
- ¿Se han importado los datos a las tablas Cuentas, Planes, Usuarios, Productos...? → <span style="color:red;">NO</span>
- ¿Se ha añadido una tabla TRAZA y se usa para seguir errores? → <span style="color:red;">SÍ</span>

## 2. Seguridad

- ¿Se ha añadido alguna columna como se indicaba en la práctica de seguridad? → <span style="color:red;">SÍ</span>
- ¿Se ha aplicado alguna política de autorización VPD? → <span style="color:red;">NO</span>

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

# Explicación parte 2 de nivel físico

## **Estructura General de Seguridad**

El script implementa un sistema de seguridad basado en **roles** y **políticas de acceso a nivel de fila (RLS - Row Level Security)** para un sistema llamado Plytix. Se definen 4 tipos de usuarios con diferentes niveles de acceso:

### **1. Roles Creados**

```sql
CREATE ROLE R_USER_STD;              -- Usuario Estándar
CREATE ROLE R_GESTOR_CUENTA;         -- Gestor de Cuentas  
CREATE ROLE R_PLANIFICADOR_SERVICIOS; -- Planificador de Servicios
```

El **Administrador del Sistema** es el usuario PLYTIX (propietario de las tablas), no necesita rol específico.

## **2. Usuario Estándar (R_USER_STD)**

### **Acceso a su propia información de usuario:**
- **Vista V_USUARIO**: Solo puede ver y modificar su propio registro
```sql
CREATE OR REPLACE VIEW V_USUARIO AS 
SELECT * FROM USUARIO WHERE UPPER(USUARIO.NOMBREUSUARIO)=USER
```
- La condición `WHERE UPPER(USUARIO.NOMBREUSUARIO)=USER` garantiza que solo vea su propio registro
- Permisos limitados: `SELECT, UPDATE(NOMBRECOMPLETO, AVATAR, EMAIL, TELEFONO)`

### **Acceso a Productos:**
- **Vista V_PRODUCTO_STD**: Solo productos de su cuenta
```sql
WHERE PRODUCTO.CUENTA_ID IN (SELECT CUENTA_ID FROM V_USUARIO)
```
- **Triggers INSTEAD OF** para operaciones CRUD que:
  - En INSERT: Asignan automáticamente la CUENTA_ID del usuario actual
  - En UPDATE/DELETE: Solo permiten modificar productos de su cuenta

### **Acceso a Activos:**
- **Vista V_ACTIVO_STD**: Solo activos de su cuenta
- **Triggers similares** que verifican pertenencia a la cuenta del usuario
- **Vista adicional V_ACTIVO_CATEGORIA_STD** para gestionar relaciones activo-categoría

### **Política de Seguridad VPD para Atributos:**
```sql
CREATE OR REPLACE FUNCTION SOLO_USER_ATRIB(...) RETURN VARCHAR2 AS
BEGIN
    RETURN 'CUENTA_ID IN (SELECT CUENTA_ID FROM V_USUARIO)';
END;
```
- **Virtual Private Database (VPD)** aplica automáticamente esta condición a SELECT, UPDATE, DELETE
- Para INSERT usa un **trigger adicional** ya que VPD no cubre esta operación

## **3. Gestor de Cuentas (R_GESTOR_CUENTA)**

### **Acceso completo a tabla CUENTA:**
```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON CUENTA TO R_GESTOR_CUENTA;
```

### **Acceso limitado a información de usuarios:**
- **Vista V_USUARIO_GESTOR**: Excluye datos sensibles (Email, Teléfono)
```sql
SELECT ID, NOMBREUSUARIO, NOMBRECOMPLETO, AVATAR, CUENTA_ID FROM USUARIO;
```
- **Trigger de protección** impide eliminar usuarios que son propietarios de cuentas

## **4. Planificador de Servicios (R_PLANIFICADOR_SERVICIOS)**

### **Acceso completo a tabla PLAN:**
```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON PLAN TO R_PLANIFICADOR_SERVICIOS;
```

## **5. Características Especiales de Seguridad**

### **Productos Públicos/Privados:**
- **Campo PUBLICO** añadido a tabla PRODUCTO (por defecto 'S')
- **Vista V_PRODUCTO_PUBLICO** para productos públicos accesible a todos
```sql
CREATE OR REPLACE VIEW V_PRODUCTO_PUBLICO AS
SELECT * FROM PRODUCTO WHERE PUBLICO = 'S';
GRANT SELECT ON V_PRODUCTO_PUBLICO TO PUBLIC;
```

### **Triggers de Validación:**
- **Verifican pertenencia a la misma cuenta** antes de crear relaciones
- **Previenen operaciones no autorizadas** como relacionar productos de diferentes cuentas
- **Asignación automática de CUENTA_ID** basada en el usuario conectado

### **Sinónimos Públicos:**
```sql
CREATE PUBLIC SYNONYM MI_USUARIO FOR V_USUARIO;
CREATE PUBLIC SYNONYM MIS_PRODUCTOS FOR V_PRODUCTO_STD;
```
- Facilitan el acceso a las vistas sin especificar el esquema

## **6. Principios de Seguridad Implementados**

1. **Principio de menor privilegio**: Cada rol solo tiene acceso a lo estrictamente necesario
2. **Segregación de datos por cuenta**: Los usuarios solo ven datos de su propia cuenta
3. **Protección de datos sensibles**: El gestor de cuentas no puede ver emails/teléfonos
4. **Integridad referencial**: Los triggers verifican que las relaciones sean válidas
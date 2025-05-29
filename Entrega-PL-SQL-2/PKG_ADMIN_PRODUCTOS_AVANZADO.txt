CREATE OR REPLACE 
PACKAGE PKG_ADMIN_PRODUCTOS_AVANZADO AS 

------------------------------------------------------------------------------
-- Función: F_VALIDAR_PLAN_SUFICIENTE
-- Descripción:
--   Verifica si una cuenta tiene suficiente capacidad disponible según los
--   límites definidos en su plan de suscripción. Evalúa distintos recursos
--   como productos, activos, categorías y relaciones, y devuelve una cadena
--   indicando si la cuenta supera alguno de los límites establecidos.
-- Parámetros:
--   - p_cuenta_id (CUENTA.ID%TYPE): ID de la cuenta a validar.
-- Devuelve:
--   - VARCHAR2:
--       - 'SUFICIENTE' si la cuenta está dentro de los límites permitidos.
--       - 'INSUFICIENTE: <TIPO>' si se supera alguno de los siguientes límites:
--           - PRODUCTOS
--           - ACTIVOS
--           - CATEGORIASPRODUCTO
--           - CATEGORIASACTIVOS
--           - RELACIONES
------------------------------------------------------------------------------
FUNCTION  F_VALIDAR_PLAN_SUFICIENTE(p_cuenta_id IN CUENTA.ID%TYPE) RETURN VARCHAR2;

------------------------------------------------------------------------------
-- Función: F_LISTA_CATEGORIAS_PRODUCTO
-- Descripción:
--   Devuelve una lista separada por punto y coma con los nombres de las 
--   categorías a las que pertenece un producto concreto dentro de una cuenta.
--   Si el producto no está asociado a ninguna categoría, devuelve 'Sin categoría'.
--   Solo se permite la consulta si el usuario tiene acceso a la cuenta.
-- Parámetros:
--   - p_producto_gtin (PRODUCTO.GTIN%TYPE): Código GTIN del producto a consultar.
--   - p_cuenta_id (PRODUCTO.CUENTA_ID%TYPE): ID de la cuenta propietaria del producto.
-- Devuelve:
--   - VARCHAR2: Cadena con los nombres de las categorías separadas por ' ; ',
--               o el texto 'Sin categoría' si no tiene ninguna.
-- Excepciones:
--   - RAISE de EXCEPTION_SIN_ACCESO_CUENTA si el usuario no tiene acceso a la cuenta.
--   - NO_DATA_FOUND si el producto no existe en la cuenta especificada (registrado en traza).
--   - OTHERS: cualquier otro error se registra en la tabla TRAZA y se relanza.
------------------------------------------------------------------------------
FUNCTION F_LISTA_CATEGORIAS_PRODUCTO(p_producto_gtin IN PRODUCTO.GTIN%TYPE, p_cuenta_id IN PRODUCTO.CUENTA_ID%TYPE) RETURN VARCHAR2;

------------------------------------------------------------------------------
-- Procedimiento: P_MIGRAR_PRODUCTOS_A_CATEGORIA
-- Descripción:
--   Migra todos los productos de una categoría origen a una categoría destino
--   dentro de una misma cuenta. Se realiza una actualización en la tabla
--   PRODUCTO_CATEGORIA y se manejan posibles duplicados de forma controlada.
--   El procedimiento registra los errores en la tabla TRAZA y utiliza SAVEPOINT
--   para permitir continuar la transacción en caso de errores puntuales.
-- Parámetros:
--   - p_cuenta_id (CUENTA.ID%TYPE): ID de la cuenta en la que se realiza la migración.
--   - p_categoria_origen_id (CATEGORIA.ID%TYPE): ID de la categoría desde la que se migrarán los productos.
--   - p_categoria_destino_id (CATEGORIA.ID%TYPE): ID de la categoría a la que se migrarán los productos.
-- Consideraciones:
--   - Si la categoría origen y destino son la misma, no se realiza ninguna acción.
--   - Se requiere que ambas categorías pertenezcan a la cuenta especificada.
--   - En caso de intentar duplicar una asignación ya existente, se omite la actualización
--     y se registra el incidente en la tabla TRAZA.
-- Excepciones:
--   - RAISE de EXCEPTION_SIN_ACCESO_CUENTA si el usuario no tiene acceso a la cuenta.
--   - NO_DATA_FOUND si alguna de las categorías no existe en la cuenta (registrado en TRAZA).
--   - OTHERS: cualquier otro error se registra en TRAZA y se relanza.
------------------------------------------------------------------------------
PROCEDURE P_MIGRAR_PRODUCTOS_A_CATEGORIA(p_cuenta_id IN CUENTA.ID%TYPE, p_categoria_origen_id IN CATEGORIA.ID%TYPE, p_categoria_destino_id IN CATEGORIA.ID%TYPE);

------------------------------------------------------------------------------
-- Procedimiento: P_REPLICAR_ATRIBUTOS
-- Descripción:
--   Copia todos los atributos de un producto origen a un producto destino dentro
--   de la misma cuenta. Si el atributo ya existe en el producto destino, se actualiza
--   su valor; de lo contrario, se inserta uno nuevo.
-- Parámetros:
--   - p_cuenta_id (CUENTA.ID%TYPE): ID de la cuenta a la que pertenecen ambos productos.
--   - p_producto_gtin_origen (PRODUCTO.GTIN%TYPE): GTIN del producto desde el que se replican los atributos.
--   - p_producto_gtin_destino (PRODUCTO.GTIN%TYPE): GTIN del producto al que se copian los atributos.
-- Consideraciones funcionales:
--   - Ambos productos deben existir y pertenecer a la cuenta indicada.
--   - Se omiten los atributos que ya existan y tengan el mismo identificador, actualizando su valor.
--   - Los atributos que no existan en el producto destino se insertan con el valor proveniente del origen.
--   - Todos los errores son registrados en la tabla TRAZA.
-- Excepciones:
--   - RAISE de EXCEPTION_SIN_ACCESO_CUENTA si el usuario no tiene acceso a la cuenta.
--   - NO_DATA_FOUND si alguno de los productos no existe (registrado en TRAZA).
--   - OTHERS: cualquier otro error se registra en TRAZA y se relanza tras rollback.
------------------------------------------------------------------------------
PROCEDURE P_REPLICAR_ATRIBUTOS(p_cuenta_id IN CUENTA.ID%TYPE, 
p_producto_gtin_origen IN PRODUCTO.GTIN%TYPE, p_producto_gtin_destino IN PRODUCTO.GTIN%TYPE);

END PKG_ADMIN_PRODUCTOS_AVANZADO;

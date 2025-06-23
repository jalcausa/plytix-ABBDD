create or replace PACKAGE PKG_ADMIN_PRODUCTOS AS 

  EXCEPTION_PLAN_NO_ASIGNADO EXCEPTION;
  EXCEPTION_SIN_ACCESO_CUENTA EXCEPTION;
  EXCEPTION_ASOCIACION_DUPLICADA EXCEPTION;
  INVALID_DATA EXCEPTION;
  EXCEPTION_USUARIO_YA_EXISTENTE EXCEPTION;
  EXCEPTION_ROL_INEXISTENTE EXCEPTION;

  ------------------------------------------------------------------------------
  -- Función: F_USUARIO_ACCESO_CUENTA
  -- Descripción:
  --   Verifica si un usuario tiene acceso a una cuenta concreta.
  --   El acceso se concede si:
  --     - Existe una fila en la tabla USUARIO con ese nombre de usuario y cuenta, o
  --     - El nombre de usuario es 'PLYTIX'.
  -- Parámetros:
  --   - p_nombreusuario (USUARIO.NOMBREUSUARIO%TYPE): Nombre del usuario a verificar.
  --   - p_cuenta_id (CUENTA.ID%TYPE): ID de la cuenta a la que se desea acceder.
  -- Devuelve:
  --   - NUMBER: 1 si el usuario tiene acceso, 0 en caso contrario.
  ------------------------------------------------------------------------------
  FUNCTION F_USUARIO_ACCESO_CUENTA (
    p_nombreusuario IN USUARIO.NOMBREUSUARIO%TYPE,
    p_cuenta_id IN CUENTA.ID%TYPE
  ) RETURN NUMBER;

  ------------------------------------------------------------------------------
  -- Función: F_OBTENER_PLAN_CUENTA
  -- Descripción:
  --   Devuelve la información completa del plan asociado a una cuenta concreta.
  --   Para ello:
  --     - Verifica que la cuenta existe.
  --     - Comprueba que el usuario actual tiene acceso a la cuenta.
  --     - Obtiene el ID del plan asociado a la cuenta.
  --     - Recupera y devuelve la fila completa de la tabla PLAN correspondiente.
  --   Excepciones personalizadas:
  --     - EXCEPTION_SIN_ACCESO_CUENTA: Si el usuario no tiene acceso a la cuenta.
  --     - EXCEPTION_PLAN_NO_ASIGNADO: Si la cuenta no tiene ningún plan asociado.
  --   También se registran errores en la tabla TRAZA en caso de fallo.
  -- Parámetros:
  --   - p_cuenta_id (CUENTA.ID%TYPE): ID de la cuenta cuya información de plan se desea obtener.
  -- Devuelve:
  --   - PLAN%ROWTYPE: Fila completa del plan asociado a la cuenta.
  ------------------------------------------------------------------------------
  FUNCTION F_OBTENER_PLAN_CUENTA(
    p_cuenta_id IN CUENTA.ID%TYPE
  ) RETURN PLAN%ROWTYPE;

  ------------------------------------------------------------------------------
  -- Función: F_CONTAR_PRODUCTOS_CUENTA
  -- Descripción:
  --   Devuelve el número de productos asociados a una cuenta específica.
  --   Para ello:
  --     - Verifica que la cuenta existe.
  --     - Comprueba que el usuario actual tiene acceso a la cuenta.
  --     - Cuenta cuántos productos están asociados a dicha cuenta.
  --   En caso de error, registra la traza en la tabla TRAZA y relanza la excepción.
  -- Parámetros:
  --   - p_cuenta_id (CUENTA.ID%TYPE): ID de la cuenta cuyos productos se desean contar.
  -- Devuelve:
  --   - NUMBER: Número total de productos asociados a la cuenta.
  ------------------------------------------------------------------------------
  FUNCTION F_CONTAR_PRODUCTOS_CUENTA(
    p_cuenta_id IN CUENTA.ID%TYPE
  ) RETURN NUMBER;

  ------------------------------------------------------------------------------
  -- Función: F_NUM_CATEGORIAS_CUENTA
  -- Descripción:
  --   Devuelve el número total de categorías asociadas a una cuenta.
  --   Para ello:
  --     - Verifica que la cuenta existe.
  --     - Comprueba que el usuario actual tiene acceso a dicha cuenta.
  --     - Recorre mediante un cursor todas las categorías asociadas y las cuenta.
  --   Registra trazas en caso de cuenta inexistente, acceso denegado o errores.
  -- Parámetros:
  --   - p_cuenta_id (IN): ID de la cuenta cuyos datos de categorías se desean consultar.
  -- Devuelve:
  --   - NUMBER: Número total de categorías asociadas a la cuenta.
  ------------------------------------------------------------------------------
  FUNCTION F_NUM_CATEGORIAS_CUENTA(
    p_cuenta_id IN CUENTA.ID%TYPE
  ) RETURN NUMBER;

  ------------------------------------------------------------------------------
  -- Función: F_VALIDAR_ATRIBUTOS_PRODUCTO
  -- Descripción:
  --   Verifica si un producto tiene definidos valores para todos los atributos
  --   requeridos por su cuenta. Para ello:
  --     - Comprueba que la cuenta existe.
  --     - Valida que el usuario actual tiene acceso a la cuenta.
  --     - Verifica que el producto existe dentro de la cuenta.
  --     - Cuenta cuántos atributos están definidos para la cuenta.
  --     - Cuenta cuántos de esos atributos tienen valores definidos para el producto.
  --   Devuelve TRUE si todos los atributos tienen valores, FALSE en caso contrario.
  --   Registra errores en la tabla TRAZA en caso de excepción.
  -- Parámetros:
  --   - p_producto_gtin (PRODUCTO.GTIN%TYPE): Código GTIN del producto.
  --   - p_cuenta_id (PRODUCTO.CUENTA_ID%TYPE): ID de la cuenta a la que pertenece el producto.
  -- Devuelve:
  --   - BOOLEAN: TRUE si el producto tiene todos los atributos cubiertos, FALSE si no.
  ------------------------------------------------------------------------------
  FUNCTION F_VALIDAR_ATRIBUTOS_PRODUCTO(
    p_producto_gtin IN PRODUCTO.GTIN%TYPE,
    p_cuenta_id IN PRODUCTO.CUENTA_ID%TYPE
  ) RETURN BOOLEAN;

  ------------------------------------------------------------------------------
  -- Procedimiento: P_ASOCIAR_ACTIVO_A_PRODUCTO
  -- Descripción:
  --   Asocia un activo existente a un producto determinado, siempre que ambos
  --   pertenezcan a sus respectivas cuentas y que la asociación no exista ya.
  --   Si la asociación ya está registrada, se lanza la excepción personalizada
  --   EXCEPTION_ASOCIACION_DUPLICADA. Cualquier error se registra en la tabla TRAZA.
  -- Parámetros:
  --   - p_producto_gtin           : Identificador GTIN del producto.
  --   - p_producto_cuenta_id      : ID de la cuenta a la que pertenece el producto.
  --   - p_activo_id               : ID del activo a asociar.
  --   - p_activo_cuenta_id        : ID de la cuenta a la que pertenece el activo.
  ------------------------------------------------------------------------------
  PROCEDURE P_ASOCIAR_ACTIVO_A_PRODUCTO(
    p_producto_gtin IN PRODUCTO.GTIN%TYPE,
    p_producto_cuenta_id IN PRODUCTO.CUENTA_ID%TYPE, 
    p_activo_id IN ACTIVO.ID%TYPE,
    p_activo_cuenta_id IN ACTIVO.CUENTA_ID%TYPE
  );

  ------------------------------------------------------------------------------
  -- Procedimiento: P_ELIMINAR_PRODUCTO_Y_ASOCIACIONES
  -- Descripción:
  --   Elimina un producto identificado por su GTIN y su cuenta asociada, junto
  --   con todas las asociaciones relacionadas en otras tablas: PRODUCTO_ACTIVO,
  --   ATRIBUTO_PRODUCTO, PRODUCTO_CATEGORIA y RELACIONADO. Garantiza el orden
  --   correcto de eliminación para evitar violaciones de claves foráneas.
  --   Registra errores en la tabla TRAZA si el producto no existe o si ocurre
  --   cualquier otro error durante la operación.
  -- Parámetros:
  --   - p_producto_gtin : Identificador GTIN del producto a eliminar.
  --   - p_cuenta_id     : ID de la cuenta a la que pertenece el producto.
  ------------------------------------------------------------------------------
  PROCEDURE P_ELIMINAR_PRODUCTO_Y_ASOCIACIONES(
    p_producto_gtin IN PRODUCTO.GTIN%TYPE,
    p_cuenta_id IN PRODUCTO.CUENTA_ID%TYPE
  );

  ------------------------------------------------------------------------------
  -- Procedimiento: P_ACTUALIZAR_NOMBRE_PRODUCTO
  -- Descripción:
  --   Actualiza el nombre de un producto identificado por su GTIN dentro de una cuenta.
  --   Realiza las siguientes validaciones:
  --     - El nuevo nombre no puede ser nulo ni estar vacío.
  --     - El usuario debe tener acceso a la cuenta.
  --     - El producto debe existir dentro de la cuenta.
  --   En caso de error (producto no encontrado, acceso denegado, datos inválidos u otros),
  --   se registra una traza y se lanza la excepción correspondiente.
  -- Parámetros:
  --   - p_producto_gtin (IN): Código GTIN del producto a actualizar.
  --   - p_cuenta_id (IN): ID de la cuenta a la que pertenece el producto.
  --   - p_nuevo_nombre (IN): Nuevo nombre que se asignará al producto.
  ------------------------------------------------------------------------------
  PROCEDURE P_ACTUALIZAR_NOMBRE_PRODUCTO(
    p_producto_gtin IN PRODUCTO.GTIN%TYPE, 
    p_cuenta_id IN PRODUCTO.CUENTA_ID%TYPE, 
    p_nuevo_nombre IN PRODUCTO.NOMBRE%TYPE
  );

  ------------------------------------------------------------------------------
  -- Procedimiento: P_ACTUALIZAR_TODAS_CUENTAS
  -- Descripción:
  --   Procedimiento auxiliar utilizado por el job J_ACTUALIZA_PRODUCTOS.
  --   Recorre todas las cuentas registradas en el sistema y ejecuta sobre cada una
  --   el procedimiento P_ACTUALIZAR_PRODUCTOS, definido en el ejercicio 8 de la
  --   primera relación de prácticas de PL/SQL.
  --   Si ocurre un error al actualizar una cuenta, se registra en la tabla TRAZA
  --   con una descripción del fallo, pero se continúa con el resto.
  -- Parámetros:
  --   - Ninguno.
  ------------------------------------------------------------------------------
  PROCEDURE P_ACTUALIZAR_TODAS_CUENTAS;

  ------------------------------------------------------------------------------
  -- Procedimiento: P_ACTUALIZAR_PRODUCTOS
  -- Descripción:
  --   Sincroniza la tabla PRODUCTO con los datos provenientes de la tabla externa
  --   S_PRODUCTO para una cuenta dada. Realiza las siguientes operaciones:
  --     1. Inserta productos nuevos que existen en S_PRODUCTO pero no en PRODUCTO.
  --     2. Actualiza el nombre de productos si difiere del registrado en S_PRODUCTO.
  --     3. Elimina productos que existen en PRODUCTO pero no en S_PRODUCTO.
  --   Utiliza procedimientos auxiliares como P_ACTUALIZAR_NOMBRE_PRODUCTO y 
  --   P_ELIMINAR_PRODUCTO_Y_ASOCIACIONES para mantener la consistencia.
  --   Se comprueba que el usuario tenga acceso a la cuenta mediante 
  --   F_USUARIO_ACCESO_CUENTA, y se registran errores en la tabla TRAZA.
  -- Parámetros:
  --   - p_cuenta_id : ID de la cuenta cuyos productos deben sincronizarse.
  ------------------------------------------------------------------------------
  PROCEDURE P_ACTUALIZAR_PRODUCTOS(
    p_cuenta_id IN cuenta.id%TYPE
  );

  ------------------------------------------------------------------------------
  -- Procedimiento: P_CREAR_USUARIO
  -- Descripción:
  --   Crea un nuevo usuario en la base de datos y en la tabla USUARIO. Realiza
  --   las siguientes operaciones:
  --     1. Verifica que el rol proporcionado sea uno de los roles válidos:
  --        'R_USER_STD', 'R_GESTOR_CUENTA' o 'R_PLANIFICADOR_SERVICIOS'.
  --     2. Comprueba que no exista ya un usuario con el mismo ID.
  --     3. Si no existe, crea el usuario en la base de datos con la contraseña
  --        proporcionada, le asigna el rol indicado y lo inserta en la tabla USUARIO.
  --     4. En caso de errores, registra el detalle en la tabla TRAZA y propaga la excepción.
  -- Parámetros:
  --   - p_usuario  : Registro completo con los datos del nuevo usuario (tipo USUARIO%ROWTYPE).
  --   - p_rol      : Rol que se le asignará al nuevo usuario.
  --   - p_password : Contraseña con la que se creará el usuario en la base de datos.
  ------------------------------------------------------------------------------
  PROCEDURE P_CREAR_USUARIO(
    p_usuario IN USUARIO%ROWTYPE, 
    p_rol IN VARCHAR2, 
    p_password IN VARCHAR2
  );

END PKG_ADMIN_PRODUCTOS;
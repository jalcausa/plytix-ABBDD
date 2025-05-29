DECLARE
    v_cuenta_id CUENTA.ID%TYPE;
    v_cat_origen_id CATEGORIA.ID%TYPE;
    v_cat_destino_id CATEGORIA.ID%TYPE;
    v_producto_gtin PRODUCTO.GTIN%TYPE;
BEGIN
    -- Limpiamos el estado anterior
    DELETE FROM traza WHERE causante = 'P_MIGRAR_PRODUCTOS_A_CATEGORIA';

    -- Creamos una cuenta de prueba
    INSERT INTO cuenta VALUES (9999, 'Cuenta de prueba', 'Calle Prueba', 'NIFPRUEBA', SYSDATE, NULL, 1);
    v_cuenta_id := 9999;
    INSERT INTO USUARIO (id, nombreusuario, nombrecompleto, avatar, email, telefono, cuenta_id) VALUES (500, USER, 'Alberto Ramirez', NULL, 'correoprueba9999@gmail.com', '+34 626 49 94 93', 9999);

    -- Creamos dos categorías de prueba
    INSERT INTO categoria(id, cuenta_id, nombre) VALUES (1001, v_cuenta_id, 'Categoría origen');
    INSERT INTO categoria(id, cuenta_id, nombre) VALUES (1002, v_cuenta_id, 'Categoría destino');
    v_cat_origen_id := 1001;
    v_cat_destino_id := 1002;

    -- Creamos un producto de prueba
    v_producto_gtin := 9001;
    INSERT INTO producto VALUES (v_producto_gtin, 'SKU_000999', 'Producto de prueba', NULL, NULL, NULL, NULL, v_cuenta_id);

    -- Insertamos el elemento pertinente en producto_categoria
    INSERT INTO producto_categoria(producto_gtin, producto_cuenta_id, categoria_id, categoria_cuenta_id)
    VALUES (v_producto_gtin, v_cuenta_id, v_cat_origen_id, v_cuenta_id);

    -- Ejecutamos el procedimiento
    PKG_ADMIN_PRODUCTOS_AVANZADO.P_MIGRAR_PRODUCTOS_A_CATEGORIA(v_cuenta_id, v_cat_origen_id, v_cat_destino_id);

    -- Verificamos que el producto ha migrado correctamente
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM producto_categoria
        WHERE producto_gtin = v_producto_gtin AND categoria_id = v_cat_destino_id;

        IF v_count = 1 THEN
            DBMS_OUTPUT.PUT_LINE('Producto migrado correctamente.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR: Producto no fue migrado.');
        END IF;
    END;

    -- Probamos que el producto de prueba ya no está en la categoría origen
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM producto_categoria
        WHERE producto_gtin = v_producto_gtin AND categoria_id = v_cat_origen_id;

        IF v_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Producto eliminado de categoría origen.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR: Producto sigue en categoría origen.');
        END IF;
    END;

    -- Comprobamos que no se ha generado ninguna traza de error
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM traza
        WHERE causante = 'P_MIGRAR_PRODUCTOS_A_CATEGORIA';

        IF v_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No se generaron errores en traza.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Se generaron entradas en traza.');
        END IF;
    END;

    -- Deshacemos todos los cambios
    DELETE FROM USUARIO WHERE id = 500;
    DELETE FROM PRODUCTO_CATEGORIA WHERE producto_gtin = 9001;
    DELETE FROM CATEGORIA WHERE id IN (1001, 1002);
    DELETE FROM PRODUCTO WHERE gtin = 9001;
    DELETE FROM CUENTA WHERE id = 9999;
EXCEPTION
    WHEN PKG_ADMIN_PRODUCTOS.EXCEPTION_SIN_ACCESO_CUENTA THEN
        DBMS_OUTPUT.PUT_LINE('Error accediendo a la cuenta con id ' || v_cuenta_id || '. ' || SQLERRM);
    
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error accediendo a los datos: ' || SQLERRM);
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error insertando resultado de test: ' || SQLERRM);
END;
/

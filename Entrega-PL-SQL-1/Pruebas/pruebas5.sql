-- 1. Tabla de resultados de test
CREATE TABLE TEST_RESULTADOS (
    id_test       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_test   VARCHAR2(100),
    resultado     VARCHAR2(20),
    mensaje       VARCHAR2(500),
    fecha         DATE DEFAULT SYSDATE
);

-- 2. Procedimiento para registrar resultados
CREATE OR REPLACE PROCEDURE P_INSERTAR_RESULTADO_TEST(
    p_nombre_test IN VARCHAR2,
    p_resultado   IN VARCHAR2,
    p_mensaje     IN VARCHAR2
) AS
BEGIN
    INSERT INTO TEST_RESULTADOS(nombre_test, resultado, mensaje)
    VALUES (p_nombre_test, p_resultado, p_mensaje);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error insertando resultado de test: ' || SQLERRM);
END;
/

-- 3. Procedimiento que ejecuta todas las pruebas
CREATE OR REPLACE PROCEDURE P_RUN_TESTS_P_ACTUALIZAR_NOMBRE_PRODUCTO AS
    v_result NUMBER;
BEGIN
    -- Test 1: Actualización correcta (GTIN válido, cuenta 1)
    BEGIN
        PKG_ADMIN_PRODUCTOS.P_ACTUALIZAR_NOMBRE_PRODUCTO(90, 27, 'Doble Elefante Telépata de Guerra');
        P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - correcto', 'OK', 'Nombre actualizado');
    EXCEPTION
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - correcto', 'FAIL', SQLERRM);
    END;

    -- Test 2: GTIN inválido
    BEGIN
        PKG_ADMIN_PRODUCTOS.P_ACTUALIZAR_NOMBRE_PRODUCTO('9999999999999', 1, 'Nombre');
        P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - GTIN inválido', 'FAIL', 'NO_DATA_FOUND no lanzada');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - GTIN inválido', 'OK', 'Excepción capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - GTIN inválido', 'FAIL', SQLERRM);
    END;

    -- Test 3: Nombre NULL
    BEGIN
        PKG_ADMIN_PRODUCTOS.P_ACTUALIZAR_NOMBRE_PRODUCTO(28, 27, NULL);
        P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - nombre NULL', 'FAIL', 'INVALID_DATA no lanzada');
    EXCEPTION
        WHEN PKG_ADMIN_PRODUCTOS.INVALID_DATA THEN
            P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - nombre NULL', 'OK', 'Excepción capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - nombre NULL', 'FAIL', SQLERRM);
    END;

    -- Test 4: Nombre en blanco
    BEGIN
        PKG_ADMIN_PRODUCTOS.P_ACTUALIZAR_NOMBRE_PRODUCTO(21, 27, '   ');
        P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - nombre en blanco', 'FAIL', 'INVALID_DATA no lanzada');
    EXCEPTION
        WHEN PKG_ADMIN_PRODUCTOS.INVALID_DATA THEN
            P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - nombre en blanco', 'OK', 'Excepción capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - nombre en blanco', 'FAIL', SQLERRM);
    END;

    -- Test 5: Cuenta incorrecta
    BEGIN
        PKG_ADMIN_PRODUCTOS.P_ACTUALIZAR_NOMBRE_PRODUCTO(44, 1, 'Nombre');
        P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - cuenta inválida', 'FAIL', 'NO_DATA_FOUND no lanzada');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - cuenta inválida', 'OK', 'Excepción capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - cuenta inválida', 'FAIL', SQLERRM);
    END;

    -- Test 6: Sin acceso a la cuenta (cuenta 3)
    BEGIN
        PKG_ADMIN_PRODUCTOS.P_ACTUALIZAR_NOMBRE_PRODUCTO('1234567890123', 3, 'Nombre');
        P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - sin acceso', 'FAIL', 'EXCEPTION_SIN_ACCESO_CUENTA no lanzada');
    EXCEPTION
        WHEN PKG_ADMIN_PRODUCTOS.EXCEPTION_SIN_ACCESO_CUENTA THEN
            P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - sin acceso', 'OK', 'Excepción capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('P_ACTUALIZAR_NOMBRE_PRODUCTO - sin acceso', 'FAIL', SQLERRM);
    END;
END;
/

-- Para ejecutar y ver los resultados
BEGIN
    P_RUN_TESTS_P_ACTUALIZAR_NOMBRE_PRODUCTO;
END;
/

SELECT * FROM TEST_RESULTADOS ORDER BY fecha DESC;

-- Para borrar todas las filas de la tabla
TRUNCATE TABLE TEST_RESULTADOS;
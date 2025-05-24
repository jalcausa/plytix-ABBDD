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
CREATE OR REPLACE PROCEDURE P_RUN_TESTS_P_ASOCIAR_ACTIVO_A_PRODUCTO AS
BEGIN
    -- Test 1: Asociación válida
    BEGIN
        PKG_ADMIN_PRODUCTOS.P_ASOCIAR_ACTIVO_A_PRODUCTO('1111111111111', 1, 100, 1);
        P_INSERTAR_RESULTADO_TEST('Asociación válida', 'OK', 'Asociación insertada');
    EXCEPTION
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('Asociación válida', 'FAIL', SQLERRM);
    END;

    -- Test 2: Producto inexistente
    BEGIN
        PKG_ADMIN_PRODUCTOS.P_ASOCIAR_ACTIVO_A_PRODUCTO('9999999999999', 1, 100, 1);
        P_INSERTAR_RESULTADO_TEST('Producto inexistente', 'FAIL', 'NO_DATA_FOUND no lanzada');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_INSERTAR_RESULTADO_TEST('Producto inexistente', 'OK', 'Excepción capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('Producto inexistente', 'FAIL', SQLERRM);
    END;

    -- Test 3: Activo inexistente
    BEGIN
        PKG_ADMIN_PRODUCTOS.P_ASOCIAR_ACTIVO_A_PRODUCTO('1111111111111', 1, 9999, 1);
        P_INSERTAR_RESULTADO_TEST('Activo inexistente', 'FAIL', 'NO_DATA_FOUND no lanzada');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_INSERTAR_RESULTADO_TEST('Activo inexistente', 'OK', 'Excepción capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('Activo inexistente', 'FAIL', SQLERRM);
    END;

    -- Test 4: Asociación duplicada
    BEGIN
        -- Intentar insertar de nuevo la misma asociación del test 1
        PKG_ADMIN_PRODUCTOS.P_ASOCIAR_ACTIVO_A_PRODUCTO('1111111111111', 1, 100, 1);
        P_INSERTAR_RESULTADO_TEST('Asociación duplicada', 'FAIL', 'EXCEPTION_ASOCIACION_DUPLICADA no lanzada');
    EXCEPTION
        WHEN PKG_ADMIN_PRODUCTOS.EXCEPTION_ASOCIACION_DUPLICADA THEN
            P_INSERTAR_RESULTADO_TEST('Asociación duplicada', 'OK', 'Excepción capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('Asociación duplicada', 'FAIL', SQLERRM);
    END;
END;
/


-- Para ejecutar y ver los resultados
BEGIN
    P_RUN_TESTS_P_ASOCIAR_ACTIVO_A_PRODUCTO;
END;
/

SELECT * FROM TEST_RESULTADOS ORDER BY fecha DESC;


-- Para borrar todas las filas de la tabla
TRUNCATE TABLE TEST_RESULTADOS;
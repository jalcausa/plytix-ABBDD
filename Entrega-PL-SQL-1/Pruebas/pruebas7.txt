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
CREATE OR REPLACE PROCEDURE P_RUN_TESTS_P_ELIMINAR_PRODUCTO_Y_ASOCIACIONES AS
BEGIN
    -- Test 1: Eliminación válida (producto existe y se eliminan asociaciones)
    BEGIN
        PKG_ADMIN_PRODUCTOS.P_ELIMINAR_PRODUCTO_Y_ASOCIACIONES('2222222222222', 1);
        P_INSERTAR_RESULTADO_TEST('Eliminación válida', 'OK', 'Producto y asociaciones eliminados');
    EXCEPTION
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('Eliminación válida', 'FAIL', SQLERRM);
    END;

    -- Test 2: Producto inexistente (debe lanzar NO_DATA_FOUND)
    BEGIN
        PKG_ADMIN_PRODUCTOS.P_ELIMINAR_PRODUCTO_Y_ASOCIACIONES('9999999999999', 1);
        P_INSERTAR_RESULTADO_TEST('Producto inexistente', 'FAIL', 'NO_DATA_FOUND no lanzada');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_INSERTAR_RESULTADO_TEST('Producto inexistente', 'OK', 'Excepción capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('Producto inexistente', 'FAIL', SQLERRM);
    END;
END;
/

-- Ejemplo de datos para preparar las pruebas (asegúrate de insertarlos antes de ejecutar los tests)

-- Insertar producto y asociaciones para test 1
INSERT INTO PRODUCTO (GTIN, CUENTA_ID, ...) VALUES ('2222222222222', 1, ...);
INSERT INTO PRODUCTO_ACTIVO (PRODUCTO_GTIN, PRODUCTO_CUENTA_ID, ACTIVO_ID, ACTIVO_CUENTA_ID) VALUES ('2222222222222', 1, 100, 1);
INSERT INTO ATRIBUTO_PRODUCTO (PRODUCTO_GTIN, PRODUCTO_CUENTA_ID, ...) VALUES ('2222222222222', 1, ...);
INSERT INTO PRODUCTO_CATEGORIA (PRODUCTO_GTIN, PRODUCTO_CUENTA_ID, ...) VALUES ('2222222222222', 1, ...);
INSERT INTO RELACIONADO (PRODUCTO_GTIN, PRODUCTO_CUENTA_ID, PRODUCTO_GTIN1, PRODUCTO_CUENTA_ID1, ...) VALUES ('2222222222222', 1, '3333333333333', 1, ...);
COMMIT;

-- Para ejecutar y ver los resultados
BEGIN
    P_RUN_TESTS_P_ELIMINAR_PRODUCTO_Y_ASOCIACIONES;
END;
/

-- Consultar resultados
SELECT * FROM TEST_RESULTADOS ORDER BY fecha DESC;

-- Limpiar resultados de tests
TRUNCATE TABLE TEST_RESULTADOS;

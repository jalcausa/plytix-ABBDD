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
CREATE OR REPLACE PROCEDURE P_RUN_TESTS_F_NUM_CATEGORIAS_CUENTA AS
    v_result NUMBER;
BEGIN
    -- Test 1: Cuenta válida con categorías (cuenta 1, espera 3 categorías)
    BEGIN
        v_result := PKG_ADMIN_PRODUCTOS.F_NUM_CATEGORIAS_CUENTA(27);
        IF v_result = 3 THEN
            P_INSERTAR_RESULTADO_TEST('F_NUM_CATEGORIAS_CUENTA - cuenta válida', 'OK', 'Resultado esperado: 3');
        ELSE
            P_INSERTAR_RESULTADO_TEST('F_NUM_CATEGORIAS_CUENTA - cuenta válida', 'FAIL', 'Se obtuvo: ' || v_result);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('F_NUM_CATEGORIAS_CUENTA - cuenta válida', 'FAIL', SQLERRM);
    END;

    -- Test 2: Cuenta sin categorías (cuenta 2)
    BEGIN
        v_result := PKG_ADMIN_PRODUCTOS.F_NUM_CATEGORIAS_CUENTA(1);
        IF v_result = 0 THEN
            P_INSERTAR_RESULTADO_TEST('F_NUM_CATEGORIAS_CUENTA - sin categorías', 'OK', 'Resultado esperado: 0');
        ELSE
            P_INSERTAR_RESULTADO_TEST('F_NUM_CATEGORIAS_CUENTA - sin categorías', 'FAIL', 'Se obtuvo: ' || v_result);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('F_NUM_CATEGORIAS_CUENTA - sin categorías', 'FAIL', SQLERRM);
    END;

    -- Test 3: Cuenta inexistente (9999)
    BEGIN
        v_result := PKG_ADMIN_PRODUCTOS.F_NUM_CATEGORIAS_CUENTA(9999);
        P_INSERTAR_RESULTADO_TEST('F_NUM_CATEGORIAS_CUENTA - cuenta inexistente', 'FAIL', 'No se lanzó NO_DATA_FOUND');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_INSERTAR_RESULTADO_TEST('F_NUM_CATEGORIAS_CUENTA - cuenta inexistente', 'OK', 'Excepción capturada correctamente');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('F_NUM_CATEGORIAS_CUENTA - cuenta inexistente', 'FAIL', SQLERRM);
    END;

    -- Test 4: Sin acceso a la cuenta (cuenta 3)
    BEGIN
        v_result := PKG_ADMIN_PRODUCTOS.F_NUM_CATEGORIAS_CUENTA(3);
        P_INSERTAR_RESULTADO_TEST('F_NUM_CATEGORIAS_CUENTA - sin acceso', 'FAIL', 'No se lanzó EXCEPTION_SIN_ACCESO_CUENTA');
    EXCEPTION
        WHEN PKG_ADMIN_PRODUCTOS.EXCEPTION_SIN_ACCESO_CUENTA THEN
            P_INSERTAR_RESULTADO_TEST('F_NUM_CATEGORIAS_CUENTA - sin acceso', 'OK', 'Excepción capturada correctamente');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('F_NUM_CATEGORIAS_CUENTA - sin acceso', 'FAIL', SQLERRM);
    END;
END;
/

-- Para ejecutar y ver los resultados
BEGIN
    P_RUN_TESTS_F_NUM_CATEGORIAS_CUENTA;
END;
/

SELECT * FROM TEST_RESULTADOS ORDER BY fecha DESC;

-- Para borrar todas las filas de la tabla
TRUNCATE TABLE TEST_RESULTADOS;
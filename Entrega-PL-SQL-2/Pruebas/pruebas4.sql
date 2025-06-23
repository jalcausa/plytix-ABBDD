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
CREATE OR REPLACE PROCEDURE P_RUN_TESTS_P_REPLICAR_ATRIBUTOS AS
BEGIN
    -- Test 1: Replicación válida
    BEGIN
        -- Suponemos que el producto origen y destino existen en cuenta 1 y que el origen tiene atributos
        PKG_ADMIN_PRODUCTOS_AVANZADO.P_REPLICAR_ATRIBUTOS(1, 1111111111111, 2222222222222);
        P_INSERTAR_RESULTADO_TEST('Replicación válida', 'OK', 'Atributos replicados correctamente');
    EXCEPTION
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('Replicación válida', 'FAIL', SQLERRM);
    END;

    -- Test 2: Producto origen inexistente
    BEGIN
        PKG_ADMIN_PRODUCTOS_AVANZADO.P_REPLICAR_ATRIBUTOS(1, 9999999999999, 2222222222222);
        P_INSERTAR_RESULTADO_TEST('Producto origen inexistente', 'FAIL', 'NO_DATA_FOUND no lanzada');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_INSERTAR_RESULTADO_TEST('Producto origen inexistente', 'OK', 'Excepción NO_DATA_FOUND capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('Producto origen inexistente', 'FAIL', SQLERRM);
    END;

    -- Test 3: Producto destino inexistente
    BEGIN
        PKG_ADMIN_PRODUCTOS_AVANZADO.P_REPLICAR_ATRIBUTOS(1, 1111111111111, 9999999999999);
        P_INSERTAR_RESULTADO_TEST('Producto destino inexistente', 'FAIL', 'NO_DATA_FOUND no lanzada');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_INSERTAR_RESULTADO_TEST('Producto destino inexistente', 'OK', 'Excepción NO_DATA_FOUND capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('Producto destino inexistente', 'FAIL', SQLERRM);
    END;

    -- Test 4: Replicación con actualización
    BEGIN
        -- Primero, se replica para insertar el atributo
        PKG_ADMIN_PRODUCTOS_AVANZADO.P_REPLICAR_ATRIBUTOS(1, 1111111111111, 3333333333333);
        -- Luego se cambia el valor del atributo origen y se vuelve a replicar
        UPDATE ATRIBUTO_PRODUCTO
        SET VALOR = 'VALOR_ACTUALIZADO'
        WHERE PRODUCTO_GTIN = 1111111111111
          AND PRODUCTO_CUENTA_ID = 1
          AND ROWNUM = 1;

        PKG_ADMIN_PRODUCTOS_AVANZADO.P_REPLICAR_ATRIBUTOS(1, 1111111111111, 3333333333333);

        P_INSERTAR_RESULTADO_TEST('Replicación con actualización', 'OK', 'Atributo actualizado correctamente');
    EXCEPTION
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('Replicación con actualización', 'FAIL', SQLERRM);
    END;
END;
/

-- Para ejecutar y ver los resultados
BEGIN
    P_RUN_TESTS_P_REPLICAR_ATRIBUTOS;
END;
/

SELECT * FROM TEST_RESULTADOS ORDER BY fecha DESC;

-- Para borrar todas las filas de la tabla
TRUNCATE TABLE TEST_RESULTADOS;
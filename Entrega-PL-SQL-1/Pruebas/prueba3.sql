-- 1. Crear tabla temporal para los resultados de test
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
CREATE OR REPLACE PROCEDURE P_RUN_TESTS_F_VALIDAR_ATRIBUTOS_PRODUCTO AS
    v_result BOOLEAN;
    v_total_atributos NUMBER;
    v_total_valores NUMBER;
BEGIN
    -- Test 1: Producto con todos los atributos completados
    BEGIN
        -- Obtener conteos para diagnóstico
        SELECT COUNT(*) INTO v_total_atributos
        FROM ATRIBUTO
        WHERE cuenta_id = 1027;
        
        SELECT COUNT(DISTINCT ap.ATRIBUTO_ID) INTO v_total_valores
        FROM ATRIBUTO_PRODUCTO ap
        WHERE ap.PRODUCTO_GTIN = 1001
        AND ap.PRODUCTO_CUENTA_ID = 1027
        AND ap.ATRIBUTO_CUENTA_ID = 1027;

        v_result := PKG_ADMIN_PRODUCTOS.F_VALIDAR_ATRIBUTOS_PRODUCTO(1001, 1027);
        IF v_result = TRUE THEN
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - producto completo', 
                'OK', 
                'El producto 1001 tiene todos sus atributos completados (' || v_total_valores || ' de ' || v_total_atributos || ')'
            );
        ELSE
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - producto completo', 
                'FAIL', 
                'Se esperaba TRUE (atributos completos), se obtuvo FALSE. Valores: ' || v_total_valores || ' de ' || v_total_atributos || ' atributos'
            );
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - producto completo', 
                'FAIL', 
                SQLERRM
            );
    END;

    -- Test 2: Producto con atributos incompletos
    BEGIN
        v_result := PKG_ADMIN_PRODUCTOS.F_VALIDAR_ATRIBUTOS_PRODUCTO(1002, 1027);
        IF v_result = FALSE THEN
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - atributos incompletos', 
                'OK', 
                'Se detectó correctamente que el producto 1002 tiene atributos incompletos'
            );
        ELSE
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - atributos incompletos', 
                'FAIL', 
                'Se esperaba FALSE (atributos incompletos), se obtuvo TRUE para producto 1002'
            );
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - atributos incompletos', 
                'FAIL', 
                SQLERRM
            );
    END;

    -- Test 3: Producto inexistente
    BEGIN
        v_result := PKG_ADMIN_PRODUCTOS.F_VALIDAR_ATRIBUTOS_PRODUCTO(9999, 1027);
        P_INSERTAR_RESULTADO_TEST(
            'F_VALIDAR_ATRIBUTOS_PRODUCTO - producto inexistente', 
            'FAIL', 
            'No se lanzó NO_DATA_FOUND para producto inexistente 9999'
        );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - producto inexistente', 
                'OK', 
                'Excepción NO_DATA_FOUND capturada correctamente para producto 9999'
            );
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - producto inexistente', 
                'FAIL', 
                SQLERRM
            );
    END;

    -- Test 4: Cuenta inexistente
    BEGIN
        v_result := PKG_ADMIN_PRODUCTOS.F_VALIDAR_ATRIBUTOS_PRODUCTO(1001, 9999);
        P_INSERTAR_RESULTADO_TEST(
            'F_VALIDAR_ATRIBUTOS_PRODUCTO - cuenta inexistente', 
            'FAIL', 
            'No se lanzó NO_DATA_FOUND para cuenta inexistente 9999'
        );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - cuenta inexistente', 
                'OK', 
                'Excepción NO_DATA_FOUND capturada correctamente para cuenta 9999'
            );
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - cuenta inexistente', 
                'FAIL', 
                SQLERRM
            );
    END;

    -- Test 5: Producto sin atributos definidos en la cuenta
    BEGIN
        v_result := PKG_ADMIN_PRODUCTOS.F_VALIDAR_ATRIBUTOS_PRODUCTO(1003, 1000);
        IF v_result = TRUE THEN
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - sin atributos definidos', 
                'OK', 
                'Correcto: producto 1003 en cuenta sin atributos retorna TRUE'
            );
        ELSE
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - sin atributos definidos', 
                'FAIL', 
                'Se esperaba TRUE (sin atributos), se obtuvo FALSE para producto 1003'
            );
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST(
                'F_VALIDAR_ATRIBUTOS_PRODUCTO - sin atributos definidos', 
                'FAIL', 
                SQLERRM
            );
    END;
END;
/

-- 4. Crear los datos de prueba necesarios
-- Asegurarse de que existe el plan con ID 10
INSERT INTO PLAN (id, nombre, productos, activos, almacenamiento, categoriasproducto, categoriasactivos, relaciones, precio)
SELECT 10, 'Plan Pruebas', 100, 100, '1GB', 10, 10, 10, 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM PLAN WHERE id = 10);

-- Insertar cuentas de prueba si no existen
INSERT INTO CUENTA (id, nombre, direccionfiscal, nif, fechaalta, plan_id)
SELECT 1000, 'Cuenta Sin Atributos', 'Dirección 1', 'B12345678', TO_DATE('2025-05-24 19:32:58', 'YYYY-MM-DD HH24:MI:SS'), 10
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM CUENTA WHERE id = 1000);

INSERT INTO CUENTA (id, nombre, direccionfiscal, nif, fechaalta, plan_id)
SELECT 1027, 'Cuenta Test', 'Dirección 2', 'B87654321', TO_DATE('2025-05-24 19:32:58', 'YYYY-MM-DD HH24:MI:SS'), 10
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM CUENTA WHERE id = 1027);

-- Insertar atributos para la cuenta 1027 si no existen
INSERT INTO ATRIBUTO (id, nombre, tipo, creado, cuenta_id)
SELECT 1, 'Color', 'STRING', TO_DATE('2025-05-24 19:32:58', 'YYYY-MM-DD HH24:MI:SS'), 1027
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ATRIBUTO WHERE id = 1 AND cuenta_id = 1027);

INSERT INTO ATRIBUTO (id, nombre, tipo, creado, cuenta_id)
SELECT 2, 'Tamaño', 'STRING', TO_DATE('2025-05-24 19:32:58', 'YYYY-MM-DD HH24:MI:SS'), 1027
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ATRIBUTO WHERE id = 2 AND cuenta_id = 1027);

INSERT INTO ATRIBUTO (id, nombre, tipo, creado, cuenta_id)
SELECT 3, 'Peso', 'NUMBER', TO_DATE('2025-05-24 19:32:58', 'YYYY-MM-DD HH24:MI:SS'), 1027
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ATRIBUTO WHERE id = 3 AND cuenta_id = 1027);

-- Insertar productos de prueba si no existen
INSERT INTO PRODUCTO (gtin, sku, nombre, textocorto, creado, cuenta_id)
SELECT 1001, 'SKU1001', 'Producto Completo', 'Descripción 1', TO_DATE('2025-05-24 19:32:58', 'YYYY-MM-DD HH24:MI:SS'), 1027
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM PRODUCTO WHERE gtin = 1001 AND cuenta_id = 1027);

INSERT INTO PRODUCTO (gtin, sku, nombre, textocorto, creado, cuenta_id)
SELECT 1002, 'SKU1002', 'Producto Incompleto', 'Descripción 2', TO_DATE('2025-05-24 19:32:58', 'YYYY-MM-DD HH24:MI:SS'), 1027
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM PRODUCTO WHERE gtin = 1002 AND cuenta_id = 1027);

INSERT INTO PRODUCTO (gtin, sku, nombre, textocorto, creado, cuenta_id)
SELECT 1003, 'SKU1003', 'Producto Sin Atributos', 'Descripción 3', TO_DATE('2025-05-24 19:32:58', 'YYYY-MM-DD HH24:MI:SS'), 1000
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM PRODUCTO WHERE gtin = 1003 AND cuenta_id = 1000);

-- Insertar valores de atributos para el producto completo
INSERT INTO ATRIBUTO_PRODUCTO (valor, producto_gtin, atributo_id, producto_cuenta_id, atributo_cuenta_id)
SELECT 'Rojo', 1001, 1, 1027, 1027
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 
    FROM ATRIBUTO_PRODUCTO 
    WHERE producto_gtin = 1001 
    AND atributo_id = 1 
    AND producto_cuenta_id = 1027
);

INSERT INTO ATRIBUTO_PRODUCTO (valor, producto_gtin, atributo_id, producto_cuenta_id, atributo_cuenta_id)
SELECT 'Grande', 1001, 2, 1027, 1027
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 
    FROM ATRIBUTO_PRODUCTO 
    WHERE producto_gtin = 1001 
    AND atributo_id = 2 
    AND producto_cuenta_id = 1027
);

INSERT INTO ATRIBUTO_PRODUCTO (valor, producto_gtin, atributo_id, producto_cuenta_id, atributo_cuenta_id)
SELECT '500', 1001, 3, 1027, 1027
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 
    FROM ATRIBUTO_PRODUCTO 
    WHERE producto_gtin = 1001 
    AND atributo_id = 3 
    AND producto_cuenta_id = 1027
);

-- Insertar valor incompleto para el segundo producto
INSERT INTO ATRIBUTO_PRODUCTO (valor, producto_gtin, atributo_id, producto_cuenta_id, atributo_cuenta_id)
SELECT 'Azul', 1002, 1, 1027, 1027
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 
    FROM ATRIBUTO_PRODUCTO 
    WHERE producto_gtin = 1002 
    AND atributo_id = 1 
    AND producto_cuenta_id = 1027
);

COMMIT;

-- 5. Ejecutar las pruebas
BEGIN
    P_RUN_TESTS_F_VALIDAR_ATRIBUTOS_PRODUCTO;
END;
/

-- 6. Mostrar resultados
SELECT 
    TO_CHAR(fecha, 'YYYY-MM-DD HH24:MI:SS') as fecha_test,
    nombre_test,
    resultado,
    mensaje
FROM TEST_RESULTADOS 
ORDER BY fecha DESC;

-- 7. Limpiar objetos temporales
DROP PROCEDURE P_INSERTAR_RESULTADO_TEST;
DROP PROCEDURE P_RUN_TESTS_F_VALIDAR_ATRIBUTOS_PRODUCTO;
DROP TABLE TEST_RESULTADOS PURGE;

-- 8. Limpiar datos de prueba
/*
DELETE FROM ATRIBUTO_PRODUCTO WHERE producto_gtin IN (1001, 1002, 1003);
DELETE FROM PRODUCTO WHERE gtin IN (1001, 1002, 1003);
DELETE FROM ATRIBUTO WHERE cuenta_id IN (1000, 1027);
DELETE FROM CUENTA WHERE id IN (1000, 1027);
DELETE FROM PLAN WHERE id = 10;
COMMIT;
*/
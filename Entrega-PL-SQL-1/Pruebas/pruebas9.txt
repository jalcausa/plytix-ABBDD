-- 1. Tabla de resultados de test
CREATE TABLE TEST_RESULTADOS (
    id_test       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_test   VARCHAR2(100),
    resultado     VARCHAR2(20),
    mensaje       VARCHAR2(500),
    fecha         DATE DEFAULT SYSDATE
);

-- 2. Procedimiento para insertar resultados
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

-- P_CREAR_CUENTA
CREATE OR REPLACE PROCEDURE P_RUN_TESTS_P_CREAR_USUARIO AS
    v_usuario USUARIO%ROWTYPE;
BEGIN
    -- Test 1: Crear usuario válido
    BEGIN
        v_usuario.id := 'TEST_USER_127';
        v_usuario.nombre := 'Usuario Prueba';
        v_usuario.creado := SYSDATE;
        v_usuario.cuenta_id := 127;

        PKG_ADMIN_PRODUCTOS.P_CREAR_USUARIO(v_usuario, 'R_USER_STD', 'Prueba123');
        P_INSERTAR_RESULTADO_TEST('P_CREAR_USUARIO - usuario válido', 'OK', 'Usuario creado correctamente');
    EXCEPTION
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('P_CREAR_USUARIO - usuario válido', 'FAIL', SQLERRM);
    END;

    -- Test 2: Usuario ya existente
    BEGIN
        v_usuario.id := 'TEST_EXISTENTE';
        v_usuario.nombre := 'Existente';
        v_usuario.creado := SYSDATE;
        v_usuario.cuenta_id := 27;

        -- Insert manual previo si es necesario
        INSERT INTO USUARIO VALUES v_usuario;

        PKG_ADMIN_PRODUCTOS.P_CREAR_USUARIO(v_usuario, 'R_USER_STD', 'Pass123');
        P_INSERTAR_RESULTADO_TEST('P_CREAR_USUARIO - usuario ya existe', 'FAIL', 'No se lanzó excepción');
    EXCEPTION
        WHEN PKG_ADMIN_PRODUCTOS.EXCEPTION_USUARIO_YA_EXISTENTE THEN
            P_INSERTAR_RESULTADO_TEST('P_CREAR_USUARIO - usuario ya existe', 'OK', 'Excepción capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('P_CREAR_USUARIO - usuario ya existe', 'FAIL', SQLERRM);
    END;

    -- Test 3: Rol inválido
    BEGIN
        v_usuario.id := 'TEST_ROL_INVALIDO';
        v_usuario.nombre := 'Rol Inválido';
        v_usuario.creado := SYSDATE;
        v_usuario.cuenta_id := 127;

        PKG_ADMIN_PRODUCTOS.P_CREAR_USUARIO(v_usuario, 'ROL_FANTASMA', 'Clave123');
        P_INSERTAR_RESULTADO_TEST('P_CREAR_USUARIO - rol inválido', 'FAIL', 'No se lanzó excepción');
    EXCEPTION
        WHEN PKG_ADMIN_PRODUCTOS.EXCEPTION_ROL_INEXISTENTE THEN
            P_INSERTAR_RESULTADO_TEST('P_CREAR_USUARIO - rol inválido', 'OK', 'Excepción capturada');
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('P_CREAR_USUARIO - rol inválido', 'FAIL', SQLERRM);
    END;

    -- Test 4: Usuario con valores nulos
    BEGIN
        v_usuario.id := NULL;
        v_usuario.nombre := NULL;
        v_usuario.creado := NULL;
        v_usuario.cuenta_id := NULL;

        PKG_ADMIN_PRODUCTOS.P_CREAR_USUARIO(v_usuario, 'R_USER_STD', NULL);
        P_INSERTAR_RESULTADO_TEST('P_CREAR_USUARIO - datos nulos', 'FAIL', 'No se lanzó excepción');
    EXCEPTION
        WHEN OTHERS THEN
            P_INSERTAR_RESULTADO_TEST('P_CREAR_USUARIO - datos nulos', 'OK', SQLERRM);
    END;
END;
/

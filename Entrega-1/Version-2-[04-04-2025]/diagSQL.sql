CREATE TABLE activos (
    id        INTEGER NOT NULL,
    nombre    VARCHAR2(50) NOT NULL,
    tamaño    INTEGER NOT NULL,
    tipo      VARCHAR2(50),
    url       VARCHAR2(100),
    cuenta_id INTEGER NOT NULL
);

ALTER TABLE activos 
ADD CONSTRAINT activos_pk PRIMARY KEY ( id, cuenta_id ) 
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE atributo_producto (
    valor              VARCHAR2(50) NOT NULL,
    producto_gtin      NUMBER NOT NULL,
    atributos_id       INTEGER NOT NULL,
    producto_cuenta_id INTEGER NOT NULL
);

ALTER TABLE atributo_producto
ADD CONSTRAINT atributo_producto_pk PRIMARY KEY ( producto_gtin,
                                                  producto_cuenta_id,
                                                  atributos_id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE atributos (
    id     INTEGER NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    tipo   VARCHAR2(50),
    creado DATE NOT NULL
);

ALTER TABLE atributos
ADD CONSTRAINT atributos_pk PRIMARY KEY ( id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE categoría (
    id        INTEGER NOT NULL,
    nombre    VARCHAR2(50) NOT NULL,
    cuenta_id INTEGER NOT NULL
);

ALTER TABLE categoría
ADD CONSTRAINT categoría_pk PRIMARY KEY ( id,
                                          cuenta_id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE categoria_activos (
    id        INTEGER NOT NULL,
    nombre    VARCHAR2(50) NOT NULL,
    cuenta_id INTEGER NOT NULL
);

ALTER TABLE categoria_activos
ADD CONSTRAINT categoria_activos_pk PRIMARY KEY ( id,
                                                  cuenta_id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE cuenta (
    id              INTEGER NOT NULL,
    nombre          VARCHAR2(50) NOT NULL,
    direccionfiscal VARCHAR2(50) NOT NULL,
    nif             VARCHAR2(9) NOT NULL,
    fechaalta       DATE NOT NULL,
    usuario_id      INTEGER,
    plan_id         INTEGER NOT NULL
);

CREATE UNIQUE INDEX cuenta__idx ON cuenta (usuario_id ASC) TABLESPACE TS_INDICES;

ALTER TABLE cuenta
ADD CONSTRAINT cuenta_pk PRIMARY KEY ( id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE plan (
    id                 INTEGER NOT NULL,
    nombre             VARCHAR(20) NOT NULL,
    productos          INTEGER NOT NULL,
    activos            INTEGER NOT NULL,
    almacenamiento     VARCHAR2(10) NOT NULL,
    categoriasproducto INTEGER NOT NULL,
    categoriasactivos  INTEGER NOT NULL,
    relaciones         INTEGER NOT NULL,
    precio             INTEGER NOT NULL
);

ALTER TABLE plan
ADD CONSTRAINT plan_pk PRIMARY KEY ( id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE producto (
    gtin       NUMBER NOT NULL,
    sku        VARCHAR2(100) NOT NULL,
    nombre     VARCHAR2(50) NOT NULL,
    miniatura  VARCHAR2(100),
    textocorto VARCHAR2(100),
    creado     DATE,
    modificado DATE,
    cuenta_id  INTEGER NOT NULL
);

ALTER TABLE producto
ADD CONSTRAINT producto_pk PRIMARY KEY ( gtin,
                                         cuenta_id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE relacionado (
    nombre              VARCHAR2(50) NOT NULL,
    sentido             VARCHAR2(50),
    producto_gtin       NUMBER NOT NULL,
    producto_gtin1      NUMBER NOT NULL,
    producto_cuenta_id  INTEGER NOT NULL,
    producto_cuenta_id1 INTEGER NOT NULL
);

ALTER TABLE relacionado
ADD CONSTRAINT relacionado_pk PRIMARY KEY ( producto_gtin,
                                            producto_cuenta_id,
                                            producto_gtin1,
                                            producto_cuenta_id1 )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE relation_16 (
    activos_id        INTEGER NOT NULL,
    activos_cuenta_id INTEGER NOT NULL,
    cat_act_id        INTEGER NOT NULL,
    cat_act_cuenta_id INTEGER NOT NULL
);

ALTER TABLE relation_16
ADD CONSTRAINT relation_16_pk PRIMARY KEY ( activos_id,
                                            activos_cuenta_id,
                                            cat_act_cuenta_id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE relation_4 (
    producto_gtin      NUMBER NOT NULL,
    producto_cuenta_id INTEGER NOT NULL,
    activos_id         INTEGER NOT NULL,
    activos_cuenta_id  INTEGER NOT NULL
);

ALTER TABLE relation_4
ADD CONSTRAINT relation_4_pk PRIMARY KEY ( producto_gtin,
                                           producto_cuenta_id,
                                           activos_id,
                                           activos_cuenta_id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE relation_7 (
    producto_gtin       NUMBER NOT NULL,
    producto_cuenta_id  INTEGER NOT NULL,
    categoría_id        INTEGER NOT NULL,
    categoría_cuenta_id INTEGER
);

ALTER TABLE relation_7
ADD CONSTRAINT relation_7_pk PRIMARY KEY ( producto_gtin,
                                           producto_cuenta_id,
                                           categoría_id,
                                           categoría_cuenta_id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE usuario (
    id             INTEGER NOT NULL,
    nombreusuario  VARCHAR2(20) NOT NULL,
    nombrecompleto VARCHAR2(50) NOT NULL,
    avatar         VARCHAR2(100),
    email          VARCHAR(50),
    teléfono       VARCHAR(20),
    cuenta_id      INTEGER NOT NULL
);

COMMENT ON COLUMN usuario.nombreusuario IS
    'Usuario con el que se conecta a la base de datos de Oracle';

ALTER TABLE usuario
ADD CONSTRAINT usuario_pk PRIMARY KEY ( id )
USING INDEX TABLESPACE TS_INDICES;

ALTER TABLE activos
    ADD CONSTRAINT activos_cuenta_fk FOREIGN KEY ( cuenta_id )
        REFERENCES cuenta ( id );

ALTER TABLE atributo_producto
    ADD CONSTRAINT atributo_producto_atributos_fk FOREIGN KEY ( atributos_id )
        REFERENCES atributos ( id );

ALTER TABLE atributo_producto
    ADD CONSTRAINT atributo_producto_producto_fk FOREIGN KEY ( producto_gtin,
                                                               producto_cuenta_id )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE categoria_activos
    ADD CONSTRAINT categoria_activos_cuenta_fk FOREIGN KEY ( cuenta_id )
        REFERENCES cuenta ( id );

ALTER TABLE categoría
    ADD CONSTRAINT categoría_cuenta_fk FOREIGN KEY ( cuenta_id )
        REFERENCES cuenta ( id );

ALTER TABLE cuenta
    ADD CONSTRAINT cuenta_plan_fk FOREIGN KEY ( plan_id )
        REFERENCES plan ( id );
        
ALTER TABLE cuenta
    ADD CONSTRAINT cuenta_usuario_fk FOREIGN KEY ( usuario_id )
        REFERENCES usuario ( id );

ALTER TABLE producto
    ADD CONSTRAINT producto_cuenta_fk FOREIGN KEY ( cuenta_id )
        REFERENCES cuenta ( id );

ALTER TABLE relacionado
    ADD CONSTRAINT relacionado_producto_fk FOREIGN KEY ( producto_gtin,
                                                         producto_cuenta_id )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE relacionado
    ADD CONSTRAINT relacionado_producto_fkv1 FOREIGN KEY ( producto_gtin1,
                                                           producto_cuenta_id1 )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE relation_16
    ADD CONSTRAINT relation_16_activos_fk FOREIGN KEY ( activos_id,
                                                        activos_cuenta_id )
        REFERENCES activos ( id,
                             cuenta_id );

ALTER TABLE relation_16
    ADD CONSTRAINT relation_16_cat_act_fk FOREIGN KEY ( cat_act_id,
                                                        cat_act_cuenta_id )
        REFERENCES categoria_activos ( id, cuenta_id );

ALTER TABLE relation_4
    ADD CONSTRAINT relation_4_activos_fk FOREIGN KEY ( activos_id,
                                                       activos_cuenta_id )
        REFERENCES activos ( id,
                             cuenta_id );

ALTER TABLE relation_4
    ADD CONSTRAINT relation_4_producto_fk FOREIGN KEY ( producto_gtin,
                                                        producto_cuenta_id )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE relation_7
    ADD CONSTRAINT relation_7_categoría_fk FOREIGN KEY ( categoría_id,
                                                         categoría_cuenta_id )
        REFERENCES categoría ( id,
                               cuenta_id );

ALTER TABLE relation_7
    ADD CONSTRAINT relation_7_producto_fk FOREIGN KEY ( producto_gtin,
                                                        producto_cuenta_id )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE usuario
    ADD CONSTRAINT usuario_cuenta_fk FOREIGN KEY ( cuenta_id )
        REFERENCES cuenta ( id );
-- Renombre de tablas y constraints
RENAME relation_4 TO producto_activo;
RENAME relation_7 TO producto_categoría;
RENAME relation_16 TO activo_categoria_activo;

ALTER TABLE producto_activo RENAME CONSTRAINT relation_4_pk TO producto_activo_pk;
ALTER TABLE producto_activo RENAME CONSTRAINT relation_4_activos_fk TO producto_activo_activo_fk;
ALTER TABLE producto_activo RENAME CONSTRAINT relation_4_producto_fk TO producto_activo_producto_fk;

ALTER TABLE producto_categoría RENAME CONSTRAINT relation_7_pk TO producto_categoría_pk;
ALTER TABLE producto_categoría RENAME CONSTRAINT relation_7_categoría_fk TO producto_categoría_categoría_fk;
ALTER TABLE producto_categoría RENAME CONSTRAINT relation_7_producto_fk TO producto_categoría_producto_fk;

ALTER TABLE activo_categoria_activo RENAME CONSTRAINT relation_16_pk TO activo_categoria_activo_pk;
ALTER TABLE activo_categoria_activo RENAME CONSTRAINT relation_16_activos_fk TO activo_categoria_activo_activo_fk;
ALTER TABLE activo_categoria_activo RENAME CONSTRAINT relation_16_cat_act_fk TO activo_categoria_activo_categoria_fk;
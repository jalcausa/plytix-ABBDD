CREATE TABLE activo (
    id        INTEGER NOT NULL,
    nombre    VARCHAR2(50) NOT NULL,
    tamanio    INTEGER NOT NULL,
    tipo      VARCHAR2(50),
    url       VARCHAR2(100),
    cuenta_id INTEGER NOT NULL
);

ALTER TABLE activo
ADD CONSTRAINT activo_pk PRIMARY KEY ( id, cuenta_id ) 
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE atributo_producto (
    valor              VARCHAR2(50) NOT NULL,
    producto_gtin      INTEGER NOT NULL,
    atributo_id       INTEGER NOT NULL,
    producto_cuenta_id INTEGER NOT NULL,
	atributo_cuenta_id INTEGER NOT NULL
);

ALTER TABLE atributo_producto
ADD CONSTRAINT atributo_producto_pk PRIMARY KEY ( producto_gtin,
                                                  producto_cuenta_id,
                                                  atributo_id,
												  atributo_cuenta_id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE atributo (
    id     INTEGER NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    tipo   VARCHAR2(50),
    creado DATE NOT NULL,
    cuenta_id INTEGER NOT NULL
);

ALTER TABLE atributo
ADD CONSTRAINT atributo_pk PRIMARY KEY (id, cuenta_id)
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE categoria (
    id        INTEGER NOT NULL,
    nombre    VARCHAR2(50) NOT NULL,
    cuenta_id INTEGER NOT NULL
);

ALTER TABLE categoria
ADD CONSTRAINT categoria_pk PRIMARY KEY ( id,
                                          cuenta_id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE categoria_activo (
    id        INTEGER NOT NULL,
    nombre    VARCHAR2(50) NOT NULL,
    cuenta_id INTEGER NOT NULL
);

ALTER TABLE categoria_activo
ADD CONSTRAINT categoria_activo_pk PRIMARY KEY ( id,
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

CREATE UNIQUE INDEX cuenta_idx ON cuenta (usuario_id ASC) TABLESPACE TS_INDICES;

ALTER TABLE cuenta
ADD CONSTRAINT cuenta_pk PRIMARY KEY ( id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE plan (
    id                 INTEGER NOT NULL,
    nombre             VARCHAR2(20) NOT NULL,
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
    gtin       INTEGER NOT NULL,
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
    producto_gtin       INTEGER NOT NULL,
    producto_gtin1      INTEGER NOT NULL,
    producto_cuenta_id  INTEGER NOT NULL,
    producto_cuenta_id1 INTEGER NOT NULL
);

ALTER TABLE relacionado
ADD CONSTRAINT relacionado_pk PRIMARY KEY ( producto_gtin,
                                            producto_cuenta_id,
                                            producto_gtin1,
                                            producto_cuenta_id1 )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE activo_categoria_activo (
    activo_id        INTEGER NOT NULL,
    activo_cuenta_id INTEGER NOT NULL,
    cat_act_id        INTEGER NOT NULL,
    cat_act_cuenta_id INTEGER NOT NULL
);

ALTER TABLE activo_categoria_activo
ADD CONSTRAINT activo_categoria_activo_pk PRIMARY KEY ( activo_id,
                                            activo_cuenta_id,
											cat_act_id,
                                            cat_act_cuenta_id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE producto_activo (
    producto_gtin      INTEGER NOT NULL,
    producto_cuenta_id INTEGER NOT NULL,
    activo_id         INTEGER NOT NULL,
    activo_cuenta_id  INTEGER NOT NULL
);

ALTER TABLE producto_activo
ADD CONSTRAINT producto_activo_pk PRIMARY KEY ( producto_gtin,
                                           producto_cuenta_id,
                                           activo_id,
                                           activo_cuenta_id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE producto_categoria (
    producto_gtin       INTEGER NOT NULL,
    producto_cuenta_id  INTEGER NOT NULL,
    categoria_id        INTEGER NOT NULL,
    categoria_cuenta_id INTEGER NOT NULL
);

ALTER TABLE producto_categoria
ADD CONSTRAINT producto_categoria_pk PRIMARY KEY ( producto_gtin,
                                           producto_cuenta_id,
                                           categoria_id,
                                           categoria_cuenta_id )
USING INDEX TABLESPACE TS_INDICES;

CREATE TABLE usuario (
    id             INTEGER NOT NULL,
    nombreusuario  VARCHAR2(20) NOT NULL,
    nombrecompleto VARCHAR2(50) NOT NULL,
    avatar         VARCHAR2(100),
    email          VARCHAR2(50),
    telefono       VARCHAR2(20),
    cuenta_id      INTEGER NOT NULL
);

COMMENT ON COLUMN usuario.nombreusuario IS
    'Usuario con el que se conecta a la base de datos de Oracle';

ALTER TABLE usuario
ADD CONSTRAINT usuario_pk PRIMARY KEY ( id )
USING INDEX TABLESPACE TS_INDICES;

ALTER TABLE activo
    ADD CONSTRAINT activo_cuenta_fk FOREIGN KEY ( cuenta_id )
        REFERENCES cuenta ( id );

ALTER TABLE atributo_producto
    ADD CONSTRAINT atributo_producto_atributo_fk FOREIGN KEY 
( atributo_id, atributo_cuenta_id )
       REFERENCES atributo ( id, cuenta_id );

ALTER TABLE atributo_producto
    ADD CONSTRAINT atributo_producto_producto_fk FOREIGN KEY ( producto_gtin,
                                                               producto_cuenta_id )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE categoria_activo
    ADD CONSTRAINT categoria_activo_cuenta_fk FOREIGN KEY ( cuenta_id )
        REFERENCES cuenta ( id );

ALTER TABLE categoria
    ADD CONSTRAINT categoria_cuenta_fk FOREIGN KEY ( cuenta_id )
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

ALTER TABLE activo_categoria_activo
    ADD CONSTRAINT act_cat_activo_activo_fk FOREIGN KEY ( activo_id,
                                                        activo_cuenta_id )
        REFERENCES activo ( id,
                             cuenta_id );

ALTER TABLE activo_categoria_activo
    ADD CONSTRAINT act_cat_activo_cat_act_fk FOREIGN KEY ( cat_act_id,
                                                        cat_act_cuenta_id )
        REFERENCES categoria_activo ( id, cuenta_id );

ALTER TABLE producto_activo
    ADD CONSTRAINT producto_activo_activo_fk FOREIGN KEY ( activo_id,
                                                       activo_cuenta_id )
        REFERENCES activo ( id,
                             cuenta_id );

ALTER TABLE producto_activo
    ADD CONSTRAINT producto_activo_producto_fk FOREIGN KEY ( producto_gtin,
                                                        producto_cuenta_id )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE producto_categoria
    ADD CONSTRAINT prod_categoria_categoria_fk FOREIGN KEY ( categoria_id,
                                                         categoria_cuenta_id )
        REFERENCES categoria ( id,
                               cuenta_id );

ALTER TABLE producto_categoria
    ADD CONSTRAINT prod_categoria_producto_fk FOREIGN KEY ( producto_gtin,
                                                        producto_cuenta_id )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE usuario
    ADD CONSTRAINT usuario_cuenta_fk FOREIGN KEY ( cuenta_id )
        REFERENCES cuenta ( id );

ALTER TABLE atributo
    ADD CONSTRAINT atributo_cuenta_fk FOREIGN KEY (cuenta_id)
    REFERENCES cuenta( id );


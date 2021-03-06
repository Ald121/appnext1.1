PGDMP                     
    t            NBPRE    9.5.5    9.5.5 "    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false                        2615    36485    administracion    SCHEMA        CREATE SCHEMA administracion;
    DROP SCHEMA administracion;
             postgres    false            �            1259    45870    empresas    TABLE     ^  CREATE TABLE empresas (
    id integer NOT NULL,
    razon_social character varying(250) NOT NULL,
    actividad_economica character varying(750),
    ruc_ci character varying(25) NOT NULL,
    nombre_comercial character varying(250),
    id_estado character varying(5) NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL
);
 $   DROP TABLE administracion.empresas;
       administracion         postgres    false    14            �           0    0    COLUMN empresas.id    COMMENT     J   COMMENT ON COLUMN empresas.id IS 'define el identificador de la empresa';
            administracion       postgres    false    250            �           0    0    COLUMN empresas.razon_social    COMMENT     S   COMMENT ON COLUMN empresas.razon_social IS 'define la razon social de la empresa';
            administracion       postgres    false    250            �           0    0 #   COLUMN empresas.actividad_economica    COMMENT     `   COMMENT ON COLUMN empresas.actividad_economica IS 'actividad economica que realiza la empresa';
            administracion       postgres    false    250            �           0    0    COLUMN empresas.ruc_ci    COMMENT     T   COMMENT ON COLUMN empresas.ruc_ci IS 'ruc o cedula dependiendo el tipo de usuario';
            administracion       postgres    false    250            �           0    0     COLUMN empresas.nombre_comercial    COMMENT     ^   COMMENT ON COLUMN empresas.nombre_comercial IS 'nombre con el que se le conoce a la empresa';
            administracion       postgres    false    250            �           0    0    COLUMN empresas.id_estado    COMMENT     b   COMMENT ON COLUMN empresas.id_estado IS 'define el estado de la empresa para el sistema Nexbook';
            administracion       postgres    false    250            �            1259    45868    empresas_id_seq    SEQUENCE     q   CREATE SEQUENCE empresas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE administracion.empresas_id_seq;
       administracion       postgres    false    14    250            �           0    0    empresas_id_seq    SEQUENCE OWNED BY     5   ALTER SEQUENCE empresas_id_seq OWNED BY empresas.id;
            administracion       postgres    false    249                        1259    47146    imagen_empresa    TABLE     �   CREATE TABLE imagen_empresa (
    id integer NOT NULL,
    empresa integer NOT NULL,
    direccion_imagen_empresa character varying(500) NOT NULL,
    estado character varying(5) NOT NULL,
    fecha time with time zone DEFAULT now() NOT NULL
);
 *   DROP TABLE administracion.imagen_empresa;
       administracion         postgres    false    14            �            1259    47144    imagen_empresa_id_seq    SEQUENCE     w   CREATE SEQUENCE imagen_empresa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE administracion.imagen_empresa_id_seq;
       administracion       postgres    false    256    14            �           0    0    imagen_empresa_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE imagen_empresa_id_seq OWNED BY imagen_empresa.id;
            administracion       postgres    false    255            �            1259    47076 
   sucursales    TABLE     �   CREATE TABLE sucursales (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    responsable integer NOT NULL,
    lugar character varying(15) NOT NULL,
    calle character varying(250) NOT NULL,
    numero character varying(10)
);
 &   DROP TABLE administracion.sucursales;
       administracion         postgres    false    14            �            1259    47074    sucursales_id_seq    SEQUENCE     s   CREATE SEQUENCE sucursales_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE administracion.sucursales_id_seq;
       administracion       postgres    false    252    14            �           0    0    sucursales_id_seq    SEQUENCE OWNED BY     9   ALTER SEQUENCE sucursales_id_seq OWNED BY sucursales.id;
            administracion       postgres    false    251            ,           2604    45873    id    DEFAULT     \   ALTER TABLE ONLY empresas ALTER COLUMN id SET DEFAULT nextval('empresas_id_seq'::regclass);
 B   ALTER TABLE administracion.empresas ALTER COLUMN id DROP DEFAULT;
       administracion       postgres    false    250    249    250            /           2604    47149    id    DEFAULT     h   ALTER TABLE ONLY imagen_empresa ALTER COLUMN id SET DEFAULT nextval('imagen_empresa_id_seq'::regclass);
 H   ALTER TABLE administracion.imagen_empresa ALTER COLUMN id DROP DEFAULT;
       administracion       postgres    false    255    256    256            .           2604    47079    id    DEFAULT     `   ALTER TABLE ONLY sucursales ALTER COLUMN id SET DEFAULT nextval('sucursales_id_seq'::regclass);
 D   ALTER TABLE administracion.sucursales ALTER COLUMN id DROP DEFAULT;
       administracion       postgres    false    252    251    252            �          0    45870    empresas 
   TABLE DATA               w   COPY empresas (id, razon_social, actividad_economica, ruc_ci, nombre_comercial, id_estado, fecha_creacion) FROM stdin;
    administracion       postgres    false    250   �%       �           0    0    empresas_id_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('empresas_id_seq', 1, false);
            administracion       postgres    false    249            �          0    47146    imagen_empresa 
   TABLE DATA               W   COPY imagen_empresa (id, empresa, direccion_imagen_empresa, estado, fecha) FROM stdin;
    administracion       postgres    false    256   &       �           0    0    imagen_empresa_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('imagen_empresa_id_seq', 1, false);
            administracion       postgres    false    255            �          0    47076 
   sucursales 
   TABLE DATA               L   COPY sucursales (id, nombre, responsable, lugar, calle, numero) FROM stdin;
    administracion       postgres    false    252   0&       �           0    0    sucursales_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('sucursales_id_seq', 1, false);
            administracion       postgres    false    251            2           2606    45879    empresas_PK 
   CONSTRAINT     M   ALTER TABLE ONLY empresas
    ADD CONSTRAINT "empresas_PK" PRIMARY KEY (id);
 H   ALTER TABLE ONLY administracion.empresas DROP CONSTRAINT "empresas_PK";
       administracion         postgres    false    250    250            8           2606    47155    imagen_empresa_PK 
   CONSTRAINT     Y   ALTER TABLE ONLY imagen_empresa
    ADD CONSTRAINT "imagen_empresa_PK" PRIMARY KEY (id);
 T   ALTER TABLE ONLY administracion.imagen_empresa DROP CONSTRAINT "imagen_empresa_PK";
       administracion         postgres    false    256    256            6           2606    47081    sucursales_PK 
   CONSTRAINT     Q   ALTER TABLE ONLY sucursales
    ADD CONSTRAINT "sucursales_PK" PRIMARY KEY (id);
 L   ALTER TABLE ONLY administracion.sucursales DROP CONSTRAINT "sucursales_PK";
       administracion         postgres    false    252    252            4           2606    45881    valor_unico 
   CONSTRAINT     P   ALTER TABLE ONLY empresas
    ADD CONSTRAINT valor_unico UNIQUE (razon_social);
 F   ALTER TABLE ONLY administracion.empresas DROP CONSTRAINT valor_unico;
       administracion         postgres    false    250    250            9           2606    45882    estado_empresa_FK    FK CONSTRAINT     x   ALTER TABLE ONLY empresas
    ADD CONSTRAINT "estado_empresa_FK" FOREIGN KEY (id_estado) REFERENCES public.estados(id);
 N   ALTER TABLE ONLY administracion.empresas DROP CONSTRAINT "estado_empresa_FK";
       administracion       postgres    false    250            :           2606    47156    imagen_empresa_dir_FK    FK CONSTRAINT     z   ALTER TABLE ONLY imagen_empresa
    ADD CONSTRAINT "imagen_empresa_dir_FK" FOREIGN KEY (empresa) REFERENCES empresas(id);
 X   ALTER TABLE ONLY administracion.imagen_empresa DROP CONSTRAINT "imagen_empresa_dir_FK";
       administracion       postgres    false    3122    256    250            ;           2606    47161    imagen_empresa_estado_FK    FK CONSTRAINT     �   ALTER TABLE ONLY imagen_empresa
    ADD CONSTRAINT "imagen_empresa_estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);
 [   ALTER TABLE ONLY administracion.imagen_empresa DROP CONSTRAINT "imagen_empresa_estado_FK";
       administracion       postgres    false    256            �      x������ � �      �      x������ � �      �      x������ � �     
PGDMP     ;                
    t            NBPRE    9.5.5    9.5.5 
    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false                        2615    16401    usuarios    SCHEMA        CREATE SCHEMA usuarios;
    DROP SCHEMA usuarios;
             postgres    false            �            1259    16632    usuarios    TABLE       CREATE TABLE usuarios (
    id character varying NOT NULL,
    nick character varying(50),
    clave_clave character varying(75),
    id_estado character varying(5),
    fecha_creacion timestamp with time zone,
    estado_clave boolean DEFAULT true NOT NULL
);
    DROP TABLE usuarios.usuarios;
       usuarios         postgres    false    11            �           0    0    COLUMN usuarios.id    COMMENT     C   COMMENT ON COLUMN usuarios.id IS 'id usuario del sistema Nexboot';
            usuarios       postgres    false    238            �           0    0    COLUMN usuarios.clave_clave    COMMENT     I   COMMENT ON COLUMN usuarios.clave_clave IS 'define la clave del usuario';
            usuarios       postgres    false    238            �           0    0    COLUMN usuarios.id_estado    COMMENT     >   COMMENT ON COLUMN usuarios.id_estado IS 'estado del usuario';
            usuarios       postgres    false    238            �           0    0    COLUMN usuarios.fecha_creacion    COMMENT     V   COMMENT ON COLUMN usuarios.fecha_creacion IS 'fecha en la que fue creado el usuario';
            usuarios       postgres    false    238            �          0    16632    usuarios 
   TABLE DATA               [   COPY usuarios (id, nick, clave_clave, id_estado, fecha_creacion, estado_clave) FROM stdin;
    usuarios       postgres    false    238   ;	       /           2606    16766    usuarios_PK 
   CONSTRAINT     M   ALTER TABLE ONLY usuarios
    ADD CONSTRAINT "usuarios_PK" PRIMARY KEY (id);
 B   ALTER TABLE ONLY usuarios.usuarios DROP CONSTRAINT "usuarios_PK";
       usuarios         postgres    false    238    238            �      x������ � �     
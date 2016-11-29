--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.5
-- Dumped by pg_dump version 9.5.5

-- Started on 2016-11-24 15:58:29 ECT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 16396)
-- Name: auditoria; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auditoria;


ALTER SCHEMA auditoria OWNER TO postgres;

--
-- TOC entry 3476 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA auditoria; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA auditoria IS 'auditoria de los cambios en la bd';


--
-- TOC entry 8 (class 2615 OID 16397)
-- Name: contabilidad; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA contabilidad;


ALTER SCHEMA contabilidad OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 16399)
-- Name: inventario; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA inventario;


ALTER SCHEMA inventario OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 16400)
-- Name: talento_humano; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA talento_humano;


ALTER SCHEMA talento_humano OWNER TO postgres;

--
-- TOC entry 11 (class 2615 OID 16401)
-- Name: usuarios; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA usuarios;


ALTER SCHEMA usuarios OWNER TO postgres;

--
-- TOC entry 12 (class 2615 OID 16402)
-- Name: ventas; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ventas;


ALTER SCHEMA ventas OWNER TO postgres;

--
-- TOC entry 1 (class 3079 OID 13276)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3479 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 264 (class 1255 OID 16408)
-- Name: f_convnl(numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_convnl(num numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
-- Función que devuelve la cadena de texto en castellano que corresponde a un número.
-- Parámetros: número con 2 decimales, máximo 999.999.999,99.

DECLARE	
	d varchar[];
	f varchar[];
	g varchar[];
	numt varchar;
	txt varchar;
	a integer;
	a1 integer;
	a2 integer;
	n integer;
	p integer;
	negativo boolean;
BEGIN
	-- Máximo 999.999.999,99
	if num > 999999999.99 then
		return '---';
	end if;
	txt = '';
	d = array[' un',' dos',' tres',' cuatro',' cinco',' seis',' siete',' ocho',' nueve',' diez',' once',' doce',' trece',' catorce',' quince',
		' dieciseis',' diecisiete',' dieciocho',' diecinueve',' veinte',' veintiun',' veintidos', ' veintitres', ' veinticuatro', ' veinticinco',
		' veintiseis',' veintisiete',' veintiocho',' veintinueve'];
	f = array ['','',' treinta',' cuarenta',' cincuenta',' sesenta',' setenta',' ochenta', ' noventa'];
	g= array [' ciento',' doscientos',' trescientos',' cuatrocientos',' quinientos',' seiscientos',' setecientos',' ochocientos',' novecientos'];
	numt = lpad((num::numeric(12,2))::text,12,'0');
	if strpos(numt,'-') > 0 then
	   negativo = true;
	else
	   negativo = false;
	end if;
	numt = translate(numt,'-','0');
	numt = translate(numt,'.,','');
	-- Trato 4 grupos: millones, miles, unidades y decimales
	p = 1;
	for i in 1..4 loop
		if i < 4 then
			n = substring(numt::text from p for 3);
		else
			n = substring(numt::text from p for 2);
		end if;
		p = p + 3;
		if i = 4 then
			if txt = '' then
				txt = ' cero';
			end if;
			if n > 0 then
			-- Empieza con los decimales
				txt = txt || ' con';
			end if;
		end if;
		-- Centenas 
		if n > 99 then
			a = substring(n::text from 1 for 1);
			a1 = substring(n::text from 2 for 2);
			if a = 1 then
				if a1 = 0 then
					txt = txt || ' cien';
				else
					txt = txt || ' ciento';
				end if;
			else
				txt = txt || g[a];
			end if;
		else
			a1 = n;
		end if;
		-- Decenas
		a = a1;
		if a > 0 then
			if a < 30 then
				if a = 21 and (i = 3 or i = 4) then
					txt = txt || ' veintiuno';
				elsif n = 1 and i = 2 then
					txt = txt; 
				elsif a = 1 and (i = 3 or i = 4)then
					txt = txt || ' uno';
				else
					txt = txt || d[a];
				end if;
			else
				a1 = substring(a::text from 1 for 1);
				a2 = substring(a::text from 2 for 1);
				if a2 = 1 and (i = 3 or i = 4) then
						txt = txt || f[a1] || ' y' || ' uno';
				else
					if a2 <> 0 then
						txt = txt || f[a1] || ' y' || d[a2];
					else
						txt = txt || f[a1];
					end if;
				end if;
			end if;
		end if;
		if n > 0 then
			if i = 1 then
				if n = 1 then
					txt = txt || ' millón';
				else
					txt = txt || ' millones';
				end if;
			elsif i = 2 then
				txt = txt || ' mil';
			end if;		
		end if;
	end loop;
	txt = ltrim(txt);
	if negativo = true then
	   txt= '-' || txt;
	end if;
    RETURN txt;
END;
$$;


ALTER FUNCTION public.f_convnl(num numeric) OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 16409)
-- Name: fun_auditoria(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_auditoria() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO auditoria.auditoria ("tabla_afectada", "operacion", "variable_anterior", "variable_nueva", "fecha", "usuario")
           VALUES (TG_TABLE_NAME, 'D', OLD, NULL, now(), USER);
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO auditoria.auditoria ("tabla_afectada", "operacion", "variable_anterior", "variable_nueva", "fecha", "usuario")
           VALUES (TG_TABLE_NAME, 'U', OLD, NEW, now(), USER);
    RETURN NEW;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO auditoria.auditoria ("tabla_afectada", "operacion", "variable_anterior", "variable_nueva", "fecha", "usuario")
           VALUES (TG_TABLE_NAME, 'I', NULL, NEW, now(), USER);
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION public.fun_auditoria() OWNER TO postgres;

SET search_path = auditoria, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 187 (class 1259 OID 16422)
-- Name: auditoria; Type: TABLE; Schema: auditoria; Owner: postgres
--

CREATE TABLE auditoria (
    id integer NOT NULL,
    tabla_afectada character(45) NOT NULL,
    operacion character(1) NOT NULL,
    variable_anterior text,
    variable_nueva text,
    fecha timestamp without time zone NOT NULL,
    usuario character(45) NOT NULL
);


ALTER TABLE auditoria OWNER TO postgres;

--
-- TOC entry 3480 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN auditoria.id; Type: COMMENT; Schema: auditoria; Owner: postgres
--

COMMENT ON COLUMN auditoria.id IS 'define el identificador de la tabla auditoria';


--
-- TOC entry 3481 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN auditoria.tabla_afectada; Type: COMMENT; Schema: auditoria; Owner: postgres
--

COMMENT ON COLUMN auditoria.tabla_afectada IS 'almacena el nombre de la tabla que fue afectada';


--
-- TOC entry 3482 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN auditoria.operacion; Type: COMMENT; Schema: auditoria; Owner: postgres
--

COMMENT ON COLUMN auditoria.operacion IS 'guarda la operacion realizada, I insertar / U actualizar/ D borrar  ';


--
-- TOC entry 3483 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN auditoria.variable_anterior; Type: COMMENT; Schema: auditoria; Owner: postgres
--

COMMENT ON COLUMN auditoria.variable_anterior IS 'almacena los valores viejos';


--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN auditoria.variable_nueva; Type: COMMENT; Schema: auditoria; Owner: postgres
--

COMMENT ON COLUMN auditoria.variable_nueva IS 'almacena los valores nuevos';


--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN auditoria.fecha; Type: COMMENT; Schema: auditoria; Owner: postgres
--

COMMENT ON COLUMN auditoria.fecha IS 'almacena la fecha de modificacion de los datos';


--
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN auditoria.usuario; Type: COMMENT; Schema: auditoria; Owner: postgres
--

COMMENT ON COLUMN auditoria.usuario IS 'almacena el usuario de la BDD';


--
-- TOC entry 188 (class 1259 OID 16428)
-- Name: auditoria_id_seq; Type: SEQUENCE; Schema: auditoria; Owner: postgres
--

CREATE SEQUENCE auditoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auditoria_id_seq OWNER TO postgres;

--
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 188
-- Name: auditoria_id_seq; Type: SEQUENCE OWNED BY; Schema: auditoria; Owner: postgres
--

ALTER SEQUENCE auditoria_id_seq OWNED BY auditoria.id;


--
-- TOC entry 189 (class 1259 OID 16430)
-- Name: ingresos_usuarios; Type: TABLE; Schema: auditoria; Owner: postgres
--

CREATE TABLE ingresos_usuarios (
    id integer NOT NULL,
    usuario character varying(100) NOT NULL,
    informacion_servidor json NOT NULL,
    fecha timestamp with time zone NOT NULL,
    ip_acceso json NOT NULL
);


ALTER TABLE ingresos_usuarios OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 16436)
-- Name: ingresos_usuarios_id_seq; Type: SEQUENCE; Schema: auditoria; Owner: postgres
--

CREATE SEQUENCE ingresos_usuarios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ingresos_usuarios_id_seq OWNER TO postgres;

--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 190
-- Name: ingresos_usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: auditoria; Owner: postgres
--

ALTER SEQUENCE ingresos_usuarios_id_seq OWNED BY ingresos_usuarios.id;


SET search_path = contabilidad, pg_catalog;

--
-- TOC entry 191 (class 1259 OID 16438)
-- Name: ambitos_impuestos; Type: TABLE; Schema: contabilidad; Owner: postgres
--

CREATE TABLE ambitos_impuestos (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE ambitos_impuestos OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 16441)
-- Name: ambitos_impuestos_id_seq; Type: SEQUENCE; Schema: contabilidad; Owner: postgres
--

CREATE SEQUENCE ambitos_impuestos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ambitos_impuestos_id_seq OWNER TO postgres;

--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 192
-- Name: ambitos_impuestos_id_seq; Type: SEQUENCE OWNED BY; Schema: contabilidad; Owner: postgres
--

ALTER SEQUENCE ambitos_impuestos_id_seq OWNED BY ambitos_impuestos.id;


--
-- TOC entry 193 (class 1259 OID 16443)
-- Name: genealogia_impuestos; Type: TABLE; Schema: contabilidad; Owner: postgres
--

CREATE TABLE genealogia_impuestos (
    id_impuesto_padre integer NOT NULL,
    id_impuesto_hijo integer NOT NULL
);


ALTER TABLE genealogia_impuestos OWNER TO postgres;

--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 193
-- Name: TABLE genealogia_impuestos; Type: COMMENT; Schema: contabilidad; Owner: postgres
--

COMMENT ON TABLE genealogia_impuestos IS 'define el arbol de los impuestos para el grupo';


--
-- TOC entry 194 (class 1259 OID 16446)
-- Name: grupo_impuestos; Type: TABLE; Schema: contabilidad; Owner: postgres
--

CREATE TABLE grupo_impuestos (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE grupo_impuestos OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 16449)
-- Name: grupo_impuestos_id_seq; Type: SEQUENCE; Schema: contabilidad; Owner: postgres
--

CREATE SEQUENCE grupo_impuestos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE grupo_impuestos_id_seq OWNER TO postgres;

--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 195
-- Name: grupo_impuestos_id_seq; Type: SEQUENCE OWNED BY; Schema: contabilidad; Owner: postgres
--

ALTER SEQUENCE grupo_impuestos_id_seq OWNED BY grupo_impuestos.id;


--
-- TOC entry 196 (class 1259 OID 16451)
-- Name: impuestos; Type: TABLE; Schema: contabilidad; Owner: postgres
--

CREATE TABLE impuestos (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    descripcion character varying(2000) NOT NULL,
    cantidad int4range NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL,
    ambito integer NOT NULL
);


ALTER TABLE impuestos OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 16457)
-- Name: impuestos_id_seq; Type: SEQUENCE; Schema: contabilidad; Owner: postgres
--

CREATE SEQUENCE impuestos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE impuestos_id_seq OWNER TO postgres;

--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 197
-- Name: impuestos_id_seq; Type: SEQUENCE OWNED BY; Schema: contabilidad; Owner: postgres
--

ALTER SEQUENCE impuestos_id_seq OWNED BY impuestos.id;


SET search_path = inventario, pg_catalog;

--
-- TOC entry 198 (class 1259 OID 16468)
-- Name: catalogos; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE catalogos (
    id integer NOT NULL,
    tipo_catalogo integer NOT NULL,
    producto integer NOT NULL
);


ALTER TABLE catalogos OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 16471)
-- Name: catalogos_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE catalogos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE catalogos_id_seq OWNER TO postgres;

--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 199
-- Name: catalogos_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE catalogos_id_seq OWNED BY catalogos.id;


--
-- TOC entry 200 (class 1259 OID 16473)
-- Name: categorias; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE categorias (
    id integer NOT NULL,
    nombre character varying(50),
    descripcion character varying(2000) NOT NULL,
    tipo_categoria integer NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE categorias OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 16479)
-- Name: categorias_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE categorias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE categorias_id_seq OWNER TO postgres;

--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 201
-- Name: categorias_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE categorias_id_seq OWNED BY categorias.id;


--
-- TOC entry 202 (class 1259 OID 16481)
-- Name: descripcion_producto; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE descripcion_producto (
    id integer NOT NULL,
    producto integer NOT NULL,
    descripcion_corta character varying(2000) NOT NULL,
    descripcion_proveedor character varying(4000) NOT NULL,
    descripcion_proformas character varying(4000) NOT NULL,
    descripcion_movi_inventa character varying(4000) NOT NULL
);


ALTER TABLE descripcion_producto OWNER TO postgres;

--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN descripcion_producto.descripcion_corta; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN descripcion_producto.descripcion_corta IS 'descripcion en caso de ubicar en la factura';


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN descripcion_producto.descripcion_proveedor; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN descripcion_producto.descripcion_proveedor IS 'descripcion para poner en solicitud del proveedor';


--
-- TOC entry 203 (class 1259 OID 16487)
-- Name: descripcion_producto_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE descripcion_producto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE descripcion_producto_id_seq OWNER TO postgres;

--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 203
-- Name: descripcion_producto_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE descripcion_producto_id_seq OWNED BY descripcion_producto.id;


--
-- TOC entry 204 (class 1259 OID 16489)
-- Name: estado_descriptivo; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE estado_descriptivo (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    descripcion character varying(2000) NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE estado_descriptivo OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 16495)
-- Name: estado_descriptivo_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE estado_descriptivo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE estado_descriptivo_id_seq OWNER TO postgres;

--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 205
-- Name: estado_descriptivo_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE estado_descriptivo_id_seq OWNED BY estado_descriptivo.id;


--
-- TOC entry 206 (class 1259 OID 16497)
-- Name: garantias; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE garantias (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion character varying(2000),
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL,
    tipo_garantia integer NOT NULL,
    duracion integer NOT NULL
);


ALTER TABLE garantias OWNER TO postgres;

--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN garantias.duracion; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN garantias.duracion IS 'duracion en meses de la garantia';


--
-- TOC entry 207 (class 1259 OID 16503)
-- Name: garantias_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE garantias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE garantias_id_seq OWNER TO postgres;

--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 207
-- Name: garantias_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE garantias_id_seq OWNED BY garantias.id;


--
-- TOC entry 208 (class 1259 OID 16505)
-- Name: imagenes_productos; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE imagenes_productos (
    id character varying(25) NOT NULL,
    nombre character varying(50) NOT NULL,
    direccion character varying(250) NOT NULL,
    tipo_imagen integer NOT NULL,
    estado character varying(5) NOT NULL,
    fecha time without time zone DEFAULT now() NOT NULL,
    producto integer NOT NULL
);


ALTER TABLE imagenes_productos OWNER TO postgres;

--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN imagenes_productos.id; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN imagenes_productos.id IS 'identificador';


--
-- TOC entry 3502 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN imagenes_productos.nombre; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN imagenes_productos.nombre IS 'nombre de la imagen';


--
-- TOC entry 3503 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN imagenes_productos.direccion; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN imagenes_productos.direccion IS 'direccion donde se encuentra la imagen';


--
-- TOC entry 3504 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN imagenes_productos.tipo_imagen; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN imagenes_productos.tipo_imagen IS 'codigo del tipo de imagen';


--
-- TOC entry 209 (class 1259 OID 16509)
-- Name: marcas; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE marcas (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion character varying(2000) NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE marcas OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 16515)
-- Name: marcas_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE marcas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE marcas_id_seq OWNER TO postgres;

--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 210
-- Name: marcas_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE marcas_id_seq OWNED BY marcas.id;


--
-- TOC entry 211 (class 1259 OID 16517)
-- Name: modelos; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE modelos (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    descripcion character varying(2000) NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE modelos OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 16523)
-- Name: modelos_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE modelos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE modelos_id_seq OWNER TO postgres;

--
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 212
-- Name: modelos_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE modelos_id_seq OWNED BY modelos.id;


--
-- TOC entry 213 (class 1259 OID 16525)
-- Name: productos; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE productos (
    id integer NOT NULL,
    nombre_corto character varying(50) NOT NULL,
    vendible boolean NOT NULL,
    comprable boolean NOT NULL,
    precio money NOT NULL,
    costo money,
    estado_descriptivo integer NOT NULL,
    categoria integer NOT NULL,
    garantia integer NOT NULL,
    marca integer NOT NULL,
    modelo integer NOT NULL,
    ubicacion integer NOT NULL,
    cantidad integer NOT NULL,
    descripcion character varying(500) NOT NULL,
    codigo_baras character varying(15),
    tipo_consumo integer NOT NULL
);


ALTER TABLE productos OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16531)
-- Name: productos_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE productos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE productos_id_seq OWNER TO postgres;

--
-- TOC entry 3507 (class 0 OID 0)
-- Dependencies: 214
-- Name: productos_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE productos_id_seq OWNED BY productos.id;


--
-- TOC entry 215 (class 1259 OID 16533)
-- Name: productos_impuestos; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE productos_impuestos (
    id smallint NOT NULL,
    producto integer NOT NULL,
    inpuesto integer NOT NULL
);


ALTER TABLE productos_impuestos OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16536)
-- Name: proveedores; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE proveedores (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    ruc character varying(15) NOT NULL,
    direccion character varying(250) NOT NULL
);


ALTER TABLE proveedores OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16542)
-- Name: proveedores_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE proveedores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE proveedores_id_seq OWNER TO postgres;

--
-- TOC entry 3508 (class 0 OID 0)
-- Dependencies: 217
-- Name: proveedores_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE proveedores_id_seq OWNED BY proveedores.id;


--
-- TOC entry 218 (class 1259 OID 16544)
-- Name: sucursal; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE sucursal (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    id_localidad character varying(25) NOT NULL,
    id_responsable character varying(25) NOT NULL,
    fecha timestamp with time zone NOT NULL,
    estado character varying(5) NOT NULL
);


ALTER TABLE sucursal OWNER TO postgres;

--
-- TOC entry 3509 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN sucursal.id; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN sucursal.id IS 'identificados untoincremental';


--
-- TOC entry 3510 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN sucursal.nombre; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN sucursal.nombre IS 'nombre de la bodega';


--
-- TOC entry 3511 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN sucursal.id_localidad; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN sucursal.id_localidad IS 'lugar direccion de la bodega';


--
-- TOC entry 3512 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN sucursal.id_responsable; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN sucursal.id_responsable IS 'persona responsable de la bodega';


--
-- TOC entry 3513 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN sucursal.fecha; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN sucursal.fecha IS 'fecha de creacion de la bodega en el sistema';


--
-- TOC entry 3514 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN sucursal.estado; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN sucursal.estado IS 'estado de la bodega';


--
-- TOC entry 219 (class 1259 OID 16547)
-- Name: sucursal_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE sucursal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sucursal_id_seq OWNER TO postgres;

--
-- TOC entry 3515 (class 0 OID 0)
-- Dependencies: 219
-- Name: sucursal_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE sucursal_id_seq OWNED BY sucursal.id;


--
-- TOC entry 220 (class 1259 OID 16549)
-- Name: tipo_consumo; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE tipo_consumo (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion character varying(2000) NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE tipo_consumo OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16555)
-- Name: tipo_consumo_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE tipo_consumo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tipo_consumo_id_seq OWNER TO postgres;

--
-- TOC entry 3516 (class 0 OID 0)
-- Dependencies: 221
-- Name: tipo_consumo_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE tipo_consumo_id_seq OWNED BY tipo_consumo.id;


--
-- TOC entry 222 (class 1259 OID 16557)
-- Name: tipos_catalogos; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE tipos_catalogos (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    descripcion character varying(2000) NOT NULL,
    fecha_inicio timestamp with time zone NOT NULL,
    fecha_fin timestamp with time zone NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE tipos_catalogos OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16563)
-- Name: tipos_catalogos_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE tipos_catalogos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tipos_catalogos_id_seq OWNER TO postgres;

--
-- TOC entry 3517 (class 0 OID 0)
-- Dependencies: 223
-- Name: tipos_catalogos_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE tipos_catalogos_id_seq OWNED BY tipos_catalogos.id;


--
-- TOC entry 224 (class 1259 OID 16565)
-- Name: tipos_categorias; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE tipos_categorias (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion character varying(2000) NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone
);


ALTER TABLE tipos_categorias OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16571)
-- Name: tipos_categorias_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE tipos_categorias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tipos_categorias_id_seq OWNER TO postgres;

--
-- TOC entry 3518 (class 0 OID 0)
-- Dependencies: 225
-- Name: tipos_categorias_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE tipos_categorias_id_seq OWNED BY tipos_categorias.id;


--
-- TOC entry 226 (class 1259 OID 16573)
-- Name: tipos_garantias; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE tipos_garantias (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    descripcion character varying(2000),
    fecha timestamp with time zone NOT NULL,
    estado character varying(5)
);


ALTER TABLE tipos_garantias OWNER TO postgres;

--
-- TOC entry 3519 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN tipos_garantias.id; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN tipos_garantias.id IS 'identificador';


--
-- TOC entry 3520 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN tipos_garantias.fecha; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN tipos_garantias.fecha IS 'fechade creacion del tipo de garantia';


--
-- TOC entry 3521 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN tipos_garantias.estado; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN tipos_garantias.estado IS 'define el estado del tipo de garantia';


--
-- TOC entry 227 (class 1259 OID 16579)
-- Name: tipos_garantias_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE tipos_garantias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tipos_garantias_id_seq OWNER TO postgres;

--
-- TOC entry 3522 (class 0 OID 0)
-- Dependencies: 227
-- Name: tipos_garantias_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE tipos_garantias_id_seq OWNED BY tipos_garantias.id;


--
-- TOC entry 228 (class 1259 OID 16581)
-- Name: tipos_imagenes_productos; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE tipos_imagenes_productos (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE tipos_imagenes_productos OWNER TO postgres;

--
-- TOC entry 3523 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE tipos_imagenes_productos; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON TABLE tipos_imagenes_productos IS 'contiene las direccioenes de las imagenes ';


--
-- TOC entry 3524 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN tipos_imagenes_productos.id; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN tipos_imagenes_productos.id IS 'identificador de clave primaria';


--
-- TOC entry 3525 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN tipos_imagenes_productos.nombre; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN tipos_imagenes_productos.nombre IS 'nombre del tipo de imagen';


--
-- TOC entry 3526 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN tipos_imagenes_productos.estado; Type: COMMENT; Schema: inventario; Owner: postgres
--

COMMENT ON COLUMN tipos_imagenes_productos.estado IS 'define si esta activo o no le tipo de imagen';


--
-- TOC entry 229 (class 1259 OID 16584)
-- Name: tipos_imagenes_productos_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE tipos_imagenes_productos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tipos_imagenes_productos_id_seq OWNER TO postgres;

--
-- TOC entry 3527 (class 0 OID 0)
-- Dependencies: 229
-- Name: tipos_imagenes_productos_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE tipos_imagenes_productos_id_seq OWNED BY tipos_imagenes_productos.id;


--
-- TOC entry 230 (class 1259 OID 16586)
-- Name: tipos_productos; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE tipos_productos (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    descripcion character varying(2000) NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE tipos_productos OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16592)
-- Name: tipos_productos_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE tipos_productos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tipos_productos_id_seq OWNER TO postgres;

--
-- TOC entry 3528 (class 0 OID 0)
-- Dependencies: 231
-- Name: tipos_productos_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE tipos_productos_id_seq OWNED BY tipos_productos.id;


--
-- TOC entry 232 (class 1259 OID 16594)
-- Name: ubicaciones; Type: TABLE; Schema: inventario; Owner: postgres
--

CREATE TABLE ubicaciones (
    id integer NOT NULL,
    nombre character varying(250) NOT NULL,
    descripcion character varying(2000) NOT NULL,
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE ubicaciones OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16600)
-- Name: ubicaciones_id_seq; Type: SEQUENCE; Schema: inventario; Owner: postgres
--

CREATE SEQUENCE ubicaciones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ubicaciones_id_seq OWNER TO postgres;

--
-- TOC entry 3529 (class 0 OID 0)
-- Dependencies: 233
-- Name: ubicaciones_id_seq; Type: SEQUENCE OWNED BY; Schema: inventario; Owner: postgres
--

ALTER SEQUENCE ubicaciones_id_seq OWNED BY ubicaciones.id;


SET search_path = public, pg_catalog;

--
-- TOC entry 234 (class 1259 OID 16602)
-- Name: estados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE estados (
    id character varying(5) NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion character varying(250) NOT NULL
);


ALTER TABLE estados OWNER TO postgres;

--
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN estados.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN estados.id IS 'define el identificados';


--
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN estados.nombre; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN estados.nombre IS 'define nombre corto del estado';


--
-- TOC entry 235 (class 1259 OID 16605)
-- Name: localidades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE localidades (
    id character varying(15) NOT NULL,
    nombre character varying(250) NOT NULL,
    codigo character varying(5) NOT NULL,
    id_padre character varying(15),
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL,
    codigo_telefonico character varying
);


ALTER TABLE localidades OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16611)
-- Name: personas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE personas (
    id integer NOT NULL,
    ci_docuemto character varying(15) NOT NULL,
    pasaporte character varying(15),
    primer_nombre character varying(50) NOT NULL,
    segundo_nombre character varying(50),
    primer_apellido character varying(50) NOT NULL,
    segundo_apellido character varying(50),
    id_localidad character varying(15) NOT NULL,
    calle character varying(500) NOT NULL,
    transversal character varying(500),
    numero character varying(25),
    ruc character varying(15)
);


ALTER TABLE personas OWNER TO postgres;

--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN personas.ci_docuemto; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN personas.ci_docuemto IS 'número de cedula de identidad';


--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN personas.pasaporte; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN personas.pasaporte IS 'número de pasaporte';


--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN personas.ruc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN personas.ruc IS 'número de ruc';


--
-- TOC entry 237 (class 1259 OID 16617)
-- Name: personas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE personas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE personas_id_seq OWNER TO postgres;

--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 237
-- Name: personas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE personas_id_seq OWNED BY personas.id;


--
-- TOC entry 238 (class 1259 OID 16619)
-- Name: telefonos_personas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE telefonos_personas (
    id integer NOT NULL,
    id_persona integer NOT NULL,
    numero character varying(25) NOT NULL,
    fecha timestamp with time zone[] NOT NULL,
    estado character varying(5) NOT NULL
);


ALTER TABLE telefonos_personas OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16625)
-- Name: telefonos_personas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE telefonos_personas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE telefonos_personas_id_seq OWNER TO postgres;

--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 239
-- Name: telefonos_personas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE telefonos_personas_id_seq OWNED BY telefonos_personas.id;


--
-- TOC entry 240 (class 1259 OID 16627)
-- Name: view_localidades; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_localidades AS
 WITH RECURSIVE path(nombre, codigo_telefonico, path, parent, id, codigo, id_padre) AS (
         SELECT localidades.nombre,
            localidades.codigo_telefonico,
            '/'::text AS text,
            NULL::text AS text,
            localidades.id,
            localidades.codigo,
            localidades.id_padre
           FROM localidades
          WHERE ((localidades.id_padre)::text = '0'::text)
        UNION
         SELECT localidades.nombre,
            localidades.codigo_telefonico,
            ((parentpath.path ||
                CASE parentpath.path
                    WHEN '/'::text THEN ''::text
                    ELSE '/'::text
                END) || (localidades.nombre)::text),
            parentpath.path,
            localidades.id,
            localidades.codigo,
            localidades.id_padre
           FROM localidades,
            path parentpath
          WHERE ((localidades.id_padre)::text = (parentpath.id)::text)
        )
 SELECT path.nombre,
    path.codigo_telefonico,
    path.path,
    path.parent,
    path.id,
    path.codigo,
    path.id_padre
   FROM path;


ALTER TABLE view_localidades OWNER TO postgres;

--
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 240
-- Name: VIEW view_localidades; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW view_localidades IS 'crea la vista localidades, definida como arbol';


SET search_path = usuarios, pg_catalog;

--
-- TOC entry 241 (class 1259 OID 16632)
-- Name: usuarios; Type: TABLE; Schema: usuarios; Owner: postgres
--

CREATE TABLE usuarios (
    id character varying NOT NULL,
    nick character varying(50),
    clave_clave character varying(75),
    id_estado character varying(5),
    fecha_creacion timestamp with time zone
);


ALTER TABLE usuarios OWNER TO postgres;

--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN usuarios.id; Type: COMMENT; Schema: usuarios; Owner: postgres
--

COMMENT ON COLUMN usuarios.id IS 'id usuario del sistema Nexboot';


--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN usuarios.clave_clave; Type: COMMENT; Schema: usuarios; Owner: postgres
--

COMMENT ON COLUMN usuarios.clave_clave IS 'define la clave del usuario';


--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN usuarios.id_estado; Type: COMMENT; Schema: usuarios; Owner: postgres
--

COMMENT ON COLUMN usuarios.id_estado IS 'estado del usuario';


--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN usuarios.fecha_creacion; Type: COMMENT; Schema: usuarios; Owner: postgres
--

COMMENT ON COLUMN usuarios.fecha_creacion IS 'fecha en la que fue creado el usuario';


SET search_path = ventas, pg_catalog;

--
-- TOC entry 242 (class 1259 OID 16638)
-- Name: detalle_factura; Type: TABLE; Schema: ventas; Owner: postgres
--

CREATE TABLE detalle_factura (
    id integer NOT NULL,
    id_factura integer NOT NULL,
    id_producto integer NOT NULL
);


ALTER TABLE detalle_factura OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16641)
-- Name: detalle_factura_id_seq; Type: SEQUENCE; Schema: ventas; Owner: postgres
--

CREATE SEQUENCE detalle_factura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE detalle_factura_id_seq OWNER TO postgres;

--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 243
-- Name: detalle_factura_id_seq; Type: SEQUENCE OWNED BY; Schema: ventas; Owner: postgres
--

ALTER SEQUENCE detalle_factura_id_seq OWNED BY detalle_factura.id;


--
-- TOC entry 244 (class 1259 OID 16643)
-- Name: facturas; Type: TABLE; Schema: ventas; Owner: postgres
--

CREATE TABLE facturas (
    id integer NOT NULL,
    numero_factura character varying(10) NOT NULL,
    numero_autorizacion integer NOT NULL,
    ruc_emisor character varying(15) NOT NULL,
    denominacion character varying(15) DEFAULT 'FACTURA'::character varying NOT NULL,
    direccion_matriz character varying(250) NOT NULL,
    direccion_sucursal character varying(250),
    fecha_autorizacion date NOT NULL,
    adquiriente character varying(500) NOT NULL,
    ruc_ci_pas character varying(15) NOT NULL,
    fecha_emicion timestamp with time zone NOT NULL,
    guia_remision character varying(15),
    fecha_caducidad_factura date NOT NULL,
    datos_imprenta character varying(500),
    subtotal_iva money NOT NULL,
    subtotal_sin_iva money NOT NULL,
    descuentos money NOT NULL,
    valor_iva money NOT NULL,
    ice money NOT NULL,
    total money NOT NULL,
    estado character varying(5) NOT NULL
);


ALTER TABLE facturas OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 16650)
-- Name: facturas_id_seq; Type: SEQUENCE; Schema: ventas; Owner: postgres
--

CREATE SEQUENCE facturas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE facturas_id_seq OWNER TO postgres;

--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 245
-- Name: facturas_id_seq; Type: SEQUENCE OWNED BY; Schema: ventas; Owner: postgres
--

ALTER SEQUENCE facturas_id_seq OWNED BY facturas.id;


--
-- TOC entry 246 (class 1259 OID 16652)
-- Name: formas_pago; Type: TABLE; Schema: ventas; Owner: postgres
--

CREATE TABLE formas_pago (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion character varying(500),
    estado character varying(5) NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE formas_pago OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 16658)
-- Name: formas_pago_facturas; Type: TABLE; Schema: ventas; Owner: postgres
--

CREATE TABLE formas_pago_facturas (
    id integer NOT NULL,
    id_factura integer NOT NULL,
    id_formas_pago integer NOT NULL
);


ALTER TABLE formas_pago_facturas OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 16661)
-- Name: formas_pago_facturas_id_seq; Type: SEQUENCE; Schema: ventas; Owner: postgres
--

CREATE SEQUENCE formas_pago_facturas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE formas_pago_facturas_id_seq OWNER TO postgres;

--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 248
-- Name: formas_pago_facturas_id_seq; Type: SEQUENCE OWNED BY; Schema: ventas; Owner: postgres
--

ALTER SEQUENCE formas_pago_facturas_id_seq OWNED BY formas_pago_facturas.id;


--
-- TOC entry 249 (class 1259 OID 16663)
-- Name: formas_pago_id_seq; Type: SEQUENCE; Schema: ventas; Owner: postgres
--

CREATE SEQUENCE formas_pago_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE formas_pago_id_seq OWNER TO postgres;

--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 249
-- Name: formas_pago_id_seq; Type: SEQUENCE OWNED BY; Schema: ventas; Owner: postgres
--

ALTER SEQUENCE formas_pago_id_seq OWNED BY formas_pago.id;


--
-- TOC entry 250 (class 1259 OID 16665)
-- Name: producto_descuento; Type: TABLE; Schema: ventas; Owner: postgres
--

CREATE TABLE producto_descuento (
    id integer NOT NULL,
    id_producto integer NOT NULL,
    id_catalogo integer NOT NULL,
    estado character varying(5) NOT NULL,
    fecha_fin_descuento timestamp with time zone NOT NULL,
    fecha_inicio_descuento timestamp with time zone NOT NULL
);


ALTER TABLE producto_descuento OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 16668)
-- Name: producto_descuento_id_seq; Type: SEQUENCE; Schema: ventas; Owner: postgres
--

CREATE SEQUENCE producto_descuento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE producto_descuento_id_seq OWNER TO postgres;

--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 251
-- Name: producto_descuento_id_seq; Type: SEQUENCE OWNED BY; Schema: ventas; Owner: postgres
--

ALTER SEQUENCE producto_descuento_id_seq OWNED BY producto_descuento.id;


SET search_path = auditoria, pg_catalog;

--
-- TOC entry 3127 (class 2604 OID 17040)
-- Name: id; Type: DEFAULT; Schema: auditoria; Owner: postgres
--

ALTER TABLE ONLY auditoria ALTER COLUMN id SET DEFAULT nextval('auditoria_id_seq'::regclass);


--
-- TOC entry 3128 (class 2604 OID 17041)
-- Name: id; Type: DEFAULT; Schema: auditoria; Owner: postgres
--

ALTER TABLE ONLY ingresos_usuarios ALTER COLUMN id SET DEFAULT nextval('ingresos_usuarios_id_seq'::regclass);


SET search_path = contabilidad, pg_catalog;

--
-- TOC entry 3129 (class 2604 OID 17042)
-- Name: id; Type: DEFAULT; Schema: contabilidad; Owner: postgres
--

ALTER TABLE ONLY ambitos_impuestos ALTER COLUMN id SET DEFAULT nextval('ambitos_impuestos_id_seq'::regclass);


--
-- TOC entry 3130 (class 2604 OID 17043)
-- Name: id; Type: DEFAULT; Schema: contabilidad; Owner: postgres
--

ALTER TABLE ONLY grupo_impuestos ALTER COLUMN id SET DEFAULT nextval('grupo_impuestos_id_seq'::regclass);


--
-- TOC entry 3131 (class 2604 OID 17044)
-- Name: id; Type: DEFAULT; Schema: contabilidad; Owner: postgres
--

ALTER TABLE ONLY impuestos ALTER COLUMN id SET DEFAULT nextval('impuestos_id_seq'::regclass);


SET search_path = inventario, pg_catalog;

--
-- TOC entry 3132 (class 2604 OID 17045)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY catalogos ALTER COLUMN id SET DEFAULT nextval('catalogos_id_seq'::regclass);


--
-- TOC entry 3133 (class 2604 OID 17046)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY categorias ALTER COLUMN id SET DEFAULT nextval('categorias_id_seq'::regclass);


--
-- TOC entry 3134 (class 2604 OID 17047)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY descripcion_producto ALTER COLUMN id SET DEFAULT nextval('descripcion_producto_id_seq'::regclass);


--
-- TOC entry 3135 (class 2604 OID 17048)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY estado_descriptivo ALTER COLUMN id SET DEFAULT nextval('estado_descriptivo_id_seq'::regclass);


--
-- TOC entry 3136 (class 2604 OID 17049)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY garantias ALTER COLUMN id SET DEFAULT nextval('garantias_id_seq'::regclass);


--
-- TOC entry 3138 (class 2604 OID 17050)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY marcas ALTER COLUMN id SET DEFAULT nextval('marcas_id_seq'::regclass);


--
-- TOC entry 3139 (class 2604 OID 17051)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY modelos ALTER COLUMN id SET DEFAULT nextval('modelos_id_seq'::regclass);


--
-- TOC entry 3140 (class 2604 OID 17052)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY productos ALTER COLUMN id SET DEFAULT nextval('productos_id_seq'::regclass);


--
-- TOC entry 3141 (class 2604 OID 17053)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY proveedores ALTER COLUMN id SET DEFAULT nextval('proveedores_id_seq'::regclass);


--
-- TOC entry 3142 (class 2604 OID 17054)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY sucursal ALTER COLUMN id SET DEFAULT nextval('sucursal_id_seq'::regclass);


--
-- TOC entry 3143 (class 2604 OID 17055)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipo_consumo ALTER COLUMN id SET DEFAULT nextval('tipo_consumo_id_seq'::regclass);


--
-- TOC entry 3144 (class 2604 OID 17056)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_catalogos ALTER COLUMN id SET DEFAULT nextval('tipos_catalogos_id_seq'::regclass);


--
-- TOC entry 3145 (class 2604 OID 17057)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_categorias ALTER COLUMN id SET DEFAULT nextval('tipos_categorias_id_seq'::regclass);


--
-- TOC entry 3146 (class 2604 OID 17058)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_garantias ALTER COLUMN id SET DEFAULT nextval('tipos_garantias_id_seq'::regclass);


--
-- TOC entry 3147 (class 2604 OID 17059)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_imagenes_productos ALTER COLUMN id SET DEFAULT nextval('tipos_imagenes_productos_id_seq'::regclass);


--
-- TOC entry 3148 (class 2604 OID 17060)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_productos ALTER COLUMN id SET DEFAULT nextval('tipos_productos_id_seq'::regclass);


--
-- TOC entry 3149 (class 2604 OID 17061)
-- Name: id; Type: DEFAULT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY ubicaciones ALTER COLUMN id SET DEFAULT nextval('ubicaciones_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- TOC entry 3150 (class 2604 OID 17062)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY personas ALTER COLUMN id SET DEFAULT nextval('personas_id_seq'::regclass);


--
-- TOC entry 3151 (class 2604 OID 17063)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY telefonos_personas ALTER COLUMN id SET DEFAULT nextval('telefonos_personas_id_seq'::regclass);


SET search_path = ventas, pg_catalog;

--
-- TOC entry 3152 (class 2604 OID 17064)
-- Name: id; Type: DEFAULT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY detalle_factura ALTER COLUMN id SET DEFAULT nextval('detalle_factura_id_seq'::regclass);


--
-- TOC entry 3154 (class 2604 OID 17065)
-- Name: id; Type: DEFAULT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY facturas ALTER COLUMN id SET DEFAULT nextval('facturas_id_seq'::regclass);


--
-- TOC entry 3155 (class 2604 OID 17066)
-- Name: id; Type: DEFAULT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY formas_pago ALTER COLUMN id SET DEFAULT nextval('formas_pago_id_seq'::regclass);


--
-- TOC entry 3156 (class 2604 OID 17067)
-- Name: id; Type: DEFAULT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY formas_pago_facturas ALTER COLUMN id SET DEFAULT nextval('formas_pago_facturas_id_seq'::regclass);


--
-- TOC entry 3157 (class 2604 OID 17068)
-- Name: id; Type: DEFAULT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY producto_descuento ALTER COLUMN id SET DEFAULT nextval('producto_descuento_id_seq'::regclass);


SET search_path = auditoria, pg_catalog;

--
-- TOC entry 3407 (class 0 OID 16422)
-- Dependencies: 187
-- Data for Name: auditoria; Type: TABLE DATA; Schema: auditoria; Owner: postgres
--

COPY auditoria (id, tabla_afectada, operacion, variable_anterior, variable_nueva, fecha, usuario) FROM stdin;
1	estados                                      	I	\N	(A,ACTIVO,"El estado es Activo y permite su administracion y los cambios que requiera para el sitema","2016-09-26 16:19:09.640461-05")	2016-09-26 16:19:09.640461	postgres                                     
8	empresas                                     	I	\N	(123456789,"JUAN CARLOS LOPEZ JACOME","VENTA DE GRANOS ANDINOS",1002424735001,ACTIVO,"2016-01-17 00:00:00-05",,NO,ACTIVO,A,"2016-09-27 09:05:11.32264-05")	2016-09-27 09:05:11.32264	postgres                                     
9	empresas                                     	D	(123456789,"JUAN CARLOS LOPEZ JACOME","VENTA DE GRANOS ANDINOS",1002424735001,ACTIVO,"2016-01-17 00:00:00-05",,NO,ACTIVO,A,"2016-09-27 09:05:11.32264-05")	\N	2016-09-27 09:06:45.671201	postgres                                     
22	empresas                                     	I	\N	(123456789,JUAN_CARLOS_LOPEZ_JACOME,"VENTA DE GRANOS ANDINOS",1002424735001,ACTIVO,"2016-01-17 00:00:00-05",,NO,"PERSONA NATURAL",A,"2016-09-27 10:46:40.965931-05")	2016-09-27 10:46:40.965931	postgres                                     
23	clientes                                     	I	\N	(1,1002424735001,JUAN_CARLOS_LOPEZ_JACOME,1002424735001,P_C,A,"2016-09-27 10:46:40.965931-05")	2016-09-27 10:46:40.965931	postgres                                     
24	empresas                                     	I	\N	(23456789,gaLO,VENTA,1224567899,ACTIVO,"2015-01-25 00:00:00-05",,NO,SOCIEDAD,A,"2016-09-27 10:51:34.567491-05")	2016-09-27 10:51:34.567491	postgres                                     
25	clientes                                     	I	\N	(2,1224567899,gaLO,1224567899,P_C,A,"2016-09-27 10:51:34.567491-05")	2016-09-27 10:51:34.567491	postgres                                     
26	empresas                                     	I	\N	(123456987,PEDRO,COMPRE,1234569,ACTIVO,"2013-01-14 00:00:00-05",,SI,SOCIEDA,A,"2016-09-27 11:09:22.159753-05")	2016-09-27 11:09:22.159753	postgres                                     
27	clientes                                     	I	\N	(3,1234569,PEDRO,1234569,P_C,A,"2016-09-27 11:09:22.159753-05")	2016-09-27 11:09:22.159753	postgres                                     
28	clientes                                     	D	(1,1002424735001,JUAN_CARLOS_LOPEZ_JACOME,1002424735001,P_C,A,"2016-09-27 10:46:40.965931-05")	\N	2016-09-28 17:35:03.983639	postgres                                     
29	clientes                                     	D	(2,1224567899,gaLO,1224567899,P_C,A,"2016-09-27 10:51:34.567491-05")	\N	2016-09-28 17:35:08.314858	postgres                                     
30	clientes                                     	D	(3,1234569,PEDRO,1234569,P_C,A,"2016-09-27 11:09:22.159753-05")	\N	2016-09-28 17:35:12.558843	postgres                                     
39	empresas                                     	I	\N	(235467897,GAlLINDO,VENTA,123456789001,ACTIVO,"2014-01-12 00:00:00-05","LA FERIA",SI,"PERSONA NATURAL",A,"2016-09-28 17:50:41.810732-05")	2016-09-28 17:50:41.810732	postgres                                     
40	clientes                                     	I	\N	(4,123456789001,GAlLINDO,123456789001,P_C,A,"2016-09-28 17:50:41.810732-05")	2016-09-28 17:50:41.810732	postgres                                     
41	empresas                                     	I	\N	(3216548521,DAVID,VENTA,123569887,ACTIVO,"2011-05-05 00:00:00-05",,NO,SOCIEDAD,A,"2016-09-28 17:54:34.965827-05")	2016-09-28 17:54:34.965827	postgres                                     
42	clientes                                     	I	\N	(5,123569887,DAVID,123569887,P_C,A,"2016-09-28 17:54:34.965827-05")	2016-09-28 17:54:34.965827	postgres                                     
43	empresas                                     	I	\N	(97987,ALEX,PROGRAMACION,100161321322001,ACTIVO,"2016-07-10 00:00:00-05",YO,SI,"PERSONA NATURAL",A,"2016-10-07 16:14:30.04886-05")	2016-10-07 16:14:30.04886	postgres                                     
44	clientes                                     	I	\N	(6,100161321322001,ALEX,100161321322001,P_C,A,"2016-10-07 16:14:30.04886-05")	2016-10-07 16:14:30.04886	postgres                                     
45	localidades                                  	I	\N	(00,ECUADOR,ECU,0,A,"2016-10-11 17:02:39.77365-05")	2016-10-11 17:02:39.77365	postgres                                     
46	localidades                                  	I	\N	(10,IMBABURA,IMB,00,A,"2016-10-11 17:03:14.556837-05")	2016-10-11 17:03:14.556837	postgres                                     
47	localidades                                  	I	\N	(1001,IBARRA,IBA,10,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
48	localidades                                  	I	\N	(1002,"ANTONIO ANTE",ANT,10,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
49	localidades                                  	I	\N	(1003,COTACACHI,COT,10,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
50	localidades                                  	I	\N	(1004,OTAVALO,OTA,10,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
51	localidades                                  	I	\N	(1005,PIMAMPIRO,PIM,10,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
52	localidades                                  	I	\N	(1006,"SAN MIGUEL DE URCUQUI",URC,10,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
53	localidades                                  	I	\N	(100101,CARANQUI,CAR,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
54	localidades                                  	I	\N	(100102,"GUAYAQUIL DE ALPACHACA",ALP,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
55	localidades                                  	I	\N	(100103,SAGRARIO,SAG,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
56	localidades                                  	I	\N	(100104,"SAN FRANCISCO",FRA,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
57	localidades                                  	I	\N	(100105,"LA DOLOROSA DEL PRIORATO",PIO,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
58	localidades                                  	I	\N	(100150,"SAN MIGUEL DE IBARRA",IBA,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
59	localidades                                  	I	\N	(100151,AMBUQUI,AMB,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
60	localidades                                  	I	\N	(100152,ANGOCHAGUA,ANG,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
61	localidades                                  	I	\N	(100153,CAROLINA,CAR,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
62	localidades                                  	I	\N	(100154,"LA ESPERANZA",ESP,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
63	localidades                                  	I	\N	(100155,LITA,LIT,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
64	localidades                                  	I	\N	(100156,SALINAS,SAL,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
65	localidades                                  	I	\N	(100157,"SAN ANTONIO",ANT,1001,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
66	localidades                                  	I	\N	(100201,"ANDRADE MARÍN (LOURDES)",AND,1002,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
67	localidades                                  	I	\N	(100202,ATUNTAQUI,ATU,1002,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
68	localidades                                  	I	\N	(100251,"IMBAYA (SAN LUIS DE COBUENDO)",IMB,1002,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
69	localidades                                  	I	\N	(100252,"SAN FRANCISCO DE NATABUELA",NAT,1002,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
70	localidades                                  	I	\N	(100253,"SAN JOSÉ DE CHALTURA",CHA,1002,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
71	localidades                                  	I	\N	(100254,"SAN ROQUE",ROQ,1002,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
72	localidades                                  	I	\N	(100301,SAGRARIO,SAG,1003,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
73	localidades                                  	I	\N	(100302,"SAN FRANCISCO",FRA,1003,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
74	localidades                                  	I	\N	(100350,COTACACHI,COT,1003,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
75	localidades                                  	I	\N	(100351,APUELA,APU,1003,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
76	localidades                                  	I	\N	(100352,"GARCIA MORENO (LLURIMAGUA)",GMO,1003,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
77	localidades                                  	I	\N	(100353,IMANTAG,IMA,1003,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
78	localidades                                  	I	\N	(100354,PEÑAHERRERA,PEÑ,1003,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
79	localidades                                  	I	\N	(100355,"PLAZA GUTIERREZ (CALVARIO)",PGU,1003,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
80	localidades                                  	I	\N	(100356,QUIROGA,1003,QUI,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
81	localidades                                  	I	\N	(100357,"6 DE JULIO DE CUELLAJE (CAB. EN CUELLAJE)",CUE,1003,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
82	localidades                                  	I	\N	(100358,"VACAS GALINDO (EL CHURO) (CAB.EN SAN MIGUEL ALTO)",VAC,1003,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
83	localidades                                  	I	\N	(100550,PIMAMPIRO,PIM,1004,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
84	localidades                                  	I	\N	(100551,CHUGA,CHU,1004,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
85	localidades                                  	I	\N	(100552,"MARIANO ACOSTA",MAC,1004,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
86	localidades                                  	I	\N	(100553,"SAN FRANCISCO DE SIGSIPAMBA",SIG,1004,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
87	localidades                                  	I	\N	(100650,"URCUQUI CABECERA CANTONAL",URC,1005,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
88	localidades                                  	I	\N	(100651,CAHUASQUI,CAH,1005,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
89	localidades                                  	I	\N	(100652,"LA MERCED DE BUENOS AIRES",BUE,1005,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
90	localidades                                  	I	\N	(100653,"PABLO ARENAS",PAR,1005,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
91	localidades                                  	I	\N	(100654,"SAN BLAS",SBL,1005,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
92	localidades                                  	I	\N	(100655,TUMBABIRO,TUM,1005,A,"2016-10-11 17:42:51.770289-05")	2016-10-11 17:42:51.770289	postgres                                     
93	localidades                                  	I	\N	(100401,JORDÁN,JOR,1004,A,"2016-10-12 12:21:18.08894-05")	2016-10-12 12:21:18.08894	postgres                                     
94	localidades                                  	I	\N	(100402,"SAN LUIS",LUI,1004,A,"2016-10-12 12:21:18.08894-05")	2016-10-12 12:21:18.08894	postgres                                     
95	localidades                                  	I	\N	(100450,OTAVALO,OTA,1004,A,"2016-10-12 12:21:18.08894-05")	2016-10-12 12:21:18.08894	postgres                                     
96	localidades                                  	I	\N	(100451,"DR. MIGUEL EGAS CABEZAS (PEGUCHE)",PEG,1004,A,"2016-10-12 12:21:18.08894-05")	2016-10-12 12:21:18.08894	postgres                                     
97	localidades                                  	I	\N	(100452,"EUGENIO ESPEJO (CALPAQUÍ)",ESP,1004,A,"2016-10-12 12:21:18.08894-05")	2016-10-12 12:21:18.08894	postgres                                     
98	localidades                                  	I	\N	(100453,"GONZÁLEZ SUÁREZ",GON,1004,A,"2016-10-12 12:21:18.08894-05")	2016-10-12 12:21:18.08894	postgres                                     
99	localidades                                  	I	\N	(100454,PATAQUÍ,PAT,1004,A,"2016-10-12 12:21:18.08894-05")	2016-10-12 12:21:18.08894	postgres                                     
100	localidades                                  	I	\N	(100455,"SAN JOSÉ DE QUICHINCHE",QUI,1004,A,"2016-10-12 12:21:18.08894-05")	2016-10-12 12:21:18.08894	postgres                                     
176	localidades                                  	I	\N	(0102,GIRÓN,GIR,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
101	localidades                                  	I	\N	(100456,"SAN JUAN DE ILUMÁN",ILU,1004,A,"2016-10-12 12:21:18.08894-05")	2016-10-12 12:21:18.08894	postgres                                     
102	localidades                                  	I	\N	(100457,"SAN PABLO",PAB,1004,A,"2016-10-12 12:21:18.08894-05")	2016-10-12 12:21:18.08894	postgres                                     
103	localidades                                  	I	\N	(100458,"SAN RAFAEL",RAF,1004,A,"2016-10-12 12:21:18.08894-05")	2016-10-12 12:21:18.08894	postgres                                     
104	localidades                                  	I	\N	(100459,"SELVA ALEGRE (CAB.EN SAN MIGUEL DE PAMPLONA)",SEL,1004,A,"2016-10-12 12:21:18.08894-05")	2016-10-12 12:21:18.08894	postgres                                     
111	empresas                                     	D	(97987,ALEX,PROGRAMACION,100161321322001,ACTIVO,"2016-07-10 00:00:00-05",YO,SI,"PERSONA NATURAL",A,"2016-10-07 16:14:30.04886-05")	\N	2016-10-12 17:13:16.484267	postgres                                     
112	empresas                                     	D	(3216548521,DAVID,VENTA,123569887,ACTIVO,"2011-05-05 00:00:00-05",,NO,SOCIEDAD,A,"2016-09-28 17:54:34.965827-05")	\N	2016-10-12 17:13:21.115683	postgres                                     
113	empresas                                     	D	(235467897,GAlLINDO,VENTA,123456789001,ACTIVO,"2014-01-12 00:00:00-05","LA FERIA",SI,"PERSONA NATURAL",A,"2016-09-28 17:50:41.810732-05")	\N	2016-10-12 17:13:24.635688	postgres                                     
114	empresas                                     	D	(23456789,gaLO,VENTA,1224567899,ACTIVO,"2015-01-25 00:00:00-05",,NO,SOCIEDAD,A,"2016-09-27 10:51:34.567491-05")	\N	2016-10-12 17:13:28.876288	postgres                                     
115	empresas                                     	D	(123456987,PEDRO,COMPRE,1234569,ACTIVO,"2013-01-14 00:00:00-05",,SI,SOCIEDA,A,"2016-09-27 11:09:22.159753-05")	\N	2016-10-12 17:13:28.886333	postgres                                     
116	empresas                                     	D	(123456789,JUAN_CARLOS_LOPEZ_JACOME,"VENTA DE GRANOS ANDINOS",1002424735001,ACTIVO,"2016-01-17 00:00:00-05",,NO,"PERSONA NATURAL",A,"2016-09-27 10:46:40.965931-05")	\N	2016-10-12 17:13:28.894673	postgres                                     
117	clientes                                     	D	(4,123456789001,GAlLINDO,123456789001,P_C,A,"2016-09-28 17:50:41.810732-05")	\N	2016-10-12 17:13:59.130926	postgres                                     
118	clientes                                     	D	(5,123569887,DAVID,123569887,P_C,A,"2016-09-28 17:54:34.965827-05")	\N	2016-10-12 17:14:02.537612	postgres                                     
119	clientes                                     	D	(6,100161321322001,ALEX,100161321322001,P_C,A,"2016-10-07 16:14:30.04886-05")	\N	2016-10-12 17:14:05.713247	postgres                                     
120	clientes                                     	I	\N	(7,154654546,JUAN,154654546,P_C,A,"2016-10-13 08:38:38.617974-05")	2016-10-13 08:38:38.617974	postgres                                     
121	clientes                                     	D	(7,154654546,JUAN,154654546,P_C,A,"2016-10-13 08:38:38.617974-05")	\N	2016-10-13 08:39:13.669254	postgres                                     
122	clientes                                     	I	\N	(2,asd,asdasdasd,asd,P_C,A,"2016-10-13 08:43:09.907453-05")	2016-10-13 08:43:09.907453	postgres                                     
123	clientes                                     	D	(2,asd,asdasdasd,asd,P_C,A,"2016-10-13 08:43:09.907453-05")	\N	2016-10-13 08:44:53.010502	postgres                                     
124	empresas                                     	I	\N	(123456,Juan,"juanK                                   ",venta,12346569,activo,"2015-01-01 00:00:00-05",,no,"per natu",A,"2016-10-13 09:16:41.215187-05")	2016-10-13 09:16:41.215187	postgres                                     
191	localidades                                  	I	\N	(0202,CHILLANES,CHI,02,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
125	empresas                                     	D	(123456,Juan,"juanK                                   ",venta,12346569,activo,"2015-01-01 00:00:00-05",,no,"per natu",A,"2016-10-13 09:16:41.215187-05")	\N	2016-10-13 09:18:39.067932	postgres                                     
128	empresas                                     	I	\N	(12345,"JUAN CARLOS LOPEZ","JUANk                                   ",VENTA,12345,ACTIVO,"2015-01-01 00:00:00-05",,NO,"PER NATU",A,"2016-10-13 09:29:18.104741-05")	2016-10-13 09:29:18.104741	postgres                                     
129	clientes                                     	I	\N	(3,12345,JUANk,12345,P_C,A,"2016-10-13 09:29:18.104741-05")	2016-10-13 09:29:18.104741	postgres                                     
130	clientes                                     	D	(3,12345,JUANk,12345,P_C,A,"2016-10-13 09:29:18.104741-05")	\N	2016-10-13 09:30:37.737249	postgres                                     
131	empresas                                     	D	(12345,"JUAN CARLOS LOPEZ","JUANk                                   ",VENTA,12345,ACTIVO,"2015-01-01 00:00:00-05",,NO,"PER NATU",A,"2016-10-13 09:29:18.104741-05")	\N	2016-10-13 09:30:57.146031	postgres                                     
133	empresas                                     	I	\N	(2016101310250757ffa753e1124,"RIVADENEIRA EGAS JUAN CARLOS","RIVADENEIRA_EGAS_JUAN_CA_1001611381001  ","OTRAS ACTIVIDADES DE LA ADMINISTRACION PUBLICA EN GENERAL.",1001611381001,,,"no disponible",,"Persona Natural",A,"2016-10-13 00:00:00-05")	2016-10-13 10:25:07.962189	postgres                                     
134	clientes                                     	I	\N	(5,1001611381001,RIVADENEIRA_EGAS_JUAN_CA_1001611381001,1001611381001,P_C,A,"2016-10-13 10:25:07.962189-05")	2016-10-13 10:25:07.962189	postgres                                     
135	clientes                                     	D	(5,1001611381001,RIVADENEIRA_EGAS_JUAN_CA_1001611381001,1001611381001,P_C,A,"2016-10-13 10:25:07.962189-05")	\N	2016-10-13 11:22:24.632759	postgres                                     
136	empresas                                     	D	(2016101310250757ffa753e1124,"RIVADENEIRA EGAS JUAN CARLOS","RIVADENEIRA_EGAS_JUAN_CA_1001611381001  ","OTRAS ACTIVIDADES DE LA ADMINISTRACION PUBLICA EN GENERAL.",1001611381001,,,"no disponible",,"Persona Natural",A,"2016-10-13 00:00:00-05")	\N	2016-10-13 11:22:32.123496	postgres                                     
138	empresas                                     	I	\N	(2016101311225457ffb4decc6eb,"RIVADENEIRA EGAS JUAN CARLOS","RIVADENEIRA_EGAS_JUAN_CA_1001611381001  ","OTRAS ACTIVIDADES DE LA ADMINISTRACION PUBLICA EN GENERAL.",1001611381001,,,"no disponible",,"Persona Natural",A,"2016-10-13 00:00:00-05")	2016-10-13 11:22:54.877409	postgres                                     
139	clientes                                     	I	\N	(6,1001611381001,RIVADENEIRA_EGAS_JUAN_CA_1001611381001,1001611381001,P_C,A,"2016-10-13 11:22:54.877409-05")	2016-10-13 11:22:54.877409	postgres                                     
140	clientes                                     	D	(6,1001611381001,RIVADENEIRA_EGAS_JUAN_CA_1001611381001,1001611381001,P_C,A,"2016-10-13 11:22:54.877409-05")	\N	2016-10-13 11:24:45.355287	postgres                                     
177	localidades                                  	I	\N	(0103,GUALACEO,GUA,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
141	empresas                                     	D	(2016101311225457ffb4decc6eb,"RIVADENEIRA EGAS JUAN CARLOS","RIVADENEIRA_EGAS_JUAN_CA_1001611381001  ","OTRAS ACTIVIDADES DE LA ADMINISTRACION PUBLICA EN GENERAL.",1001611381001,,,"no disponible",,"Persona Natural",A,"2016-10-13 00:00:00-05")	\N	2016-10-13 11:27:20.02111	postgres                                     
143	empresas                                     	I	\N	(2016101311275957ffb60f35ab8,"RIVADENEIRA EGAS JUAN CARLOS","RIVADENEIRA_EGAS_JUAN_CA_1001611381001  ","OTRAS ACTIVIDADES DE LA ADMINISTRACION PUBLICA EN GENERAL.",1001611381001,,,"no disponible",,"Persona Natural",A,"2016-10-13 00:00:00-05")	2016-10-13 11:27:59.259302	postgres                                     
144	clientes                                     	I	\N	(7,1001611381001,RIVADENEIRA_EGAS_JUAN_CA_1001611381001,1001611381001,P_C,A,"2016-10-13 11:27:59.259302-05")	2016-10-13 11:27:59.259302	postgres                                     
145	empresas                                     	D	(2016101311275957ffb60f35ab8,"RIVADENEIRA EGAS JUAN CARLOS","RIVADENEIRA_EGAS_JUAN_CA_1001611381001  ","OTRAS ACTIVIDADES DE LA ADMINISTRACION PUBLICA EN GENERAL.",1001611381001,,,"no disponible",,"Persona Natural",A,"2016-10-13 00:00:00-05")	\N	2016-10-13 11:30:45.123419	postgres                                     
146	clientes                                     	D	(7,1001611381001,RIVADENEIRA_EGAS_JUAN_CA_1001611381001,1001611381001,P_C,A,"2016-10-13 11:27:59.259302-05")	\N	2016-10-13 11:30:53.149741	postgres                                     
147	empresas                                     	I	\N	(2016101311311057ffb6ceb9807,"RIVADENEIRA EGAS JUAN CARLOS","RIVADENEIRA_EGAS_JUAN_CA_1001611381001  ","OTRAS ACTIVIDADES DE LA ADMINISTRACION PUBLICA EN GENERAL.",1001611381001,,,"no disponible",,"Persona Natural",A,"2016-10-13 00:00:00-05")	2016-10-13 11:31:10.7999	postgres                                     
148	clientes                                     	I	\N	(8,1001611381001,RIVADENEIRA_EGAS_JUAN_CA_1001611381001,1001611381001,P_C,A,"2016-10-13 11:31:10.7999-05")	2016-10-13 11:31:10.7999	postgres                                     
149	empresas                                     	D	(2016101311311057ffb6ceb9807,"RIVADENEIRA EGAS JUAN CARLOS","RIVADENEIRA_EGAS_JUAN_CA_1001611381001  ","OTRAS ACTIVIDADES DE LA ADMINISTRACION PUBLICA EN GENERAL.",1001611381001,,,"no disponible",,"Persona Natural",A,"2016-10-13 00:00:00-05")	\N	2016-10-13 11:32:05.668945	postgres                                     
192	localidades                                  	I	\N	(0203,CHIMBO,CHI,02,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
150	clientes                                     	D	(8,1001611381001,RIVADENEIRA_EGAS_JUAN_CA_1001611381001,1001611381001,P_C,A,"2016-10-13 11:31:10.7999-05")	\N	2016-10-13 11:32:11.319677	postgres                                     
151	localidades                                  	I	\N	(01,AZUAY,AZU,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
152	localidades                                  	I	\N	(02,BOLIVAR,BOL,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
153	localidades                                  	I	\N	(03,CAÑAR,CAÑ,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
154	localidades                                  	I	\N	(04,CARCHI,CAR,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
155	localidades                                  	I	\N	(05,COTOPAXI,COT,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
156	localidades                                  	I	\N	(06,CHIMBORAZO,CHI,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
157	localidades                                  	I	\N	(07,"EL ORO","EL ",00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
158	localidades                                  	I	\N	(08,ESMERALDAS,ESM,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
159	localidades                                  	I	\N	(09,GUAYAS,GUA,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
160	localidades                                  	I	\N	(11,LOJA,LOJ,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
161	localidades                                  	I	\N	(12,"LOS RIOS",LOS,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
162	localidades                                  	I	\N	(13,MANABI,MAN,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
163	localidades                                  	I	\N	(14,"MORONA SANTIAGO",MOR,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
164	localidades                                  	I	\N	(15,NAPO,NAP,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
165	localidades                                  	I	\N	(16,PASTAZA,PAS,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
166	localidades                                  	I	\N	(17,PICHINCHA,PIC,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
167	localidades                                  	I	\N	(18,TUNGURAHUA,TUN,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
168	localidades                                  	I	\N	(19,"ZAMORA CHINCHIPE",ZAM,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
169	localidades                                  	I	\N	(20,GALAPAGOS,GAL,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
170	localidades                                  	I	\N	(21,SUCUMBIOS,SUC,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
171	localidades                                  	I	\N	(22,ORELLANA,ORE,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
172	localidades                                  	I	\N	(23,"SANTO DOMINGO DE LOS TSACHILAS",SAN,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
173	localidades                                  	I	\N	(24,"SANTA ELENA",SAN,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
174	localidades                                  	I	\N	(90,"ZONAS NO DELIMITADAS",ZON,00,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
175	localidades                                  	I	\N	(0101,CUENCA,CUE,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
178	localidades                                  	I	\N	(0104,NABÓN,NAB,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
179	localidades                                  	I	\N	(0105,PAUTE,PAU,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
180	localidades                                  	I	\N	(0106,PUCARA,PUC,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
181	localidades                                  	I	\N	(0107,"SAN FERNANDO",SAN,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
182	localidades                                  	I	\N	(0108,"SANTA ISABEL",SAN,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
183	localidades                                  	I	\N	(0109,SIGSIG,SIG,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
184	localidades                                  	I	\N	(0110,OÑA,OÑA,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
185	localidades                                  	I	\N	(0111,CHORDELEG,CHO,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
186	localidades                                  	I	\N	(0112,"EL PAN","EL ",01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
187	localidades                                  	I	\N	(0113,"SEVILLA DE ORO",SEV,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
188	localidades                                  	I	\N	(0114,GUACHAPALA,GUA,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
189	localidades                                  	I	\N	(0115,"CAMILO PONCE ENRÍQUEZ",CAM,01,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
190	localidades                                  	I	\N	(0201,GUARANDA,GUA,02,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
193	localidades                                  	I	\N	(0204,ECHEANDÍA,ECH,02,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
194	localidades                                  	I	\N	(0205,"SAN MIGUEL",SAN,02,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
195	localidades                                  	I	\N	(0206,CALUMA,CAL,02,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
196	localidades                                  	I	\N	(0207,"LAS NAVES",LAS,02,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
197	localidades                                  	I	\N	(0301,AZOGUES,AZO,03,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
198	localidades                                  	I	\N	(0302,BIBLIÁN,BIB,03,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
199	localidades                                  	I	\N	(0303,CAÑAR,CAÑ,03,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
200	localidades                                  	I	\N	(0304,"LA TRONCAL","LA ",03,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
201	localidades                                  	I	\N	(0305,"EL TAMBO","EL ",03,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
202	localidades                                  	I	\N	(0306,DÉLEG,DÉL,03,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
203	localidades                                  	I	\N	(0307,SUSCAL,SUS,03,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
204	localidades                                  	I	\N	(0401,TULCÁN,TUL,04,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
205	localidades                                  	I	\N	(0402,BOLÍVAR,BOL,04,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
206	localidades                                  	I	\N	(0403,ESPEJO,ESP,04,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
207	localidades                                  	I	\N	(0404,MIRA,MIR,04,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
208	localidades                                  	I	\N	(0405,MONTÚFAR,MON,04,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
209	localidades                                  	I	\N	(0406,"SAN PEDRO DE HUACA",SAN,04,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
210	localidades                                  	I	\N	(0501,LATACUNGA,LAT,05,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
211	localidades                                  	I	\N	(0502,"LA MANÁ","LA ",05,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
212	localidades                                  	I	\N	(0503,PANGUA,PAN,05,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
213	localidades                                  	I	\N	(0504,PUJILI,PUJ,05,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
214	localidades                                  	I	\N	(0505,SALCEDO,SAL,05,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
215	localidades                                  	I	\N	(0506,SAQUISILÍ,SAQ,05,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
216	localidades                                  	I	\N	(0507,SIGCHOS,SIG,05,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
217	localidades                                  	I	\N	(0601,RIOBAMBA,RIO,06,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
218	localidades                                  	I	\N	(0602,ALAUSI,ALA,06,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
219	localidades                                  	I	\N	(0603,COLTA,COL,06,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
220	localidades                                  	I	\N	(0604,CHAMBO,CHA,06,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
221	localidades                                  	I	\N	(0605,CHUNCHI,CHU,06,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
222	localidades                                  	I	\N	(0606,GUAMOTE,GUA,06,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
223	localidades                                  	I	\N	(0607,GUANO,GUA,06,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
224	localidades                                  	I	\N	(0608,PALLATANGA,PAL,06,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
225	localidades                                  	I	\N	(0609,PENIPE,PEN,06,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
226	localidades                                  	I	\N	(0610,CUMANDÁ,CUM,06,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
227	localidades                                  	I	\N	(0701,MACHALA,MAC,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
228	localidades                                  	I	\N	(0702,ARENILLAS,ARE,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
229	localidades                                  	I	\N	(0703,ATAHUALPA,ATA,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
230	localidades                                  	I	\N	(0704,BALSAS,BAL,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
231	localidades                                  	I	\N	(0705,CHILLA,CHI,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
232	localidades                                  	I	\N	(0706,"EL GUABO","EL ",07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
233	localidades                                  	I	\N	(0707,HUAQUILLAS,HUA,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
234	localidades                                  	I	\N	(0708,MARCABELÍ,MAR,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
235	localidades                                  	I	\N	(0709,PASAJE,PAS,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
236	localidades                                  	I	\N	(0710,PIÑAS,PIÑ,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
237	localidades                                  	I	\N	(0711,PORTOVELO,POR,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
238	localidades                                  	I	\N	(0712,"SANTA ROSA",SAN,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
239	localidades                                  	I	\N	(0713,ZARUMA,ZAR,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
240	localidades                                  	I	\N	(0714,"LAS LAJAS",LAS,07,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
241	localidades                                  	I	\N	(0801,ESMERALDAS,ESM,08,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
242	localidades                                  	I	\N	(0802,"ELOY ALFARO",ELO,08,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
243	localidades                                  	I	\N	(0803,MUISNE,MUI,08,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
244	localidades                                  	I	\N	(0804,QUININDÉ,QUI,08,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
245	localidades                                  	I	\N	(0805,"SAN LORENZO",SAN,08,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
246	localidades                                  	I	\N	(0806,ATACAMES,ATA,08,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
247	localidades                                  	I	\N	(0807,RIOVERDE,RIO,08,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
248	localidades                                  	I	\N	(0808,"LA CONCORDIA","LA ",08,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
249	localidades                                  	I	\N	(0901,GUAYAQUIL,GUA,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
250	localidades                                  	I	\N	(0902,"ALFREDO BAQUERIZO MORENO (JUJÁN)",ALF,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
251	localidades                                  	I	\N	(0903,BALAO,BAL,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
252	localidades                                  	I	\N	(0904,BALZAR,BAL,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
253	localidades                                  	I	\N	(0905,COLIMES,COL,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
254	localidades                                  	I	\N	(0906,DAULE,DAU,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
255	localidades                                  	I	\N	(0907,DURÁN,DUR,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
256	localidades                                  	I	\N	(0908,"EL EMPALME","EL ",09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
257	localidades                                  	I	\N	(0909,"EL TRIUNFO","EL ",09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
258	localidades                                  	I	\N	(0910,MILAGRO,MIL,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
259	localidades                                  	I	\N	(0911,NARANJAL,NAR,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
260	localidades                                  	I	\N	(0912,NARANJITO,NAR,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
261	localidades                                  	I	\N	(0913,PALESTINA,PAL,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
262	localidades                                  	I	\N	(0914,"PEDRO CARBO",PED,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
263	localidades                                  	I	\N	(0916,SAMBORONDÓN,SAM,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
264	localidades                                  	I	\N	(0918,"SANTA LUCÍA",SAN,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
265	localidades                                  	I	\N	(0919,"SALITRE (URBINA JADO)",SAL,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
266	localidades                                  	I	\N	(0920,"SAN JACINTO DE YAGUACHI",SAN,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
267	localidades                                  	I	\N	(0921,PLAYAS,PLA,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
268	localidades                                  	I	\N	(0922,"SIMÓN BOLÍVAR",SIM,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
269	localidades                                  	I	\N	(0923,"CORONEL MARCELINO MARIDUEÑA",COR,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
270	localidades                                  	I	\N	(0924,"LOMAS DE SARGENTILLO",LOM,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
271	localidades                                  	I	\N	(0925,NOBOL,NOB,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
272	localidades                                  	I	\N	(0927,"GENERAL ANTONIO ELIZALDE",GEN,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
273	localidades                                  	I	\N	(0928,"ISIDRO AYORA",ISI,09,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
274	localidades                                  	I	\N	(1101,LOJA,LOJ,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
275	localidades                                  	I	\N	(1102,CALVAS,CAL,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
276	localidades                                  	I	\N	(1103,CATAMAYO,CAT,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
277	localidades                                  	I	\N	(1104,CELICA,CEL,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
278	localidades                                  	I	\N	(1105,CHAGUARPAMBA,CHA,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
279	localidades                                  	I	\N	(1106,ESPÍNDOLA,ESP,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
280	localidades                                  	I	\N	(1107,GONZANAMÁ,GON,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
281	localidades                                  	I	\N	(1108,MACARÁ,MAC,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
282	localidades                                  	I	\N	(1109,PALTAS,PAL,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
283	localidades                                  	I	\N	(1110,PUYANGO,PUY,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
284	localidades                                  	I	\N	(1111,SARAGURO,SAR,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
285	localidades                                  	I	\N	(1112,SOZORANGA,SOZ,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
286	localidades                                  	I	\N	(1113,ZAPOTILLO,ZAP,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
287	localidades                                  	I	\N	(1114,PINDAL,PIN,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
288	localidades                                  	I	\N	(1115,QUILANGA,QUI,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
289	localidades                                  	I	\N	(1116,OLMEDO,OLM,11,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
290	localidades                                  	I	\N	(1201,BABAHOYO,BAB,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
291	localidades                                  	I	\N	(1202,BABA,BAB,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
292	localidades                                  	I	\N	(1203,MONTALVO,MON,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
293	localidades                                  	I	\N	(1204,PUEBLOVIEJO,PUE,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
294	localidades                                  	I	\N	(1205,QUEVEDO,QUE,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
295	localidades                                  	I	\N	(1206,URDANETA,URD,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
296	localidades                                  	I	\N	(1207,VENTANAS,VEN,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
297	localidades                                  	I	\N	(1208,VÍNCES,VÍN,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
298	localidades                                  	I	\N	(1209,PALENQUE,PAL,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
299	localidades                                  	I	\N	(1210,"BUENA FÉ",BUE,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
300	localidades                                  	I	\N	(1211,VALENCIA,VAL,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
301	localidades                                  	I	\N	(1212,MOCACHE,MOC,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
302	localidades                                  	I	\N	(1213,QUINSALOMA,QUI,12,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
303	localidades                                  	I	\N	(1301,PORTOVIEJO,POR,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
304	localidades                                  	I	\N	(1302,BOLÍVAR,BOL,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
305	localidades                                  	I	\N	(1303,CHONE,CHO,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
306	localidades                                  	I	\N	(1304,"EL CARMEN","EL ",13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
307	localidades                                  	I	\N	(1305,"FLAVIO ALFARO",FLA,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
308	localidades                                  	I	\N	(1306,JIPIJAPA,JIP,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
309	localidades                                  	I	\N	(1307,JUNÍN,JUN,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
310	localidades                                  	I	\N	(1308,MANTA,MAN,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
311	localidades                                  	I	\N	(1309,MONTECRISTI,MON,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
312	localidades                                  	I	\N	(1310,PAJÁN,PAJ,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
313	localidades                                  	I	\N	(1311,PICHINCHA,PIC,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
314	localidades                                  	I	\N	(1312,ROCAFUERTE,ROC,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
315	localidades                                  	I	\N	(1313,"SANTA ANA",SAN,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
316	localidades                                  	I	\N	(1314,SUCRE,SUC,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
317	localidades                                  	I	\N	(1315,TOSAGUA,TOS,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
318	localidades                                  	I	\N	(1316,"24 DE MAYO","24 ",13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
319	localidades                                  	I	\N	(1317,PEDERNALES,PED,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
320	localidades                                  	I	\N	(1318,OLMEDO,OLM,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
321	localidades                                  	I	\N	(1319,"PUERTO LÓPEZ",PUE,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
322	localidades                                  	I	\N	(1320,JAMA,JAM,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
323	localidades                                  	I	\N	(1321,JARAMIJÓ,JAR,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
324	localidades                                  	I	\N	(1322,"SAN VICENTE",SAN,13,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
325	localidades                                  	I	\N	(1401,MORONA,MOR,14,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
326	localidades                                  	I	\N	(1402,GUALAQUIZA,GUA,14,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
327	localidades                                  	I	\N	(1403,"LIMÓN INDANZA",LIM,14,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
328	localidades                                  	I	\N	(1404,PALORA,PAL,14,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
329	localidades                                  	I	\N	(1405,SANTIAGO,SAN,14,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
330	localidades                                  	I	\N	(1406,SUCÚA,SUC,14,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
331	localidades                                  	I	\N	(1407,HUAMBOYA,HUA,14,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
332	localidades                                  	I	\N	(1408,"SAN JUAN BOSCO",SAN,14,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
333	localidades                                  	I	\N	(1409,TAISHA,TAI,14,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
334	localidades                                  	I	\N	(1410,LOGROÑO,LOG,14,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
335	localidades                                  	I	\N	(1411,"PABLO SEXTO",PAB,14,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
336	localidades                                  	I	\N	(1412,TIWINTZA,TIW,14,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
337	localidades                                  	I	\N	(1501,TENA,TEN,15,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
338	localidades                                  	I	\N	(1503,ARCHIDONA,ARC,15,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
339	localidades                                  	I	\N	(1504,"EL CHACO","EL ",15,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
340	localidades                                  	I	\N	(1507,QUIJOS,QUI,15,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
341	localidades                                  	I	\N	(1509,"CARLOS JULIO AROSEMENA TOLA",CAR,15,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
342	localidades                                  	I	\N	(1601,PASTAZA,PAS,16,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
343	localidades                                  	I	\N	(1602,MERA,MER,16,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
344	localidades                                  	I	\N	(1603,"SANTA CLARA",SAN,16,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
345	localidades                                  	I	\N	(1604,ARAJUNO,ARA,16,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
346	localidades                                  	I	\N	(1701,QUITO,QUI,17,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
347	localidades                                  	I	\N	(1702,CAYAMBE,CAY,17,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
348	localidades                                  	I	\N	(1703,MEJIA,MEJ,17,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
349	localidades                                  	I	\N	(1704,"PEDRO MONCAYO",PED,17,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
350	localidades                                  	I	\N	(1705,RUMIÑAHUI,RUM,17,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
351	localidades                                  	I	\N	(1707,"SAN MIGUEL DE LOS BANCOS",SAN,17,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
352	localidades                                  	I	\N	(1708,"PEDRO VICENTE MALDONADO",PED,17,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
353	localidades                                  	I	\N	(1709,"PUERTO QUITO",PUE,17,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
354	localidades                                  	I	\N	(1801,AMBATO,AMB,18,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
355	localidades                                  	I	\N	(1802,"BAÑOS DE AGUA SANTA",BAÑ,18,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
356	localidades                                  	I	\N	(1803,CEVALLOS,CEV,18,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
357	localidades                                  	I	\N	(1804,MOCHA,MOC,18,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
358	localidades                                  	I	\N	(1805,PATATE,PAT,18,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
359	localidades                                  	I	\N	(1806,QUERO,QUE,18,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
360	localidades                                  	I	\N	(1807,"SAN PEDRO DE PELILEO",SAN,18,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
361	localidades                                  	I	\N	(1808,"SANTIAGO DE PÍLLARO",SAN,18,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
362	localidades                                  	I	\N	(1809,TISALEO,TIS,18,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
363	localidades                                  	I	\N	(1901,ZAMORA,ZAM,19,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
364	localidades                                  	I	\N	(1902,CHINCHIPE,CHI,19,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
365	localidades                                  	I	\N	(1903,NANGARITZA,NAN,19,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
366	localidades                                  	I	\N	(1904,YACUAMBI,YAC,19,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
367	localidades                                  	I	\N	(1905,"YANTZAZA (YANZATZA)",YAN,19,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
368	localidades                                  	I	\N	(1906,"EL PANGUI","EL ",19,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
369	localidades                                  	I	\N	(1907,"CENTINELA DEL CÓNDOR",CEN,19,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
370	localidades                                  	I	\N	(1908,PALANDA,PAL,19,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
371	localidades                                  	I	\N	(1909,PAQUISHA,PAQ,19,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
372	localidades                                  	I	\N	(2001,"SAN CRISTÓBAL",SAN,20,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
373	localidades                                  	I	\N	(2002,ISABELA,ISA,20,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
374	localidades                                  	I	\N	(2003,"SANTA CRUZ",SAN,20,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
375	localidades                                  	I	\N	(2101,"LAGO AGRIO",LAG,21,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
376	localidades                                  	I	\N	(2102,"GONZALO PIZARRO",GON,21,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
377	localidades                                  	I	\N	(2103,PUTUMAYO,PUT,21,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
378	localidades                                  	I	\N	(2104,SHUSHUFINDI,SHU,21,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
379	localidades                                  	I	\N	(2105,SUCUMBÍOS,SUC,21,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
380	localidades                                  	I	\N	(2106,CASCALES,CAS,21,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
381	localidades                                  	I	\N	(2107,CUYABENO,CUY,21,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
382	localidades                                  	I	\N	(2201,ORELLANA,ORE,22,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
383	localidades                                  	I	\N	(2202,AGUARICO,AGU,22,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
384	localidades                                  	I	\N	(2203,"LA JOYA DE LOS SACHAS","LA ",22,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
385	localidades                                  	I	\N	(2204,LORETO,LOR,22,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
386	localidades                                  	I	\N	(2301,"SANTO DOMINGO",SAN,23,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
387	localidades                                  	I	\N	(2401,"SANTA ELENA",SAN,24,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
388	localidades                                  	I	\N	(2402,"LA LIBERTAD","LA ",24,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
389	localidades                                  	I	\N	(2403,SALINAS,SAL,24,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
390	localidades                                  	I	\N	(9001,"LAS GOLONDRINAS",LAS,90,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
391	localidades                                  	I	\N	(9003,"MANGA DEL CURA",MAN,90,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
392	localidades                                  	I	\N	(9004,"EL PIEDRERO","EL ",90,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
393	localidades                                  	I	\N	(010101,BELLAVISTA,BEL,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
394	localidades                                  	I	\N	(010102,CAÑARIBAMBA,CAÑ,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
395	localidades                                  	I	\N	(010103,"EL BATÁN","EL ",0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
396	localidades                                  	I	\N	(010104,"EL SAGRARIO","EL ",0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
397	localidades                                  	I	\N	(010105,"EL VECINO","EL ",0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
398	localidades                                  	I	\N	(010106,"GIL RAMÍREZ DÁVALOS",GIL,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
399	localidades                                  	I	\N	(010107,HUAYNACÁPAC,HUA,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
400	localidades                                  	I	\N	(010108,MACHÁNGARA,MAC,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
401	localidades                                  	I	\N	(010109,MONAY,MON,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
402	localidades                                  	I	\N	(010110,"SAN BLAS",SAN,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
403	localidades                                  	I	\N	(010111,"SAN SEBASTIÁN",SAN,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
404	localidades                                  	I	\N	(010112,SUCRE,SUC,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
405	localidades                                  	I	\N	(010113,TOTORACOCHA,TOT,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
406	localidades                                  	I	\N	(010114,YANUNCAY,YAN,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
407	localidades                                  	I	\N	(010115,"HERMANO MIGUEL",HER,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
408	localidades                                  	I	\N	(010150,CUENCA,CUE,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
409	localidades                                  	I	\N	(010151,BAÑOS,BAÑ,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
410	localidades                                  	I	\N	(010152,CUMBE,CUM,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
411	localidades                                  	I	\N	(010153,CHAUCHA,CHA,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
412	localidades                                  	I	\N	(010154,"CHECA (JIDCAY)",CHE,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
413	localidades                                  	I	\N	(010155,CHIQUINTAD,CHI,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
414	localidades                                  	I	\N	(010156,LLACAO,LLA,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
415	localidades                                  	I	\N	(010157,MOLLETURO,MOL,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
416	localidades                                  	I	\N	(010158,NULTI,NUL,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
417	localidades                                  	I	\N	(010159,"OCTAVIO CORDERO PALACIOS (SANTA ROSA)",OCT,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
418	localidades                                  	I	\N	(010160,PACCHA,PAC,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
419	localidades                                  	I	\N	(010161,QUINGEO,QUI,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
420	localidades                                  	I	\N	(010162,RICAURTE,RIC,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
421	localidades                                  	I	\N	(010163,"SAN JOAQUÍN",SAN,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
422	localidades                                  	I	\N	(010164,"SANTA ANA",SAN,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
423	localidades                                  	I	\N	(010165,SAYAUSÍ,SAY,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
424	localidades                                  	I	\N	(010166,SIDCAY,SID,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
425	localidades                                  	I	\N	(010167,SININCAY,SIN,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
426	localidades                                  	I	\N	(010168,TARQUI,TAR,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
427	localidades                                  	I	\N	(010169,TURI,TUR,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
428	localidades                                  	I	\N	(010170,VALLE,VAL,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
429	localidades                                  	I	\N	(010171,"VICTORIA DEL PORTETE (IRQUIS)",VIC,0101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
430	localidades                                  	I	\N	(010250,GIRÓN,GIR,0102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
431	localidades                                  	I	\N	(010251,ASUNCIÓN,ASU,0102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
432	localidades                                  	I	\N	(010252,"SAN GERARDO",SAN,0102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
433	localidades                                  	I	\N	(010350,GUALACEO,GUA,0103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
434	localidades                                  	I	\N	(010351,CHORDELEG,CHO,0103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
435	localidades                                  	I	\N	(010352,"DANIEL CÓRDOVA TORAL (EL ORIENTE)",DAN,0103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
436	localidades                                  	I	\N	(010353,JADÁN,JAD,0103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
437	localidades                                  	I	\N	(010354,"MARIANO MORENO",MAR,0103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
438	localidades                                  	I	\N	(010355,PRINCIPAL,PRI,0103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
439	localidades                                  	I	\N	(010356,"REMIGIO CRESPO TORAL (GÚLAG)",REM,0103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
440	localidades                                  	I	\N	(010357,"SAN JUAN",SAN,0103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
441	localidades                                  	I	\N	(010358,ZHIDMAD,ZHI,0103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
442	localidades                                  	I	\N	(010359,"LUIS CORDERO VEGA",LUI,0103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
443	localidades                                  	I	\N	(010360,"SIMÓN BOLÍVAR (CAB. EN GAÑANZOL)",SIM,0103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
444	localidades                                  	I	\N	(010450,NABÓN,NAB,0104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
445	localidades                                  	I	\N	(010451,COCHAPATA,COC,0104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
446	localidades                                  	I	\N	(010452,"EL PROGRESO (CAB.EN ZHOTA)","EL ",0104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
447	localidades                                  	I	\N	(010453,"LAS NIEVES (CHAYA)",LAS,0104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
448	localidades                                  	I	\N	(010454,OÑA,OÑA,0104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
449	localidades                                  	I	\N	(010550,PAUTE,PAU,0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
450	localidades                                  	I	\N	(010551,AMALUZA,AMA,0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
451	localidades                                  	I	\N	(010552,"BULÁN (JOSÉ VÍCTOR IZQUIERDO)",BUL,0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
452	localidades                                  	I	\N	(010553,"CHICÁN (GUILLERMO ORTEGA)",CHI,0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
453	localidades                                  	I	\N	(010554,"EL CABO","EL ",0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
454	localidades                                  	I	\N	(010555,GUACHAPALA,GUA,0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
455	localidades                                  	I	\N	(010556,GUARAINAG,GUA,0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
456	localidades                                  	I	\N	(010557,PALMAS,PAL,0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
457	localidades                                  	I	\N	(010558,PAN,PAN,0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
458	localidades                                  	I	\N	(010559,"SAN CRISTÓBAL (CARLOS ORDÓÑEZ LAZO)",SAN,0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
459	localidades                                  	I	\N	(010560,"SEVILLA DE ORO",SEV,0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
460	localidades                                  	I	\N	(010561,TOMEBAMBA,TOM,0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
461	localidades                                  	I	\N	(010562,"DUG DUG",DUG,0105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
462	localidades                                  	I	\N	(010650,PUCARÁ,PUC,0106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
463	localidades                                  	I	\N	(010651,"CAMILO PONCE ENRÍQUEZ (CAB. EN RÍO 7 DE MOLLEPONGO)",CAM,0106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
464	localidades                                  	I	\N	(010652,"SAN RAFAEL DE SHARUG",SAN,0106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
465	localidades                                  	I	\N	(010750,"SAN FERNANDO",SAN,0107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
466	localidades                                  	I	\N	(010751,CHUMBLÍN,CHU,0107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
467	localidades                                  	I	\N	(010850,"SANTA ISABEL (CHAGUARURCO)",SAN,0108,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
468	localidades                                  	I	\N	(010851,"ABDÓN CALDERÓN (LA UNIÓN)",ABD,0108,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
469	localidades                                  	I	\N	(010852,"EL CARMEN DE PIJILÍ","EL ",0108,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
470	localidades                                  	I	\N	(010853,"ZHAGLLI (SHAGLLI)",ZHA,0108,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
471	localidades                                  	I	\N	(010854,"SAN SALVADOR DE CAÑARIBAMBA",SAN,0108,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
472	localidades                                  	I	\N	(010950,SIGSIG,SIG,0109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
473	localidades                                  	I	\N	(010951,"CUCHIL (CUTCHIL)",CUC,0109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
474	localidades                                  	I	\N	(010952,GIMA,GIM,0109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
475	localidades                                  	I	\N	(010953,GUEL,GUE,0109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
476	localidades                                  	I	\N	(010954,LUDO,LUD,0109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
477	localidades                                  	I	\N	(010955,"SAN BARTOLOMÉ",SAN,0109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
478	localidades                                  	I	\N	(010956,"SAN JOSÉ DE RARANGA",SAN,0109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
479	localidades                                  	I	\N	(011050,"SAN FELIPE DE OÑA CABECERA CANTONAL",SAN,0110,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
480	localidades                                  	I	\N	(011051,SUSUDEL,SUS,0110,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
481	localidades                                  	I	\N	(011150,CHORDELEG,CHO,0111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
482	localidades                                  	I	\N	(011151,PRINCIPAL,PRI,0111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
483	localidades                                  	I	\N	(011152,"LA UNIÓN","LA ",0111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
484	localidades                                  	I	\N	(011153,"LUIS GALARZA ORELLANA (CAB.EN DELEGSOL)",LUI,0111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
485	localidades                                  	I	\N	(011154,"SAN MARTÍN DE PUZHIO",SAN,0111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
486	localidades                                  	I	\N	(011250,"EL PAN","EL ",0112,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
487	localidades                                  	I	\N	(011251,AMALUZA,AMA,0112,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
488	localidades                                  	I	\N	(011252,PALMAS,PAL,0112,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
489	localidades                                  	I	\N	(011253,"SAN VICENTE",SAN,0112,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
490	localidades                                  	I	\N	(011350,"SEVILLA DE ORO",SEV,0113,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
491	localidades                                  	I	\N	(011351,AMALUZA,AMA,0113,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
492	localidades                                  	I	\N	(011352,PALMAS,PAL,0113,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
493	localidades                                  	I	\N	(011450,GUACHAPALA,GUA,0114,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
494	localidades                                  	I	\N	(011550,"CAMILO PONCE ENRÍQUEZ",CAM,0115,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
495	localidades                                  	I	\N	(011551,"EL CARMEN DE PIJILÍ","EL ",0115,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
496	localidades                                  	I	\N	(020101,"ÁNGEL POLIBIO CHÁVES",ÁNG,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
497	localidades                                  	I	\N	(020102,"GABRIEL IGNACIO VEINTIMILLA",GAB,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
498	localidades                                  	I	\N	(020103,GUANUJO,GUA,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
499	localidades                                  	I	\N	(020150,GUARANDA,GUA,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
500	localidades                                  	I	\N	(020151,"FACUNDO VELA",FAC,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
501	localidades                                  	I	\N	(020152,GUANUJO,GUA,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
502	localidades                                  	I	\N	(020153,"JULIO E. MORENO (CATANAHUÁN GRANDE)",JUL,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
503	localidades                                  	I	\N	(020154,"LAS NAVES",LAS,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
504	localidades                                  	I	\N	(020155,SALINAS,SAL,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
505	localidades                                  	I	\N	(020156,"SAN LORENZO",SAN,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
506	localidades                                  	I	\N	(020157,"SAN SIMÓN (YACOTO)",SAN,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
507	localidades                                  	I	\N	(020158,"SANTA FÉ (SANTA FÉ)",SAN,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
508	localidades                                  	I	\N	(020159,SIMIÁTUG,SIM,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
509	localidades                                  	I	\N	(020160,"SAN LUIS DE PAMBIL",SAN,0201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
510	localidades                                  	I	\N	(020250,CHILLANES,CHI,0202,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
511	localidades                                  	I	\N	(020251,"SAN JOSÉ DEL TAMBO (TAMBOPAMBA)",SAN,0202,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
512	localidades                                  	I	\N	(020350,"SAN JOSÉ DE CHIMBO",SAN,0203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
513	localidades                                  	I	\N	(020351,"ASUNCIÓN (ASANCOTO)",ASU,0203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
514	localidades                                  	I	\N	(020352,CALUMA,CAL,0203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
515	localidades                                  	I	\N	(020353,"MAGDALENA (CHAPACOTO)",MAG,0203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
516	localidades                                  	I	\N	(020354,"SAN SEBASTIÁN",SAN,0203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
517	localidades                                  	I	\N	(020355,TELIMBELA,TEL,0203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
518	localidades                                  	I	\N	(020450,ECHEANDÍA,ECH,0204,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
519	localidades                                  	I	\N	(020550,"SAN MIGUEL",SAN,0205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
520	localidades                                  	I	\N	(020551,BALSAPAMBA,BAL,0205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
521	localidades                                  	I	\N	(020552,BILOVÁN,BIL,0205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
522	localidades                                  	I	\N	(020553,"RÉGULO DE MORA",RÉG,0205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
523	localidades                                  	I	\N	(020554,"SAN PABLO (SAN PABLO DE ATENAS)",SAN,0205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
524	localidades                                  	I	\N	(020555,SANTIAGO,SAN,0205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
525	localidades                                  	I	\N	(020556,"SAN VICENTE",SAN,0205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
526	localidades                                  	I	\N	(020650,CALUMA,CAL,0206,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
527	localidades                                  	I	\N	(020701,"LAS MERCEDES",LAS,0207,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
528	localidades                                  	I	\N	(020702,"LAS NAVES",LAS,0207,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
529	localidades                                  	I	\N	(020750,"LAS NAVES",LAS,0207,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
530	localidades                                  	I	\N	(030101,"AURELIO BAYAS MARTÍNEZ",AUR,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
531	localidades                                  	I	\N	(030102,AZOGUES,AZO,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
532	localidades                                  	I	\N	(030103,BORRERO,BOR,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
533	localidades                                  	I	\N	(030104,"SAN FRANCISCO",SAN,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
534	localidades                                  	I	\N	(030150,AZOGUES,AZO,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
535	localidades                                  	I	\N	(030151,COJITAMBO,COJ,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
536	localidades                                  	I	\N	(030152,DÉLEG,DÉL,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
537	localidades                                  	I	\N	(030153,GUAPÁN,GUA,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
538	localidades                                  	I	\N	(030154,"JAVIER LOYOLA (CHUQUIPATA)",JAV,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
539	localidades                                  	I	\N	(030155,"LUIS CORDERO",LUI,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
540	localidades                                  	I	\N	(030156,PINDILIG,PIN,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
541	localidades                                  	I	\N	(030157,RIVERA,RIV,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
542	localidades                                  	I	\N	(030158,"SAN MIGUEL",SAN,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
543	localidades                                  	I	\N	(030159,SOLANO,SOL,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
544	localidades                                  	I	\N	(030160,TADAY,TAD,0301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
545	localidades                                  	I	\N	(030250,BIBLIÁN,BIB,0302,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
546	localidades                                  	I	\N	(030251,"NAZÓN (CAB. EN PAMPA DE DOMÍNGUEZ)",NAZ,0302,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
547	localidades                                  	I	\N	(030252,"SAN FRANCISCO DE SAGEO",SAN,0302,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
548	localidades                                  	I	\N	(030253,TURUPAMBA,TUR,0302,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
549	localidades                                  	I	\N	(030254,JERUSALÉN,JER,0302,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
550	localidades                                  	I	\N	(030350,CAÑAR,CAÑ,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
551	localidades                                  	I	\N	(030351,CHONTAMARCA,CHO,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
552	localidades                                  	I	\N	(030352,CHOROCOPTE,CHO,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
553	localidades                                  	I	\N	(030353,"GENERAL MORALES (SOCARTE)",GEN,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
554	localidades                                  	I	\N	(030354,GUALLETURO,GUA,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
555	localidades                                  	I	\N	(030355,"HONORATO VÁSQUEZ (TAMBO VIEJO)",HON,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
556	localidades                                  	I	\N	(030356,INGAPIRCA,ING,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
557	localidades                                  	I	\N	(030357,JUNCAL,JUN,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
558	localidades                                  	I	\N	(030358,"SAN ANTONIO",SAN,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
559	localidades                                  	I	\N	(030359,SUSCAL,SUS,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
560	localidades                                  	I	\N	(030360,TAMBO,TAM,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
561	localidades                                  	I	\N	(030361,ZHUD,ZHU,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
562	localidades                                  	I	\N	(030362,VENTURA,VEN,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
563	localidades                                  	I	\N	(030363,DUCUR,DUC,0303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
564	localidades                                  	I	\N	(030450,"LA TRONCAL","LA ",0304,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
565	localidades                                  	I	\N	(030451,"MANUEL J. CALLE",MAN,0304,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
566	localidades                                  	I	\N	(030452,"PANCHO NEGRO",PAN,0304,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
567	localidades                                  	I	\N	(030550,"EL TAMBO","EL ",0305,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
568	localidades                                  	I	\N	(030650,DÉLEG,DÉL,0306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
569	localidades                                  	I	\N	(030651,SOLANO,SOL,0306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
570	localidades                                  	I	\N	(030750,SUSCAL,SUS,0307,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
571	localidades                                  	I	\N	(040101,"GONZÁLEZ SUÁREZ",GON,0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
572	localidades                                  	I	\N	(040102,TULCÁN,TUL,0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
573	localidades                                  	I	\N	(040150,TULCÁN,TUL,0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
574	localidades                                  	I	\N	(040151,"EL CARMELO (EL PUN)","EL ",0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
575	localidades                                  	I	\N	(040152,HUACA,HUA,0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
576	localidades                                  	I	\N	(040153,"JULIO ANDRADE (OREJUELA)",JUL,0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
577	localidades                                  	I	\N	(040154,MALDONADO,MAL,0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
578	localidades                                  	I	\N	(040155,PIOTER,PIO,0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
579	localidades                                  	I	\N	(040156,"TOBAR DONOSO (LA BOCANA DE CAMUMBÍ)",TOB,0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
580	localidades                                  	I	\N	(040157,TUFIÑO,TUF,0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
581	localidades                                  	I	\N	(040158,"URBINA (TAYA)",URB,0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
582	localidades                                  	I	\N	(040159,"EL CHICAL","EL ",0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
583	localidades                                  	I	\N	(040160,"MARISCAL SUCRE",MAR,0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
584	localidades                                  	I	\N	(040161,"SANTA MARTHA DE CUBA",SAN,0401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
585	localidades                                  	I	\N	(040250,BOLÍVAR,BOL,0402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
586	localidades                                  	I	\N	(040251,"GARCÍA MORENO",GAR,0402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
587	localidades                                  	I	\N	(040252,"LOS ANDES",LOS,0402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
588	localidades                                  	I	\N	(040253,"MONTE OLIVO",MON,0402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
589	localidades                                  	I	\N	(040254,"SAN VICENTE DE PUSIR",SAN,0402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
590	localidades                                  	I	\N	(040255,"SAN RAFAEL",SAN,0402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
591	localidades                                  	I	\N	(040301,"EL ÁNGEL","EL ",0403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
592	localidades                                  	I	\N	(040302,"27 DE SEPTIEMBRE","27 ",0403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
593	localidades                                  	I	\N	(040350,"EL ANGEL","EL ",0403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
594	localidades                                  	I	\N	(040351,"EL GOALTAL","EL ",0403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
595	localidades                                  	I	\N	(040352,"LA LIBERTAD (ALIZO)","LA ",0403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
596	localidades                                  	I	\N	(040353,"SAN ISIDRO",SAN,0403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
597	localidades                                  	I	\N	(040450,"MIRA (CHONTAHUASI)",MIR,0404,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
598	localidades                                  	I	\N	(040451,CONCEPCIÓN,CON,0404,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
599	localidades                                  	I	\N	(040452,"JIJÓN Y CAAMAÑO (CAB. EN RÍO BLANCO)",JIJ,0404,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
600	localidades                                  	I	\N	(040453,"JUAN MONTALVO (SAN IGNACIO DE QUIL)",JUA,0404,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
601	localidades                                  	I	\N	(040501,"GONZÁLEZ SUÁREZ",GON,0405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
602	localidades                                  	I	\N	(040502,"SAN JOSÉ",SAN,0405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
603	localidades                                  	I	\N	(040550,"SAN GABRIEL",SAN,0405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
604	localidades                                  	I	\N	(040551,"CRISTÓBAL COLÓN",CRI,0405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
605	localidades                                  	I	\N	(040552,"CHITÁN DE NAVARRETE",CHI,0405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
606	localidades                                  	I	\N	(040553,"FERNÁNDEZ SALVADOR",FER,0405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
607	localidades                                  	I	\N	(040554,"LA PAZ","LA ",0405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
608	localidades                                  	I	\N	(040555,PIARTAL,PIA,0405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
609	localidades                                  	I	\N	(040650,HUACA,HUA,0406,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
610	localidades                                  	I	\N	(040651,"MARISCAL SUCRE",MAR,0406,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
611	localidades                                  	I	\N	(050101,"ELOY ALFARO (SAN FELIPE)",ELO,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
612	localidades                                  	I	\N	(050102,"IGNACIO FLORES (PARQUE FLORES)",IGN,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
613	localidades                                  	I	\N	(050103,"JUAN MONTALVO (SAN SEBASTIÁN)",JUA,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
614	localidades                                  	I	\N	(050104,"LA MATRIZ","LA ",0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
615	localidades                                  	I	\N	(050105,"SAN BUENAVENTURA",SAN,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
616	localidades                                  	I	\N	(050150,LATACUNGA,LAT,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
617	localidades                                  	I	\N	(050151,"ALAQUES (ALÁQUEZ)",ALA,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
891	localidades                                  	I	\N	(080654,TONSUPA,TON,0806,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
618	localidades                                  	I	\N	(050152,"BELISARIO QUEVEDO (GUANAILÍN)",BEL,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
619	localidades                                  	I	\N	(050153,"GUAITACAMA (GUAYTACAMA)",GUA,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
620	localidades                                  	I	\N	(050154,"JOSEGUANGO BAJO",JOS,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
621	localidades                                  	I	\N	(050155,"LAS PAMPAS",LAS,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
622	localidades                                  	I	\N	(050156,MULALÓ,MUL,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
623	localidades                                  	I	\N	(050157,"11 DE NOVIEMBRE (ILINCHISI)","11 ",0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
624	localidades                                  	I	\N	(050158,POALÓ,POA,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
625	localidades                                  	I	\N	(050159,"SAN JUAN DE PASTOCALLE",SAN,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
626	localidades                                  	I	\N	(050160,SIGCHOS,SIG,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
627	localidades                                  	I	\N	(050161,TANICUCHÍ,TAN,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
628	localidades                                  	I	\N	(050162,TOACASO,TOA,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
629	localidades                                  	I	\N	(050163,"PALO QUEMADO",PAL,0501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
630	localidades                                  	I	\N	(050201,"EL CARMEN","EL ",0502,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
631	localidades                                  	I	\N	(050202,"LA MANÁ","LA ",0502,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
632	localidades                                  	I	\N	(050203,"EL TRIUNFO","EL ",0502,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
633	localidades                                  	I	\N	(050250,"LA MANÁ","LA ",0502,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
634	localidades                                  	I	\N	(050251,"GUASAGANDA (CAB.EN GUASAGANDA",GUA,0502,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
635	localidades                                  	I	\N	(050252,PUCAYACU,PUC,0502,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
636	localidades                                  	I	\N	(050350,"EL CORAZÓN","EL ",0503,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
637	localidades                                  	I	\N	(050351,MORASPUNGO,MOR,0503,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
638	localidades                                  	I	\N	(050352,PINLLOPATA,PIN,0503,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
639	localidades                                  	I	\N	(050353,"RAMÓN CAMPAÑA",RAM,0503,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
640	localidades                                  	I	\N	(050450,PUJILÍ,PUJ,0504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
641	localidades                                  	I	\N	(050451,ANGAMARCA,ANG,0504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
642	localidades                                  	I	\N	(050452,"CHUCCHILÁN (CHUGCHILÁN)",CHU,0504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
643	localidades                                  	I	\N	(050453,GUANGAJE,GUA,0504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
644	localidades                                  	I	\N	(050454,"ISINLIBÍ (ISINLIVÍ)",ISI,0504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
645	localidades                                  	I	\N	(050455,"LA VICTORIA","LA ",0504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
646	localidades                                  	I	\N	(050456,PILALÓ,PIL,0504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
647	localidades                                  	I	\N	(050457,TINGO,TIN,0504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
648	localidades                                  	I	\N	(050458,ZUMBAHUA,ZUM,0504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
649	localidades                                  	I	\N	(050550,"SAN MIGUEL",SAN,0505,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
650	localidades                                  	I	\N	(050551,"ANTONIO JOSÉ HOLGUÍN (SANTA LUCÍA)",ANT,0505,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
651	localidades                                  	I	\N	(050552,CUSUBAMBA,CUS,0505,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
652	localidades                                  	I	\N	(050553,MULALILLO,MUL,0505,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
653	localidades                                  	I	\N	(050554,"MULLIQUINDIL (SANTA ANA)",MUL,0505,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
654	localidades                                  	I	\N	(050555,PANSALEO,PAN,0505,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
655	localidades                                  	I	\N	(050650,SAQUISILÍ,SAQ,0506,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
656	localidades                                  	I	\N	(050651,CANCHAGUA,CAN,0506,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
657	localidades                                  	I	\N	(050652,CHANTILÍN,CHA,0506,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
658	localidades                                  	I	\N	(050653,COCHAPAMBA,COC,0506,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
659	localidades                                  	I	\N	(050750,SIGCHOS,SIG,0507,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
660	localidades                                  	I	\N	(050751,CHUGCHILLÁN,CHU,0507,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
661	localidades                                  	I	\N	(050752,ISINLIVÍ,ISI,0507,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
662	localidades                                  	I	\N	(050753,"LAS PAMPAS",LAS,0507,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
663	localidades                                  	I	\N	(050754,"PALO QUEMADO",PAL,0507,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
664	localidades                                  	I	\N	(060101,LIZARZABURU,LIZ,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
665	localidades                                  	I	\N	(060102,MALDONADO,MAL,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
666	localidades                                  	I	\N	(060103,VELASCO,VEL,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
667	localidades                                  	I	\N	(060104,VELOZ,VEL,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
668	localidades                                  	I	\N	(060105,YARUQUÍES,YAR,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
669	localidades                                  	I	\N	(060150,RIOBAMBA,RIO,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
670	localidades                                  	I	\N	(060151,"CACHA (CAB. EN MACHÁNGARA)",CAC,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
671	localidades                                  	I	\N	(060152,CALPI,CAL,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
672	localidades                                  	I	\N	(060153,CUBIJÍES,CUB,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
673	localidades                                  	I	\N	(060154,FLORES,FLO,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
674	localidades                                  	I	\N	(060155,LICÁN,LIC,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
675	localidades                                  	I	\N	(060156,LICTO,LIC,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
676	localidades                                  	I	\N	(060157,PUNGALÁ,PUN,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
677	localidades                                  	I	\N	(060158,PUNÍN,PUN,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
678	localidades                                  	I	\N	(060159,QUIMIAG,QUI,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
679	localidades                                  	I	\N	(060160,"SAN JUAN",SAN,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
680	localidades                                  	I	\N	(060161,"SAN LUIS",SAN,0601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
681	localidades                                  	I	\N	(060250,ALAUSÍ,ALA,0602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
682	localidades                                  	I	\N	(060251,ACHUPALLAS,ACH,0602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
683	localidades                                  	I	\N	(060252,CUMANDÁ,CUM,0602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
684	localidades                                  	I	\N	(060253,GUASUNTOS,GUA,0602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
685	localidades                                  	I	\N	(060254,HUIGRA,HUI,0602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
686	localidades                                  	I	\N	(060255,MULTITUD,MUL,0602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
687	localidades                                  	I	\N	(060256,"PISTISHÍ (NARIZ DEL DIABLO)",PIS,0602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
688	localidades                                  	I	\N	(060257,PUMALLACTA,PUM,0602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
689	localidades                                  	I	\N	(060258,SEVILLA,SEV,0602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
690	localidades                                  	I	\N	(060259,SIBAMBE,SIB,0602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
691	localidades                                  	I	\N	(060260,TIXÁN,TIX,0602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
692	localidades                                  	I	\N	(060301,CAJABAMBA,CAJ,0603,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
693	localidades                                  	I	\N	(060302,SICALPA,SIC,0603,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
694	localidades                                  	I	\N	(060350,"VILLA LA UNIÓN (CAJABAMBA)",VIL,0603,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
695	localidades                                  	I	\N	(060351,CAÑI,CAÑ,0603,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
696	localidades                                  	I	\N	(060352,COLUMBE,COL,0603,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
697	localidades                                  	I	\N	(060353,"JUAN DE VELASCO (PANGOR)",JUA,0603,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
698	localidades                                  	I	\N	(060354,"SANTIAGO DE QUITO (CAB. EN SAN ANTONIO DE QUITO)",SAN,0603,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
699	localidades                                  	I	\N	(060450,CHAMBO,CHA,0604,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
700	localidades                                  	I	\N	(060550,CHUNCHI,CHU,0605,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
701	localidades                                  	I	\N	(060551,CAPZOL,CAP,0605,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
702	localidades                                  	I	\N	(060552,COMPUD,COM,0605,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
703	localidades                                  	I	\N	(060553,GONZOL,GON,0605,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
704	localidades                                  	I	\N	(060554,LLAGOS,LLA,0605,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
705	localidades                                  	I	\N	(060650,GUAMOTE,GUA,0606,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
706	localidades                                  	I	\N	(060651,CEBADAS,CEB,0606,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
707	localidades                                  	I	\N	(060652,PALMIRA,PAL,0606,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
708	localidades                                  	I	\N	(060701,"EL ROSARIO","EL ",0607,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
709	localidades                                  	I	\N	(060702,"LA MATRIZ","LA ",0607,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
710	localidades                                  	I	\N	(060750,GUANO,GUA,0607,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
711	localidades                                  	I	\N	(060751,GUANANDO,GUA,0607,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
712	localidades                                  	I	\N	(060752,ILAPO,ILA,0607,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
713	localidades                                  	I	\N	(060753,"LA PROVIDENCIA","LA ",0607,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
714	localidades                                  	I	\N	(060754,"SAN ANDRÉS",SAN,0607,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
715	localidades                                  	I	\N	(060755,"SAN GERARDO DE PACAICAGUÁN",SAN,0607,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
716	localidades                                  	I	\N	(060756,"SAN ISIDRO DE PATULÚ",SAN,0607,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
717	localidades                                  	I	\N	(060757,"SAN JOSÉ DEL CHAZO",SAN,0607,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
718	localidades                                  	I	\N	(060758,"SANTA FÉ DE GALÁN",SAN,0607,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
719	localidades                                  	I	\N	(060759,VALPARAÍSO,VAL,0607,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
720	localidades                                  	I	\N	(060850,PALLATANGA,PAL,0608,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
721	localidades                                  	I	\N	(060950,PENIPE,PEN,0609,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
722	localidades                                  	I	\N	(060951,"EL ALTAR","EL ",0609,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
723	localidades                                  	I	\N	(060952,MATUS,MAT,0609,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
724	localidades                                  	I	\N	(060953,PUELA,PUE,0609,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
725	localidades                                  	I	\N	(060954,"SAN ANTONIO DE BAYUSHIG",SAN,0609,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
726	localidades                                  	I	\N	(060955,"LA CANDELARIA","LA ",0609,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
727	localidades                                  	I	\N	(060956,"BILBAO (CAB.EN QUILLUYACU)",BIL,0609,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
728	localidades                                  	I	\N	(061050,CUMANDÁ,CUM,0610,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
729	localidades                                  	I	\N	(070101,"LA PROVIDENCIA","LA ",0701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
730	localidades                                  	I	\N	(070102,MACHALA,MAC,0701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
731	localidades                                  	I	\N	(070103,"PUERTO BOLÍVAR",PUE,0701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
732	localidades                                  	I	\N	(070104,"NUEVE DE MAYO",NUE,0701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
733	localidades                                  	I	\N	(070105,"EL CAMBIO","EL ",0701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
734	localidades                                  	I	\N	(070150,MACHALA,MAC,0701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
735	localidades                                  	I	\N	(070151,"EL CAMBIO","EL ",0701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
736	localidades                                  	I	\N	(070152,"EL RETIRO","EL ",0701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
737	localidades                                  	I	\N	(070250,ARENILLAS,ARE,0702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
738	localidades                                  	I	\N	(070251,CHACRAS,CHA,0702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
739	localidades                                  	I	\N	(070252,"LA LIBERTAD","LA ",0702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
740	localidades                                  	I	\N	(070253,"LAS LAJAS (CAB. EN LA VICTORIA)",LAS,0702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
741	localidades                                  	I	\N	(070254,PALMALES,PAL,0702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
742	localidades                                  	I	\N	(070255,CARCABÓN,CAR,0702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
743	localidades                                  	I	\N	(070350,PACCHA,PAC,0703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
744	localidades                                  	I	\N	(070351,AYAPAMBA,AYA,0703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
745	localidades                                  	I	\N	(070352,CORDONCILLO,COR,0703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
746	localidades                                  	I	\N	(070353,MILAGRO,MIL,0703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
747	localidades                                  	I	\N	(070354,"SAN JOSÉ",SAN,0703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
748	localidades                                  	I	\N	(070355,"SAN JUAN DE CERRO AZUL",SAN,0703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
749	localidades                                  	I	\N	(070450,BALSAS,BAL,0704,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
750	localidades                                  	I	\N	(070451,BELLAMARÍA,BEL,0704,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
751	localidades                                  	I	\N	(070550,CHILLA,CHI,0705,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
752	localidades                                  	I	\N	(070650,"EL GUABO","EL ",0706,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
753	localidades                                  	I	\N	(070651,"BARBONES (SUCRE)",BAR,0706,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
754	localidades                                  	I	\N	(070652,"LA IBERIA","LA ",0706,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
755	localidades                                  	I	\N	(070653,"TENDALES (CAB.EN PUERTO TENDALES)",TEN,0706,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
756	localidades                                  	I	\N	(070654,"RÍO BONITO",RÍO,0706,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
757	localidades                                  	I	\N	(070701,ECUADOR,ECU,0707,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
758	localidades                                  	I	\N	(070702,"EL PARAÍSO","EL ",0707,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
759	localidades                                  	I	\N	(070703,HUALTACO,HUA,0707,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
760	localidades                                  	I	\N	(070704,"MILTON REYES",MIL,0707,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
761	localidades                                  	I	\N	(070705,"UNIÓN LOJANA",UNI,0707,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
762	localidades                                  	I	\N	(070750,HUAQUILLAS,HUA,0707,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
763	localidades                                  	I	\N	(070850,MARCABELÍ,MAR,0708,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
764	localidades                                  	I	\N	(070851,"EL INGENIO","EL ",0708,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
765	localidades                                  	I	\N	(070901,BOLÍVAR,BOL,0709,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
766	localidades                                  	I	\N	(070902,"LOMA DE FRANCO",LOM,0709,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
767	localidades                                  	I	\N	(070903,"OCHOA LEÓN (MATRIZ)",OCH,0709,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
768	localidades                                  	I	\N	(070904,"TRES CERRITOS",TRE,0709,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
769	localidades                                  	I	\N	(070950,PASAJE,PAS,0709,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
770	localidades                                  	I	\N	(070951,BUENAVISTA,BUE,0709,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
771	localidades                                  	I	\N	(070952,CASACAY,CAS,0709,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
772	localidades                                  	I	\N	(070953,"LA PEAÑA","LA ",0709,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
773	localidades                                  	I	\N	(070954,PROGRESO,PRO,0709,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
774	localidades                                  	I	\N	(070955,UZHCURRUMI,UZH,0709,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
775	localidades                                  	I	\N	(070956,CAÑAQUEMADA,CAÑ,0709,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
776	localidades                                  	I	\N	(071001,"LA MATRIZ","LA ",0710,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
777	localidades                                  	I	\N	(071002,"LA SUSAYA","LA ",0710,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
778	localidades                                  	I	\N	(071003,"PIÑAS GRANDE",PIÑ,0710,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
779	localidades                                  	I	\N	(071050,PIÑAS,PIÑ,0710,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
780	localidades                                  	I	\N	(071051,"CAPIRO (CAB. EN LA CAPILLA DE CAPIRO)",CAP,0710,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
781	localidades                                  	I	\N	(071052,"LA BOCANA","LA ",0710,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
782	localidades                                  	I	\N	(071053,"MOROMORO (CAB. EN EL VADO)",MOR,0710,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
783	localidades                                  	I	\N	(071054,PIEDRAS,PIE,0710,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
784	localidades                                  	I	\N	(071055,"SAN ROQUE (AMBROSIO MALDONADO)",SAN,0710,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
785	localidades                                  	I	\N	(071056,SARACAY,SAR,0710,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
786	localidades                                  	I	\N	(071150,PORTOVELO,POR,0711,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
787	localidades                                  	I	\N	(071151,CURTINCAPA,CUR,0711,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
788	localidades                                  	I	\N	(071152,MORALES,MOR,0711,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
789	localidades                                  	I	\N	(071153,SALATÍ,SAL,0711,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
790	localidades                                  	I	\N	(071201,"SANTA ROSA",SAN,0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
791	localidades                                  	I	\N	(071202,"PUERTO JELÍ",PUE,0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
792	localidades                                  	I	\N	(071203,"BALNEARIO JAMBELÍ (SATÉLITE)",BAL,0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
793	localidades                                  	I	\N	(071204,"JUMÓN (SATÉLITE)",JUM,0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
794	localidades                                  	I	\N	(071205,"NUEVO SANTA ROSA",NUE,0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
795	localidades                                  	I	\N	(071250,"SANTA ROSA",SAN,0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
796	localidades                                  	I	\N	(071251,BELLAVISTA,BEL,0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
797	localidades                                  	I	\N	(071252,JAMBELÍ,JAM,0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
798	localidades                                  	I	\N	(071253,"LA AVANZADA","LA ",0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
799	localidades                                  	I	\N	(071254,"SAN ANTONIO",SAN,0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
800	localidades                                  	I	\N	(071255,TORATA,TOR,0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
801	localidades                                  	I	\N	(071256,VICTORIA,VIC,0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
802	localidades                                  	I	\N	(071257,BELLAMARÍA,BEL,0712,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
803	localidades                                  	I	\N	(071350,ZARUMA,ZAR,0713,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
804	localidades                                  	I	\N	(071351,ABAÑÍN,ABA,0713,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
805	localidades                                  	I	\N	(071352,ARCAPAMBA,ARC,0713,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
806	localidades                                  	I	\N	(071353,GUANAZÁN,GUA,0713,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
807	localidades                                  	I	\N	(071354,GUIZHAGUIÑA,GUI,0713,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
808	localidades                                  	I	\N	(071355,HUERTAS,HUE,0713,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
809	localidades                                  	I	\N	(071356,MALVAS,MAL,0713,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
810	localidades                                  	I	\N	(071357,"MULUNCAY GRANDE",MUL,0713,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
811	localidades                                  	I	\N	(071358,SINSAO,SIN,0713,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
812	localidades                                  	I	\N	(071359,SALVIAS,SAL,0713,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
813	localidades                                  	I	\N	(071401,"LA VICTORIA","LA ",0714,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
814	localidades                                  	I	\N	(071402,PLATANILLOS,PLA,0714,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
815	localidades                                  	I	\N	(071403,"VALLE HERMOSO",VAL,0714,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
816	localidades                                  	I	\N	(071450,"LA VICTORIA","LA ",0714,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
817	localidades                                  	I	\N	(071451,"LA LIBERTAD","LA ",0714,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
818	localidades                                  	I	\N	(071452,"EL PARAÍSO","EL ",0714,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
819	localidades                                  	I	\N	(071453,"SAN ISIDRO",SAN,0714,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
820	localidades                                  	I	\N	(080101,"BARTOLOMÉ RUIZ (CÉSAR FRANCO CARRIÓN)",BAR,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
821	localidades                                  	I	\N	(080102,"5 DE AGOSTO","5 D",0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
822	localidades                                  	I	\N	(080103,ESMERALDAS,ESM,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
823	localidades                                  	I	\N	(080104,"LUIS TELLO (LAS PALMAS)",LUI,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
824	localidades                                  	I	\N	(080105,"SIMÓN PLATA TORRES",SIM,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
825	localidades                                  	I	\N	(080150,ESMERALDAS,ESM,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
826	localidades                                  	I	\N	(080151,ATACAMES,ATA,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
827	localidades                                  	I	\N	(080152,"CAMARONES (CAB. EN SAN VICENTE)",CAM,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
828	localidades                                  	I	\N	(080153,"CRNEL. CARLOS CONCHA TORRES (CAB.EN HUELE)",CRN,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
829	localidades                                  	I	\N	(080154,CHINCA,CHI,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
830	localidades                                  	I	\N	(080155,CHONTADURO,CHO,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
831	localidades                                  	I	\N	(080156,CHUMUNDÉ,CHU,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
832	localidades                                  	I	\N	(080157,LAGARTO,LAG,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
833	localidades                                  	I	\N	(080158,"LA UNIÓN","LA ",0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
834	localidades                                  	I	\N	(080159,MAJUA,MAJ,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
835	localidades                                  	I	\N	(080160,"MONTALVO (CAB. EN HORQUETA)",MON,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
836	localidades                                  	I	\N	(080161,"RÍO VERDE",RÍO,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
837	localidades                                  	I	\N	(080162,ROCAFUERTE,ROC,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
838	localidades                                  	I	\N	(080163,"SAN MATEO",SAN,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
839	localidades                                  	I	\N	(080164,"SÚA (CAB. EN LA BOCANA)",SÚA,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
840	localidades                                  	I	\N	(080165,TABIAZO,TAB,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
841	localidades                                  	I	\N	(080166,TACHINA,TAC,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
842	localidades                                  	I	\N	(080167,TONCHIGÜE,TON,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
843	localidades                                  	I	\N	(080168,"VUELTA LARGA",VUE,0801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
844	localidades                                  	I	\N	(080250,"VALDEZ (LIMONES)",VAL,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
845	localidades                                  	I	\N	(080251,ANCHAYACU,ANC,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
846	localidades                                  	I	\N	(080252,"ATAHUALPA (CAB. EN CAMARONES)",ATA,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
847	localidades                                  	I	\N	(080253,BORBÓN,BOR,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
848	localidades                                  	I	\N	(080254,"LA TOLA","LA ",0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
849	localidades                                  	I	\N	(080255,"LUIS VARGAS TORRES (CAB. EN PLAYA DE ORO)",LUI,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
850	localidades                                  	I	\N	(080256,MALDONADO,MAL,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
851	localidades                                  	I	\N	(080257,"PAMPANAL DE BOLÍVAR",PAM,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
852	localidades                                  	I	\N	(080258,"SAN FRANCISCO DE ONZOLE",SAN,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
853	localidades                                  	I	\N	(080259,"SANTO DOMINGO DE ONZOLE",SAN,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
854	localidades                                  	I	\N	(080260,"SELVA ALEGRE",SEL,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
855	localidades                                  	I	\N	(080261,TELEMBÍ,TEL,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
856	localidades                                  	I	\N	(080262,"COLÓN ELOY DEL MARÍA",COL,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
857	localidades                                  	I	\N	(080263,"SAN JOSÉ DE CAYAPAS",SAN,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
858	localidades                                  	I	\N	(080264,TIMBIRÉ,TIM,0802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
859	localidades                                  	I	\N	(080350,MUISNE,MUI,0803,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
860	localidades                                  	I	\N	(080351,BOLÍVAR,BOL,0803,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
861	localidades                                  	I	\N	(080352,DAULE,DAU,0803,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
862	localidades                                  	I	\N	(080353,GALERA,GAL,0803,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
863	localidades                                  	I	\N	(080354,"QUINGUE (OLMEDO PERDOMO FRANCO)",QUI,0803,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
864	localidades                                  	I	\N	(080355,SALIMA,SAL,0803,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
865	localidades                                  	I	\N	(080356,"SAN FRANCISCO",SAN,0803,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
866	localidades                                  	I	\N	(080357,"SAN GREGORIO",SAN,0803,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
867	localidades                                  	I	\N	(080358,"SAN JOSÉ DE CHAMANGA (CAB.EN CHAMANGA)",SAN,0803,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
868	localidades                                  	I	\N	(080450,"ROSA ZÁRATE (QUININDÉ)",ROS,0804,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
869	localidades                                  	I	\N	(080451,CUBE,CUB,0804,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
870	localidades                                  	I	\N	(080452,"CHURA (CHANCAMA) (CAB. EN EL YERBERO)",CHU,0804,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
871	localidades                                  	I	\N	(080453,MALIMPIA,MAL,0804,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
872	localidades                                  	I	\N	(080454,VICHE,VIC,0804,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
873	localidades                                  	I	\N	(080455,"LA UNIÓN","LA ",0804,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
874	localidades                                  	I	\N	(080550,"SAN LORENZO",SAN,0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
875	localidades                                  	I	\N	(080551,"ALTO TAMBO (CAB. EN GUADUAL)",ALT,0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
876	localidades                                  	I	\N	(080552,"ANCÓN (PICHANGAL) (CAB. EN PALMA REAL)",ANC,0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
877	localidades                                  	I	\N	(080553,CALDERÓN,CAL,0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
878	localidades                                  	I	\N	(080554,CARONDELET,CAR,0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
879	localidades                                  	I	\N	(080555,"5 DE JUNIO (CAB. EN UIMBI)","5 D",0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
880	localidades                                  	I	\N	(080556,CONCEPCIÓN,CON,0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
881	localidades                                  	I	\N	(080557,"MATAJE (CAB. EN SANTANDER)",MAT,0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
882	localidades                                  	I	\N	(080558,"SAN JAVIER DE CACHAVÍ (CAB. EN SAN JAVIER)",SAN,0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
883	localidades                                  	I	\N	(080559,"SANTA RITA",SAN,0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
884	localidades                                  	I	\N	(080560,TAMBILLO,TAM,0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
885	localidades                                  	I	\N	(080561,"TULULBÍ (CAB. EN RICAURTE)",TUL,0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
886	localidades                                  	I	\N	(080562,URBINA,URB,0805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
887	localidades                                  	I	\N	(080650,ATACAMES,ATA,0806,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
888	localidades                                  	I	\N	(080651,"LA UNIÓN","LA ",0806,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
889	localidades                                  	I	\N	(080652,"SÚA (CAB. EN LA BOCANA)",SÚA,0806,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
890	localidades                                  	I	\N	(080653,TONCHIGÜE,TON,0806,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
892	localidades                                  	I	\N	(080750,RIOVERDE,RIO,0807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
893	localidades                                  	I	\N	(080751,CHONTADURO,CHO,0807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
894	localidades                                  	I	\N	(080752,CHUMUNDÉ,CHU,0807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
895	localidades                                  	I	\N	(080753,LAGARTO,LAG,0807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
896	localidades                                  	I	\N	(080754,"MONTALVO (CAB. EN HORQUETA)",MON,0807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
897	localidades                                  	I	\N	(080755,ROCAFUERTE,ROC,0807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
898	localidades                                  	I	\N	(080850,"LA CONCORDIA","LA ",0808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
899	localidades                                  	I	\N	(080851,MONTERREY,MON,0808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
900	localidades                                  	I	\N	(080852,"LA VILLEGAS","LA ",0808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1290	localidades                                  	I	\N	(140159,TAISHA,TAI,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
901	localidades                                  	I	\N	(080853,"PLAN PILOTO",PLA,0808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
902	localidades                                  	I	\N	(090101,AYACUCHO,AYA,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
903	localidades                                  	I	\N	(090102,"BOLÍVAR (SAGRARIO)",BOL,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
904	localidades                                  	I	\N	(090103,"CARBO (CONCEPCIÓN)",CAR,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
905	localidades                                  	I	\N	(090104,"FEBRES CORDERO",FEB,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
906	localidades                                  	I	\N	(090105,"GARCÍA MORENO",GAR,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
907	localidades                                  	I	\N	(090106,LETAMENDI,LET,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
908	localidades                                  	I	\N	(090107,"NUEVE DE OCTUBRE",NUE,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
909	localidades                                  	I	\N	(090108,"OLMEDO (SAN ALEJO)",OLM,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
910	localidades                                  	I	\N	(090109,ROCA,ROC,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
911	localidades                                  	I	\N	(090110,ROCAFUERTE,ROC,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
912	localidades                                  	I	\N	(090111,SUCRE,SUC,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
913	localidades                                  	I	\N	(090112,TARQUI,TAR,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
914	localidades                                  	I	\N	(090113,URDANETA,URD,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
915	localidades                                  	I	\N	(090114,XIMENA,XIM,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
916	localidades                                  	I	\N	(090115,PASCUALES,PAS,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
917	localidades                                  	I	\N	(090150,GUAYAQUIL,GUA,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
918	localidades                                  	I	\N	(090151,CHONGÓN,CHO,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
919	localidades                                  	I	\N	(090152,"JUAN GÓMEZ RENDÓN (PROGRESO)",JUA,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
920	localidades                                  	I	\N	(090153,MORRO,MOR,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
921	localidades                                  	I	\N	(090154,PASCUALES,PAS,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
922	localidades                                  	I	\N	(090155,"PLAYAS (GRAL. VILLAMIL)",PLA,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
923	localidades                                  	I	\N	(090156,POSORJA,POS,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
924	localidades                                  	I	\N	(090157,PUNÁ,PUN,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
925	localidades                                  	I	\N	(090158,TENGUEL,TEN,0901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
926	localidades                                  	I	\N	(090250,"ALFREDO BAQUERIZO MORENO (JUJÁN)",ALF,0902,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
927	localidades                                  	I	\N	(090350,BALAO,BAL,0903,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
928	localidades                                  	I	\N	(090450,BALZAR,BAL,0904,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
929	localidades                                  	I	\N	(090550,COLIMES,COL,0905,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
930	localidades                                  	I	\N	(090551,"SAN JACINTO",SAN,0905,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
931	localidades                                  	I	\N	(090601,DAULE,DAU,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
932	localidades                                  	I	\N	(090602,"LA AURORA (SATÉLITE)","LA ",0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
933	localidades                                  	I	\N	(090603,BANIFE,BAN,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
934	localidades                                  	I	\N	(090604,"EMILIANO CAICEDO MARCOS",EMI,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
935	localidades                                  	I	\N	(090605,MAGRO,MAG,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
936	localidades                                  	I	\N	(090606,"PADRE JUAN BAUTISTA AGUIRRE",PAD,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
937	localidades                                  	I	\N	(090607,"SANTA CLARA",SAN,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
938	localidades                                  	I	\N	(090608,"VICENTE PIEDRAHITA",VIC,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
939	localidades                                  	I	\N	(090650,DAULE,DAU,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
940	localidades                                  	I	\N	(090651,"ISIDRO AYORA (SOLEDAD)",ISI,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
941	localidades                                  	I	\N	(090652,"JUAN BAUTISTA AGUIRRE (LOS TINTOS)",JUA,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
942	localidades                                  	I	\N	(090653,LAUREL,LAU,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
943	localidades                                  	I	\N	(090654,LIMONAL,LIM,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
944	localidades                                  	I	\N	(090655,"LOMAS DE SARGENTILLO",LOM,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
945	localidades                                  	I	\N	(090656,"LOS LOJAS (ENRIQUE BAQUERIZO MORENO)",LOS,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
946	localidades                                  	I	\N	(090657,"PIEDRAHITA (NOBOL)",PIE,0906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
947	localidades                                  	I	\N	(090701,"ELOY ALFARO (DURÁN)",ELO,0907,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
948	localidades                                  	I	\N	(090702,"EL RECREO","EL ",0907,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
949	localidades                                  	I	\N	(090750,"ELOY ALFARO (DURÁN)",ELO,0907,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
950	localidades                                  	I	\N	(090850,"VELASCO IBARRA (EL EMPALME)",VEL,0908,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
951	localidades                                  	I	\N	(090851,"GUAYAS (PUEBLO NUEVO)",GUA,0908,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
952	localidades                                  	I	\N	(090852,"EL ROSARIO","EL ",0908,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
953	localidades                                  	I	\N	(090950,"EL TRIUNFO","EL ",0909,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
954	localidades                                  	I	\N	(091050,MILAGRO,MIL,0910,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
955	localidades                                  	I	\N	(091051,CHOBO,CHO,0910,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
956	localidades                                  	I	\N	(091052,"GENERAL ELIZALDE (BUCAY)",GEN,0910,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
957	localidades                                  	I	\N	(091053,"MARISCAL SUCRE (HUAQUES)",MAR,0910,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
958	localidades                                  	I	\N	(091054,"ROBERTO ASTUDILLO (CAB. EN CRUCE DE VENECIA)",ROB,0910,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
959	localidades                                  	I	\N	(091150,NARANJAL,NAR,0911,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
960	localidades                                  	I	\N	(091151,"JESÚS MARÍA",JES,0911,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
961	localidades                                  	I	\N	(091152,"SAN CARLOS",SAN,0911,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
962	localidades                                  	I	\N	(091153,"SANTA ROSA DE FLANDES",SAN,0911,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
963	localidades                                  	I	\N	(091154,TAURA,TAU,0911,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
964	localidades                                  	I	\N	(091250,NARANJITO,NAR,0912,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
965	localidades                                  	I	\N	(091350,PALESTINA,PAL,0913,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
966	localidades                                  	I	\N	(091450,"PEDRO CARBO",PED,0914,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
967	localidades                                  	I	\N	(091451,"VALLE DE LA VIRGEN",VAL,0914,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
968	localidades                                  	I	\N	(091452,SABANILLA,SAB,0914,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
969	localidades                                  	I	\N	(091601,SAMBORONDÓN,SAM,0916,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
970	localidades                                  	I	\N	(091602,"LA PUNTILLA (SATÉLITE)","LA ",0916,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
971	localidades                                  	I	\N	(091650,SAMBORONDÓN,SAM,0916,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
972	localidades                                  	I	\N	(091651,TARIFA,TAR,0916,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
973	localidades                                  	I	\N	(091850,"SANTA LUCÍA",SAN,0918,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
974	localidades                                  	I	\N	(091901,BOCANA,BOC,0919,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
975	localidades                                  	I	\N	(091902,CANDILEJOS,CAN,0919,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
976	localidades                                  	I	\N	(091903,CENTRAL,CEN,0919,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
977	localidades                                  	I	\N	(091904,PARAÍSO,PAR,0919,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
978	localidades                                  	I	\N	(091905,"SAN MATEO",SAN,0919,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
979	localidades                                  	I	\N	(091950,"EL SALITRE (LAS RAMAS)","EL ",0919,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
980	localidades                                  	I	\N	(091951,"GRAL. VERNAZA (DOS ESTEROS)",GRA,0919,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
981	localidades                                  	I	\N	(091952,"LA VICTORIA (ÑAUZA)","LA ",0919,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
982	localidades                                  	I	\N	(091953,JUNQUILLAL,JUN,0919,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
983	localidades                                  	I	\N	(092050,"SAN JACINTO DE YAGUACHI",SAN,0920,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
984	localidades                                  	I	\N	(092051,"CRNEL. LORENZO DE GARAICOA (PEDREGAL)",CRN,0920,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
985	localidades                                  	I	\N	(092052,"CRNEL. MARCELINO MARIDUEÑA (SAN CARLOS)",CRN,0920,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
986	localidades                                  	I	\N	(092053,"GRAL. PEDRO J. MONTERO (BOLICHE)",GRA,0920,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
987	localidades                                  	I	\N	(092054,"SIMÓN BOLÍVAR",SIM,0920,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
988	localidades                                  	I	\N	(092055,"YAGUACHI VIEJO (CONE)",YAG,0920,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
989	localidades                                  	I	\N	(092056,"VIRGEN DE FÁTIMA",VIR,0920,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
990	localidades                                  	I	\N	(092150,"GENERAL VILLAMIL (PLAYAS)",GEN,0921,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
991	localidades                                  	I	\N	(092250,"SIMÓN BOLÍVAR",SIM,0922,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
992	localidades                                  	I	\N	(092251,"CRNEL.LORENZO DE GARAICOA (PEDREGAL)",CRN,0922,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
993	localidades                                  	I	\N	(092350,"CORONEL MARCELINO MARIDUEÑA (SAN CARLOS)",COR,0923,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
994	localidades                                  	I	\N	(092450,"LOMAS DE SARGENTILLO",LOM,0924,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
995	localidades                                  	I	\N	(092451,"ISIDRO AYORA (SOLEDAD)",ISI,0924,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
996	localidades                                  	I	\N	(092550,"NARCISA DE JESÚS",NAR,0925,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
997	localidades                                  	I	\N	(092750,"GENERAL ANTONIO ELIZALDE (BUCAY)",GEN,0927,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
998	localidades                                  	I	\N	(092850,"ISIDRO AYORA",ISI,0928,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
999	localidades                                  	I	\N	(110101,"EL SAGRARIO","EL ",1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1000	localidades                                  	I	\N	(110102,"SAN SEBASTIÁN",SAN,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1001	localidades                                  	I	\N	(110103,SUCRE,SUC,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1002	localidades                                  	I	\N	(110104,VALLE,VAL,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1003	localidades                                  	I	\N	(110150,LOJA,LOJ,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1004	localidades                                  	I	\N	(110151,CHANTACO,CHA,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1005	localidades                                  	I	\N	(110152,CHUQUIRIBAMBA,CHU,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1006	localidades                                  	I	\N	(110153,"EL CISNE","EL ",1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1007	localidades                                  	I	\N	(110154,GUALEL,GUA,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1008	localidades                                  	I	\N	(110155,JIMBILLA,JIM,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1009	localidades                                  	I	\N	(110156,"MALACATOS (VALLADOLID)",MAL,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1010	localidades                                  	I	\N	(110157,"SAN LUCAS",SAN,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1011	localidades                                  	I	\N	(110158,"SAN PEDRO DE VILCABAMBA",SAN,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1012	localidades                                  	I	\N	(110159,SANTIAGO,SAN,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1013	localidades                                  	I	\N	(110160,"TAQUIL (MIGUEL RIOFRÍO)",TAQ,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1014	localidades                                  	I	\N	(110161,"VILCABAMBA (VICTORIA)",VIL,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1015	localidades                                  	I	\N	(110162,"YANGANA (ARSENIO CASTILLO)",YAN,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1016	localidades                                  	I	\N	(110163,QUINARA,QUI,1101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1017	localidades                                  	I	\N	(110201,CARIAMANGA,CAR,1102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1018	localidades                                  	I	\N	(110202,CHILE,CHI,1102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1019	localidades                                  	I	\N	(110203,"SAN VICENTE",SAN,1102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1020	localidades                                  	I	\N	(110250,CARIAMANGA,CAR,1102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1021	localidades                                  	I	\N	(110251,COLAISACA,COL,1102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1022	localidades                                  	I	\N	(110252,"EL LUCERO","EL ",1102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1023	localidades                                  	I	\N	(110253,UTUANA,UTU,1102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1024	localidades                                  	I	\N	(110254,SANGUILLÍN,SAN,1102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1025	localidades                                  	I	\N	(110301,CATAMAYO,CAT,1103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1026	localidades                                  	I	\N	(110302,"SAN JOSÉ",SAN,1103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1027	localidades                                  	I	\N	(110350,"CATAMAYO (LA TOMA)",CAT,1103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1028	localidades                                  	I	\N	(110351,"EL TAMBO","EL ",1103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1029	localidades                                  	I	\N	(110352,GUAYQUICHUMA,GUA,1103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1030	localidades                                  	I	\N	(110353,"SAN PEDRO DE LA BENDITA",SAN,1103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1031	localidades                                  	I	\N	(110354,ZAMBI,ZAM,1103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1032	localidades                                  	I	\N	(110450,CELICA,CEL,1104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1033	localidades                                  	I	\N	(110451,"CRUZPAMBA (CAB. EN CARLOS BUSTAMANTE)",CRU,1104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1034	localidades                                  	I	\N	(110452,CHAQUINAL,CHA,1104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1035	localidades                                  	I	\N	(110453,"12 DE DICIEMBRE (CAB. EN ACHIOTES)","12 ",1104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1036	localidades                                  	I	\N	(110454,"PINDAL (FEDERICO PÁEZ)",PIN,1104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1037	localidades                                  	I	\N	(110455,"POZUL (SAN JUAN DE POZUL)",POZ,1104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1038	localidades                                  	I	\N	(110456,SABANILLA,SAB,1104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1039	localidades                                  	I	\N	(110457,"TNTE. MAXIMILIANO RODRÍGUEZ LOAIZA",TNT,1104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1040	localidades                                  	I	\N	(110550,CHAGUARPAMBA,CHA,1105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1041	localidades                                  	I	\N	(110551,BUENAVISTA,BUE,1105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1042	localidades                                  	I	\N	(110552,"EL ROSARIO","EL ",1105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1043	localidades                                  	I	\N	(110553,"SANTA RUFINA",SAN,1105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1044	localidades                                  	I	\N	(110554,AMARILLOS,AMA,1105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1045	localidades                                  	I	\N	(110650,AMALUZA,AMA,1106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1046	localidades                                  	I	\N	(110651,BELLAVISTA,BEL,1106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1047	localidades                                  	I	\N	(110652,JIMBURA,JIM,1106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1048	localidades                                  	I	\N	(110653,"SANTA TERESITA",SAN,1106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1049	localidades                                  	I	\N	(110654,"27 DE ABRIL (CAB. EN LA NARANJA)","27 ",1106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1050	localidades                                  	I	\N	(110655,"EL INGENIO","EL ",1106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1051	localidades                                  	I	\N	(110656,"EL AIRO","EL ",1106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1052	localidades                                  	I	\N	(110750,GONZANAMÁ,GON,1107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1053	localidades                                  	I	\N	(110751,"CHANGAIMINA (LA LIBERTAD)",CHA,1107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1054	localidades                                  	I	\N	(110752,FUNDOCHAMBA,FUN,1107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1055	localidades                                  	I	\N	(110753,NAMBACOLA,NAM,1107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1056	localidades                                  	I	\N	(110754,"PURUNUMA (EGUIGUREN)",PUR,1107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1057	localidades                                  	I	\N	(110755,"QUILANGA (LA PAZ)",QUI,1107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1058	localidades                                  	I	\N	(110756,SACAPALCA,SAC,1107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1059	localidades                                  	I	\N	(110757,"SAN ANTONIO DE LAS ARADAS (CAB. EN LAS ARADAS)",SAN,1107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1060	localidades                                  	I	\N	(110801,"GENERAL ELOY ALFARO (SAN SEBASTIÁN)",GEN,1108,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1061	localidades                                  	I	\N	(110802,"MACARÁ (MANUEL ENRIQUE RENGEL SUQUILANDA)",MAC,1108,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1062	localidades                                  	I	\N	(110850,MACARÁ,MAC,1108,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1063	localidades                                  	I	\N	(110851,LARAMA,LAR,1108,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1064	localidades                                  	I	\N	(110852,"LA VICTORIA","LA ",1108,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1065	localidades                                  	I	\N	(110853,"SABIANGO (LA CAPILLA)",SAB,1108,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1066	localidades                                  	I	\N	(110901,CATACOCHA,CAT,1109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1067	localidades                                  	I	\N	(110902,LOURDES,LOU,1109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1068	localidades                                  	I	\N	(110950,CATACOCHA,CAT,1109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1069	localidades                                  	I	\N	(110951,CANGONAMÁ,CAN,1109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1070	localidades                                  	I	\N	(110952,GUACHANAMÁ,GUA,1109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1071	localidades                                  	I	\N	(110953,"LA TINGUE","LA ",1109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1072	localidades                                  	I	\N	(110954,"LAURO GUERRERO",LAU,1109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1073	localidades                                  	I	\N	(110955,"OLMEDO (SANTA BÁRBARA)",OLM,1109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1074	localidades                                  	I	\N	(110956,ORIANGA,ORI,1109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1075	localidades                                  	I	\N	(110957,"SAN ANTONIO",SAN,1109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1076	localidades                                  	I	\N	(110958,CASANGA,CAS,1109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1077	localidades                                  	I	\N	(110959,YAMANA,YAM,1109,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1078	localidades                                  	I	\N	(111050,ALAMOR,ALA,1110,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1079	localidades                                  	I	\N	(111051,CIANO,CIA,1110,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1080	localidades                                  	I	\N	(111052,"EL ARENAL","EL ",1110,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1081	localidades                                  	I	\N	(111053,"EL LIMO (MARIANA DE JESÚS)","EL ",1110,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1082	localidades                                  	I	\N	(111054,MERCADILLO,MER,1110,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1083	localidades                                  	I	\N	(111055,VICENTINO,VIC,1110,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1084	localidades                                  	I	\N	(111150,SARAGURO,SAR,1111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1085	localidades                                  	I	\N	(111151,"EL PARAÍSO DE CELÉN","EL ",1111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1086	localidades                                  	I	\N	(111152,"EL TABLÓN","EL ",1111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1087	localidades                                  	I	\N	(111153,LLUZHAPA,LLU,1111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1088	localidades                                  	I	\N	(111154,MANÚ,MAN,1111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1089	localidades                                  	I	\N	(111155,"SAN ANTONIO DE QUMBE (CUMBE)",SAN,1111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1090	localidades                                  	I	\N	(111156,"SAN PABLO DE TENTA",SAN,1111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1091	localidades                                  	I	\N	(111157,"SAN SEBASTIÁN DE YÚLUC",SAN,1111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1092	localidades                                  	I	\N	(111158,"SELVA ALEGRE",SEL,1111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1093	localidades                                  	I	\N	(111159,"URDANETA (PAQUISHAPA)",URD,1111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1094	localidades                                  	I	\N	(111160,SUMAYPAMBA,SUM,1111,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1095	localidades                                  	I	\N	(111250,SOZORANGA,SOZ,1112,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1096	localidades                                  	I	\N	(111251,"NUEVA FÁTIMA",NUE,1112,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1097	localidades                                  	I	\N	(111252,TACAMOROS,TAC,1112,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1098	localidades                                  	I	\N	(111350,ZAPOTILLO,ZAP,1113,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1099	localidades                                  	I	\N	(111351,"MANGAHURCO (CAZADEROS)",MAN,1113,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1100	localidades                                  	I	\N	(111352,GARZAREAL,GAR,1113,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1101	localidades                                  	I	\N	(111353,LIMONES,LIM,1113,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1102	localidades                                  	I	\N	(111354,PALETILLAS,PAL,1113,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1103	localidades                                  	I	\N	(111355,BOLASPAMBA,BOL,1113,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1104	localidades                                  	I	\N	(111450,PINDAL,PIN,1114,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1105	localidades                                  	I	\N	(111451,CHAQUINAL,CHA,1114,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1106	localidades                                  	I	\N	(111452,"12 DE DICIEMBRE (CAB.EN ACHIOTES)","12 ",1114,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1107	localidades                                  	I	\N	(111453,MILAGROS,MIL,1114,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1108	localidades                                  	I	\N	(111550,QUILANGA,QUI,1115,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1109	localidades                                  	I	\N	(111551,FUNDOCHAMBA,FUN,1115,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1110	localidades                                  	I	\N	(111552,"SAN ANTONIO DE LAS ARADAS (CAB. EN LAS ARADAS)",SAN,1115,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1111	localidades                                  	I	\N	(111650,OLMEDO,OLM,1116,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1112	localidades                                  	I	\N	(111651,"LA TINGUE","LA ",1116,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1113	localidades                                  	I	\N	(120101,"CLEMENTE BAQUERIZO",CLE,1201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1114	localidades                                  	I	\N	(120102,"DR. CAMILO PONCE",DR.,1201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1115	localidades                                  	I	\N	(120103,BARREIRO,BAR,1201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1116	localidades                                  	I	\N	(120104,"EL SALTO","EL ",1201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1117	localidades                                  	I	\N	(120150,BABAHOYO,BAB,1201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1118	localidades                                  	I	\N	(120151,"BARREIRO (SANTA RITA)",BAR,1201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1119	localidades                                  	I	\N	(120152,CARACOL,CAR,1201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1120	localidades                                  	I	\N	(120153,"FEBRES CORDERO (LAS JUNTAS)",FEB,1201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1121	localidades                                  	I	\N	(120154,PIMOCHA,PIM,1201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1122	localidades                                  	I	\N	(120155,"LA UNIÓN","LA ",1201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1123	localidades                                  	I	\N	(120250,BABA,BAB,1202,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1124	localidades                                  	I	\N	(120251,GUARE,GUA,1202,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1125	localidades                                  	I	\N	(120252,"ISLA DE BEJUCAL",ISL,1202,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1126	localidades                                  	I	\N	(120350,MONTALVO,MON,1203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1127	localidades                                  	I	\N	(120450,PUEBLOVIEJO,PUE,1204,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1128	localidades                                  	I	\N	(120451,"PUERTO PECHICHE",PUE,1204,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1129	localidades                                  	I	\N	(120452,"SAN JUAN",SAN,1204,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1130	localidades                                  	I	\N	(120501,QUEVEDO,QUE,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1131	localidades                                  	I	\N	(120502,"SAN CAMILO",SAN,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1132	localidades                                  	I	\N	(120503,"SAN JOSÉ",SAN,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1133	localidades                                  	I	\N	(120504,GUAYACÁN,GUA,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1134	localidades                                  	I	\N	(120505,"NICOLÁS INFANTE DÍAZ",NIC,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1135	localidades                                  	I	\N	(120506,"SAN CRISTÓBAL",SAN,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1136	localidades                                  	I	\N	(120507,"SIETE DE OCTUBRE",SIE,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1137	localidades                                  	I	\N	(120508,"24 DE MAYO","24 ",1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1138	localidades                                  	I	\N	(120509,"VENUS DEL RÍO QUEVEDO",VEN,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1139	localidades                                  	I	\N	(120510,"VIVA ALFARO",VIV,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1140	localidades                                  	I	\N	(120550,QUEVEDO,QUE,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1141	localidades                                  	I	\N	(120551,"BUENA FÉ",BUE,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1142	localidades                                  	I	\N	(120552,MOCACHE,MOC,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1143	localidades                                  	I	\N	(120553,"SAN CARLOS",SAN,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1144	localidades                                  	I	\N	(120554,VALENCIA,VAL,1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1145	localidades                                  	I	\N	(120555,"LA ESPERANZA","LA ",1205,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1146	localidades                                  	I	\N	(120650,CATARAMA,CAT,1206,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1147	localidades                                  	I	\N	(120651,RICAURTE,RIC,1206,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1148	localidades                                  	I	\N	(120701,"10 DE NOVIEMBRE","10 ",1207,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1149	localidades                                  	I	\N	(120750,VENTANAS,VEN,1207,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1150	localidades                                  	I	\N	(120751,QUINSALOMA,QUI,1207,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1151	localidades                                  	I	\N	(120752,ZAPOTAL,ZAP,1207,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1152	localidades                                  	I	\N	(120753,CHACARITA,CHA,1207,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1153	localidades                                  	I	\N	(120754,"LOS ÁNGELES",LOS,1207,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1154	localidades                                  	I	\N	(120850,VINCES,VIN,1208,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1155	localidades                                  	I	\N	(120851,"ANTONIO SOTOMAYOR (CAB. EN PLAYAS DE VINCES)",ANT,1208,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1156	localidades                                  	I	\N	(120852,PALENQUE,PAL,1208,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1157	localidades                                  	I	\N	(120950,PALENQUE,PAL,1209,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1158	localidades                                  	I	\N	(121001,"SAN JACINTO DE BUENA FÉ",SAN,1210,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1159	localidades                                  	I	\N	(121002,"7 DE AGOSTO","7 D",1210,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1160	localidades                                  	I	\N	(121003,"11 DE OCTUBRE","11 ",1210,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1161	localidades                                  	I	\N	(121050,"SAN JACINTO DE BUENA FÉ",SAN,1210,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1162	localidades                                  	I	\N	(121051,"PATRICIA PILAR",PAT,1210,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1163	localidades                                  	I	\N	(121150,VALENCIA,VAL,1211,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1164	localidades                                  	I	\N	(121250,MOCACHE,MOC,1212,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1165	localidades                                  	I	\N	(121350,QUINSALOMA,QUI,1213,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1166	localidades                                  	I	\N	(130101,PORTOVIEJO,POR,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1167	localidades                                  	I	\N	(130102,"12 DE MARZO","12 ",1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1168	localidades                                  	I	\N	(130103,COLÓN,COL,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1169	localidades                                  	I	\N	(130104,PICOAZÁ,PIC,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1170	localidades                                  	I	\N	(130105,"SAN PABLO",SAN,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1171	localidades                                  	I	\N	(130106,"ANDRÉS DE VERA",AND,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1172	localidades                                  	I	\N	(130107,"FRANCISCO PACHECO",FRA,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1173	localidades                                  	I	\N	(130108,"18 DE OCTUBRE","18 ",1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1174	localidades                                  	I	\N	(130109,"SIMÓN BOLÍVAR",SIM,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1175	localidades                                  	I	\N	(130150,PORTOVIEJO,POR,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1176	localidades                                  	I	\N	(130151,"ABDÓN CALDERÓN (SAN FRANCISCO)",ABD,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1177	localidades                                  	I	\N	(130152,"ALHAJUELA (BAJO GRANDE)",ALH,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1178	localidades                                  	I	\N	(130153,CRUCITA,CRU,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1179	localidades                                  	I	\N	(130154,"PUEBLO NUEVO",PUE,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1180	localidades                                  	I	\N	(130155,"RIOCHICO (RÍO CHICO)",RIO,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1181	localidades                                  	I	\N	(130156,"SAN PLÁCIDO",SAN,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1182	localidades                                  	I	\N	(130157,CHIRIJOS,CHI,1301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1183	localidades                                  	I	\N	(130250,CALCETA,CAL,1302,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1184	localidades                                  	I	\N	(130251,MEMBRILLO,MEM,1302,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1185	localidades                                  	I	\N	(130252,QUIROGA,QUI,1302,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1186	localidades                                  	I	\N	(130301,CHONE,CHO,1303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1187	localidades                                  	I	\N	(130302,"SANTA RITA",SAN,1303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1188	localidades                                  	I	\N	(130350,CHONE,CHO,1303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1189	localidades                                  	I	\N	(130351,BOYACÁ,BOY,1303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1190	localidades                                  	I	\N	(130352,CANUTO,CAN,1303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1191	localidades                                  	I	\N	(130353,CONVENTO,CON,1303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1192	localidades                                  	I	\N	(130354,CHIBUNGA,CHI,1303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1193	localidades                                  	I	\N	(130355,"ELOY ALFARO",ELO,1303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1194	localidades                                  	I	\N	(130356,RICAURTE,RIC,1303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1195	localidades                                  	I	\N	(130357,"SAN ANTONIO",SAN,1303,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1196	localidades                                  	I	\N	(130401,"EL CARMEN","EL ",1304,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1197	localidades                                  	I	\N	(130402,"4 DE DICIEMBRE","4 D",1304,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1198	localidades                                  	I	\N	(130450,"EL CARMEN","EL ",1304,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1199	localidades                                  	I	\N	(130451,"WILFRIDO LOOR MOREIRA (MAICITO)",WIL,1304,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1200	localidades                                  	I	\N	(130452,"SAN PEDRO DE SUMA",SAN,1304,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1201	localidades                                  	I	\N	(130550,"FLAVIO ALFARO",FLA,1305,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1202	localidades                                  	I	\N	(130551,"SAN FRANCISCO DE NOVILLO (CAB. EN",SAN,1305,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1203	localidades                                  	I	\N	(130552,ZAPALLO,ZAP,1305,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1204	localidades                                  	I	\N	(130601,"DR. MIGUEL MORÁN LUCIO",DR.,1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1205	localidades                                  	I	\N	(130602,"MANUEL INOCENCIO PARRALES Y GUALE",MAN,1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1206	localidades                                  	I	\N	(130603,"SAN LORENZO DE JIPIJAPA",SAN,1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1207	localidades                                  	I	\N	(130650,JIPIJAPA,JIP,1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1208	localidades                                  	I	\N	(130651,AMÉRICA,AMÉ,1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1209	localidades                                  	I	\N	(130652,"EL ANEGADO (CAB. EN ELOY ALFARO)","EL ",1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1210	localidades                                  	I	\N	(130653,JULCUY,JUL,1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1211	localidades                                  	I	\N	(130654,"LA UNIÓN","LA ",1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1212	localidades                                  	I	\N	(130655,MACHALILLA,MAC,1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1213	localidades                                  	I	\N	(130656,MEMBRILLAL,MEM,1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1214	localidades                                  	I	\N	(130657,"PEDRO PABLO GÓMEZ",PED,1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1215	localidades                                  	I	\N	(130658,"PUERTO DE CAYO",PUE,1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1216	localidades                                  	I	\N	(130659,"PUERTO LÓPEZ",PUE,1306,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1217	localidades                                  	I	\N	(130750,JUNÍN,JUN,1307,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1218	localidades                                  	I	\N	(130801,"LOS ESTEROS",LOS,1308,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1219	localidades                                  	I	\N	(130802,MANTA,MAN,1308,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1220	localidades                                  	I	\N	(130803,"SAN MATEO",SAN,1308,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1221	localidades                                  	I	\N	(130804,TARQUI,TAR,1308,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1222	localidades                                  	I	\N	(130805,"ELOY ALFARO",ELO,1308,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1223	localidades                                  	I	\N	(130850,MANTA,MAN,1308,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1224	localidades                                  	I	\N	(130851,"SAN LORENZO",SAN,1308,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1225	localidades                                  	I	\N	(130852,"SANTA MARIANITA (BOCA DE PACOCHE)",SAN,1308,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1226	localidades                                  	I	\N	(130901,"ANIBAL SAN ANDRÉS",ANI,1309,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1227	localidades                                  	I	\N	(130902,MONTECRISTI,MON,1309,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1228	localidades                                  	I	\N	(130903,"EL COLORADO","EL ",1309,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1229	localidades                                  	I	\N	(130904,"GENERAL ELOY ALFARO",GEN,1309,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1230	localidades                                  	I	\N	(130905,"LEONIDAS PROAÑO",LEO,1309,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1231	localidades                                  	I	\N	(130950,MONTECRISTI,MON,1309,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1232	localidades                                  	I	\N	(130951,JARAMIJÓ,JAR,1309,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1233	localidades                                  	I	\N	(130952,"LA PILA","LA ",1309,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1234	localidades                                  	I	\N	(131050,PAJÁN,PAJ,1310,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1235	localidades                                  	I	\N	(131051,"CAMPOZANO (LA PALMA DE PAJÁN)",CAM,1310,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1236	localidades                                  	I	\N	(131052,CASCOL,CAS,1310,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1237	localidades                                  	I	\N	(131053,GUALE,GUA,1310,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1238	localidades                                  	I	\N	(131054,LASCANO,LAS,1310,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1239	localidades                                  	I	\N	(131150,PICHINCHA,PIC,1311,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1240	localidades                                  	I	\N	(131151,BARRAGANETE,BAR,1311,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1241	localidades                                  	I	\N	(131152,"SAN SEBASTIÁN",SAN,1311,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1242	localidades                                  	I	\N	(131250,ROCAFUERTE,ROC,1312,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1243	localidades                                  	I	\N	(131301,"SANTA ANA",SAN,1313,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1244	localidades                                  	I	\N	(131302,LODANA,LOD,1313,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1245	localidades                                  	I	\N	(131350,"SANTA ANA DE VUELTA LARGA",SAN,1313,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1246	localidades                                  	I	\N	(131351,AYACUCHO,AYA,1313,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1247	localidades                                  	I	\N	(131352,"HONORATO VÁSQUEZ (CAB. EN VÁSQUEZ)",HON,1313,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1248	localidades                                  	I	\N	(131353,"LA UNIÓN","LA ",1313,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1249	localidades                                  	I	\N	(131354,OLMEDO,OLM,1313,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1250	localidades                                  	I	\N	(131355,"SAN PABLO (CAB. EN PUEBLO NUEVO)",SAN,1313,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1251	localidades                                  	I	\N	(131401,"BAHÍA DE CARÁQUEZ",BAH,1314,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1252	localidades                                  	I	\N	(131402,"LEONIDAS PLAZA GUTIÉRREZ",LEO,1314,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1253	localidades                                  	I	\N	(131450,"BAHÍA DE CARÁQUEZ",BAH,1314,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1254	localidades                                  	I	\N	(131451,CANOA,CAN,1314,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1255	localidades                                  	I	\N	(131452,COJIMÍES,COJ,1314,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1256	localidades                                  	I	\N	(131453,CHARAPOTÓ,CHA,1314,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1257	localidades                                  	I	\N	(131454,"10 DE AGOSTO","10 ",1314,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1258	localidades                                  	I	\N	(131455,JAMA,JAM,1314,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1259	localidades                                  	I	\N	(131456,PEDERNALES,PED,1314,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1260	localidades                                  	I	\N	(131457,"SAN ISIDRO",SAN,1314,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1261	localidades                                  	I	\N	(131458,"SAN VICENTE",SAN,1314,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1262	localidades                                  	I	\N	(131550,TOSAGUA,TOS,1315,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1263	localidades                                  	I	\N	(131551,BACHILLERO,BAC,1315,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1264	localidades                                  	I	\N	(131552,"ANGEL PEDRO GILER (LA ESTANCILLA)",ANG,1315,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1265	localidades                                  	I	\N	(131650,SUCRE,SUC,1316,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1266	localidades                                  	I	\N	(131651,BELLAVISTA,BEL,1316,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1267	localidades                                  	I	\N	(131652,NOBOA,NOB,1316,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1268	localidades                                  	I	\N	(131653,"ARQ. SIXTO DURÁN BALLÉN",ARQ,1316,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1269	localidades                                  	I	\N	(131750,PEDERNALES,PED,1317,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1270	localidades                                  	I	\N	(131751,COJIMÍES,COJ,1317,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1271	localidades                                  	I	\N	(131752,"10 DE AGOSTO","10 ",1317,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1272	localidades                                  	I	\N	(131753,ATAHUALPA,ATA,1317,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1273	localidades                                  	I	\N	(131850,OLMEDO,OLM,1318,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1274	localidades                                  	I	\N	(131950,"PUERTO LÓPEZ",PUE,1319,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1275	localidades                                  	I	\N	(131951,MACHALILLA,MAC,1319,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1276	localidades                                  	I	\N	(131952,SALANGO,SAL,1319,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1277	localidades                                  	I	\N	(132050,JAMA,JAM,1320,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1278	localidades                                  	I	\N	(132150,JARAMIJÓ,JAR,1321,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1279	localidades                                  	I	\N	(132250,"SAN VICENTE",SAN,1322,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1280	localidades                                  	I	\N	(132251,CANOA,CAN,1322,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1281	localidades                                  	I	\N	(140150,MACAS,MAC,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1282	localidades                                  	I	\N	(140151,"ALSHI (CAB. EN 9 DE OCTUBRE)",ALS,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1283	localidades                                  	I	\N	(140152,CHIGUAZA,CHI,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1284	localidades                                  	I	\N	(140153,"GENERAL PROAÑO",GEN,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1285	localidades                                  	I	\N	(140154,"HUASAGA (CAB.EN WAMPUIK)",HUA,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1286	localidades                                  	I	\N	(140155,MACUMA,MAC,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1287	localidades                                  	I	\N	(140156,"SAN ISIDRO",SAN,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1288	localidades                                  	I	\N	(140157,"SEVILLA DON BOSCO",SEV,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1289	localidades                                  	I	\N	(140158,SINAÍ,SIN,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1291	localidades                                  	I	\N	(140160,"ZUÑA (ZÚÑAC)",ZUÑ,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1292	localidades                                  	I	\N	(140161,TUUTINENTZA,TUU,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1293	localidades                                  	I	\N	(140162,CUCHAENTZA,CUC,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1294	localidades                                  	I	\N	(140163,"SAN JOSÉ DE MORONA",SAN,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1295	localidades                                  	I	\N	(140164,"RÍO BLANCO",RÍO,1401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1296	localidades                                  	I	\N	(140201,GUALAQUIZA,GUA,1402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1297	localidades                                  	I	\N	(140202,"MERCEDES MOLINA",MER,1402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1298	localidades                                  	I	\N	(140250,GUALAQUIZA,GUA,1402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1299	localidades                                  	I	\N	(140251,"AMAZONAS (ROSARIO DE CUYES)",AMA,1402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1300	localidades                                  	I	\N	(140252,BERMEJOS,BER,1402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1301	localidades                                  	I	\N	(140253,BOMBOIZA,BOM,1402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1302	localidades                                  	I	\N	(140254,CHIGÜINDA,CHI,1402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1303	localidades                                  	I	\N	(140255,"EL ROSARIO","EL ",1402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1304	localidades                                  	I	\N	(140256,"NUEVA TARQUI",NUE,1402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1305	localidades                                  	I	\N	(140257,"SAN MIGUEL DE CUYES",SAN,1402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1306	localidades                                  	I	\N	(140258,"EL IDEAL","EL ",1402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1307	localidades                                  	I	\N	(140350,"GENERAL LEONIDAS PLAZA GUTIÉRREZ (LIMÓN)",GEN,1403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1308	localidades                                  	I	\N	(140351,INDANZA,IND,1403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1309	localidades                                  	I	\N	(140352,"PAN DE AZÚCAR",PAN,1403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1310	localidades                                  	I	\N	(140353,"SAN ANTONIO (CAB. EN SAN ANTONIO CENTRO",SAN,1403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1311	localidades                                  	I	\N	(140354,"SAN CARLOS DE LIMÓN (SAN CARLOS DEL",SAN,1403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1312	localidades                                  	I	\N	(140355,"SAN JUAN BOSCO",SAN,1403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1313	localidades                                  	I	\N	(140356,"SAN MIGUEL DE CONCHAY",SAN,1403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1314	localidades                                  	I	\N	(140357,"SANTA SUSANA DE CHIVIAZA (CAB. EN CHIVIAZA)",SAN,1403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1315	localidades                                  	I	\N	(140358,"YUNGANZA (CAB. EN EL ROSARIO)",YUN,1403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1316	localidades                                  	I	\N	(140450,"PALORA (METZERA)",PAL,1404,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1317	localidades                                  	I	\N	(140451,ARAPICOS,ARA,1404,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1318	localidades                                  	I	\N	(140452,"CUMANDÁ (CAB. EN COLONIA AGRÍCOLA SEVILLA DEL ORO)",CUM,1404,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1319	localidades                                  	I	\N	(140453,HUAMBOYA,HUA,1404,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1320	localidades                                  	I	\N	(140454,"SANGAY (CAB. EN NAYAMANACA)",SAN,1404,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1321	localidades                                  	I	\N	(140550,"SANTIAGO DE MÉNDEZ",SAN,1405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1322	localidades                                  	I	\N	(140551,COPAL,COP,1405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1323	localidades                                  	I	\N	(140552,CHUPIANZA,CHU,1405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1324	localidades                                  	I	\N	(140553,PATUCA,PAT,1405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1325	localidades                                  	I	\N	(140554,"SAN LUIS DE EL ACHO (CAB. EN EL ACHO)",SAN,1405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1326	localidades                                  	I	\N	(140555,SANTIAGO,SAN,1405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1327	localidades                                  	I	\N	(140556,TAYUZA,TAY,1405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1328	localidades                                  	I	\N	(140557,"SAN FRANCISCO DE CHINIMBIMI",SAN,1405,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1329	localidades                                  	I	\N	(140650,SUCÚA,SUC,1406,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1330	localidades                                  	I	\N	(140651,ASUNCIÓN,ASU,1406,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1331	localidades                                  	I	\N	(140652,HUAMBI,HUA,1406,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1332	localidades                                  	I	\N	(140653,LOGROÑO,LOG,1406,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1333	localidades                                  	I	\N	(140654,YAUPI,YAU,1406,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1334	localidades                                  	I	\N	(140655,"SANTA MARIANITA DE JESÚS",SAN,1406,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1335	localidades                                  	I	\N	(140750,HUAMBOYA,HUA,1407,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1336	localidades                                  	I	\N	(140751,CHIGUAZA,CHI,1407,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1337	localidades                                  	I	\N	(140752,"PABLO SEXTO",PAB,1407,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1338	localidades                                  	I	\N	(140850,"SAN JUAN BOSCO",SAN,1408,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1339	localidades                                  	I	\N	(140851,"PAN DE AZÚCAR",PAN,1408,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1340	localidades                                  	I	\N	(140852,"SAN CARLOS DE LIMÓN",SAN,1408,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1341	localidades                                  	I	\N	(140853,"SAN JACINTO DE WAKAMBEIS",SAN,1408,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1342	localidades                                  	I	\N	(140854,"SANTIAGO DE PANANZA",SAN,1408,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1343	localidades                                  	I	\N	(140950,TAISHA,TAI,1409,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1344	localidades                                  	I	\N	(140951,"HUASAGA (CAB. EN WAMPUIK)",HUA,1409,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1345	localidades                                  	I	\N	(140952,MACUMA,MAC,1409,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1346	localidades                                  	I	\N	(140953,TUUTINENTZA,TUU,1409,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1347	localidades                                  	I	\N	(140954,PUMPUENTSA,PUM,1409,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1348	localidades                                  	I	\N	(141050,LOGROÑO,LOG,1410,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1349	localidades                                  	I	\N	(141051,YAUPI,YAU,1410,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1350	localidades                                  	I	\N	(141052,SHIMPIS,SHI,1410,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1351	localidades                                  	I	\N	(141150,"PABLO SEXTO",PAB,1411,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1352	localidades                                  	I	\N	(141250,SANTIAGO,SAN,1412,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1353	localidades                                  	I	\N	(141251,"SAN JOSÉ DE MORONA",SAN,1412,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1354	localidades                                  	I	\N	(150150,TENA,TEN,1501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1355	localidades                                  	I	\N	(150151,AHUANO,AHU,1501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1356	localidades                                  	I	\N	(150152,"CARLOS JULIO AROSEMENA TOLA (ZATZA-YACU)",CAR,1501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1357	localidades                                  	I	\N	(150153,CHONTAPUNTA,CHO,1501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1358	localidades                                  	I	\N	(150154,PANO,PAN,1501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1359	localidades                                  	I	\N	(150155,"PUERTO MISAHUALLI",PUE,1501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1360	localidades                                  	I	\N	(150156,"PUERTO NAPO",PUE,1501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1361	localidades                                  	I	\N	(150157,TÁLAG,TÁL,1501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1362	localidades                                  	I	\N	(150158,"SAN JUAN DE MUYUNA",SAN,1501,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1363	localidades                                  	I	\N	(150350,ARCHIDONA,ARC,1503,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1364	localidades                                  	I	\N	(150351,AVILA,AVI,1503,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1365	localidades                                  	I	\N	(150352,COTUNDO,COT,1503,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1366	localidades                                  	I	\N	(150353,LORETO,LOR,1503,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1367	localidades                                  	I	\N	(150354,"SAN PABLO DE USHPAYACU",SAN,1503,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1368	localidades                                  	I	\N	(150355,"PUERTO MURIALDO",PUE,1503,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1369	localidades                                  	I	\N	(150450,"EL CHACO","EL ",1504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1370	localidades                                  	I	\N	(150451,"GONZALO DíAZ DE PINEDA (EL BOMBÓN)",GON,1504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1371	localidades                                  	I	\N	(150452,LINARES,LIN,1504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1372	localidades                                  	I	\N	(150453,OYACACHI,OYA,1504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1373	localidades                                  	I	\N	(150454,"SANTA ROSA",SAN,1504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1374	localidades                                  	I	\N	(150455,SARDINAS,SAR,1504,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1375	localidades                                  	I	\N	(150750,BAEZA,BAE,1507,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1376	localidades                                  	I	\N	(150751,COSANGA,COS,1507,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1377	localidades                                  	I	\N	(150752,CUYUJA,CUY,1507,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1378	localidades                                  	I	\N	(150753,PAPALLACTA,PAP,1507,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1379	localidades                                  	I	\N	(150754,"SAN FRANCISCO DE BORJA (VIRGILIO DÁVILA)",SAN,1507,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1380	localidades                                  	I	\N	(150755,"SAN JOSÉ DEL PAYAMINO",SAN,1507,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1381	localidades                                  	I	\N	(150756,SUMACO,SUM,1507,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1382	localidades                                  	I	\N	(150950,"CARLOS JULIO AROSEMENA TOLA",CAR,1509,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1383	localidades                                  	I	\N	(160150,PUYO,PUY,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1384	localidades                                  	I	\N	(160151,ARAJUNO,ARA,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1385	localidades                                  	I	\N	(160152,CANELOS,CAN,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1386	localidades                                  	I	\N	(160153,CURARAY,CUR,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1387	localidades                                  	I	\N	(160154,"DIEZ DE AGOSTO",DIE,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1388	localidades                                  	I	\N	(160155,FÁTIMA,FÁT,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1389	localidades                                  	I	\N	(160156,"MONTALVO (ANDOAS)",MON,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1390	localidades                                  	I	\N	(160157,POMONA,POM,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1391	localidades                                  	I	\N	(160158,"RÍO CORRIENTES",RÍO,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1392	localidades                                  	I	\N	(160159,"RÍO TIGRE",RÍO,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1393	localidades                                  	I	\N	(160160,"SANTA CLARA",SAN,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1394	localidades                                  	I	\N	(160161,SARAYACU,SAR,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1395	localidades                                  	I	\N	(160162,"SIMÓN BOLÍVAR (CAB. EN MUSHULLACTA)",SIM,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1396	localidades                                  	I	\N	(160163,TARQUI,TAR,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1397	localidades                                  	I	\N	(160164,"TENIENTE HUGO ORTIZ",TEN,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1398	localidades                                  	I	\N	(160165,"VERACRUZ (INDILLAMA) (CAB. EN INDILLAMA)",VER,1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1399	localidades                                  	I	\N	(160166,"EL TRIUNFO","EL ",1601,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1400	localidades                                  	I	\N	(160250,MERA,MER,1602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1401	localidades                                  	I	\N	(160251,"MADRE TIERRA",MAD,1602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1402	localidades                                  	I	\N	(160252,SHELL,SHE,1602,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1403	localidades                                  	I	\N	(160350,"SANTA CLARA",SAN,1603,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1404	localidades                                  	I	\N	(160351,"SAN JOSÉ",SAN,1603,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1405	localidades                                  	I	\N	(160450,ARAJUNO,ARA,1604,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1406	localidades                                  	I	\N	(160451,CURARAY,CUR,1604,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1407	localidades                                  	I	\N	(170101,"BELISARIO QUEVEDO",BEL,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1408	localidades                                  	I	\N	(170102,CARCELÉN,CAR,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1409	localidades                                  	I	\N	(170103,"CENTRO HISTÓRICO",CEN,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1410	localidades                                  	I	\N	(170104,COCHAPAMBA,COC,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1411	localidades                                  	I	\N	(170105,"COMITÉ DEL PUEBLO",COM,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1412	localidades                                  	I	\N	(170106,COTOCOLLAO,COT,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1413	localidades                                  	I	\N	(170107,CHILIBULO,CHI,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1414	localidades                                  	I	\N	(170108,CHILLOGALLO,CHI,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1415	localidades                                  	I	\N	(170109,CHIMBACALLE,CHI,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1416	localidades                                  	I	\N	(170110,"EL CONDADO","EL ",1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1417	localidades                                  	I	\N	(170111,GUAMANÍ,GUA,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1418	localidades                                  	I	\N	(170112,IÑAQUITO,IÑA,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1419	localidades                                  	I	\N	(170113,ITCHIMBÍA,ITC,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1420	localidades                                  	I	\N	(170114,JIPIJAPA,JIP,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1421	localidades                                  	I	\N	(170115,KENNEDY,KEN,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1422	localidades                                  	I	\N	(170116,"LA ARGELIA","LA ",1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1423	localidades                                  	I	\N	(170117,"LA CONCEPCIÓN","LA ",1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1424	localidades                                  	I	\N	(170118,"LA ECUATORIANA","LA ",1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1425	localidades                                  	I	\N	(170119,"LA FERROVIARIA","LA ",1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1426	localidades                                  	I	\N	(170120,"LA LIBERTAD","LA ",1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1427	localidades                                  	I	\N	(170121,"LA MAGDALENA","LA ",1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1428	localidades                                  	I	\N	(170122,"LA MENA","LA ",1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1429	localidades                                  	I	\N	(170123,"MARISCAL SUCRE",MAR,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1430	localidades                                  	I	\N	(170124,PONCEANO,PON,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1431	localidades                                  	I	\N	(170125,PUENGASÍ,PUE,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1432	localidades                                  	I	\N	(170126,QUITUMBE,QUI,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1433	localidades                                  	I	\N	(170127,RUMIPAMBA,RUM,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1434	localidades                                  	I	\N	(170128,"SAN BARTOLO",SAN,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1435	localidades                                  	I	\N	(170129,"SAN ISIDRO DEL INCA",SAN,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1436	localidades                                  	I	\N	(170130,"SAN JUAN",SAN,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1437	localidades                                  	I	\N	(170131,SOLANDA,SOL,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1438	localidades                                  	I	\N	(170132,TURUBAMBA,TUR,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1439	localidades                                  	I	\N	(170150,"QUITO DISTRITO METROPOLITANO",QUI,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1440	localidades                                  	I	\N	(170151,ALANGASÍ,ALA,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1441	localidades                                  	I	\N	(170152,AMAGUAÑA,AMA,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1442	localidades                                  	I	\N	(170153,ATAHUALPA,ATA,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1443	localidades                                  	I	\N	(170154,CALACALÍ,CAL,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1444	localidades                                  	I	\N	(170155,CALDERÓN,CAL,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1445	localidades                                  	I	\N	(170156,CONOCOTO,CON,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1446	localidades                                  	I	\N	(170157,CUMBAYÁ,CUM,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1447	localidades                                  	I	\N	(170158,CHAVEZPAMBA,CHA,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1448	localidades                                  	I	\N	(170159,CHECA,CHE,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1449	localidades                                  	I	\N	(170160,"EL QUINCHE","EL ",1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1450	localidades                                  	I	\N	(170161,GUALEA,GUA,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1451	localidades                                  	I	\N	(170162,GUANGOPOLO,GUA,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1452	localidades                                  	I	\N	(170163,GUAYLLABAMBA,GUA,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1453	localidades                                  	I	\N	(170164,"LA MERCED","LA ",1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1454	localidades                                  	I	\N	(170165,"LLANO CHICO",LLA,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1455	localidades                                  	I	\N	(170166,LLOA,LLO,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1456	localidades                                  	I	\N	(170167,MINDO,MIN,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1457	localidades                                  	I	\N	(170168,NANEGAL,NAN,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1458	localidades                                  	I	\N	(170169,NANEGALITO,NAN,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1459	localidades                                  	I	\N	(170170,NAYÓN,NAY,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1460	localidades                                  	I	\N	(170171,NONO,NON,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1461	localidades                                  	I	\N	(170172,PACTO,PAC,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1462	localidades                                  	I	\N	(170173,"PEDRO VICENTE MALDONADO",PED,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1463	localidades                                  	I	\N	(170174,PERUCHO,PER,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1464	localidades                                  	I	\N	(170175,PIFO,PIF,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1465	localidades                                  	I	\N	(170176,PÍNTAG,PÍN,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1466	localidades                                  	I	\N	(170177,POMASQUI,POM,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1467	localidades                                  	I	\N	(170178,PUÉLLARO,PUÉ,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1468	localidades                                  	I	\N	(170179,PUEMBO,PUE,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1469	localidades                                  	I	\N	(170180,"SAN ANTONIO",SAN,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1470	localidades                                  	I	\N	(170181,"SAN JOSÉ DE MINAS",SAN,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1471	localidades                                  	I	\N	(170182,"SAN MIGUEL DE LOS BANCOS",SAN,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1472	localidades                                  	I	\N	(170183,TABABELA,TAB,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1473	localidades                                  	I	\N	(170184,TUMBACO,TUM,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1474	localidades                                  	I	\N	(170185,YARUQUÍ,YAR,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1475	localidades                                  	I	\N	(170186,ZAMBIZA,ZAM,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1476	localidades                                  	I	\N	(170187,"PUERTO QUITO",PUE,1701,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1477	localidades                                  	I	\N	(170201,AYORA,AYO,1702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1478	localidades                                  	I	\N	(170202,CAYAMBE,CAY,1702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1479	localidades                                  	I	\N	(170203,"JUAN MONTALVO",JUA,1702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1480	localidades                                  	I	\N	(170250,CAYAMBE,CAY,1702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1481	localidades                                  	I	\N	(170251,ASCÁZUBI,ASC,1702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1482	localidades                                  	I	\N	(170252,CANGAHUA,CAN,1702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1483	localidades                                  	I	\N	(170253,"OLMEDO (PESILLO)",OLM,1702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1484	localidades                                  	I	\N	(170254,OTÓN,OTÓ,1702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1485	localidades                                  	I	\N	(170255,"SANTA ROSA DE CUZUBAMBA",SAN,1702,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1486	localidades                                  	I	\N	(170350,MACHACHI,MAC,1703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1487	localidades                                  	I	\N	(170351,ALÓAG,ALÓ,1703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1488	localidades                                  	I	\N	(170352,ALOASÍ,ALO,1703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1489	localidades                                  	I	\N	(170353,CUTUGLAHUA,CUT,1703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1490	localidades                                  	I	\N	(170354,"EL CHAUPI","EL ",1703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1491	localidades                                  	I	\N	(170355,"MANUEL CORNEJO ASTORGA (TANDAPI)",MAN,1703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1492	localidades                                  	I	\N	(170356,TAMBILLO,TAM,1703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1493	localidades                                  	I	\N	(170357,UYUMBICHO,UYU,1703,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1494	localidades                                  	I	\N	(170450,TABACUNDO,TAB,1704,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1495	localidades                                  	I	\N	(170451,"LA ESPERANZA","LA ",1704,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1496	localidades                                  	I	\N	(170452,MALCHINGUÍ,MAL,1704,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1497	localidades                                  	I	\N	(170453,TOCACHI,TOC,1704,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1498	localidades                                  	I	\N	(170454,TUPIGACHI,TUP,1704,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1499	localidades                                  	I	\N	(170501,SANGOLQUÍ,SAN,1705,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1500	localidades                                  	I	\N	(170502,"SAN PEDRO DE TABOADA",SAN,1705,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1501	localidades                                  	I	\N	(170503,"SAN RAFAEL",SAN,1705,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1502	localidades                                  	I	\N	(170550,SANGOLQUI,SAN,1705,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1503	localidades                                  	I	\N	(170551,COTOGCHOA,COT,1705,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1504	localidades                                  	I	\N	(170552,RUMIPAMBA,RUM,1705,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1505	localidades                                  	I	\N	(170750,"SAN MIGUEL DE LOS BANCOS",SAN,1707,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1506	localidades                                  	I	\N	(170751,MINDO,MIN,1707,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1507	localidades                                  	I	\N	(170752,"PEDRO VICENTE MALDONADO",PED,1707,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1508	localidades                                  	I	\N	(170753,"PUERTO QUITO",PUE,1707,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1509	localidades                                  	I	\N	(170850,"PEDRO VICENTE MALDONADO",PED,1708,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1510	localidades                                  	I	\N	(170950,"PUERTO QUITO",PUE,1709,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1511	localidades                                  	I	\N	(180101,"ATOCHA – FICOA",ATO,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1512	localidades                                  	I	\N	(180102,"CELIANO MONGE",CEL,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1513	localidades                                  	I	\N	(180103,"HUACHI CHICO",HUA,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1514	localidades                                  	I	\N	(180104,"HUACHI LORETO",HUA,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1515	localidades                                  	I	\N	(180105,"LA MERCED","LA ",1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1516	localidades                                  	I	\N	(180106,"LA PENÍNSULA","LA ",1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1517	localidades                                  	I	\N	(180107,MATRIZ,MAT,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1518	localidades                                  	I	\N	(180108,PISHILATA,PIS,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1519	localidades                                  	I	\N	(180109,"SAN FRANCISCO",SAN,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1520	localidades                                  	I	\N	(180150,AMBATO,AMB,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1521	localidades                                  	I	\N	(180151,AMBATILLO,AMB,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1522	localidades                                  	I	\N	(180152,"ATAHUALPA (CHISALATA)",ATA,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1523	localidades                                  	I	\N	(180153,"AUGUSTO N. MARTÍNEZ (MUNDUGLEO)",AUG,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1524	localidades                                  	I	\N	(180154,"CONSTANTINO FERNÁNDEZ (CAB. EN CULLITAHUA)",CON,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1525	localidades                                  	I	\N	(180155,"HUACHI GRANDE",HUA,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1526	localidades                                  	I	\N	(180156,IZAMBA,IZA,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1527	localidades                                  	I	\N	(180157,"JUAN BENIGNO VELA",JUA,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1528	localidades                                  	I	\N	(180158,MONTALVO,MON,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1529	localidades                                  	I	\N	(180159,PASA,PAS,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1530	localidades                                  	I	\N	(180160,PICAIGUA,PIC,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1531	localidades                                  	I	\N	(180161,"PILAGÜÍN (PILAHÜÍN)",PIL,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1532	localidades                                  	I	\N	(180162,"QUISAPINCHA (QUIZAPINCHA)",QUI,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1533	localidades                                  	I	\N	(180163,"SAN BARTOLOMÉ DE PINLLOG",SAN,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1534	localidades                                  	I	\N	(180164,"SAN FERNANDO (PASA SAN FERNANDO)",SAN,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1535	localidades                                  	I	\N	(180165,"SANTA ROSA",SAN,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1536	localidades                                  	I	\N	(180166,TOTORAS,TOT,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1537	localidades                                  	I	\N	(180167,CUNCHIBAMBA,CUN,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1538	localidades                                  	I	\N	(180168,UNAMUNCHO,UNA,1801,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1539	localidades                                  	I	\N	(180250,"BAÑOS DE AGUA SANTA",BAÑ,1802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1540	localidades                                  	I	\N	(180251,LLIGUA,LLI,1802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1541	localidades                                  	I	\N	(180252,"RÍO NEGRO",RÍO,1802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1542	localidades                                  	I	\N	(180253,"RÍO VERDE",RÍO,1802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1543	localidades                                  	I	\N	(180254,ULBA,ULB,1802,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1544	localidades                                  	I	\N	(180350,CEVALLOS,CEV,1803,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1545	localidades                                  	I	\N	(180450,MOCHA,MOC,1804,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1546	localidades                                  	I	\N	(180451,PINGUILÍ,PIN,1804,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1547	localidades                                  	I	\N	(180550,PATATE,PAT,1805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1548	localidades                                  	I	\N	(180551,"EL TRIUNFO","EL ",1805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1549	localidades                                  	I	\N	(180552,"LOS ANDES (CAB. EN POATUG)",LOS,1805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1550	localidades                                  	I	\N	(180553,"SUCRE (CAB. EN SUCRE-PATATE URCU)",SUC,1805,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1551	localidades                                  	I	\N	(180650,QUERO,QUE,1806,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1552	localidades                                  	I	\N	(180651,RUMIPAMBA,RUM,1806,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1553	localidades                                  	I	\N	(180652,"YANAYACU - MOCHAPATA (CAB. EN YANAYACU)",YAN,1806,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1554	localidades                                  	I	\N	(180701,PELILEO,PEL,1807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1555	localidades                                  	I	\N	(180702,"PELILEO GRANDE",PEL,1807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1556	localidades                                  	I	\N	(180750,PELILEO,PEL,1807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1557	localidades                                  	I	\N	(180751,"BENÍTEZ (PACHANLICA)",BEN,1807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1558	localidades                                  	I	\N	(180752,BOLÍVAR,BOL,1807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1559	localidades                                  	I	\N	(180753,COTALÓ,COT,1807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1560	localidades                                  	I	\N	(180754,"CHIQUICHA (CAB. EN CHIQUICHA GRANDE)",CHI,1807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1561	localidades                                  	I	\N	(180755,"EL ROSARIO (RUMICHACA)","EL ",1807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1562	localidades                                  	I	\N	(180756,"GARCÍA MORENO (CHUMAQUI)",GAR,1807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1563	localidades                                  	I	\N	(180757,"GUAMBALÓ (HUAMBALÓ)",GUA,1807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1564	localidades                                  	I	\N	(180758,SALASACA,SAL,1807,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1565	localidades                                  	I	\N	(180801,"CIUDAD NUEVA",CIU,1808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1566	localidades                                  	I	\N	(180802,PÍLLARO,PÍL,1808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1567	localidades                                  	I	\N	(180850,PÍLLARO,PÍL,1808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1568	localidades                                  	I	\N	(180851,"BAQUERIZO MORENO",BAQ,1808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1569	localidades                                  	I	\N	(180852,"EMILIO MARÍA TERÁN (RUMIPAMBA)",EMI,1808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1570	localidades                                  	I	\N	(180853,"MARCOS ESPINEL (CHACATA)",MAR,1808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1571	localidades                                  	I	\N	(180854,"PRESIDENTE URBINA (CHAGRAPAMBA -PATZUCUL)",PRE,1808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1572	localidades                                  	I	\N	(180855,"SAN ANDRÉS",SAN,1808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1573	localidades                                  	I	\N	(180856,"SAN JOSÉ DE POALÓ",SAN,1808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1574	localidades                                  	I	\N	(180857,"SAN MIGUELITO",SAN,1808,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1575	localidades                                  	I	\N	(180950,TISALEO,TIS,1809,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1576	localidades                                  	I	\N	(180951,QUINCHICOTO,QUI,1809,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1577	localidades                                  	I	\N	(190101,"EL LIMÓN","EL ",1901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1578	localidades                                  	I	\N	(190102,ZAMORA,ZAM,1901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1579	localidades                                  	I	\N	(190150,ZAMORA,ZAM,1901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1580	localidades                                  	I	\N	(190151,CUMBARATZA,CUM,1901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1581	localidades                                  	I	\N	(190152,GUADALUPE,GUA,1901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1582	localidades                                  	I	\N	(190153,"IMBANA (LA VICTORIA DE IMBANA)",IMB,1901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1583	localidades                                  	I	\N	(190154,PAQUISHA,PAQ,1901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1584	localidades                                  	I	\N	(190155,SABANILLA,SAB,1901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1585	localidades                                  	I	\N	(190156,TIMBARA,TIM,1901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1586	localidades                                  	I	\N	(190157,ZUMBI,ZUM,1901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1587	localidades                                  	I	\N	(190158,"SAN CARLOS DE LAS MINAS",SAN,1901,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1588	localidades                                  	I	\N	(190250,ZUMBA,ZUM,1902,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1589	localidades                                  	I	\N	(190251,CHITO,CHI,1902,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1590	localidades                                  	I	\N	(190252,"EL CHORRO","EL ",1902,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1591	localidades                                  	I	\N	(190253,"EL PORVENIR DEL CARMEN","EL ",1902,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1592	localidades                                  	I	\N	(190254,"LA CHONTA","LA ",1902,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1593	localidades                                  	I	\N	(190255,PALANDA,PAL,1902,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1594	localidades                                  	I	\N	(190256,PUCAPAMBA,PUC,1902,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1595	localidades                                  	I	\N	(190257,"SAN FRANCISCO DEL VERGEL",SAN,1902,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1596	localidades                                  	I	\N	(190258,VALLADOLID,VAL,1902,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1597	localidades                                  	I	\N	(190259,"SAN ANDRÉS",SAN,1902,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1598	localidades                                  	I	\N	(190350,GUAYZIMI,GUA,1903,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1599	localidades                                  	I	\N	(190351,ZURMI,ZUR,1903,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1600	localidades                                  	I	\N	(190352,"NUEVO PARAÍSO",NUE,1903,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1601	localidades                                  	I	\N	(190450,"28 DE MAYO (SAN JOSÉ DE YACUAMBI)","28 ",1904,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1602	localidades                                  	I	\N	(190451,"LA PAZ","LA ",1904,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1603	localidades                                  	I	\N	(190452,TUTUPALI,TUT,1904,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1604	localidades                                  	I	\N	(190550,"YANTZAZA (YANZATZA)",YAN,1905,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1605	localidades                                  	I	\N	(190551,CHICAÑA,CHI,1905,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1606	localidades                                  	I	\N	(190552,"EL PANGUI","EL ",1905,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1607	localidades                                  	I	\N	(190553,"LOS ENCUENTROS",LOS,1905,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1608	localidades                                  	I	\N	(190650,"EL PANGUI","EL ",1906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1609	localidades                                  	I	\N	(190651,"EL GUISME","EL ",1906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1610	localidades                                  	I	\N	(190652,PACHICUTZA,PAC,1906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1611	localidades                                  	I	\N	(190653,TUNDAYME,TUN,1906,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1612	localidades                                  	I	\N	(190750,ZUMBI,ZUM,1907,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1613	localidades                                  	I	\N	(190751,PAQUISHA,PAQ,1907,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1614	localidades                                  	I	\N	(190752,TRIUNFO-DORADO,TRI,1907,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1615	localidades                                  	I	\N	(190753,PANGUINTZA,PAN,1907,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1616	localidades                                  	I	\N	(190850,PALANDA,PAL,1908,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1617	localidades                                  	I	\N	(190851,"EL PORVENIR DEL CARMEN","EL ",1908,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1618	localidades                                  	I	\N	(190852,"SAN FRANCISCO DEL VERGEL",SAN,1908,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1619	localidades                                  	I	\N	(190853,VALLADOLID,VAL,1908,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1620	localidades                                  	I	\N	(190854,"LA CANELA","LA ",1908,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1621	localidades                                  	I	\N	(190950,PAQUISHA,PAQ,1909,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1622	localidades                                  	I	\N	(190951,BELLAVISTA,BEL,1909,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1623	localidades                                  	I	\N	(190952,"NUEVO QUITO",NUE,1909,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1624	localidades                                  	I	\N	(200150,"PUERTO BAQUERIZO MORENO",PUE,2001,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1625	localidades                                  	I	\N	(200151,"EL PROGRESO","EL ",2001,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1626	localidades                                  	I	\N	(200152,"ISLA SANTA MARÍA (FLOREANA) (CAB. EN PTO. VELASCO IBARRA)",ISL,2001,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1627	localidades                                  	I	\N	(200250,"PUERTO VILLAMIL",PUE,2002,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1628	localidades                                  	I	\N	(200251,"TOMÁS DE BERLANGA (SANTO TOMÁS)",TOM,2002,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1629	localidades                                  	I	\N	(200350,"PUERTO AYORA",PUE,2003,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1630	localidades                                  	I	\N	(200351,BELLAVISTA,BEL,2003,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1631	localidades                                  	I	\N	(200352,"SANTA ROSA (INCLUYE LA ISLA BALTRA)",SAN,2003,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1632	localidades                                  	I	\N	(210150,"NUEVA LOJA",NUE,2101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1633	localidades                                  	I	\N	(210151,CUYABENO,CUY,2101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1634	localidades                                  	I	\N	(210152,DURENO,DUR,2101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1635	localidades                                  	I	\N	(210153,"GENERAL FARFÁN",GEN,2101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1636	localidades                                  	I	\N	(210154,TARAPOA,TAR,2101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1637	localidades                                  	I	\N	(210155,"EL ENO","EL ",2101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1638	localidades                                  	I	\N	(210156,PACAYACU,PAC,2101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1639	localidades                                  	I	\N	(210157,JAMBELÍ,JAM,2101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1640	localidades                                  	I	\N	(210158,"SANTA CECILIA",SAN,2101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1641	localidades                                  	I	\N	(210159,"AGUAS NEGRAS",AGU,2101,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1642	localidades                                  	I	\N	(210250,"EL DORADO DE CASCALES","EL ",2102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1643	localidades                                  	I	\N	(210251,"EL REVENTADOR","EL ",2102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1644	localidades                                  	I	\N	(210252,"GONZALO PIZARRO",GON,2102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1645	localidades                                  	I	\N	(210253,LUMBAQUÍ,LUM,2102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1646	localidades                                  	I	\N	(210254,"PUERTO LIBRE",PUE,2102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1647	localidades                                  	I	\N	(210255,"SANTA ROSA DE SUCUMBÍOS",SAN,2102,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1648	localidades                                  	I	\N	(210350,"PUERTO EL CARMEN DEL PUTUMAYO",PUE,2103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1649	localidades                                  	I	\N	(210351,"PALMA ROJA",PAL,2103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1650	localidades                                  	I	\N	(210352,"PUERTO BOLÍVAR (PUERTO MONTÚFAR)",PUE,2103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1651	localidades                                  	I	\N	(210353,"PUERTO RODRÍGUEZ",PUE,2103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1652	localidades                                  	I	\N	(210354,"SANTA ELENA",SAN,2103,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1653	localidades                                  	I	\N	(210450,SHUSHUFINDI,SHU,2104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1654	localidades                                  	I	\N	(210451,LIMONCOCHA,LIM,2104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1655	localidades                                  	I	\N	(210452,PAÑACOCHA,PAÑ,2104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1656	localidades                                  	I	\N	(210453,"SAN ROQUE (CAB. EN SAN VICENTE)",SAN,2104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1657	localidades                                  	I	\N	(210454,"SAN PEDRO DE LOS COFANES",SAN,2104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1658	localidades                                  	I	\N	(210455,"SIETE DE JULIO",SIE,2104,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1659	localidades                                  	I	\N	(210550,"LA BONITA","LA ",2105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1660	localidades                                  	I	\N	(210551,"EL PLAYÓN DE SAN FRANCISCO","EL ",2105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1661	localidades                                  	I	\N	(210552,"LA SOFÍA","LA ",2105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1662	localidades                                  	I	\N	(210553,"ROSA FLORIDA",ROS,2105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1663	localidades                                  	I	\N	(210554,"SANTA BÁRBARA",SAN,2105,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1664	localidades                                  	I	\N	(210650,"EL DORADO DE CASCALES","EL ",2106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1665	localidades                                  	I	\N	(210651,"SANTA ROSA DE SUCUMBÍOS",SAN,2106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1666	localidades                                  	I	\N	(210652,SEVILLA,SEV,2106,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1667	localidades                                  	I	\N	(210750,TARAPOA,TAR,2107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1668	localidades                                  	I	\N	(210751,CUYABENO,CUY,2107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1669	localidades                                  	I	\N	(210752,"AGUAS NEGRAS",AGU,2107,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1670	localidades                                  	I	\N	(220150,"PUERTO FRANCISCO DE ORELLANA (EL COCA)",PUE,2201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1671	localidades                                  	I	\N	(220151,DAYUMA,DAY,2201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1672	localidades                                  	I	\N	(220152,"TARACOA (NUEVA ESPERANZA: YUCA)",TAR,2201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1673	localidades                                  	I	\N	(220153,"ALEJANDRO LABAKA",ALE,2201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1674	localidades                                  	I	\N	(220154,"EL DORADO","EL ",2201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1675	localidades                                  	I	\N	(220155,"EL EDÉN","EL ",2201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1676	localidades                                  	I	\N	(220156,"GARCÍA MORENO",GAR,2201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1677	localidades                                  	I	\N	(220157,"INÉS ARANGO (CAB. EN WESTERN)",INÉ,2201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1678	localidades                                  	I	\N	(220158,"LA BELLEZA","LA ",2201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1679	localidades                                  	I	\N	(220159,"NUEVO PARAÍSO (CAB. EN UNIÓN",NUE,2201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1680	localidades                                  	I	\N	(220160,"SAN JOSÉ DE GUAYUSA",SAN,2201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1681	localidades                                  	I	\N	(220161,"SAN LUIS DE ARMENIA",SAN,2201,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1682	localidades                                  	I	\N	(220201,TIPITINI,TIP,2202,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1683	localidades                                  	I	\N	(220250,"NUEVO ROCAFUERTE",NUE,2202,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1684	localidades                                  	I	\N	(220251,"CAPITÁN AUGUSTO RIVADENEYRA",CAP,2202,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1685	localidades                                  	I	\N	(220252,CONONACO,CON,2202,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1686	localidades                                  	I	\N	(220253,"SANTA MARÍA DE HUIRIRIMA",SAN,2202,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1687	localidades                                  	I	\N	(220254,TIPUTINI,TIP,2202,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1688	localidades                                  	I	\N	(220255,YASUNÍ,YAS,2202,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1689	localidades                                  	I	\N	(220350,"LA JOYA DE LOS SACHAS","LA ",2203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1690	localidades                                  	I	\N	(220351,ENOKANQUI,ENO,2203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1691	localidades                                  	I	\N	(220352,POMPEYA,POM,2203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1692	localidades                                  	I	\N	(220353,"SAN CARLOS",SAN,2203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1693	localidades                                  	I	\N	(220354,"SAN SEBASTIÁN DEL COCA",SAN,2203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1694	localidades                                  	I	\N	(220355,"LAGO SAN PEDRO",LAG,2203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1695	localidades                                  	I	\N	(220356,RUMIPAMBA,RUM,2203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1696	localidades                                  	I	\N	(220357,"TRES DE NOVIEMBRE",TRE,2203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1697	localidades                                  	I	\N	(220358,"UNIÓN MILAGREÑA",UNI,2203,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1698	localidades                                  	I	\N	(220450,LORETO,LOR,2204,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1699	localidades                                  	I	\N	(220451,"AVILA (CAB. EN HUIRUNO)",AVI,2204,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1700	localidades                                  	I	\N	(220452,"PUERTO MURIALDO",PUE,2204,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1701	localidades                                  	I	\N	(220453,"SAN JOSÉ DE PAYAMINO",SAN,2204,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1702	localidades                                  	I	\N	(220454,"SAN JOSÉ DE DAHUANO",SAN,2204,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1703	localidades                                  	I	\N	(220455,"SAN VICENTE DE HUATICOCHA",SAN,2204,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1704	localidades                                  	I	\N	(230101,"ABRAHAM CALAZACÓN",ABR,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1705	localidades                                  	I	\N	(230102,BOMBOLÍ,BOM,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1706	localidades                                  	I	\N	(230103,CHIGUILPE,CHI,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1707	localidades                                  	I	\N	(230104,"RÍO TOACHI",RÍO,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1708	localidades                                  	I	\N	(230105,"RÍO VERDE",RÍO,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1709	localidades                                  	I	\N	(230106,"SANTO DOMINGO DE LOS COLORADOS",SAN,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1710	localidades                                  	I	\N	(230107,ZARACAY,ZAR,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1711	localidades                                  	I	\N	(230150,"SANTO DOMINGO DE LOS COLORADOS",SAN,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1712	localidades                                  	I	\N	(230151,ALLURIQUÍN,ALL,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1713	localidades                                  	I	\N	(230152,"PUERTO LIMÓN",PUE,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1714	localidades                                  	I	\N	(230153,"LUZ DE AMÉRICA",LUZ,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1715	localidades                                  	I	\N	(230154,"SAN JACINTO DEL BÚA",SAN,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1716	localidades                                  	I	\N	(230155,"VALLE HERMOSO",VAL,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1717	localidades                                  	I	\N	(230156,"EL ESFUERZO","EL ",2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1718	localidades                                  	I	\N	(230157,"SANTA MARÍA DEL TOACHI",SAN,2301,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1719	localidades                                  	I	\N	(240101,BALLENITA,BAL,2401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1720	localidades                                  	I	\N	(240102,"SANTA ELENA",SAN,2401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1721	localidades                                  	I	\N	(240150,"SANTA ELENA",SAN,2401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1722	localidades                                  	I	\N	(240151,ATAHUALPA,ATA,2401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1723	localidades                                  	I	\N	(240152,COLONCHE,COL,2401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1724	localidades                                  	I	\N	(240153,CHANDUY,CHA,2401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1725	localidades                                  	I	\N	(240154,MANGLARALTO,MAN,2401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1726	localidades                                  	I	\N	(240155,"SIMÓN BOLÍVAR (JULIO MORENO)",SIM,2401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1727	localidades                                  	I	\N	(240156,"SAN JOSÉ DE ANCÓN",SAN,2401,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1728	localidades                                  	I	\N	(240250,"LA LIBERTAD","LA ",2402,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1729	localidades                                  	I	\N	(240301,"CARLOS ESPINOZA LARREA",CAR,2403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1730	localidades                                  	I	\N	(240302,"GRAL. ALBERTO ENRÍQUEZ GALLO",GRA,2403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1731	localidades                                  	I	\N	(240303,"VICENTE ROCAFUERTE",VIC,2403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1732	localidades                                  	I	\N	(240304,"SANTA ROSA",SAN,2403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1733	localidades                                  	I	\N	(240350,SALINAS,SAL,2403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1734	localidades                                  	I	\N	(240351,ANCONCITO,ANC,2403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1735	localidades                                  	I	\N	(240352,"JOSÉ LUIS TAMAYO (MUEY)",JOS,2403,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1736	localidades                                  	I	\N	(900151,"LAS GOLONDRINAS",LAS,9001,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1737	localidades                                  	I	\N	(900351,"MANGA DEL CURA",MAN,9003,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1738	localidades                                  	I	\N	(900451,"EL PIEDRERO","EL ",9004,A,"2016-10-14 11:41:16.627838-05")	2016-10-14 11:41:16.627838	postgres                                     
1739	localidades                                  	I	\N	(080265,"SANTA LUCÍA DE LAS PEÑAS",SAN,0802,A,"2016-10-18 10:02:22.031498-05")	2016-10-18 10:02:22.031498	postgres                                     
1740	estados                                      	I	\N	(I,Inactivo,"El estado  es Inactivo ","2016-10-19 16:12:45.450871-05")	2016-10-19 16:12:45.450871	postgres                                     
1741	estados                                      	I	\N	(P,PASIVO,"ESTADO PASIVO SE USA PARA USUARIOS QUE NO AN ACTIVADO SU CUENTA YA SOLICITANDOLA","2016-10-19 16:13:32.175724-05")	2016-10-19 16:13:32.175724	postgres                                     
1742	estados                                      	U	(I,Inactivo,"El estado  es Inactivo ","2016-10-19 16:12:45.450871-05")	(I,INACTIVO,"El estado  es Inactivo ","2016-10-19 16:12:45.450871-05")	2016-10-19 16:13:41.214637	postgres                                     
1743	empresas                                     	I	\N	(201610191640015807e831ae796,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",P,"2016-10-19 00:00:00-05")	2016-10-19 16:40:01.757579	postgres                                     
1744	clientes                                     	I	\N	(9,1001843646001,MONTESDEOCA_BENAVIDES_ED_1001843646001,1001843646001,P_C,A,"2016-10-19 16:40:01.757579-05")	2016-10-19 16:40:01.757579	postgres                                     
1745	localidades                                  	U	(01,AZUAY,AZU,00,A,"2016-10-14 11:41:16.627838-05",)	(01,AZUAY,AZU,00,A,"2016-10-14 11:41:16.627838-05",072)	2016-10-19 16:47:36.712257	postgres                                     
1746	localidades                                  	U	(01,AZUAY,AZU,00,A,"2016-10-14 11:41:16.627838-05",072)	(01,AZUAY,AZU,00,A,"2016-10-14 11:41:16.627838-05","(072)")	2016-10-19 16:48:02.16173	postgres                                     
1747	localidades                                  	U	(02,BOLIVAR,BOL,00,A,"2016-10-14 11:41:16.627838-05",)	(02,BOLIVAR,BOL,00,A,"2016-10-14 11:41:16.627838-05","(032)")	2016-10-19 16:51:03.277118	postgres                                     
1748	localidades                                  	U	(03,CAÑAR,CAÑ,00,A,"2016-10-14 11:41:16.627838-05",)	(03,CAÑAR,CAÑ,00,A,"2016-10-14 11:41:16.627838-05","(07=")	2016-10-19 16:51:20.100616	postgres                                     
1749	localidades                                  	U	(03,CAÑAR,CAÑ,00,A,"2016-10-14 11:41:16.627838-05","(07=")	(03,CAÑAR,CAÑ,00,A,"2016-10-14 11:41:16.627838-05","(07)")	2016-10-19 16:51:27.341274	postgres                                     
1750	localidades                                  	U	(03,CAÑAR,CAÑ,00,A,"2016-10-14 11:41:16.627838-05","(07)")	(03,CAÑAR,CAÑ,00,A,"2016-10-14 11:41:16.627838-05","(072)")	2016-10-19 16:51:49.70844	postgres                                     
1751	empresas                                     	D	(201610191640015807e831ae796,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",P,"2016-10-19 00:00:00-05")	\N	2016-10-19 17:01:38.980026	postgres                                     
1752	localidades                                  	U	(00,ECUADOR,ECU,0,A,"2016-10-11 17:02:39.77365-05",)	(00,ECUADOR,ECU,0,A,"2016-10-11 17:02:39.77365-05","(593)")	2016-10-19 17:11:38.452244	postgres                                     
1753	localidades                                  	U	(0101,CUENCA,CUE,01,A,"2016-10-14 11:41:16.627838-05",)	(0101,CUENCA,CUE,01,A,"2016-10-14 11:41:16.627838-05","(072)")	2016-10-19 17:16:47.874182	postgres                                     
1754	localidades                                  	U	(010101,BELLAVISTA,BEL,0101,A,"2016-10-14 11:41:16.627838-05",)	(010101,BELLAVISTA,BEL,0101,A,"2016-10-14 11:41:16.627838-05","(072)")	2016-10-19 17:16:53.922023	postgres                                     
1755	localidades                                  	U	(0101,CUENCA,CUE,01,A,"2016-10-14 11:41:16.627838-05","(072)")	(0101,CUENCA,CUE,01,A,"2016-10-14 11:41:16.627838-05",)	2016-10-19 17:17:12.912776	postgres                                     
1756	localidades                                  	U	(010101,BELLAVISTA,BEL,0101,A,"2016-10-14 11:41:16.627838-05","(072)")	(010101,BELLAVISTA,BEL,0101,A,"2016-10-14 11:41:16.627838-05",)	2016-10-19 17:17:18.449407	postgres                                     
1757	localidades                                  	U	(04,CARCHI,CAR,00,A,"2016-10-14 11:41:16.627838-05",)	(04,CARCHI,CAR,00,A,"2016-10-14 11:41:16.627838-05",062)	2016-10-19 17:19:39.146409	postgres                                     
1758	localidades                                  	U	(05,COTOPAXI,COT,00,A,"2016-10-14 11:41:16.627838-05",)	(05,COTOPAXI,COT,00,A,"2016-10-14 11:41:16.627838-05",032)	2016-10-19 17:20:42.987751	postgres                                     
1759	localidades                                  	U	(06,CHIMBORAZO,CHI,00,A,"2016-10-14 11:41:16.627838-05",)	(06,CHIMBORAZO,CHI,00,A,"2016-10-14 11:41:16.627838-05","(032)")	2016-10-19 17:21:17.458483	postgres                                     
1760	localidades                                  	U	(05,COTOPAXI,COT,00,A,"2016-10-14 11:41:16.627838-05",032)	(05,COTOPAXI,COT,00,A,"2016-10-14 11:41:16.627838-05","(032)")	2016-10-19 17:21:42.001067	postgres                                     
1761	localidades                                  	U	(04,CARCHI,CAR,00,A,"2016-10-14 11:41:16.627838-05",062)	(04,CARCHI,CAR,00,A,"2016-10-14 11:41:16.627838-05","(062)")	2016-10-19 17:22:19.486979	postgres                                     
1762	localidades                                  	U	(07,"EL ORO","EL ",00,A,"2016-10-14 11:41:16.627838-05",)	(07,"EL ORO","EL ",00,A,"2016-10-14 11:41:16.627838-05","(072)")	2016-10-19 17:23:31.263618	postgres                                     
1763	localidades                                  	U	(08,ESMERALDAS,ESM,00,A,"2016-10-14 11:41:16.627838-05",)	(08,ESMERALDAS,ESM,00,A,"2016-10-14 11:41:16.627838-05","(062)")	2016-10-19 17:24:19.098053	postgres                                     
1764	localidades                                  	U	(09,GUAYAS,GUA,00,A,"2016-10-14 11:41:16.627838-05",)	(09,GUAYAS,GUA,00,A,"2016-10-14 11:41:16.627838-05","(042)")	2016-10-19 17:24:57.469673	postgres                                     
1765	localidades                                  	U	(10,IMBABURA,IMB,00,A,"2016-10-11 17:03:14.556837-05",)	(10,IMBABURA,IMB,00,A,"2016-10-11 17:03:14.556837-05","(06)")	2016-10-19 17:25:22.088201	postgres                                     
1766	localidades                                  	U	(11,LOJA,LOJ,00,A,"2016-10-14 11:41:16.627838-05",)	(11,LOJA,LOJ,00,A,"2016-10-14 11:41:16.627838-05","(072)")	2016-10-19 17:26:09.641393	postgres                                     
1767	localidades                                  	U	(12,"LOS RIOS",LOS,00,A,"2016-10-14 11:41:16.627838-05",)	(12,"LOS RIOS",LOS,00,A,"2016-10-14 11:41:16.627838-05","(052)")	2016-10-19 17:28:03.094155	postgres                                     
1768	localidades                                  	U	(13,MANABI,MAN,00,A,"2016-10-14 11:41:16.627838-05",)	(13,MANABI,MAN,00,A,"2016-10-14 11:41:16.627838-05","(052)")	2016-10-19 17:28:41.800412	postgres                                     
1769	localidades                                  	U	(14,"MORONA SANTIAGO",MOR,00,A,"2016-10-14 11:41:16.627838-05",)	(14,"MORONA SANTIAGO",MOR,00,A,"2016-10-14 11:41:16.627838-05","(072)")	2016-10-19 17:29:34.62943	postgres                                     
1770	localidades                                  	U	(15,NAPO,NAP,00,A,"2016-10-14 11:41:16.627838-05",)	(15,NAPO,NAP,00,A,"2016-10-14 11:41:16.627838-05","(062)")	2016-10-19 17:30:10.891242	postgres                                     
1771	localidades                                  	U	(16,PASTAZA,PAS,00,A,"2016-10-14 11:41:16.627838-05",)	(16,PASTAZA,PAS,00,A,"2016-10-14 11:41:16.627838-05","(032)")	2016-10-19 17:30:57.562076	postgres                                     
1772	localidades                                  	U	(17,PICHINCHA,PIC,00,A,"2016-10-14 11:41:16.627838-05",)	(17,PICHINCHA,PIC,00,A,"2016-10-14 11:41:16.627838-05","(022)")	2016-10-19 17:31:19.279142	postgres                                     
1773	localidades                                  	U	(19,"ZAMORA CHINCHIPE",ZAM,00,A,"2016-10-14 11:41:16.627838-05",)	(19,"ZAMORA CHINCHIPE",ZAM,00,A,"2016-10-14 11:41:16.627838-05","(072)")	2016-10-19 17:32:29.723082	postgres                                     
1774	localidades                                  	U	(20,GALAPAGOS,GAL,00,A,"2016-10-14 11:41:16.627838-05",)	(20,GALAPAGOS,GAL,00,A,"2016-10-14 11:41:16.627838-05","(052)")	2016-10-19 17:33:07.736854	postgres                                     
1775	localidades                                  	U	(21,SUCUMBIOS,SUC,00,A,"2016-10-14 11:41:16.627838-05",)	(21,SUCUMBIOS,SUC,00,A,"2016-10-14 11:41:16.627838-05","(062)")	2016-10-19 17:33:42.734527	postgres                                     
1776	localidades                                  	U	(22,ORELLANA,ORE,00,A,"2016-10-14 11:41:16.627838-05",)	(22,ORELLANA,ORE,00,A,"2016-10-14 11:41:16.627838-05","(062)")	2016-10-19 17:34:13.893639	postgres                                     
1777	localidades                                  	U	(23,"SANTO DOMINGO DE LOS TSACHILAS",SAN,00,A,"2016-10-14 11:41:16.627838-05",)	(23,"SANTO DOMINGO DE LOS TSACHILAS",SAN,00,A,"2016-10-14 11:41:16.627838-05","(022)")	2016-10-19 17:34:57.850398	postgres                                     
1778	localidades                                  	U	(24,"SANTA ELENA",SAN,00,A,"2016-10-14 11:41:16.627838-05",)	(24,"SANTA ELENA",SAN,00,A,"2016-10-14 11:41:16.627838-05","(042)")	2016-10-19 17:35:50.743291	postgres                                     
1779	localidades                                  	U	(18,TUNGURAHUA,TUN,00,A,"2016-10-14 11:41:16.627838-05",)	(18,TUNGURAHUA,TUN,00,A,"2016-10-14 11:41:16.627838-05","(032)")	2016-10-20 08:50:05.393318	postgres                                     
1780	localidades                                  	U	(10,IMBABURA,IMB,00,A,"2016-10-11 17:03:14.556837-05","(06)")	(10,IMBABURA,IMB,00,A,"2016-10-11 17:03:14.556837-05","(062)")	2016-10-20 08:52:28.236056	postgres                                     
1781	empresas                                     	I	\N	(201610200917225808d1f243285,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",P,"2016-10-20 00:00:00-05")	2016-10-20 09:17:22.31947	postgres                                     
1782	clientes                                     	I	\N	(10,1001843646001,MONTESDEOCA_BENAVIDES_ED_1001843646001,1001843646001,P_C,A,"2016-10-20 09:17:22.31947-05")	2016-10-20 09:17:22.31947	postgres                                     
1783	empresas                                     	D	(201610200917225808d1f243285,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",P,"2016-10-20 00:00:00-05")	\N	2016-10-20 09:26:56.157615	postgres                                     
1784	empresas                                     	I	\N	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",P,"2016-10-20 00:00:00-05")	2016-10-20 09:28:20.967768	postgres                                     
1785	clientes                                     	I	\N	(11,1001843646001,MONTESDEOCA_BENAVIDES_ED_1001843646001,1001843646001,P_C,A,"2016-10-20 09:28:20.967768-05")	2016-10-20 09:28:20.967768	postgres                                     
1786	clientes                                     	D	(10,1001843646001,MONTESDEOCA_BENAVIDES_ED_1001843646001,1001843646001,P_C,A,"2016-10-20 09:17:22.31947-05")	\N	2016-10-20 09:37:47.383326	postgres                                     
1787	clientes                                     	D	(9,1001843646001,MONTESDEOCA_BENAVIDES_ED_1001843646001,1001843646001,P_C,A,"2016-10-19 16:40:01.757579-05")	\N	2016-10-20 09:37:47.406569	postgres                                     
1788	empresas                                     	U	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",P,"2016-10-20 00:00:00-05")	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",A,"2016-10-20 00:00:00-05")	2016-10-24 09:29:09.678994	postgres                                     
1789	empresas                                     	U	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",A,"2016-10-20 00:00:00-05")	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",P,"2016-10-20 00:00:00-05")	2016-10-24 09:44:03.395015	postgres                                     
1790	empresas                                     	U	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",P,"2016-10-20 00:00:00-05")	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",A,"2016-10-20 00:00:00-05")	2016-10-24 10:16:04.416305	postgres                                     
1791	empresas                                     	U	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",A,"2016-10-20 00:00:00-05")	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",P,"2016-10-20 00:00:00-05")	2016-10-24 10:17:21.580753	postgres                                     
1792	empresas                                     	U	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",P,"2016-10-20 00:00:00-05")	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",A,"2016-10-20 00:00:00-05")	2016-10-24 10:18:18.253368	postgres                                     
1793	empresas                                     	U	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",A,"2016-10-20 00:00:00-05")	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",P,"2016-10-20 00:00:00-05")	2016-10-24 10:21:11.384971	postgres                                     
1794	empresas                                     	U	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",P,"2016-10-20 00:00:00-05")	(201610200928205808d484e1758,"MONTESDEOCA BENAVIDES EDWIN RUBEN","MONTESDEOCA_BENAVIDES_ED_1001843646001  ","FABRICACION DE ARTICULOS DE CERAMICA PARA LA INDUSTRIA EN GENERAL",1001843646001,,"2001-08-01 00:00:00-05","KERAPAC CONSTRUCTORA",,"Persona Natural",A,"2016-10-20 00:00:00-05")	2016-10-24 10:21:20.946337	postgres                                     
\.


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 188
-- Name: auditoria_id_seq; Type: SEQUENCE SET; Schema: auditoria; Owner: postgres
--

SELECT pg_catalog.setval('auditoria_id_seq', 1794, true);


--
-- TOC entry 3409 (class 0 OID 16430)
-- Dependencies: 189
-- Data for Name: ingresos_usuarios; Type: TABLE DATA; Schema: auditoria; Owner: postgres
--

COPY ingresos_usuarios (id, usuario, informacion_servidor, fecha, ip_acceso) FROM stdin;
14	{"nick":"1001843646","clave_clave":"1231"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
15	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
16	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
17	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
18	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
19	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
20	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
21	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
22	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
23	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
24	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
25	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
26	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
27	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
28	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
29	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
30	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
31	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
32	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
33	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
34	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
35	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
36	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
37	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
38	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-25 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
39	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-27 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
40	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-27 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
41	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-27 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
42	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-27 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
43	{"email":"1001843646","password":"1001843646"}	{"ip":"186.33.168.250","hostname":"No Hostname","city":"Quito","region":"Provincia de Pichincha","country":"EC","loc":"-0.2167,-78.5000","org":"AS27947 Telconet S.A"}	2016-10-27 00:00:00-05	{"ip_cliente":"192.168.0.1","macadress":"25:ik:256:90"}
\.


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 190
-- Name: ingresos_usuarios_id_seq; Type: SEQUENCE SET; Schema: auditoria; Owner: postgres
--

SELECT pg_catalog.setval('ingresos_usuarios_id_seq', 43, true);


SET search_path = contabilidad, pg_catalog;

--
-- TOC entry 3411 (class 0 OID 16438)
-- Dependencies: 191
-- Data for Name: ambitos_impuestos; Type: TABLE DATA; Schema: contabilidad; Owner: postgres
--

COPY ambitos_impuestos (id, nombre, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 192
-- Name: ambitos_impuestos_id_seq; Type: SEQUENCE SET; Schema: contabilidad; Owner: postgres
--

SELECT pg_catalog.setval('ambitos_impuestos_id_seq', 1, false);


--
-- TOC entry 3413 (class 0 OID 16443)
-- Dependencies: 193
-- Data for Name: genealogia_impuestos; Type: TABLE DATA; Schema: contabilidad; Owner: postgres
--

COPY genealogia_impuestos (id_impuesto_padre, id_impuesto_hijo) FROM stdin;
\.


--
-- TOC entry 3414 (class 0 OID 16446)
-- Dependencies: 194
-- Data for Name: grupo_impuestos; Type: TABLE DATA; Schema: contabilidad; Owner: postgres
--

COPY grupo_impuestos (id, nombre, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 195
-- Name: grupo_impuestos_id_seq; Type: SEQUENCE SET; Schema: contabilidad; Owner: postgres
--

SELECT pg_catalog.setval('grupo_impuestos_id_seq', 1, false);


--
-- TOC entry 3416 (class 0 OID 16451)
-- Dependencies: 196
-- Data for Name: impuestos; Type: TABLE DATA; Schema: contabilidad; Owner: postgres
--

COPY impuestos (id, nombre, descripcion, cantidad, estado, fecha, ambito) FROM stdin;
\.


--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 197
-- Name: impuestos_id_seq; Type: SEQUENCE SET; Schema: contabilidad; Owner: postgres
--

SELECT pg_catalog.setval('impuestos_id_seq', 1, false);


SET search_path = inventario, pg_catalog;

--
-- TOC entry 3418 (class 0 OID 16468)
-- Dependencies: 198
-- Data for Name: catalogos; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY catalogos (id, tipo_catalogo, producto) FROM stdin;
\.


--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 199
-- Name: catalogos_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('catalogos_id_seq', 1, false);


--
-- TOC entry 3420 (class 0 OID 16473)
-- Dependencies: 200
-- Data for Name: categorias; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY categorias (id, nombre, descripcion, tipo_categoria, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 201
-- Name: categorias_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('categorias_id_seq', 1, false);


--
-- TOC entry 3422 (class 0 OID 16481)
-- Dependencies: 202
-- Data for Name: descripcion_producto; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY descripcion_producto (id, producto, descripcion_corta, descripcion_proveedor, descripcion_proformas, descripcion_movi_inventa) FROM stdin;
\.


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 203
-- Name: descripcion_producto_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('descripcion_producto_id_seq', 1, false);


--
-- TOC entry 3424 (class 0 OID 16489)
-- Dependencies: 204
-- Data for Name: estado_descriptivo; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY estado_descriptivo (id, nombre, descripcion, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 205
-- Name: estado_descriptivo_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('estado_descriptivo_id_seq', 1, false);


--
-- TOC entry 3426 (class 0 OID 16497)
-- Dependencies: 206
-- Data for Name: garantias; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY garantias (id, nombre, descripcion, estado, fecha, tipo_garantia, duracion) FROM stdin;
\.


--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 207
-- Name: garantias_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('garantias_id_seq', 1, false);


--
-- TOC entry 3428 (class 0 OID 16505)
-- Dependencies: 208
-- Data for Name: imagenes_productos; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY imagenes_productos (id, nombre, direccion, tipo_imagen, estado, fecha, producto) FROM stdin;
\.


--
-- TOC entry 3429 (class 0 OID 16509)
-- Dependencies: 209
-- Data for Name: marcas; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY marcas (id, nombre, descripcion, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 210
-- Name: marcas_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('marcas_id_seq', 1, false);


--
-- TOC entry 3431 (class 0 OID 16517)
-- Dependencies: 211
-- Data for Name: modelos; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY modelos (id, nombre, descripcion, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3558 (class 0 OID 0)
-- Dependencies: 212
-- Name: modelos_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('modelos_id_seq', 1, false);


--
-- TOC entry 3433 (class 0 OID 16525)
-- Dependencies: 213
-- Data for Name: productos; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY productos (id, nombre_corto, vendible, comprable, precio, costo, estado_descriptivo, categoria, garantia, marca, modelo, ubicacion, cantidad, descripcion, codigo_baras, tipo_consumo) FROM stdin;
\.


--
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 214
-- Name: productos_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('productos_id_seq', 1, false);


--
-- TOC entry 3435 (class 0 OID 16533)
-- Dependencies: 215
-- Data for Name: productos_impuestos; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY productos_impuestos (id, producto, inpuesto) FROM stdin;
\.


--
-- TOC entry 3436 (class 0 OID 16536)
-- Dependencies: 216
-- Data for Name: proveedores; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY proveedores (id, nombre, ruc, direccion) FROM stdin;
\.


--
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 217
-- Name: proveedores_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('proveedores_id_seq', 1, false);


--
-- TOC entry 3438 (class 0 OID 16544)
-- Dependencies: 218
-- Data for Name: sucursal; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY sucursal (id, nombre, id_localidad, id_responsable, fecha, estado) FROM stdin;
\.


--
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 219
-- Name: sucursal_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('sucursal_id_seq', 1, false);


--
-- TOC entry 3440 (class 0 OID 16549)
-- Dependencies: 220
-- Data for Name: tipo_consumo; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY tipo_consumo (id, nombre, descripcion, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 221
-- Name: tipo_consumo_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('tipo_consumo_id_seq', 1, false);


--
-- TOC entry 3442 (class 0 OID 16557)
-- Dependencies: 222
-- Data for Name: tipos_catalogos; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY tipos_catalogos (id, nombre, descripcion, fecha_inicio, fecha_fin, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 223
-- Name: tipos_catalogos_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('tipos_catalogos_id_seq', 1, false);


--
-- TOC entry 3444 (class 0 OID 16565)
-- Dependencies: 224
-- Data for Name: tipos_categorias; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY tipos_categorias (id, nombre, descripcion, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 225
-- Name: tipos_categorias_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('tipos_categorias_id_seq', 1, false);


--
-- TOC entry 3446 (class 0 OID 16573)
-- Dependencies: 226
-- Data for Name: tipos_garantias; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY tipos_garantias (id, nombre, descripcion, fecha, estado) FROM stdin;
\.


--
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 227
-- Name: tipos_garantias_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('tipos_garantias_id_seq', 1, false);


--
-- TOC entry 3448 (class 0 OID 16581)
-- Dependencies: 228
-- Data for Name: tipos_imagenes_productos; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY tipos_imagenes_productos (id, nombre, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 229
-- Name: tipos_imagenes_productos_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('tipos_imagenes_productos_id_seq', 1, false);


--
-- TOC entry 3450 (class 0 OID 16586)
-- Dependencies: 230
-- Data for Name: tipos_productos; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY tipos_productos (id, nombre, descripcion, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 231
-- Name: tipos_productos_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('tipos_productos_id_seq', 1, false);


--
-- TOC entry 3452 (class 0 OID 16594)
-- Dependencies: 232
-- Data for Name: ubicaciones; Type: TABLE DATA; Schema: inventario; Owner: postgres
--

COPY ubicaciones (id, nombre, descripcion, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 233
-- Name: ubicaciones_id_seq; Type: SEQUENCE SET; Schema: inventario; Owner: postgres
--

SELECT pg_catalog.setval('ubicaciones_id_seq', 1, false);


SET search_path = public, pg_catalog;

--
-- TOC entry 3454 (class 0 OID 16602)
-- Dependencies: 234
-- Data for Name: estados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY estados (id, nombre, descripcion) FROM stdin;
\.


--
-- TOC entry 3455 (class 0 OID 16605)
-- Dependencies: 235
-- Data for Name: localidades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY localidades (id, nombre, codigo, id_padre, estado, fecha, codigo_telefonico) FROM stdin;
1001	IBARRA	IBA	10	A	2016-10-11 17:42:51.770289-05	\N
1002	ANTONIO ANTE	ANT	10	A	2016-10-11 17:42:51.770289-05	\N
1003	COTACACHI	COT	10	A	2016-10-11 17:42:51.770289-05	\N
1004	OTAVALO	OTA	10	A	2016-10-11 17:42:51.770289-05	\N
1005	PIMAMPIRO	PIM	10	A	2016-10-11 17:42:51.770289-05	\N
1006	SAN MIGUEL DE URCUQUI	URC	10	A	2016-10-11 17:42:51.770289-05	\N
100101	CARANQUI	CAR	1001	A	2016-10-11 17:42:51.770289-05	\N
100102	GUAYAQUIL DE ALPACHACA	ALP	1001	A	2016-10-11 17:42:51.770289-05	\N
100103	SAGRARIO	SAG	1001	A	2016-10-11 17:42:51.770289-05	\N
100104	SAN FRANCISCO	FRA	1001	A	2016-10-11 17:42:51.770289-05	\N
100105	LA DOLOROSA DEL PRIORATO	PIO	1001	A	2016-10-11 17:42:51.770289-05	\N
100150	SAN MIGUEL DE IBARRA	IBA	1001	A	2016-10-11 17:42:51.770289-05	\N
100151	AMBUQUI	AMB	1001	A	2016-10-11 17:42:51.770289-05	\N
100152	ANGOCHAGUA	ANG	1001	A	2016-10-11 17:42:51.770289-05	\N
100153	CAROLINA	CAR	1001	A	2016-10-11 17:42:51.770289-05	\N
100154	LA ESPERANZA	ESP	1001	A	2016-10-11 17:42:51.770289-05	\N
100155	LITA	LIT	1001	A	2016-10-11 17:42:51.770289-05	\N
100156	SALINAS	SAL	1001	A	2016-10-11 17:42:51.770289-05	\N
100157	SAN ANTONIO	ANT	1001	A	2016-10-11 17:42:51.770289-05	\N
100201	ANDRADE MARÍN (LOURDES)	AND	1002	A	2016-10-11 17:42:51.770289-05	\N
100202	ATUNTAQUI	ATU	1002	A	2016-10-11 17:42:51.770289-05	\N
100251	IMBAYA (SAN LUIS DE COBUENDO)	IMB	1002	A	2016-10-11 17:42:51.770289-05	\N
100252	SAN FRANCISCO DE NATABUELA	NAT	1002	A	2016-10-11 17:42:51.770289-05	\N
100253	SAN JOSÉ DE CHALTURA	CHA	1002	A	2016-10-11 17:42:51.770289-05	\N
100254	SAN ROQUE	ROQ	1002	A	2016-10-11 17:42:51.770289-05	\N
100301	SAGRARIO	SAG	1003	A	2016-10-11 17:42:51.770289-05	\N
100302	SAN FRANCISCO	FRA	1003	A	2016-10-11 17:42:51.770289-05	\N
100350	COTACACHI	COT	1003	A	2016-10-11 17:42:51.770289-05	\N
100351	APUELA	APU	1003	A	2016-10-11 17:42:51.770289-05	\N
100352	GARCIA MORENO (LLURIMAGUA)	GMO	1003	A	2016-10-11 17:42:51.770289-05	\N
100353	IMANTAG	IMA	1003	A	2016-10-11 17:42:51.770289-05	\N
100354	PEÑAHERRERA	PEÑ	1003	A	2016-10-11 17:42:51.770289-05	\N
100355	PLAZA GUTIERREZ (CALVARIO)	PGU	1003	A	2016-10-11 17:42:51.770289-05	\N
100356	QUIROGA	1003	QUI	A	2016-10-11 17:42:51.770289-05	\N
100357	6 DE JULIO DE CUELLAJE (CAB. EN CUELLAJE)	CUE	1003	A	2016-10-11 17:42:51.770289-05	\N
100358	VACAS GALINDO (EL CHURO) (CAB.EN SAN MIGUEL ALTO)	VAC	1003	A	2016-10-11 17:42:51.770289-05	\N
100550	PIMAMPIRO	PIM	1004	A	2016-10-11 17:42:51.770289-05	\N
100551	CHUGA	CHU	1004	A	2016-10-11 17:42:51.770289-05	\N
100552	MARIANO ACOSTA	MAC	1004	A	2016-10-11 17:42:51.770289-05	\N
100553	SAN FRANCISCO DE SIGSIPAMBA	SIG	1004	A	2016-10-11 17:42:51.770289-05	\N
100650	URCUQUI CABECERA CANTONAL	URC	1005	A	2016-10-11 17:42:51.770289-05	\N
100651	CAHUASQUI	CAH	1005	A	2016-10-11 17:42:51.770289-05	\N
100652	LA MERCED DE BUENOS AIRES	BUE	1005	A	2016-10-11 17:42:51.770289-05	\N
100653	PABLO ARENAS	PAR	1005	A	2016-10-11 17:42:51.770289-05	\N
100654	SAN BLAS	SBL	1005	A	2016-10-11 17:42:51.770289-05	\N
100655	TUMBABIRO	TUM	1005	A	2016-10-11 17:42:51.770289-05	\N
100401	JORDÁN	JOR	1004	A	2016-10-12 12:21:18.08894-05	\N
100402	SAN LUIS	LUI	1004	A	2016-10-12 12:21:18.08894-05	\N
100450	OTAVALO	OTA	1004	A	2016-10-12 12:21:18.08894-05	\N
100451	DR. MIGUEL EGAS CABEZAS (PEGUCHE)	PEG	1004	A	2016-10-12 12:21:18.08894-05	\N
100452	EUGENIO ESPEJO (CALPAQUÍ)	ESP	1004	A	2016-10-12 12:21:18.08894-05	\N
100453	GONZÁLEZ SUÁREZ	GON	1004	A	2016-10-12 12:21:18.08894-05	\N
100454	PATAQUÍ	PAT	1004	A	2016-10-12 12:21:18.08894-05	\N
100455	SAN JOSÉ DE QUICHINCHE	QUI	1004	A	2016-10-12 12:21:18.08894-05	\N
100456	SAN JUAN DE ILUMÁN	ILU	1004	A	2016-10-12 12:21:18.08894-05	\N
100457	SAN PABLO	PAB	1004	A	2016-10-12 12:21:18.08894-05	\N
100458	SAN RAFAEL	RAF	1004	A	2016-10-12 12:21:18.08894-05	\N
100459	SELVA ALEGRE (CAB.EN SAN MIGUEL DE PAMPLONA)	SEL	1004	A	2016-10-12 12:21:18.08894-05	\N
90	ZONAS NO DELIMITADAS	ZON	00	A	2016-10-14 11:41:16.627838-05	\N
0102	GIRÓN	GIR	01	A	2016-10-14 11:41:16.627838-05	\N
0103	GUALACEO	GUA	01	A	2016-10-14 11:41:16.627838-05	\N
0104	NABÓN	NAB	01	A	2016-10-14 11:41:16.627838-05	\N
0105	PAUTE	PAU	01	A	2016-10-14 11:41:16.627838-05	\N
0106	PUCARA	PUC	01	A	2016-10-14 11:41:16.627838-05	\N
0107	SAN FERNANDO	SAN	01	A	2016-10-14 11:41:16.627838-05	\N
0108	SANTA ISABEL	SAN	01	A	2016-10-14 11:41:16.627838-05	\N
0109	SIGSIG	SIG	01	A	2016-10-14 11:41:16.627838-05	\N
0110	OÑA	OÑA	01	A	2016-10-14 11:41:16.627838-05	\N
0111	CHORDELEG	CHO	01	A	2016-10-14 11:41:16.627838-05	\N
0112	EL PAN	EL 	01	A	2016-10-14 11:41:16.627838-05	\N
0113	SEVILLA DE ORO	SEV	01	A	2016-10-14 11:41:16.627838-05	\N
0114	GUACHAPALA	GUA	01	A	2016-10-14 11:41:16.627838-05	\N
0115	CAMILO PONCE ENRÍQUEZ	CAM	01	A	2016-10-14 11:41:16.627838-05	\N
0201	GUARANDA	GUA	02	A	2016-10-14 11:41:16.627838-05	\N
0202	CHILLANES	CHI	02	A	2016-10-14 11:41:16.627838-05	\N
0203	CHIMBO	CHI	02	A	2016-10-14 11:41:16.627838-05	\N
0204	ECHEANDÍA	ECH	02	A	2016-10-14 11:41:16.627838-05	\N
0205	SAN MIGUEL	SAN	02	A	2016-10-14 11:41:16.627838-05	\N
0206	CALUMA	CAL	02	A	2016-10-14 11:41:16.627838-05	\N
0207	LAS NAVES	LAS	02	A	2016-10-14 11:41:16.627838-05	\N
0301	AZOGUES	AZO	03	A	2016-10-14 11:41:16.627838-05	\N
0302	BIBLIÁN	BIB	03	A	2016-10-14 11:41:16.627838-05	\N
0303	CAÑAR	CAÑ	03	A	2016-10-14 11:41:16.627838-05	\N
0304	LA TRONCAL	LA 	03	A	2016-10-14 11:41:16.627838-05	\N
0305	EL TAMBO	EL 	03	A	2016-10-14 11:41:16.627838-05	\N
0306	DÉLEG	DÉL	03	A	2016-10-14 11:41:16.627838-05	\N
0307	SUSCAL	SUS	03	A	2016-10-14 11:41:16.627838-05	\N
0401	TULCÁN	TUL	04	A	2016-10-14 11:41:16.627838-05	\N
0402	BOLÍVAR	BOL	04	A	2016-10-14 11:41:16.627838-05	\N
0403	ESPEJO	ESP	04	A	2016-10-14 11:41:16.627838-05	\N
0404	MIRA	MIR	04	A	2016-10-14 11:41:16.627838-05	\N
0405	MONTÚFAR	MON	04	A	2016-10-14 11:41:16.627838-05	\N
0406	SAN PEDRO DE HUACA	SAN	04	A	2016-10-14 11:41:16.627838-05	\N
0501	LATACUNGA	LAT	05	A	2016-10-14 11:41:16.627838-05	\N
02	BOLIVAR	BOL	00	A	2016-10-14 11:41:16.627838-05	(032)
03	CAÑAR	CAÑ	00	A	2016-10-14 11:41:16.627838-05	(072)
00	ECUADOR	ECU	0	A	2016-10-11 17:02:39.77365-05	(593)
07	EL ORO	EL 	00	A	2016-10-14 11:41:16.627838-05	(072)
04	CARCHI	CAR	00	A	2016-10-14 11:41:16.627838-05	(062)
06	CHIMBORAZO	CHI	00	A	2016-10-14 11:41:16.627838-05	(032)
05	COTOPAXI	COT	00	A	2016-10-14 11:41:16.627838-05	(032)
08	ESMERALDAS	ESM	00	A	2016-10-14 11:41:16.627838-05	(062)
11	LOJA	LOJ	00	A	2016-10-14 11:41:16.627838-05	(072)
12	LOS RIOS	LOS	00	A	2016-10-14 11:41:16.627838-05	(052)
13	MANABI	MAN	00	A	2016-10-14 11:41:16.627838-05	(052)
15	NAPO	NAP	00	A	2016-10-14 11:41:16.627838-05	(062)
16	PASTAZA	PAS	00	A	2016-10-14 11:41:16.627838-05	(032)
17	PICHINCHA	PIC	00	A	2016-10-14 11:41:16.627838-05	(022)
19	ZAMORA CHINCHIPE	ZAM	00	A	2016-10-14 11:41:16.627838-05	(072)
20	GALAPAGOS	GAL	00	A	2016-10-14 11:41:16.627838-05	(052)
21	SUCUMBIOS	SUC	00	A	2016-10-14 11:41:16.627838-05	(062)
23	SANTO DOMINGO DE LOS TSACHILAS	SAN	00	A	2016-10-14 11:41:16.627838-05	(022)
24	SANTA ELENA	SAN	00	A	2016-10-14 11:41:16.627838-05	(042)
18	TUNGURAHUA	TUN	00	A	2016-10-14 11:41:16.627838-05	(032)
10	IMBABURA	IMB	00	A	2016-10-11 17:03:14.556837-05	(062)
0502	LA MANÁ	LA 	05	A	2016-10-14 11:41:16.627838-05	\N
0503	PANGUA	PAN	05	A	2016-10-14 11:41:16.627838-05	\N
0504	PUJILI	PUJ	05	A	2016-10-14 11:41:16.627838-05	\N
0505	SALCEDO	SAL	05	A	2016-10-14 11:41:16.627838-05	\N
0506	SAQUISILÍ	SAQ	05	A	2016-10-14 11:41:16.627838-05	\N
0507	SIGCHOS	SIG	05	A	2016-10-14 11:41:16.627838-05	\N
0601	RIOBAMBA	RIO	06	A	2016-10-14 11:41:16.627838-05	\N
0602	ALAUSI	ALA	06	A	2016-10-14 11:41:16.627838-05	\N
0603	COLTA	COL	06	A	2016-10-14 11:41:16.627838-05	\N
0604	CHAMBO	CHA	06	A	2016-10-14 11:41:16.627838-05	\N
0605	CHUNCHI	CHU	06	A	2016-10-14 11:41:16.627838-05	\N
0606	GUAMOTE	GUA	06	A	2016-10-14 11:41:16.627838-05	\N
0607	GUANO	GUA	06	A	2016-10-14 11:41:16.627838-05	\N
0608	PALLATANGA	PAL	06	A	2016-10-14 11:41:16.627838-05	\N
0609	PENIPE	PEN	06	A	2016-10-14 11:41:16.627838-05	\N
0610	CUMANDÁ	CUM	06	A	2016-10-14 11:41:16.627838-05	\N
0701	MACHALA	MAC	07	A	2016-10-14 11:41:16.627838-05	\N
0702	ARENILLAS	ARE	07	A	2016-10-14 11:41:16.627838-05	\N
0703	ATAHUALPA	ATA	07	A	2016-10-14 11:41:16.627838-05	\N
0704	BALSAS	BAL	07	A	2016-10-14 11:41:16.627838-05	\N
0705	CHILLA	CHI	07	A	2016-10-14 11:41:16.627838-05	\N
0706	EL GUABO	EL 	07	A	2016-10-14 11:41:16.627838-05	\N
0707	HUAQUILLAS	HUA	07	A	2016-10-14 11:41:16.627838-05	\N
0708	MARCABELÍ	MAR	07	A	2016-10-14 11:41:16.627838-05	\N
0709	PASAJE	PAS	07	A	2016-10-14 11:41:16.627838-05	\N
0710	PIÑAS	PIÑ	07	A	2016-10-14 11:41:16.627838-05	\N
0711	PORTOVELO	POR	07	A	2016-10-14 11:41:16.627838-05	\N
0712	SANTA ROSA	SAN	07	A	2016-10-14 11:41:16.627838-05	\N
0713	ZARUMA	ZAR	07	A	2016-10-14 11:41:16.627838-05	\N
0714	LAS LAJAS	LAS	07	A	2016-10-14 11:41:16.627838-05	\N
0801	ESMERALDAS	ESM	08	A	2016-10-14 11:41:16.627838-05	\N
0802	ELOY ALFARO	ELO	08	A	2016-10-14 11:41:16.627838-05	\N
0803	MUISNE	MUI	08	A	2016-10-14 11:41:16.627838-05	\N
0804	QUININDÉ	QUI	08	A	2016-10-14 11:41:16.627838-05	\N
0805	SAN LORENZO	SAN	08	A	2016-10-14 11:41:16.627838-05	\N
0806	ATACAMES	ATA	08	A	2016-10-14 11:41:16.627838-05	\N
0807	RIOVERDE	RIO	08	A	2016-10-14 11:41:16.627838-05	\N
0808	LA CONCORDIA	LA 	08	A	2016-10-14 11:41:16.627838-05	\N
0901	GUAYAQUIL	GUA	09	A	2016-10-14 11:41:16.627838-05	\N
0902	ALFREDO BAQUERIZO MORENO (JUJÁN)	ALF	09	A	2016-10-14 11:41:16.627838-05	\N
0903	BALAO	BAL	09	A	2016-10-14 11:41:16.627838-05	\N
0904	BALZAR	BAL	09	A	2016-10-14 11:41:16.627838-05	\N
0905	COLIMES	COL	09	A	2016-10-14 11:41:16.627838-05	\N
0906	DAULE	DAU	09	A	2016-10-14 11:41:16.627838-05	\N
0907	DURÁN	DUR	09	A	2016-10-14 11:41:16.627838-05	\N
0908	EL EMPALME	EL 	09	A	2016-10-14 11:41:16.627838-05	\N
0909	EL TRIUNFO	EL 	09	A	2016-10-14 11:41:16.627838-05	\N
0910	MILAGRO	MIL	09	A	2016-10-14 11:41:16.627838-05	\N
0911	NARANJAL	NAR	09	A	2016-10-14 11:41:16.627838-05	\N
0912	NARANJITO	NAR	09	A	2016-10-14 11:41:16.627838-05	\N
0913	PALESTINA	PAL	09	A	2016-10-14 11:41:16.627838-05	\N
0914	PEDRO CARBO	PED	09	A	2016-10-14 11:41:16.627838-05	\N
0916	SAMBORONDÓN	SAM	09	A	2016-10-14 11:41:16.627838-05	\N
0918	SANTA LUCÍA	SAN	09	A	2016-10-14 11:41:16.627838-05	\N
0919	SALITRE (URBINA JADO)	SAL	09	A	2016-10-14 11:41:16.627838-05	\N
0920	SAN JACINTO DE YAGUACHI	SAN	09	A	2016-10-14 11:41:16.627838-05	\N
0921	PLAYAS	PLA	09	A	2016-10-14 11:41:16.627838-05	\N
0922	SIMÓN BOLÍVAR	SIM	09	A	2016-10-14 11:41:16.627838-05	\N
0923	CORONEL MARCELINO MARIDUEÑA	COR	09	A	2016-10-14 11:41:16.627838-05	\N
0924	LOMAS DE SARGENTILLO	LOM	09	A	2016-10-14 11:41:16.627838-05	\N
0925	NOBOL	NOB	09	A	2016-10-14 11:41:16.627838-05	\N
0927	GENERAL ANTONIO ELIZALDE	GEN	09	A	2016-10-14 11:41:16.627838-05	\N
0928	ISIDRO AYORA	ISI	09	A	2016-10-14 11:41:16.627838-05	\N
1101	LOJA	LOJ	11	A	2016-10-14 11:41:16.627838-05	\N
1102	CALVAS	CAL	11	A	2016-10-14 11:41:16.627838-05	\N
1103	CATAMAYO	CAT	11	A	2016-10-14 11:41:16.627838-05	\N
1104	CELICA	CEL	11	A	2016-10-14 11:41:16.627838-05	\N
1105	CHAGUARPAMBA	CHA	11	A	2016-10-14 11:41:16.627838-05	\N
1106	ESPÍNDOLA	ESP	11	A	2016-10-14 11:41:16.627838-05	\N
1107	GONZANAMÁ	GON	11	A	2016-10-14 11:41:16.627838-05	\N
1108	MACARÁ	MAC	11	A	2016-10-14 11:41:16.627838-05	\N
1109	PALTAS	PAL	11	A	2016-10-14 11:41:16.627838-05	\N
1110	PUYANGO	PUY	11	A	2016-10-14 11:41:16.627838-05	\N
1111	SARAGURO	SAR	11	A	2016-10-14 11:41:16.627838-05	\N
1112	SOZORANGA	SOZ	11	A	2016-10-14 11:41:16.627838-05	\N
1113	ZAPOTILLO	ZAP	11	A	2016-10-14 11:41:16.627838-05	\N
1114	PINDAL	PIN	11	A	2016-10-14 11:41:16.627838-05	\N
1115	QUILANGA	QUI	11	A	2016-10-14 11:41:16.627838-05	\N
1116	OLMEDO	OLM	11	A	2016-10-14 11:41:16.627838-05	\N
1201	BABAHOYO	BAB	12	A	2016-10-14 11:41:16.627838-05	\N
1202	BABA	BAB	12	A	2016-10-14 11:41:16.627838-05	\N
1203	MONTALVO	MON	12	A	2016-10-14 11:41:16.627838-05	\N
1204	PUEBLOVIEJO	PUE	12	A	2016-10-14 11:41:16.627838-05	\N
1205	QUEVEDO	QUE	12	A	2016-10-14 11:41:16.627838-05	\N
1206	URDANETA	URD	12	A	2016-10-14 11:41:16.627838-05	\N
1207	VENTANAS	VEN	12	A	2016-10-14 11:41:16.627838-05	\N
1208	VÍNCES	VÍN	12	A	2016-10-14 11:41:16.627838-05	\N
1209	PALENQUE	PAL	12	A	2016-10-14 11:41:16.627838-05	\N
1210	BUENA FÉ	BUE	12	A	2016-10-14 11:41:16.627838-05	\N
1211	VALENCIA	VAL	12	A	2016-10-14 11:41:16.627838-05	\N
1212	MOCACHE	MOC	12	A	2016-10-14 11:41:16.627838-05	\N
1213	QUINSALOMA	QUI	12	A	2016-10-14 11:41:16.627838-05	\N
1301	PORTOVIEJO	POR	13	A	2016-10-14 11:41:16.627838-05	\N
1302	BOLÍVAR	BOL	13	A	2016-10-14 11:41:16.627838-05	\N
1303	CHONE	CHO	13	A	2016-10-14 11:41:16.627838-05	\N
1304	EL CARMEN	EL 	13	A	2016-10-14 11:41:16.627838-05	\N
1305	FLAVIO ALFARO	FLA	13	A	2016-10-14 11:41:16.627838-05	\N
1306	JIPIJAPA	JIP	13	A	2016-10-14 11:41:16.627838-05	\N
1307	JUNÍN	JUN	13	A	2016-10-14 11:41:16.627838-05	\N
1308	MANTA	MAN	13	A	2016-10-14 11:41:16.627838-05	\N
1309	MONTECRISTI	MON	13	A	2016-10-14 11:41:16.627838-05	\N
1310	PAJÁN	PAJ	13	A	2016-10-14 11:41:16.627838-05	\N
1311	PICHINCHA	PIC	13	A	2016-10-14 11:41:16.627838-05	\N
1312	ROCAFUERTE	ROC	13	A	2016-10-14 11:41:16.627838-05	\N
1313	SANTA ANA	SAN	13	A	2016-10-14 11:41:16.627838-05	\N
1314	SUCRE	SUC	13	A	2016-10-14 11:41:16.627838-05	\N
1315	TOSAGUA	TOS	13	A	2016-10-14 11:41:16.627838-05	\N
1316	24 DE MAYO	24 	13	A	2016-10-14 11:41:16.627838-05	\N
1317	PEDERNALES	PED	13	A	2016-10-14 11:41:16.627838-05	\N
1318	OLMEDO	OLM	13	A	2016-10-14 11:41:16.627838-05	\N
1319	PUERTO LÓPEZ	PUE	13	A	2016-10-14 11:41:16.627838-05	\N
1320	JAMA	JAM	13	A	2016-10-14 11:41:16.627838-05	\N
1321	JARAMIJÓ	JAR	13	A	2016-10-14 11:41:16.627838-05	\N
1322	SAN VICENTE	SAN	13	A	2016-10-14 11:41:16.627838-05	\N
1401	MORONA	MOR	14	A	2016-10-14 11:41:16.627838-05	\N
1402	GUALAQUIZA	GUA	14	A	2016-10-14 11:41:16.627838-05	\N
1403	LIMÓN INDANZA	LIM	14	A	2016-10-14 11:41:16.627838-05	\N
1404	PALORA	PAL	14	A	2016-10-14 11:41:16.627838-05	\N
1405	SANTIAGO	SAN	14	A	2016-10-14 11:41:16.627838-05	\N
1406	SUCÚA	SUC	14	A	2016-10-14 11:41:16.627838-05	\N
1407	HUAMBOYA	HUA	14	A	2016-10-14 11:41:16.627838-05	\N
1408	SAN JUAN BOSCO	SAN	14	A	2016-10-14 11:41:16.627838-05	\N
1409	TAISHA	TAI	14	A	2016-10-14 11:41:16.627838-05	\N
1410	LOGROÑO	LOG	14	A	2016-10-14 11:41:16.627838-05	\N
1411	PABLO SEXTO	PAB	14	A	2016-10-14 11:41:16.627838-05	\N
1412	TIWINTZA	TIW	14	A	2016-10-14 11:41:16.627838-05	\N
1501	TENA	TEN	15	A	2016-10-14 11:41:16.627838-05	\N
1503	ARCHIDONA	ARC	15	A	2016-10-14 11:41:16.627838-05	\N
1504	EL CHACO	EL 	15	A	2016-10-14 11:41:16.627838-05	\N
1507	QUIJOS	QUI	15	A	2016-10-14 11:41:16.627838-05	\N
1509	CARLOS JULIO AROSEMENA TOLA	CAR	15	A	2016-10-14 11:41:16.627838-05	\N
1601	PASTAZA	PAS	16	A	2016-10-14 11:41:16.627838-05	\N
1602	MERA	MER	16	A	2016-10-14 11:41:16.627838-05	\N
1603	SANTA CLARA	SAN	16	A	2016-10-14 11:41:16.627838-05	\N
1604	ARAJUNO	ARA	16	A	2016-10-14 11:41:16.627838-05	\N
1701	QUITO	QUI	17	A	2016-10-14 11:41:16.627838-05	\N
1702	CAYAMBE	CAY	17	A	2016-10-14 11:41:16.627838-05	\N
1703	MEJIA	MEJ	17	A	2016-10-14 11:41:16.627838-05	\N
1704	PEDRO MONCAYO	PED	17	A	2016-10-14 11:41:16.627838-05	\N
1705	RUMIÑAHUI	RUM	17	A	2016-10-14 11:41:16.627838-05	\N
1707	SAN MIGUEL DE LOS BANCOS	SAN	17	A	2016-10-14 11:41:16.627838-05	\N
1708	PEDRO VICENTE MALDONADO	PED	17	A	2016-10-14 11:41:16.627838-05	\N
1709	PUERTO QUITO	PUE	17	A	2016-10-14 11:41:16.627838-05	\N
1801	AMBATO	AMB	18	A	2016-10-14 11:41:16.627838-05	\N
1802	BAÑOS DE AGUA SANTA	BAÑ	18	A	2016-10-14 11:41:16.627838-05	\N
1803	CEVALLOS	CEV	18	A	2016-10-14 11:41:16.627838-05	\N
1804	MOCHA	MOC	18	A	2016-10-14 11:41:16.627838-05	\N
1805	PATATE	PAT	18	A	2016-10-14 11:41:16.627838-05	\N
1806	QUERO	QUE	18	A	2016-10-14 11:41:16.627838-05	\N
1807	SAN PEDRO DE PELILEO	SAN	18	A	2016-10-14 11:41:16.627838-05	\N
1808	SANTIAGO DE PÍLLARO	SAN	18	A	2016-10-14 11:41:16.627838-05	\N
1809	TISALEO	TIS	18	A	2016-10-14 11:41:16.627838-05	\N
1901	ZAMORA	ZAM	19	A	2016-10-14 11:41:16.627838-05	\N
1902	CHINCHIPE	CHI	19	A	2016-10-14 11:41:16.627838-05	\N
1903	NANGARITZA	NAN	19	A	2016-10-14 11:41:16.627838-05	\N
1904	YACUAMBI	YAC	19	A	2016-10-14 11:41:16.627838-05	\N
1905	YANTZAZA (YANZATZA)	YAN	19	A	2016-10-14 11:41:16.627838-05	\N
1906	EL PANGUI	EL 	19	A	2016-10-14 11:41:16.627838-05	\N
1907	CENTINELA DEL CÓNDOR	CEN	19	A	2016-10-14 11:41:16.627838-05	\N
1908	PALANDA	PAL	19	A	2016-10-14 11:41:16.627838-05	\N
1909	PAQUISHA	PAQ	19	A	2016-10-14 11:41:16.627838-05	\N
2001	SAN CRISTÓBAL	SAN	20	A	2016-10-14 11:41:16.627838-05	\N
2002	ISABELA	ISA	20	A	2016-10-14 11:41:16.627838-05	\N
2003	SANTA CRUZ	SAN	20	A	2016-10-14 11:41:16.627838-05	\N
2101	LAGO AGRIO	LAG	21	A	2016-10-14 11:41:16.627838-05	\N
2102	GONZALO PIZARRO	GON	21	A	2016-10-14 11:41:16.627838-05	\N
2103	PUTUMAYO	PUT	21	A	2016-10-14 11:41:16.627838-05	\N
2104	SHUSHUFINDI	SHU	21	A	2016-10-14 11:41:16.627838-05	\N
2105	SUCUMBÍOS	SUC	21	A	2016-10-14 11:41:16.627838-05	\N
2106	CASCALES	CAS	21	A	2016-10-14 11:41:16.627838-05	\N
2107	CUYABENO	CUY	21	A	2016-10-14 11:41:16.627838-05	\N
2201	ORELLANA	ORE	22	A	2016-10-14 11:41:16.627838-05	\N
2202	AGUARICO	AGU	22	A	2016-10-14 11:41:16.627838-05	\N
2203	LA JOYA DE LOS SACHAS	LA 	22	A	2016-10-14 11:41:16.627838-05	\N
2204	LORETO	LOR	22	A	2016-10-14 11:41:16.627838-05	\N
2301	SANTO DOMINGO	SAN	23	A	2016-10-14 11:41:16.627838-05	\N
2401	SANTA ELENA	SAN	24	A	2016-10-14 11:41:16.627838-05	\N
2402	LA LIBERTAD	LA 	24	A	2016-10-14 11:41:16.627838-05	\N
2403	SALINAS	SAL	24	A	2016-10-14 11:41:16.627838-05	\N
9001	LAS GOLONDRINAS	LAS	90	A	2016-10-14 11:41:16.627838-05	\N
9003	MANGA DEL CURA	MAN	90	A	2016-10-14 11:41:16.627838-05	\N
9004	EL PIEDRERO	EL 	90	A	2016-10-14 11:41:16.627838-05	\N
010102	CAÑARIBAMBA	CAÑ	0101	A	2016-10-14 11:41:16.627838-05	\N
010103	EL BATÁN	EL 	0101	A	2016-10-14 11:41:16.627838-05	\N
010104	EL SAGRARIO	EL 	0101	A	2016-10-14 11:41:16.627838-05	\N
010105	EL VECINO	EL 	0101	A	2016-10-14 11:41:16.627838-05	\N
010106	GIL RAMÍREZ DÁVALOS	GIL	0101	A	2016-10-14 11:41:16.627838-05	\N
010107	HUAYNACÁPAC	HUA	0101	A	2016-10-14 11:41:16.627838-05	\N
010108	MACHÁNGARA	MAC	0101	A	2016-10-14 11:41:16.627838-05	\N
010109	MONAY	MON	0101	A	2016-10-14 11:41:16.627838-05	\N
010110	SAN BLAS	SAN	0101	A	2016-10-14 11:41:16.627838-05	\N
010111	SAN SEBASTIÁN	SAN	0101	A	2016-10-14 11:41:16.627838-05	\N
010112	SUCRE	SUC	0101	A	2016-10-14 11:41:16.627838-05	\N
010113	TOTORACOCHA	TOT	0101	A	2016-10-14 11:41:16.627838-05	\N
010114	YANUNCAY	YAN	0101	A	2016-10-14 11:41:16.627838-05	\N
010115	HERMANO MIGUEL	HER	0101	A	2016-10-14 11:41:16.627838-05	\N
010150	CUENCA	CUE	0101	A	2016-10-14 11:41:16.627838-05	\N
010151	BAÑOS	BAÑ	0101	A	2016-10-14 11:41:16.627838-05	\N
010152	CUMBE	CUM	0101	A	2016-10-14 11:41:16.627838-05	\N
010153	CHAUCHA	CHA	0101	A	2016-10-14 11:41:16.627838-05	\N
010154	CHECA (JIDCAY)	CHE	0101	A	2016-10-14 11:41:16.627838-05	\N
010155	CHIQUINTAD	CHI	0101	A	2016-10-14 11:41:16.627838-05	\N
010156	LLACAO	LLA	0101	A	2016-10-14 11:41:16.627838-05	\N
010157	MOLLETURO	MOL	0101	A	2016-10-14 11:41:16.627838-05	\N
010158	NULTI	NUL	0101	A	2016-10-14 11:41:16.627838-05	\N
010159	OCTAVIO CORDERO PALACIOS (SANTA ROSA)	OCT	0101	A	2016-10-14 11:41:16.627838-05	\N
010160	PACCHA	PAC	0101	A	2016-10-14 11:41:16.627838-05	\N
010161	QUINGEO	QUI	0101	A	2016-10-14 11:41:16.627838-05	\N
010162	RICAURTE	RIC	0101	A	2016-10-14 11:41:16.627838-05	\N
010163	SAN JOAQUÍN	SAN	0101	A	2016-10-14 11:41:16.627838-05	\N
010164	SANTA ANA	SAN	0101	A	2016-10-14 11:41:16.627838-05	\N
010165	SAYAUSÍ	SAY	0101	A	2016-10-14 11:41:16.627838-05	\N
010166	SIDCAY	SID	0101	A	2016-10-14 11:41:16.627838-05	\N
010167	SININCAY	SIN	0101	A	2016-10-14 11:41:16.627838-05	\N
010168	TARQUI	TAR	0101	A	2016-10-14 11:41:16.627838-05	\N
010169	TURI	TUR	0101	A	2016-10-14 11:41:16.627838-05	\N
010170	VALLE	VAL	0101	A	2016-10-14 11:41:16.627838-05	\N
010171	VICTORIA DEL PORTETE (IRQUIS)	VIC	0101	A	2016-10-14 11:41:16.627838-05	\N
010250	GIRÓN	GIR	0102	A	2016-10-14 11:41:16.627838-05	\N
010251	ASUNCIÓN	ASU	0102	A	2016-10-14 11:41:16.627838-05	\N
010252	SAN GERARDO	SAN	0102	A	2016-10-14 11:41:16.627838-05	\N
010350	GUALACEO	GUA	0103	A	2016-10-14 11:41:16.627838-05	\N
010351	CHORDELEG	CHO	0103	A	2016-10-14 11:41:16.627838-05	\N
010352	DANIEL CÓRDOVA TORAL (EL ORIENTE)	DAN	0103	A	2016-10-14 11:41:16.627838-05	\N
010353	JADÁN	JAD	0103	A	2016-10-14 11:41:16.627838-05	\N
010354	MARIANO MORENO	MAR	0103	A	2016-10-14 11:41:16.627838-05	\N
010355	PRINCIPAL	PRI	0103	A	2016-10-14 11:41:16.627838-05	\N
010356	REMIGIO CRESPO TORAL (GÚLAG)	REM	0103	A	2016-10-14 11:41:16.627838-05	\N
010357	SAN JUAN	SAN	0103	A	2016-10-14 11:41:16.627838-05	\N
010358	ZHIDMAD	ZHI	0103	A	2016-10-14 11:41:16.627838-05	\N
010359	LUIS CORDERO VEGA	LUI	0103	A	2016-10-14 11:41:16.627838-05	\N
010360	SIMÓN BOLÍVAR (CAB. EN GAÑANZOL)	SIM	0103	A	2016-10-14 11:41:16.627838-05	\N
010450	NABÓN	NAB	0104	A	2016-10-14 11:41:16.627838-05	\N
010451	COCHAPATA	COC	0104	A	2016-10-14 11:41:16.627838-05	\N
010452	EL PROGRESO (CAB.EN ZHOTA)	EL 	0104	A	2016-10-14 11:41:16.627838-05	\N
010453	LAS NIEVES (CHAYA)	LAS	0104	A	2016-10-14 11:41:16.627838-05	\N
010454	OÑA	OÑA	0104	A	2016-10-14 11:41:16.627838-05	\N
010550	PAUTE	PAU	0105	A	2016-10-14 11:41:16.627838-05	\N
010551	AMALUZA	AMA	0105	A	2016-10-14 11:41:16.627838-05	\N
010552	BULÁN (JOSÉ VÍCTOR IZQUIERDO)	BUL	0105	A	2016-10-14 11:41:16.627838-05	\N
010553	CHICÁN (GUILLERMO ORTEGA)	CHI	0105	A	2016-10-14 11:41:16.627838-05	\N
010554	EL CABO	EL 	0105	A	2016-10-14 11:41:16.627838-05	\N
010555	GUACHAPALA	GUA	0105	A	2016-10-14 11:41:16.627838-05	\N
010556	GUARAINAG	GUA	0105	A	2016-10-14 11:41:16.627838-05	\N
010557	PALMAS	PAL	0105	A	2016-10-14 11:41:16.627838-05	\N
010558	PAN	PAN	0105	A	2016-10-14 11:41:16.627838-05	\N
010559	SAN CRISTÓBAL (CARLOS ORDÓÑEZ LAZO)	SAN	0105	A	2016-10-14 11:41:16.627838-05	\N
010560	SEVILLA DE ORO	SEV	0105	A	2016-10-14 11:41:16.627838-05	\N
010561	TOMEBAMBA	TOM	0105	A	2016-10-14 11:41:16.627838-05	\N
010562	DUG DUG	DUG	0105	A	2016-10-14 11:41:16.627838-05	\N
010650	PUCARÁ	PUC	0106	A	2016-10-14 11:41:16.627838-05	\N
010651	CAMILO PONCE ENRÍQUEZ (CAB. EN RÍO 7 DE MOLLEPONGO)	CAM	0106	A	2016-10-14 11:41:16.627838-05	\N
010652	SAN RAFAEL DE SHARUG	SAN	0106	A	2016-10-14 11:41:16.627838-05	\N
010750	SAN FERNANDO	SAN	0107	A	2016-10-14 11:41:16.627838-05	\N
010751	CHUMBLÍN	CHU	0107	A	2016-10-14 11:41:16.627838-05	\N
010850	SANTA ISABEL (CHAGUARURCO)	SAN	0108	A	2016-10-14 11:41:16.627838-05	\N
010851	ABDÓN CALDERÓN (LA UNIÓN)	ABD	0108	A	2016-10-14 11:41:16.627838-05	\N
010852	EL CARMEN DE PIJILÍ	EL 	0108	A	2016-10-14 11:41:16.627838-05	\N
010853	ZHAGLLI (SHAGLLI)	ZHA	0108	A	2016-10-14 11:41:16.627838-05	\N
010854	SAN SALVADOR DE CAÑARIBAMBA	SAN	0108	A	2016-10-14 11:41:16.627838-05	\N
010950	SIGSIG	SIG	0109	A	2016-10-14 11:41:16.627838-05	\N
010951	CUCHIL (CUTCHIL)	CUC	0109	A	2016-10-14 11:41:16.627838-05	\N
010952	GIMA	GIM	0109	A	2016-10-14 11:41:16.627838-05	\N
010953	GUEL	GUE	0109	A	2016-10-14 11:41:16.627838-05	\N
010954	LUDO	LUD	0109	A	2016-10-14 11:41:16.627838-05	\N
010955	SAN BARTOLOMÉ	SAN	0109	A	2016-10-14 11:41:16.627838-05	\N
010956	SAN JOSÉ DE RARANGA	SAN	0109	A	2016-10-14 11:41:16.627838-05	\N
011050	SAN FELIPE DE OÑA CABECERA CANTONAL	SAN	0110	A	2016-10-14 11:41:16.627838-05	\N
011051	SUSUDEL	SUS	0110	A	2016-10-14 11:41:16.627838-05	\N
011150	CHORDELEG	CHO	0111	A	2016-10-14 11:41:16.627838-05	\N
011151	PRINCIPAL	PRI	0111	A	2016-10-14 11:41:16.627838-05	\N
011152	LA UNIÓN	LA 	0111	A	2016-10-14 11:41:16.627838-05	\N
011153	LUIS GALARZA ORELLANA (CAB.EN DELEGSOL)	LUI	0111	A	2016-10-14 11:41:16.627838-05	\N
011154	SAN MARTÍN DE PUZHIO	SAN	0111	A	2016-10-14 11:41:16.627838-05	\N
011250	EL PAN	EL 	0112	A	2016-10-14 11:41:16.627838-05	\N
011251	AMALUZA	AMA	0112	A	2016-10-14 11:41:16.627838-05	\N
011252	PALMAS	PAL	0112	A	2016-10-14 11:41:16.627838-05	\N
011253	SAN VICENTE	SAN	0112	A	2016-10-14 11:41:16.627838-05	\N
011350	SEVILLA DE ORO	SEV	0113	A	2016-10-14 11:41:16.627838-05	\N
011351	AMALUZA	AMA	0113	A	2016-10-14 11:41:16.627838-05	\N
011352	PALMAS	PAL	0113	A	2016-10-14 11:41:16.627838-05	\N
011450	GUACHAPALA	GUA	0114	A	2016-10-14 11:41:16.627838-05	\N
011550	CAMILO PONCE ENRÍQUEZ	CAM	0115	A	2016-10-14 11:41:16.627838-05	\N
011551	EL CARMEN DE PIJILÍ	EL 	0115	A	2016-10-14 11:41:16.627838-05	\N
020101	ÁNGEL POLIBIO CHÁVES	ÁNG	0201	A	2016-10-14 11:41:16.627838-05	\N
020102	GABRIEL IGNACIO VEINTIMILLA	GAB	0201	A	2016-10-14 11:41:16.627838-05	\N
020103	GUANUJO	GUA	0201	A	2016-10-14 11:41:16.627838-05	\N
020150	GUARANDA	GUA	0201	A	2016-10-14 11:41:16.627838-05	\N
020151	FACUNDO VELA	FAC	0201	A	2016-10-14 11:41:16.627838-05	\N
020152	GUANUJO	GUA	0201	A	2016-10-14 11:41:16.627838-05	\N
020153	JULIO E. MORENO (CATANAHUÁN GRANDE)	JUL	0201	A	2016-10-14 11:41:16.627838-05	\N
020154	LAS NAVES	LAS	0201	A	2016-10-14 11:41:16.627838-05	\N
020155	SALINAS	SAL	0201	A	2016-10-14 11:41:16.627838-05	\N
020156	SAN LORENZO	SAN	0201	A	2016-10-14 11:41:16.627838-05	\N
020157	SAN SIMÓN (YACOTO)	SAN	0201	A	2016-10-14 11:41:16.627838-05	\N
020158	SANTA FÉ (SANTA FÉ)	SAN	0201	A	2016-10-14 11:41:16.627838-05	\N
020159	SIMIÁTUG	SIM	0201	A	2016-10-14 11:41:16.627838-05	\N
020160	SAN LUIS DE PAMBIL	SAN	0201	A	2016-10-14 11:41:16.627838-05	\N
020250	CHILLANES	CHI	0202	A	2016-10-14 11:41:16.627838-05	\N
020251	SAN JOSÉ DEL TAMBO (TAMBOPAMBA)	SAN	0202	A	2016-10-14 11:41:16.627838-05	\N
020350	SAN JOSÉ DE CHIMBO	SAN	0203	A	2016-10-14 11:41:16.627838-05	\N
020351	ASUNCIÓN (ASANCOTO)	ASU	0203	A	2016-10-14 11:41:16.627838-05	\N
020352	CALUMA	CAL	0203	A	2016-10-14 11:41:16.627838-05	\N
020353	MAGDALENA (CHAPACOTO)	MAG	0203	A	2016-10-14 11:41:16.627838-05	\N
020354	SAN SEBASTIÁN	SAN	0203	A	2016-10-14 11:41:16.627838-05	\N
020355	TELIMBELA	TEL	0203	A	2016-10-14 11:41:16.627838-05	\N
020450	ECHEANDÍA	ECH	0204	A	2016-10-14 11:41:16.627838-05	\N
020550	SAN MIGUEL	SAN	0205	A	2016-10-14 11:41:16.627838-05	\N
020551	BALSAPAMBA	BAL	0205	A	2016-10-14 11:41:16.627838-05	\N
020552	BILOVÁN	BIL	0205	A	2016-10-14 11:41:16.627838-05	\N
020553	RÉGULO DE MORA	RÉG	0205	A	2016-10-14 11:41:16.627838-05	\N
020554	SAN PABLO (SAN PABLO DE ATENAS)	SAN	0205	A	2016-10-14 11:41:16.627838-05	\N
020555	SANTIAGO	SAN	0205	A	2016-10-14 11:41:16.627838-05	\N
020556	SAN VICENTE	SAN	0205	A	2016-10-14 11:41:16.627838-05	\N
020650	CALUMA	CAL	0206	A	2016-10-14 11:41:16.627838-05	\N
020701	LAS MERCEDES	LAS	0207	A	2016-10-14 11:41:16.627838-05	\N
020702	LAS NAVES	LAS	0207	A	2016-10-14 11:41:16.627838-05	\N
020750	LAS NAVES	LAS	0207	A	2016-10-14 11:41:16.627838-05	\N
030101	AURELIO BAYAS MARTÍNEZ	AUR	0301	A	2016-10-14 11:41:16.627838-05	\N
030102	AZOGUES	AZO	0301	A	2016-10-14 11:41:16.627838-05	\N
030103	BORRERO	BOR	0301	A	2016-10-14 11:41:16.627838-05	\N
030104	SAN FRANCISCO	SAN	0301	A	2016-10-14 11:41:16.627838-05	\N
030150	AZOGUES	AZO	0301	A	2016-10-14 11:41:16.627838-05	\N
030151	COJITAMBO	COJ	0301	A	2016-10-14 11:41:16.627838-05	\N
030152	DÉLEG	DÉL	0301	A	2016-10-14 11:41:16.627838-05	\N
030153	GUAPÁN	GUA	0301	A	2016-10-14 11:41:16.627838-05	\N
030154	JAVIER LOYOLA (CHUQUIPATA)	JAV	0301	A	2016-10-14 11:41:16.627838-05	\N
030155	LUIS CORDERO	LUI	0301	A	2016-10-14 11:41:16.627838-05	\N
030156	PINDILIG	PIN	0301	A	2016-10-14 11:41:16.627838-05	\N
030157	RIVERA	RIV	0301	A	2016-10-14 11:41:16.627838-05	\N
030158	SAN MIGUEL	SAN	0301	A	2016-10-14 11:41:16.627838-05	\N
030159	SOLANO	SOL	0301	A	2016-10-14 11:41:16.627838-05	\N
030160	TADAY	TAD	0301	A	2016-10-14 11:41:16.627838-05	\N
030250	BIBLIÁN	BIB	0302	A	2016-10-14 11:41:16.627838-05	\N
030251	NAZÓN (CAB. EN PAMPA DE DOMÍNGUEZ)	NAZ	0302	A	2016-10-14 11:41:16.627838-05	\N
030252	SAN FRANCISCO DE SAGEO	SAN	0302	A	2016-10-14 11:41:16.627838-05	\N
030253	TURUPAMBA	TUR	0302	A	2016-10-14 11:41:16.627838-05	\N
030254	JERUSALÉN	JER	0302	A	2016-10-14 11:41:16.627838-05	\N
030350	CAÑAR	CAÑ	0303	A	2016-10-14 11:41:16.627838-05	\N
030351	CHONTAMARCA	CHO	0303	A	2016-10-14 11:41:16.627838-05	\N
030352	CHOROCOPTE	CHO	0303	A	2016-10-14 11:41:16.627838-05	\N
030353	GENERAL MORALES (SOCARTE)	GEN	0303	A	2016-10-14 11:41:16.627838-05	\N
030354	GUALLETURO	GUA	0303	A	2016-10-14 11:41:16.627838-05	\N
030355	HONORATO VÁSQUEZ (TAMBO VIEJO)	HON	0303	A	2016-10-14 11:41:16.627838-05	\N
030356	INGAPIRCA	ING	0303	A	2016-10-14 11:41:16.627838-05	\N
030357	JUNCAL	JUN	0303	A	2016-10-14 11:41:16.627838-05	\N
030358	SAN ANTONIO	SAN	0303	A	2016-10-14 11:41:16.627838-05	\N
030359	SUSCAL	SUS	0303	A	2016-10-14 11:41:16.627838-05	\N
030360	TAMBO	TAM	0303	A	2016-10-14 11:41:16.627838-05	\N
030361	ZHUD	ZHU	0303	A	2016-10-14 11:41:16.627838-05	\N
030362	VENTURA	VEN	0303	A	2016-10-14 11:41:16.627838-05	\N
030363	DUCUR	DUC	0303	A	2016-10-14 11:41:16.627838-05	\N
030450	LA TRONCAL	LA 	0304	A	2016-10-14 11:41:16.627838-05	\N
030451	MANUEL J. CALLE	MAN	0304	A	2016-10-14 11:41:16.627838-05	\N
030452	PANCHO NEGRO	PAN	0304	A	2016-10-14 11:41:16.627838-05	\N
030550	EL TAMBO	EL 	0305	A	2016-10-14 11:41:16.627838-05	\N
030650	DÉLEG	DÉL	0306	A	2016-10-14 11:41:16.627838-05	\N
030651	SOLANO	SOL	0306	A	2016-10-14 11:41:16.627838-05	\N
030750	SUSCAL	SUS	0307	A	2016-10-14 11:41:16.627838-05	\N
040101	GONZÁLEZ SUÁREZ	GON	0401	A	2016-10-14 11:41:16.627838-05	\N
040102	TULCÁN	TUL	0401	A	2016-10-14 11:41:16.627838-05	\N
040150	TULCÁN	TUL	0401	A	2016-10-14 11:41:16.627838-05	\N
040151	EL CARMELO (EL PUN)	EL 	0401	A	2016-10-14 11:41:16.627838-05	\N
040152	HUACA	HUA	0401	A	2016-10-14 11:41:16.627838-05	\N
040153	JULIO ANDRADE (OREJUELA)	JUL	0401	A	2016-10-14 11:41:16.627838-05	\N
040154	MALDONADO	MAL	0401	A	2016-10-14 11:41:16.627838-05	\N
040155	PIOTER	PIO	0401	A	2016-10-14 11:41:16.627838-05	\N
040156	TOBAR DONOSO (LA BOCANA DE CAMUMBÍ)	TOB	0401	A	2016-10-14 11:41:16.627838-05	\N
040157	TUFIÑO	TUF	0401	A	2016-10-14 11:41:16.627838-05	\N
040158	URBINA (TAYA)	URB	0401	A	2016-10-14 11:41:16.627838-05	\N
040159	EL CHICAL	EL 	0401	A	2016-10-14 11:41:16.627838-05	\N
040160	MARISCAL SUCRE	MAR	0401	A	2016-10-14 11:41:16.627838-05	\N
040161	SANTA MARTHA DE CUBA	SAN	0401	A	2016-10-14 11:41:16.627838-05	\N
040250	BOLÍVAR	BOL	0402	A	2016-10-14 11:41:16.627838-05	\N
040251	GARCÍA MORENO	GAR	0402	A	2016-10-14 11:41:16.627838-05	\N
040252	LOS ANDES	LOS	0402	A	2016-10-14 11:41:16.627838-05	\N
040253	MONTE OLIVO	MON	0402	A	2016-10-14 11:41:16.627838-05	\N
040254	SAN VICENTE DE PUSIR	SAN	0402	A	2016-10-14 11:41:16.627838-05	\N
040255	SAN RAFAEL	SAN	0402	A	2016-10-14 11:41:16.627838-05	\N
040301	EL ÁNGEL	EL 	0403	A	2016-10-14 11:41:16.627838-05	\N
040302	27 DE SEPTIEMBRE	27 	0403	A	2016-10-14 11:41:16.627838-05	\N
040350	EL ANGEL	EL 	0403	A	2016-10-14 11:41:16.627838-05	\N
040351	EL GOALTAL	EL 	0403	A	2016-10-14 11:41:16.627838-05	\N
040352	LA LIBERTAD (ALIZO)	LA 	0403	A	2016-10-14 11:41:16.627838-05	\N
040353	SAN ISIDRO	SAN	0403	A	2016-10-14 11:41:16.627838-05	\N
040450	MIRA (CHONTAHUASI)	MIR	0404	A	2016-10-14 11:41:16.627838-05	\N
040451	CONCEPCIÓN	CON	0404	A	2016-10-14 11:41:16.627838-05	\N
040452	JIJÓN Y CAAMAÑO (CAB. EN RÍO BLANCO)	JIJ	0404	A	2016-10-14 11:41:16.627838-05	\N
040453	JUAN MONTALVO (SAN IGNACIO DE QUIL)	JUA	0404	A	2016-10-14 11:41:16.627838-05	\N
040501	GONZÁLEZ SUÁREZ	GON	0405	A	2016-10-14 11:41:16.627838-05	\N
040502	SAN JOSÉ	SAN	0405	A	2016-10-14 11:41:16.627838-05	\N
040550	SAN GABRIEL	SAN	0405	A	2016-10-14 11:41:16.627838-05	\N
040551	CRISTÓBAL COLÓN	CRI	0405	A	2016-10-14 11:41:16.627838-05	\N
040552	CHITÁN DE NAVARRETE	CHI	0405	A	2016-10-14 11:41:16.627838-05	\N
040553	FERNÁNDEZ SALVADOR	FER	0405	A	2016-10-14 11:41:16.627838-05	\N
040554	LA PAZ	LA 	0405	A	2016-10-14 11:41:16.627838-05	\N
040555	PIARTAL	PIA	0405	A	2016-10-14 11:41:16.627838-05	\N
040650	HUACA	HUA	0406	A	2016-10-14 11:41:16.627838-05	\N
040651	MARISCAL SUCRE	MAR	0406	A	2016-10-14 11:41:16.627838-05	\N
050101	ELOY ALFARO (SAN FELIPE)	ELO	0501	A	2016-10-14 11:41:16.627838-05	\N
050102	IGNACIO FLORES (PARQUE FLORES)	IGN	0501	A	2016-10-14 11:41:16.627838-05	\N
050103	JUAN MONTALVO (SAN SEBASTIÁN)	JUA	0501	A	2016-10-14 11:41:16.627838-05	\N
050104	LA MATRIZ	LA 	0501	A	2016-10-14 11:41:16.627838-05	\N
050105	SAN BUENAVENTURA	SAN	0501	A	2016-10-14 11:41:16.627838-05	\N
050150	LATACUNGA	LAT	0501	A	2016-10-14 11:41:16.627838-05	\N
050151	ALAQUES (ALÁQUEZ)	ALA	0501	A	2016-10-14 11:41:16.627838-05	\N
050152	BELISARIO QUEVEDO (GUANAILÍN)	BEL	0501	A	2016-10-14 11:41:16.627838-05	\N
050153	GUAITACAMA (GUAYTACAMA)	GUA	0501	A	2016-10-14 11:41:16.627838-05	\N
050154	JOSEGUANGO BAJO	JOS	0501	A	2016-10-14 11:41:16.627838-05	\N
050155	LAS PAMPAS	LAS	0501	A	2016-10-14 11:41:16.627838-05	\N
050156	MULALÓ	MUL	0501	A	2016-10-14 11:41:16.627838-05	\N
050157	11 DE NOVIEMBRE (ILINCHISI)	11 	0501	A	2016-10-14 11:41:16.627838-05	\N
050158	POALÓ	POA	0501	A	2016-10-14 11:41:16.627838-05	\N
050159	SAN JUAN DE PASTOCALLE	SAN	0501	A	2016-10-14 11:41:16.627838-05	\N
050160	SIGCHOS	SIG	0501	A	2016-10-14 11:41:16.627838-05	\N
050161	TANICUCHÍ	TAN	0501	A	2016-10-14 11:41:16.627838-05	\N
050162	TOACASO	TOA	0501	A	2016-10-14 11:41:16.627838-05	\N
050163	PALO QUEMADO	PAL	0501	A	2016-10-14 11:41:16.627838-05	\N
050201	EL CARMEN	EL 	0502	A	2016-10-14 11:41:16.627838-05	\N
050202	LA MANÁ	LA 	0502	A	2016-10-14 11:41:16.627838-05	\N
050203	EL TRIUNFO	EL 	0502	A	2016-10-14 11:41:16.627838-05	\N
050250	LA MANÁ	LA 	0502	A	2016-10-14 11:41:16.627838-05	\N
050251	GUASAGANDA (CAB.EN GUASAGANDA	GUA	0502	A	2016-10-14 11:41:16.627838-05	\N
050252	PUCAYACU	PUC	0502	A	2016-10-14 11:41:16.627838-05	\N
050350	EL CORAZÓN	EL 	0503	A	2016-10-14 11:41:16.627838-05	\N
050351	MORASPUNGO	MOR	0503	A	2016-10-14 11:41:16.627838-05	\N
050352	PINLLOPATA	PIN	0503	A	2016-10-14 11:41:16.627838-05	\N
050353	RAMÓN CAMPAÑA	RAM	0503	A	2016-10-14 11:41:16.627838-05	\N
050450	PUJILÍ	PUJ	0504	A	2016-10-14 11:41:16.627838-05	\N
050451	ANGAMARCA	ANG	0504	A	2016-10-14 11:41:16.627838-05	\N
050452	CHUCCHILÁN (CHUGCHILÁN)	CHU	0504	A	2016-10-14 11:41:16.627838-05	\N
050453	GUANGAJE	GUA	0504	A	2016-10-14 11:41:16.627838-05	\N
050454	ISINLIBÍ (ISINLIVÍ)	ISI	0504	A	2016-10-14 11:41:16.627838-05	\N
050455	LA VICTORIA	LA 	0504	A	2016-10-14 11:41:16.627838-05	\N
050456	PILALÓ	PIL	0504	A	2016-10-14 11:41:16.627838-05	\N
050457	TINGO	TIN	0504	A	2016-10-14 11:41:16.627838-05	\N
050458	ZUMBAHUA	ZUM	0504	A	2016-10-14 11:41:16.627838-05	\N
050550	SAN MIGUEL	SAN	0505	A	2016-10-14 11:41:16.627838-05	\N
050551	ANTONIO JOSÉ HOLGUÍN (SANTA LUCÍA)	ANT	0505	A	2016-10-14 11:41:16.627838-05	\N
050552	CUSUBAMBA	CUS	0505	A	2016-10-14 11:41:16.627838-05	\N
050553	MULALILLO	MUL	0505	A	2016-10-14 11:41:16.627838-05	\N
050554	MULLIQUINDIL (SANTA ANA)	MUL	0505	A	2016-10-14 11:41:16.627838-05	\N
050555	PANSALEO	PAN	0505	A	2016-10-14 11:41:16.627838-05	\N
050650	SAQUISILÍ	SAQ	0506	A	2016-10-14 11:41:16.627838-05	\N
050651	CANCHAGUA	CAN	0506	A	2016-10-14 11:41:16.627838-05	\N
050652	CHANTILÍN	CHA	0506	A	2016-10-14 11:41:16.627838-05	\N
050653	COCHAPAMBA	COC	0506	A	2016-10-14 11:41:16.627838-05	\N
050750	SIGCHOS	SIG	0507	A	2016-10-14 11:41:16.627838-05	\N
050751	CHUGCHILLÁN	CHU	0507	A	2016-10-14 11:41:16.627838-05	\N
050752	ISINLIVÍ	ISI	0507	A	2016-10-14 11:41:16.627838-05	\N
050753	LAS PAMPAS	LAS	0507	A	2016-10-14 11:41:16.627838-05	\N
050754	PALO QUEMADO	PAL	0507	A	2016-10-14 11:41:16.627838-05	\N
060101	LIZARZABURU	LIZ	0601	A	2016-10-14 11:41:16.627838-05	\N
060102	MALDONADO	MAL	0601	A	2016-10-14 11:41:16.627838-05	\N
060103	VELASCO	VEL	0601	A	2016-10-14 11:41:16.627838-05	\N
060104	VELOZ	VEL	0601	A	2016-10-14 11:41:16.627838-05	\N
060105	YARUQUÍES	YAR	0601	A	2016-10-14 11:41:16.627838-05	\N
060150	RIOBAMBA	RIO	0601	A	2016-10-14 11:41:16.627838-05	\N
060151	CACHA (CAB. EN MACHÁNGARA)	CAC	0601	A	2016-10-14 11:41:16.627838-05	\N
060152	CALPI	CAL	0601	A	2016-10-14 11:41:16.627838-05	\N
060153	CUBIJÍES	CUB	0601	A	2016-10-14 11:41:16.627838-05	\N
060154	FLORES	FLO	0601	A	2016-10-14 11:41:16.627838-05	\N
060155	LICÁN	LIC	0601	A	2016-10-14 11:41:16.627838-05	\N
060156	LICTO	LIC	0601	A	2016-10-14 11:41:16.627838-05	\N
060157	PUNGALÁ	PUN	0601	A	2016-10-14 11:41:16.627838-05	\N
060158	PUNÍN	PUN	0601	A	2016-10-14 11:41:16.627838-05	\N
060159	QUIMIAG	QUI	0601	A	2016-10-14 11:41:16.627838-05	\N
060160	SAN JUAN	SAN	0601	A	2016-10-14 11:41:16.627838-05	\N
060161	SAN LUIS	SAN	0601	A	2016-10-14 11:41:16.627838-05	\N
060250	ALAUSÍ	ALA	0602	A	2016-10-14 11:41:16.627838-05	\N
060251	ACHUPALLAS	ACH	0602	A	2016-10-14 11:41:16.627838-05	\N
060252	CUMANDÁ	CUM	0602	A	2016-10-14 11:41:16.627838-05	\N
060253	GUASUNTOS	GUA	0602	A	2016-10-14 11:41:16.627838-05	\N
060254	HUIGRA	HUI	0602	A	2016-10-14 11:41:16.627838-05	\N
060255	MULTITUD	MUL	0602	A	2016-10-14 11:41:16.627838-05	\N
060256	PISTISHÍ (NARIZ DEL DIABLO)	PIS	0602	A	2016-10-14 11:41:16.627838-05	\N
060257	PUMALLACTA	PUM	0602	A	2016-10-14 11:41:16.627838-05	\N
060258	SEVILLA	SEV	0602	A	2016-10-14 11:41:16.627838-05	\N
060259	SIBAMBE	SIB	0602	A	2016-10-14 11:41:16.627838-05	\N
060260	TIXÁN	TIX	0602	A	2016-10-14 11:41:16.627838-05	\N
060301	CAJABAMBA	CAJ	0603	A	2016-10-14 11:41:16.627838-05	\N
060302	SICALPA	SIC	0603	A	2016-10-14 11:41:16.627838-05	\N
060350	VILLA LA UNIÓN (CAJABAMBA)	VIL	0603	A	2016-10-14 11:41:16.627838-05	\N
060351	CAÑI	CAÑ	0603	A	2016-10-14 11:41:16.627838-05	\N
060352	COLUMBE	COL	0603	A	2016-10-14 11:41:16.627838-05	\N
060353	JUAN DE VELASCO (PANGOR)	JUA	0603	A	2016-10-14 11:41:16.627838-05	\N
060354	SANTIAGO DE QUITO (CAB. EN SAN ANTONIO DE QUITO)	SAN	0603	A	2016-10-14 11:41:16.627838-05	\N
060450	CHAMBO	CHA	0604	A	2016-10-14 11:41:16.627838-05	\N
060550	CHUNCHI	CHU	0605	A	2016-10-14 11:41:16.627838-05	\N
060551	CAPZOL	CAP	0605	A	2016-10-14 11:41:16.627838-05	\N
060552	COMPUD	COM	0605	A	2016-10-14 11:41:16.627838-05	\N
060553	GONZOL	GON	0605	A	2016-10-14 11:41:16.627838-05	\N
060554	LLAGOS	LLA	0605	A	2016-10-14 11:41:16.627838-05	\N
060650	GUAMOTE	GUA	0606	A	2016-10-14 11:41:16.627838-05	\N
060651	CEBADAS	CEB	0606	A	2016-10-14 11:41:16.627838-05	\N
060652	PALMIRA	PAL	0606	A	2016-10-14 11:41:16.627838-05	\N
060701	EL ROSARIO	EL 	0607	A	2016-10-14 11:41:16.627838-05	\N
060702	LA MATRIZ	LA 	0607	A	2016-10-14 11:41:16.627838-05	\N
060750	GUANO	GUA	0607	A	2016-10-14 11:41:16.627838-05	\N
060751	GUANANDO	GUA	0607	A	2016-10-14 11:41:16.627838-05	\N
060752	ILAPO	ILA	0607	A	2016-10-14 11:41:16.627838-05	\N
060753	LA PROVIDENCIA	LA 	0607	A	2016-10-14 11:41:16.627838-05	\N
060754	SAN ANDRÉS	SAN	0607	A	2016-10-14 11:41:16.627838-05	\N
060755	SAN GERARDO DE PACAICAGUÁN	SAN	0607	A	2016-10-14 11:41:16.627838-05	\N
060756	SAN ISIDRO DE PATULÚ	SAN	0607	A	2016-10-14 11:41:16.627838-05	\N
060757	SAN JOSÉ DEL CHAZO	SAN	0607	A	2016-10-14 11:41:16.627838-05	\N
060758	SANTA FÉ DE GALÁN	SAN	0607	A	2016-10-14 11:41:16.627838-05	\N
060759	VALPARAÍSO	VAL	0607	A	2016-10-14 11:41:16.627838-05	\N
060850	PALLATANGA	PAL	0608	A	2016-10-14 11:41:16.627838-05	\N
060950	PENIPE	PEN	0609	A	2016-10-14 11:41:16.627838-05	\N
060951	EL ALTAR	EL 	0609	A	2016-10-14 11:41:16.627838-05	\N
060952	MATUS	MAT	0609	A	2016-10-14 11:41:16.627838-05	\N
060953	PUELA	PUE	0609	A	2016-10-14 11:41:16.627838-05	\N
060954	SAN ANTONIO DE BAYUSHIG	SAN	0609	A	2016-10-14 11:41:16.627838-05	\N
060955	LA CANDELARIA	LA 	0609	A	2016-10-14 11:41:16.627838-05	\N
060956	BILBAO (CAB.EN QUILLUYACU)	BIL	0609	A	2016-10-14 11:41:16.627838-05	\N
061050	CUMANDÁ	CUM	0610	A	2016-10-14 11:41:16.627838-05	\N
070101	LA PROVIDENCIA	LA 	0701	A	2016-10-14 11:41:16.627838-05	\N
070102	MACHALA	MAC	0701	A	2016-10-14 11:41:16.627838-05	\N
070103	PUERTO BOLÍVAR	PUE	0701	A	2016-10-14 11:41:16.627838-05	\N
070104	NUEVE DE MAYO	NUE	0701	A	2016-10-14 11:41:16.627838-05	\N
070105	EL CAMBIO	EL 	0701	A	2016-10-14 11:41:16.627838-05	\N
070150	MACHALA	MAC	0701	A	2016-10-14 11:41:16.627838-05	\N
070151	EL CAMBIO	EL 	0701	A	2016-10-14 11:41:16.627838-05	\N
070152	EL RETIRO	EL 	0701	A	2016-10-14 11:41:16.627838-05	\N
070250	ARENILLAS	ARE	0702	A	2016-10-14 11:41:16.627838-05	\N
070251	CHACRAS	CHA	0702	A	2016-10-14 11:41:16.627838-05	\N
070252	LA LIBERTAD	LA 	0702	A	2016-10-14 11:41:16.627838-05	\N
070253	LAS LAJAS (CAB. EN LA VICTORIA)	LAS	0702	A	2016-10-14 11:41:16.627838-05	\N
070254	PALMALES	PAL	0702	A	2016-10-14 11:41:16.627838-05	\N
070255	CARCABÓN	CAR	0702	A	2016-10-14 11:41:16.627838-05	\N
070350	PACCHA	PAC	0703	A	2016-10-14 11:41:16.627838-05	\N
070351	AYAPAMBA	AYA	0703	A	2016-10-14 11:41:16.627838-05	\N
070352	CORDONCILLO	COR	0703	A	2016-10-14 11:41:16.627838-05	\N
070353	MILAGRO	MIL	0703	A	2016-10-14 11:41:16.627838-05	\N
070354	SAN JOSÉ	SAN	0703	A	2016-10-14 11:41:16.627838-05	\N
070355	SAN JUAN DE CERRO AZUL	SAN	0703	A	2016-10-14 11:41:16.627838-05	\N
070450	BALSAS	BAL	0704	A	2016-10-14 11:41:16.627838-05	\N
070451	BELLAMARÍA	BEL	0704	A	2016-10-14 11:41:16.627838-05	\N
070550	CHILLA	CHI	0705	A	2016-10-14 11:41:16.627838-05	\N
070650	EL GUABO	EL 	0706	A	2016-10-14 11:41:16.627838-05	\N
070651	BARBONES (SUCRE)	BAR	0706	A	2016-10-14 11:41:16.627838-05	\N
070652	LA IBERIA	LA 	0706	A	2016-10-14 11:41:16.627838-05	\N
070653	TENDALES (CAB.EN PUERTO TENDALES)	TEN	0706	A	2016-10-14 11:41:16.627838-05	\N
070654	RÍO BONITO	RÍO	0706	A	2016-10-14 11:41:16.627838-05	\N
070701	ECUADOR	ECU	0707	A	2016-10-14 11:41:16.627838-05	\N
070702	EL PARAÍSO	EL 	0707	A	2016-10-14 11:41:16.627838-05	\N
070703	HUALTACO	HUA	0707	A	2016-10-14 11:41:16.627838-05	\N
070704	MILTON REYES	MIL	0707	A	2016-10-14 11:41:16.627838-05	\N
070705	UNIÓN LOJANA	UNI	0707	A	2016-10-14 11:41:16.627838-05	\N
070750	HUAQUILLAS	HUA	0707	A	2016-10-14 11:41:16.627838-05	\N
070850	MARCABELÍ	MAR	0708	A	2016-10-14 11:41:16.627838-05	\N
070851	EL INGENIO	EL 	0708	A	2016-10-14 11:41:16.627838-05	\N
070901	BOLÍVAR	BOL	0709	A	2016-10-14 11:41:16.627838-05	\N
070902	LOMA DE FRANCO	LOM	0709	A	2016-10-14 11:41:16.627838-05	\N
070903	OCHOA LEÓN (MATRIZ)	OCH	0709	A	2016-10-14 11:41:16.627838-05	\N
070904	TRES CERRITOS	TRE	0709	A	2016-10-14 11:41:16.627838-05	\N
070950	PASAJE	PAS	0709	A	2016-10-14 11:41:16.627838-05	\N
070951	BUENAVISTA	BUE	0709	A	2016-10-14 11:41:16.627838-05	\N
070952	CASACAY	CAS	0709	A	2016-10-14 11:41:16.627838-05	\N
070953	LA PEAÑA	LA 	0709	A	2016-10-14 11:41:16.627838-05	\N
070954	PROGRESO	PRO	0709	A	2016-10-14 11:41:16.627838-05	\N
070955	UZHCURRUMI	UZH	0709	A	2016-10-14 11:41:16.627838-05	\N
070956	CAÑAQUEMADA	CAÑ	0709	A	2016-10-14 11:41:16.627838-05	\N
071001	LA MATRIZ	LA 	0710	A	2016-10-14 11:41:16.627838-05	\N
071002	LA SUSAYA	LA 	0710	A	2016-10-14 11:41:16.627838-05	\N
071003	PIÑAS GRANDE	PIÑ	0710	A	2016-10-14 11:41:16.627838-05	\N
071050	PIÑAS	PIÑ	0710	A	2016-10-14 11:41:16.627838-05	\N
071051	CAPIRO (CAB. EN LA CAPILLA DE CAPIRO)	CAP	0710	A	2016-10-14 11:41:16.627838-05	\N
071052	LA BOCANA	LA 	0710	A	2016-10-14 11:41:16.627838-05	\N
071053	MOROMORO (CAB. EN EL VADO)	MOR	0710	A	2016-10-14 11:41:16.627838-05	\N
071054	PIEDRAS	PIE	0710	A	2016-10-14 11:41:16.627838-05	\N
071055	SAN ROQUE (AMBROSIO MALDONADO)	SAN	0710	A	2016-10-14 11:41:16.627838-05	\N
071056	SARACAY	SAR	0710	A	2016-10-14 11:41:16.627838-05	\N
071150	PORTOVELO	POR	0711	A	2016-10-14 11:41:16.627838-05	\N
071151	CURTINCAPA	CUR	0711	A	2016-10-14 11:41:16.627838-05	\N
071152	MORALES	MOR	0711	A	2016-10-14 11:41:16.627838-05	\N
071153	SALATÍ	SAL	0711	A	2016-10-14 11:41:16.627838-05	\N
071201	SANTA ROSA	SAN	0712	A	2016-10-14 11:41:16.627838-05	\N
071202	PUERTO JELÍ	PUE	0712	A	2016-10-14 11:41:16.627838-05	\N
071203	BALNEARIO JAMBELÍ (SATÉLITE)	BAL	0712	A	2016-10-14 11:41:16.627838-05	\N
071204	JUMÓN (SATÉLITE)	JUM	0712	A	2016-10-14 11:41:16.627838-05	\N
071205	NUEVO SANTA ROSA	NUE	0712	A	2016-10-14 11:41:16.627838-05	\N
071250	SANTA ROSA	SAN	0712	A	2016-10-14 11:41:16.627838-05	\N
071251	BELLAVISTA	BEL	0712	A	2016-10-14 11:41:16.627838-05	\N
071252	JAMBELÍ	JAM	0712	A	2016-10-14 11:41:16.627838-05	\N
071253	LA AVANZADA	LA 	0712	A	2016-10-14 11:41:16.627838-05	\N
071254	SAN ANTONIO	SAN	0712	A	2016-10-14 11:41:16.627838-05	\N
071255	TORATA	TOR	0712	A	2016-10-14 11:41:16.627838-05	\N
071256	VICTORIA	VIC	0712	A	2016-10-14 11:41:16.627838-05	\N
071257	BELLAMARÍA	BEL	0712	A	2016-10-14 11:41:16.627838-05	\N
071350	ZARUMA	ZAR	0713	A	2016-10-14 11:41:16.627838-05	\N
071351	ABAÑÍN	ABA	0713	A	2016-10-14 11:41:16.627838-05	\N
071352	ARCAPAMBA	ARC	0713	A	2016-10-14 11:41:16.627838-05	\N
071353	GUANAZÁN	GUA	0713	A	2016-10-14 11:41:16.627838-05	\N
071354	GUIZHAGUIÑA	GUI	0713	A	2016-10-14 11:41:16.627838-05	\N
071355	HUERTAS	HUE	0713	A	2016-10-14 11:41:16.627838-05	\N
071356	MALVAS	MAL	0713	A	2016-10-14 11:41:16.627838-05	\N
071357	MULUNCAY GRANDE	MUL	0713	A	2016-10-14 11:41:16.627838-05	\N
071358	SINSAO	SIN	0713	A	2016-10-14 11:41:16.627838-05	\N
071359	SALVIAS	SAL	0713	A	2016-10-14 11:41:16.627838-05	\N
071401	LA VICTORIA	LA 	0714	A	2016-10-14 11:41:16.627838-05	\N
071402	PLATANILLOS	PLA	0714	A	2016-10-14 11:41:16.627838-05	\N
071403	VALLE HERMOSO	VAL	0714	A	2016-10-14 11:41:16.627838-05	\N
071450	LA VICTORIA	LA 	0714	A	2016-10-14 11:41:16.627838-05	\N
071451	LA LIBERTAD	LA 	0714	A	2016-10-14 11:41:16.627838-05	\N
071452	EL PARAÍSO	EL 	0714	A	2016-10-14 11:41:16.627838-05	\N
071453	SAN ISIDRO	SAN	0714	A	2016-10-14 11:41:16.627838-05	\N
080101	BARTOLOMÉ RUIZ (CÉSAR FRANCO CARRIÓN)	BAR	0801	A	2016-10-14 11:41:16.627838-05	\N
080102	5 DE AGOSTO	5 D	0801	A	2016-10-14 11:41:16.627838-05	\N
080103	ESMERALDAS	ESM	0801	A	2016-10-14 11:41:16.627838-05	\N
080104	LUIS TELLO (LAS PALMAS)	LUI	0801	A	2016-10-14 11:41:16.627838-05	\N
080105	SIMÓN PLATA TORRES	SIM	0801	A	2016-10-14 11:41:16.627838-05	\N
080150	ESMERALDAS	ESM	0801	A	2016-10-14 11:41:16.627838-05	\N
080151	ATACAMES	ATA	0801	A	2016-10-14 11:41:16.627838-05	\N
080152	CAMARONES (CAB. EN SAN VICENTE)	CAM	0801	A	2016-10-14 11:41:16.627838-05	\N
080153	CRNEL. CARLOS CONCHA TORRES (CAB.EN HUELE)	CRN	0801	A	2016-10-14 11:41:16.627838-05	\N
080154	CHINCA	CHI	0801	A	2016-10-14 11:41:16.627838-05	\N
080155	CHONTADURO	CHO	0801	A	2016-10-14 11:41:16.627838-05	\N
080156	CHUMUNDÉ	CHU	0801	A	2016-10-14 11:41:16.627838-05	\N
080157	LAGARTO	LAG	0801	A	2016-10-14 11:41:16.627838-05	\N
080158	LA UNIÓN	LA 	0801	A	2016-10-14 11:41:16.627838-05	\N
080159	MAJUA	MAJ	0801	A	2016-10-14 11:41:16.627838-05	\N
080160	MONTALVO (CAB. EN HORQUETA)	MON	0801	A	2016-10-14 11:41:16.627838-05	\N
080161	RÍO VERDE	RÍO	0801	A	2016-10-14 11:41:16.627838-05	\N
080162	ROCAFUERTE	ROC	0801	A	2016-10-14 11:41:16.627838-05	\N
080163	SAN MATEO	SAN	0801	A	2016-10-14 11:41:16.627838-05	\N
080164	SÚA (CAB. EN LA BOCANA)	SÚA	0801	A	2016-10-14 11:41:16.627838-05	\N
080165	TABIAZO	TAB	0801	A	2016-10-14 11:41:16.627838-05	\N
080166	TACHINA	TAC	0801	A	2016-10-14 11:41:16.627838-05	\N
080167	TONCHIGÜE	TON	0801	A	2016-10-14 11:41:16.627838-05	\N
080168	VUELTA LARGA	VUE	0801	A	2016-10-14 11:41:16.627838-05	\N
080250	VALDEZ (LIMONES)	VAL	0802	A	2016-10-14 11:41:16.627838-05	\N
080251	ANCHAYACU	ANC	0802	A	2016-10-14 11:41:16.627838-05	\N
080252	ATAHUALPA (CAB. EN CAMARONES)	ATA	0802	A	2016-10-14 11:41:16.627838-05	\N
080253	BORBÓN	BOR	0802	A	2016-10-14 11:41:16.627838-05	\N
080254	LA TOLA	LA 	0802	A	2016-10-14 11:41:16.627838-05	\N
080255	LUIS VARGAS TORRES (CAB. EN PLAYA DE ORO)	LUI	0802	A	2016-10-14 11:41:16.627838-05	\N
080256	MALDONADO	MAL	0802	A	2016-10-14 11:41:16.627838-05	\N
080257	PAMPANAL DE BOLÍVAR	PAM	0802	A	2016-10-14 11:41:16.627838-05	\N
080258	SAN FRANCISCO DE ONZOLE	SAN	0802	A	2016-10-14 11:41:16.627838-05	\N
080259	SANTO DOMINGO DE ONZOLE	SAN	0802	A	2016-10-14 11:41:16.627838-05	\N
080260	SELVA ALEGRE	SEL	0802	A	2016-10-14 11:41:16.627838-05	\N
080261	TELEMBÍ	TEL	0802	A	2016-10-14 11:41:16.627838-05	\N
080262	COLÓN ELOY DEL MARÍA	COL	0802	A	2016-10-14 11:41:16.627838-05	\N
080263	SAN JOSÉ DE CAYAPAS	SAN	0802	A	2016-10-14 11:41:16.627838-05	\N
080264	TIMBIRÉ	TIM	0802	A	2016-10-14 11:41:16.627838-05	\N
080350	MUISNE	MUI	0803	A	2016-10-14 11:41:16.627838-05	\N
080351	BOLÍVAR	BOL	0803	A	2016-10-14 11:41:16.627838-05	\N
080352	DAULE	DAU	0803	A	2016-10-14 11:41:16.627838-05	\N
080353	GALERA	GAL	0803	A	2016-10-14 11:41:16.627838-05	\N
080354	QUINGUE (OLMEDO PERDOMO FRANCO)	QUI	0803	A	2016-10-14 11:41:16.627838-05	\N
080355	SALIMA	SAL	0803	A	2016-10-14 11:41:16.627838-05	\N
080356	SAN FRANCISCO	SAN	0803	A	2016-10-14 11:41:16.627838-05	\N
080357	SAN GREGORIO	SAN	0803	A	2016-10-14 11:41:16.627838-05	\N
080358	SAN JOSÉ DE CHAMANGA (CAB.EN CHAMANGA)	SAN	0803	A	2016-10-14 11:41:16.627838-05	\N
080450	ROSA ZÁRATE (QUININDÉ)	ROS	0804	A	2016-10-14 11:41:16.627838-05	\N
080451	CUBE	CUB	0804	A	2016-10-14 11:41:16.627838-05	\N
080452	CHURA (CHANCAMA) (CAB. EN EL YERBERO)	CHU	0804	A	2016-10-14 11:41:16.627838-05	\N
080453	MALIMPIA	MAL	0804	A	2016-10-14 11:41:16.627838-05	\N
080454	VICHE	VIC	0804	A	2016-10-14 11:41:16.627838-05	\N
080455	LA UNIÓN	LA 	0804	A	2016-10-14 11:41:16.627838-05	\N
080550	SAN LORENZO	SAN	0805	A	2016-10-14 11:41:16.627838-05	\N
080551	ALTO TAMBO (CAB. EN GUADUAL)	ALT	0805	A	2016-10-14 11:41:16.627838-05	\N
080552	ANCÓN (PICHANGAL) (CAB. EN PALMA REAL)	ANC	0805	A	2016-10-14 11:41:16.627838-05	\N
080553	CALDERÓN	CAL	0805	A	2016-10-14 11:41:16.627838-05	\N
080554	CARONDELET	CAR	0805	A	2016-10-14 11:41:16.627838-05	\N
080555	5 DE JUNIO (CAB. EN UIMBI)	5 D	0805	A	2016-10-14 11:41:16.627838-05	\N
080556	CONCEPCIÓN	CON	0805	A	2016-10-14 11:41:16.627838-05	\N
080557	MATAJE (CAB. EN SANTANDER)	MAT	0805	A	2016-10-14 11:41:16.627838-05	\N
080558	SAN JAVIER DE CACHAVÍ (CAB. EN SAN JAVIER)	SAN	0805	A	2016-10-14 11:41:16.627838-05	\N
080559	SANTA RITA	SAN	0805	A	2016-10-14 11:41:16.627838-05	\N
080560	TAMBILLO	TAM	0805	A	2016-10-14 11:41:16.627838-05	\N
080561	TULULBÍ (CAB. EN RICAURTE)	TUL	0805	A	2016-10-14 11:41:16.627838-05	\N
080562	URBINA	URB	0805	A	2016-10-14 11:41:16.627838-05	\N
080650	ATACAMES	ATA	0806	A	2016-10-14 11:41:16.627838-05	\N
080651	LA UNIÓN	LA 	0806	A	2016-10-14 11:41:16.627838-05	\N
080652	SÚA (CAB. EN LA BOCANA)	SÚA	0806	A	2016-10-14 11:41:16.627838-05	\N
080653	TONCHIGÜE	TON	0806	A	2016-10-14 11:41:16.627838-05	\N
080654	TONSUPA	TON	0806	A	2016-10-14 11:41:16.627838-05	\N
080750	RIOVERDE	RIO	0807	A	2016-10-14 11:41:16.627838-05	\N
080751	CHONTADURO	CHO	0807	A	2016-10-14 11:41:16.627838-05	\N
080752	CHUMUNDÉ	CHU	0807	A	2016-10-14 11:41:16.627838-05	\N
080753	LAGARTO	LAG	0807	A	2016-10-14 11:41:16.627838-05	\N
080754	MONTALVO (CAB. EN HORQUETA)	MON	0807	A	2016-10-14 11:41:16.627838-05	\N
080755	ROCAFUERTE	ROC	0807	A	2016-10-14 11:41:16.627838-05	\N
080850	LA CONCORDIA	LA 	0808	A	2016-10-14 11:41:16.627838-05	\N
080851	MONTERREY	MON	0808	A	2016-10-14 11:41:16.627838-05	\N
080852	LA VILLEGAS	LA 	0808	A	2016-10-14 11:41:16.627838-05	\N
080853	PLAN PILOTO	PLA	0808	A	2016-10-14 11:41:16.627838-05	\N
090101	AYACUCHO	AYA	0901	A	2016-10-14 11:41:16.627838-05	\N
090102	BOLÍVAR (SAGRARIO)	BOL	0901	A	2016-10-14 11:41:16.627838-05	\N
090103	CARBO (CONCEPCIÓN)	CAR	0901	A	2016-10-14 11:41:16.627838-05	\N
090104	FEBRES CORDERO	FEB	0901	A	2016-10-14 11:41:16.627838-05	\N
090105	GARCÍA MORENO	GAR	0901	A	2016-10-14 11:41:16.627838-05	\N
090106	LETAMENDI	LET	0901	A	2016-10-14 11:41:16.627838-05	\N
090107	NUEVE DE OCTUBRE	NUE	0901	A	2016-10-14 11:41:16.627838-05	\N
090108	OLMEDO (SAN ALEJO)	OLM	0901	A	2016-10-14 11:41:16.627838-05	\N
090109	ROCA	ROC	0901	A	2016-10-14 11:41:16.627838-05	\N
090110	ROCAFUERTE	ROC	0901	A	2016-10-14 11:41:16.627838-05	\N
090111	SUCRE	SUC	0901	A	2016-10-14 11:41:16.627838-05	\N
090112	TARQUI	TAR	0901	A	2016-10-14 11:41:16.627838-05	\N
090113	URDANETA	URD	0901	A	2016-10-14 11:41:16.627838-05	\N
090114	XIMENA	XIM	0901	A	2016-10-14 11:41:16.627838-05	\N
090115	PASCUALES	PAS	0901	A	2016-10-14 11:41:16.627838-05	\N
090150	GUAYAQUIL	GUA	0901	A	2016-10-14 11:41:16.627838-05	\N
090151	CHONGÓN	CHO	0901	A	2016-10-14 11:41:16.627838-05	\N
090152	JUAN GÓMEZ RENDÓN (PROGRESO)	JUA	0901	A	2016-10-14 11:41:16.627838-05	\N
090153	MORRO	MOR	0901	A	2016-10-14 11:41:16.627838-05	\N
090154	PASCUALES	PAS	0901	A	2016-10-14 11:41:16.627838-05	\N
090155	PLAYAS (GRAL. VILLAMIL)	PLA	0901	A	2016-10-14 11:41:16.627838-05	\N
090156	POSORJA	POS	0901	A	2016-10-14 11:41:16.627838-05	\N
090157	PUNÁ	PUN	0901	A	2016-10-14 11:41:16.627838-05	\N
090158	TENGUEL	TEN	0901	A	2016-10-14 11:41:16.627838-05	\N
090250	ALFREDO BAQUERIZO MORENO (JUJÁN)	ALF	0902	A	2016-10-14 11:41:16.627838-05	\N
090350	BALAO	BAL	0903	A	2016-10-14 11:41:16.627838-05	\N
090450	BALZAR	BAL	0904	A	2016-10-14 11:41:16.627838-05	\N
090550	COLIMES	COL	0905	A	2016-10-14 11:41:16.627838-05	\N
090551	SAN JACINTO	SAN	0905	A	2016-10-14 11:41:16.627838-05	\N
090601	DAULE	DAU	0906	A	2016-10-14 11:41:16.627838-05	\N
090602	LA AURORA (SATÉLITE)	LA 	0906	A	2016-10-14 11:41:16.627838-05	\N
090603	BANIFE	BAN	0906	A	2016-10-14 11:41:16.627838-05	\N
090604	EMILIANO CAICEDO MARCOS	EMI	0906	A	2016-10-14 11:41:16.627838-05	\N
090605	MAGRO	MAG	0906	A	2016-10-14 11:41:16.627838-05	\N
090606	PADRE JUAN BAUTISTA AGUIRRE	PAD	0906	A	2016-10-14 11:41:16.627838-05	\N
090607	SANTA CLARA	SAN	0906	A	2016-10-14 11:41:16.627838-05	\N
090608	VICENTE PIEDRAHITA	VIC	0906	A	2016-10-14 11:41:16.627838-05	\N
090650	DAULE	DAU	0906	A	2016-10-14 11:41:16.627838-05	\N
090651	ISIDRO AYORA (SOLEDAD)	ISI	0906	A	2016-10-14 11:41:16.627838-05	\N
090652	JUAN BAUTISTA AGUIRRE (LOS TINTOS)	JUA	0906	A	2016-10-14 11:41:16.627838-05	\N
090653	LAUREL	LAU	0906	A	2016-10-14 11:41:16.627838-05	\N
090654	LIMONAL	LIM	0906	A	2016-10-14 11:41:16.627838-05	\N
090655	LOMAS DE SARGENTILLO	LOM	0906	A	2016-10-14 11:41:16.627838-05	\N
090656	LOS LOJAS (ENRIQUE BAQUERIZO MORENO)	LOS	0906	A	2016-10-14 11:41:16.627838-05	\N
090657	PIEDRAHITA (NOBOL)	PIE	0906	A	2016-10-14 11:41:16.627838-05	\N
090701	ELOY ALFARO (DURÁN)	ELO	0907	A	2016-10-14 11:41:16.627838-05	\N
090702	EL RECREO	EL 	0907	A	2016-10-14 11:41:16.627838-05	\N
090750	ELOY ALFARO (DURÁN)	ELO	0907	A	2016-10-14 11:41:16.627838-05	\N
090850	VELASCO IBARRA (EL EMPALME)	VEL	0908	A	2016-10-14 11:41:16.627838-05	\N
090851	GUAYAS (PUEBLO NUEVO)	GUA	0908	A	2016-10-14 11:41:16.627838-05	\N
090852	EL ROSARIO	EL 	0908	A	2016-10-14 11:41:16.627838-05	\N
090950	EL TRIUNFO	EL 	0909	A	2016-10-14 11:41:16.627838-05	\N
091050	MILAGRO	MIL	0910	A	2016-10-14 11:41:16.627838-05	\N
091051	CHOBO	CHO	0910	A	2016-10-14 11:41:16.627838-05	\N
091052	GENERAL ELIZALDE (BUCAY)	GEN	0910	A	2016-10-14 11:41:16.627838-05	\N
091053	MARISCAL SUCRE (HUAQUES)	MAR	0910	A	2016-10-14 11:41:16.627838-05	\N
091054	ROBERTO ASTUDILLO (CAB. EN CRUCE DE VENECIA)	ROB	0910	A	2016-10-14 11:41:16.627838-05	\N
091150	NARANJAL	NAR	0911	A	2016-10-14 11:41:16.627838-05	\N
091151	JESÚS MARÍA	JES	0911	A	2016-10-14 11:41:16.627838-05	\N
091152	SAN CARLOS	SAN	0911	A	2016-10-14 11:41:16.627838-05	\N
091153	SANTA ROSA DE FLANDES	SAN	0911	A	2016-10-14 11:41:16.627838-05	\N
091154	TAURA	TAU	0911	A	2016-10-14 11:41:16.627838-05	\N
091250	NARANJITO	NAR	0912	A	2016-10-14 11:41:16.627838-05	\N
091350	PALESTINA	PAL	0913	A	2016-10-14 11:41:16.627838-05	\N
091450	PEDRO CARBO	PED	0914	A	2016-10-14 11:41:16.627838-05	\N
091451	VALLE DE LA VIRGEN	VAL	0914	A	2016-10-14 11:41:16.627838-05	\N
091452	SABANILLA	SAB	0914	A	2016-10-14 11:41:16.627838-05	\N
091601	SAMBORONDÓN	SAM	0916	A	2016-10-14 11:41:16.627838-05	\N
091602	LA PUNTILLA (SATÉLITE)	LA 	0916	A	2016-10-14 11:41:16.627838-05	\N
091650	SAMBORONDÓN	SAM	0916	A	2016-10-14 11:41:16.627838-05	\N
091651	TARIFA	TAR	0916	A	2016-10-14 11:41:16.627838-05	\N
091850	SANTA LUCÍA	SAN	0918	A	2016-10-14 11:41:16.627838-05	\N
091901	BOCANA	BOC	0919	A	2016-10-14 11:41:16.627838-05	\N
091902	CANDILEJOS	CAN	0919	A	2016-10-14 11:41:16.627838-05	\N
091903	CENTRAL	CEN	0919	A	2016-10-14 11:41:16.627838-05	\N
091904	PARAÍSO	PAR	0919	A	2016-10-14 11:41:16.627838-05	\N
091905	SAN MATEO	SAN	0919	A	2016-10-14 11:41:16.627838-05	\N
091950	EL SALITRE (LAS RAMAS)	EL 	0919	A	2016-10-14 11:41:16.627838-05	\N
091951	GRAL. VERNAZA (DOS ESTEROS)	GRA	0919	A	2016-10-14 11:41:16.627838-05	\N
091952	LA VICTORIA (ÑAUZA)	LA 	0919	A	2016-10-14 11:41:16.627838-05	\N
091953	JUNQUILLAL	JUN	0919	A	2016-10-14 11:41:16.627838-05	\N
092050	SAN JACINTO DE YAGUACHI	SAN	0920	A	2016-10-14 11:41:16.627838-05	\N
092051	CRNEL. LORENZO DE GARAICOA (PEDREGAL)	CRN	0920	A	2016-10-14 11:41:16.627838-05	\N
092052	CRNEL. MARCELINO MARIDUEÑA (SAN CARLOS)	CRN	0920	A	2016-10-14 11:41:16.627838-05	\N
092053	GRAL. PEDRO J. MONTERO (BOLICHE)	GRA	0920	A	2016-10-14 11:41:16.627838-05	\N
092054	SIMÓN BOLÍVAR	SIM	0920	A	2016-10-14 11:41:16.627838-05	\N
092055	YAGUACHI VIEJO (CONE)	YAG	0920	A	2016-10-14 11:41:16.627838-05	\N
092056	VIRGEN DE FÁTIMA	VIR	0920	A	2016-10-14 11:41:16.627838-05	\N
092150	GENERAL VILLAMIL (PLAYAS)	GEN	0921	A	2016-10-14 11:41:16.627838-05	\N
092250	SIMÓN BOLÍVAR	SIM	0922	A	2016-10-14 11:41:16.627838-05	\N
092251	CRNEL.LORENZO DE GARAICOA (PEDREGAL)	CRN	0922	A	2016-10-14 11:41:16.627838-05	\N
092350	CORONEL MARCELINO MARIDUEÑA (SAN CARLOS)	COR	0923	A	2016-10-14 11:41:16.627838-05	\N
092450	LOMAS DE SARGENTILLO	LOM	0924	A	2016-10-14 11:41:16.627838-05	\N
092451	ISIDRO AYORA (SOLEDAD)	ISI	0924	A	2016-10-14 11:41:16.627838-05	\N
092550	NARCISA DE JESÚS	NAR	0925	A	2016-10-14 11:41:16.627838-05	\N
092750	GENERAL ANTONIO ELIZALDE (BUCAY)	GEN	0927	A	2016-10-14 11:41:16.627838-05	\N
092850	ISIDRO AYORA	ISI	0928	A	2016-10-14 11:41:16.627838-05	\N
110101	EL SAGRARIO	EL 	1101	A	2016-10-14 11:41:16.627838-05	\N
110102	SAN SEBASTIÁN	SAN	1101	A	2016-10-14 11:41:16.627838-05	\N
110103	SUCRE	SUC	1101	A	2016-10-14 11:41:16.627838-05	\N
110104	VALLE	VAL	1101	A	2016-10-14 11:41:16.627838-05	\N
110150	LOJA	LOJ	1101	A	2016-10-14 11:41:16.627838-05	\N
110151	CHANTACO	CHA	1101	A	2016-10-14 11:41:16.627838-05	\N
110152	CHUQUIRIBAMBA	CHU	1101	A	2016-10-14 11:41:16.627838-05	\N
110153	EL CISNE	EL 	1101	A	2016-10-14 11:41:16.627838-05	\N
110154	GUALEL	GUA	1101	A	2016-10-14 11:41:16.627838-05	\N
110155	JIMBILLA	JIM	1101	A	2016-10-14 11:41:16.627838-05	\N
110156	MALACATOS (VALLADOLID)	MAL	1101	A	2016-10-14 11:41:16.627838-05	\N
110157	SAN LUCAS	SAN	1101	A	2016-10-14 11:41:16.627838-05	\N
110158	SAN PEDRO DE VILCABAMBA	SAN	1101	A	2016-10-14 11:41:16.627838-05	\N
110159	SANTIAGO	SAN	1101	A	2016-10-14 11:41:16.627838-05	\N
110160	TAQUIL (MIGUEL RIOFRÍO)	TAQ	1101	A	2016-10-14 11:41:16.627838-05	\N
110161	VILCABAMBA (VICTORIA)	VIL	1101	A	2016-10-14 11:41:16.627838-05	\N
110162	YANGANA (ARSENIO CASTILLO)	YAN	1101	A	2016-10-14 11:41:16.627838-05	\N
110163	QUINARA	QUI	1101	A	2016-10-14 11:41:16.627838-05	\N
110201	CARIAMANGA	CAR	1102	A	2016-10-14 11:41:16.627838-05	\N
110202	CHILE	CHI	1102	A	2016-10-14 11:41:16.627838-05	\N
110203	SAN VICENTE	SAN	1102	A	2016-10-14 11:41:16.627838-05	\N
110250	CARIAMANGA	CAR	1102	A	2016-10-14 11:41:16.627838-05	\N
110251	COLAISACA	COL	1102	A	2016-10-14 11:41:16.627838-05	\N
110252	EL LUCERO	EL 	1102	A	2016-10-14 11:41:16.627838-05	\N
110253	UTUANA	UTU	1102	A	2016-10-14 11:41:16.627838-05	\N
110254	SANGUILLÍN	SAN	1102	A	2016-10-14 11:41:16.627838-05	\N
110301	CATAMAYO	CAT	1103	A	2016-10-14 11:41:16.627838-05	\N
110302	SAN JOSÉ	SAN	1103	A	2016-10-14 11:41:16.627838-05	\N
110350	CATAMAYO (LA TOMA)	CAT	1103	A	2016-10-14 11:41:16.627838-05	\N
110351	EL TAMBO	EL 	1103	A	2016-10-14 11:41:16.627838-05	\N
110352	GUAYQUICHUMA	GUA	1103	A	2016-10-14 11:41:16.627838-05	\N
110353	SAN PEDRO DE LA BENDITA	SAN	1103	A	2016-10-14 11:41:16.627838-05	\N
110354	ZAMBI	ZAM	1103	A	2016-10-14 11:41:16.627838-05	\N
110450	CELICA	CEL	1104	A	2016-10-14 11:41:16.627838-05	\N
110451	CRUZPAMBA (CAB. EN CARLOS BUSTAMANTE)	CRU	1104	A	2016-10-14 11:41:16.627838-05	\N
110452	CHAQUINAL	CHA	1104	A	2016-10-14 11:41:16.627838-05	\N
110453	12 DE DICIEMBRE (CAB. EN ACHIOTES)	12 	1104	A	2016-10-14 11:41:16.627838-05	\N
110454	PINDAL (FEDERICO PÁEZ)	PIN	1104	A	2016-10-14 11:41:16.627838-05	\N
110455	POZUL (SAN JUAN DE POZUL)	POZ	1104	A	2016-10-14 11:41:16.627838-05	\N
110456	SABANILLA	SAB	1104	A	2016-10-14 11:41:16.627838-05	\N
110457	TNTE. MAXIMILIANO RODRÍGUEZ LOAIZA	TNT	1104	A	2016-10-14 11:41:16.627838-05	\N
110550	CHAGUARPAMBA	CHA	1105	A	2016-10-14 11:41:16.627838-05	\N
110551	BUENAVISTA	BUE	1105	A	2016-10-14 11:41:16.627838-05	\N
110552	EL ROSARIO	EL 	1105	A	2016-10-14 11:41:16.627838-05	\N
110553	SANTA RUFINA	SAN	1105	A	2016-10-14 11:41:16.627838-05	\N
110554	AMARILLOS	AMA	1105	A	2016-10-14 11:41:16.627838-05	\N
110650	AMALUZA	AMA	1106	A	2016-10-14 11:41:16.627838-05	\N
110651	BELLAVISTA	BEL	1106	A	2016-10-14 11:41:16.627838-05	\N
110652	JIMBURA	JIM	1106	A	2016-10-14 11:41:16.627838-05	\N
110653	SANTA TERESITA	SAN	1106	A	2016-10-14 11:41:16.627838-05	\N
110654	27 DE ABRIL (CAB. EN LA NARANJA)	27 	1106	A	2016-10-14 11:41:16.627838-05	\N
110655	EL INGENIO	EL 	1106	A	2016-10-14 11:41:16.627838-05	\N
110656	EL AIRO	EL 	1106	A	2016-10-14 11:41:16.627838-05	\N
110750	GONZANAMÁ	GON	1107	A	2016-10-14 11:41:16.627838-05	\N
110751	CHANGAIMINA (LA LIBERTAD)	CHA	1107	A	2016-10-14 11:41:16.627838-05	\N
110752	FUNDOCHAMBA	FUN	1107	A	2016-10-14 11:41:16.627838-05	\N
110753	NAMBACOLA	NAM	1107	A	2016-10-14 11:41:16.627838-05	\N
110754	PURUNUMA (EGUIGUREN)	PUR	1107	A	2016-10-14 11:41:16.627838-05	\N
110755	QUILANGA (LA PAZ)	QUI	1107	A	2016-10-14 11:41:16.627838-05	\N
110756	SACAPALCA	SAC	1107	A	2016-10-14 11:41:16.627838-05	\N
110757	SAN ANTONIO DE LAS ARADAS (CAB. EN LAS ARADAS)	SAN	1107	A	2016-10-14 11:41:16.627838-05	\N
110801	GENERAL ELOY ALFARO (SAN SEBASTIÁN)	GEN	1108	A	2016-10-14 11:41:16.627838-05	\N
110802	MACARÁ (MANUEL ENRIQUE RENGEL SUQUILANDA)	MAC	1108	A	2016-10-14 11:41:16.627838-05	\N
110850	MACARÁ	MAC	1108	A	2016-10-14 11:41:16.627838-05	\N
110851	LARAMA	LAR	1108	A	2016-10-14 11:41:16.627838-05	\N
110852	LA VICTORIA	LA 	1108	A	2016-10-14 11:41:16.627838-05	\N
110853	SABIANGO (LA CAPILLA)	SAB	1108	A	2016-10-14 11:41:16.627838-05	\N
110901	CATACOCHA	CAT	1109	A	2016-10-14 11:41:16.627838-05	\N
110902	LOURDES	LOU	1109	A	2016-10-14 11:41:16.627838-05	\N
110950	CATACOCHA	CAT	1109	A	2016-10-14 11:41:16.627838-05	\N
110951	CANGONAMÁ	CAN	1109	A	2016-10-14 11:41:16.627838-05	\N
110952	GUACHANAMÁ	GUA	1109	A	2016-10-14 11:41:16.627838-05	\N
110953	LA TINGUE	LA 	1109	A	2016-10-14 11:41:16.627838-05	\N
110954	LAURO GUERRERO	LAU	1109	A	2016-10-14 11:41:16.627838-05	\N
110955	OLMEDO (SANTA BÁRBARA)	OLM	1109	A	2016-10-14 11:41:16.627838-05	\N
110956	ORIANGA	ORI	1109	A	2016-10-14 11:41:16.627838-05	\N
110957	SAN ANTONIO	SAN	1109	A	2016-10-14 11:41:16.627838-05	\N
110958	CASANGA	CAS	1109	A	2016-10-14 11:41:16.627838-05	\N
110959	YAMANA	YAM	1109	A	2016-10-14 11:41:16.627838-05	\N
111050	ALAMOR	ALA	1110	A	2016-10-14 11:41:16.627838-05	\N
111051	CIANO	CIA	1110	A	2016-10-14 11:41:16.627838-05	\N
111052	EL ARENAL	EL 	1110	A	2016-10-14 11:41:16.627838-05	\N
111053	EL LIMO (MARIANA DE JESÚS)	EL 	1110	A	2016-10-14 11:41:16.627838-05	\N
111054	MERCADILLO	MER	1110	A	2016-10-14 11:41:16.627838-05	\N
111055	VICENTINO	VIC	1110	A	2016-10-14 11:41:16.627838-05	\N
111150	SARAGURO	SAR	1111	A	2016-10-14 11:41:16.627838-05	\N
111151	EL PARAÍSO DE CELÉN	EL 	1111	A	2016-10-14 11:41:16.627838-05	\N
111152	EL TABLÓN	EL 	1111	A	2016-10-14 11:41:16.627838-05	\N
111153	LLUZHAPA	LLU	1111	A	2016-10-14 11:41:16.627838-05	\N
111154	MANÚ	MAN	1111	A	2016-10-14 11:41:16.627838-05	\N
111155	SAN ANTONIO DE QUMBE (CUMBE)	SAN	1111	A	2016-10-14 11:41:16.627838-05	\N
111156	SAN PABLO DE TENTA	SAN	1111	A	2016-10-14 11:41:16.627838-05	\N
111157	SAN SEBASTIÁN DE YÚLUC	SAN	1111	A	2016-10-14 11:41:16.627838-05	\N
111158	SELVA ALEGRE	SEL	1111	A	2016-10-14 11:41:16.627838-05	\N
111159	URDANETA (PAQUISHAPA)	URD	1111	A	2016-10-14 11:41:16.627838-05	\N
111160	SUMAYPAMBA	SUM	1111	A	2016-10-14 11:41:16.627838-05	\N
111250	SOZORANGA	SOZ	1112	A	2016-10-14 11:41:16.627838-05	\N
111251	NUEVA FÁTIMA	NUE	1112	A	2016-10-14 11:41:16.627838-05	\N
111252	TACAMOROS	TAC	1112	A	2016-10-14 11:41:16.627838-05	\N
111350	ZAPOTILLO	ZAP	1113	A	2016-10-14 11:41:16.627838-05	\N
111351	MANGAHURCO (CAZADEROS)	MAN	1113	A	2016-10-14 11:41:16.627838-05	\N
111352	GARZAREAL	GAR	1113	A	2016-10-14 11:41:16.627838-05	\N
111353	LIMONES	LIM	1113	A	2016-10-14 11:41:16.627838-05	\N
111354	PALETILLAS	PAL	1113	A	2016-10-14 11:41:16.627838-05	\N
111355	BOLASPAMBA	BOL	1113	A	2016-10-14 11:41:16.627838-05	\N
111450	PINDAL	PIN	1114	A	2016-10-14 11:41:16.627838-05	\N
111451	CHAQUINAL	CHA	1114	A	2016-10-14 11:41:16.627838-05	\N
111452	12 DE DICIEMBRE (CAB.EN ACHIOTES)	12 	1114	A	2016-10-14 11:41:16.627838-05	\N
111453	MILAGROS	MIL	1114	A	2016-10-14 11:41:16.627838-05	\N
111550	QUILANGA	QUI	1115	A	2016-10-14 11:41:16.627838-05	\N
111551	FUNDOCHAMBA	FUN	1115	A	2016-10-14 11:41:16.627838-05	\N
111552	SAN ANTONIO DE LAS ARADAS (CAB. EN LAS ARADAS)	SAN	1115	A	2016-10-14 11:41:16.627838-05	\N
111650	OLMEDO	OLM	1116	A	2016-10-14 11:41:16.627838-05	\N
111651	LA TINGUE	LA 	1116	A	2016-10-14 11:41:16.627838-05	\N
120101	CLEMENTE BAQUERIZO	CLE	1201	A	2016-10-14 11:41:16.627838-05	\N
120102	DR. CAMILO PONCE	DR.	1201	A	2016-10-14 11:41:16.627838-05	\N
120103	BARREIRO	BAR	1201	A	2016-10-14 11:41:16.627838-05	\N
120104	EL SALTO	EL 	1201	A	2016-10-14 11:41:16.627838-05	\N
120150	BABAHOYO	BAB	1201	A	2016-10-14 11:41:16.627838-05	\N
120151	BARREIRO (SANTA RITA)	BAR	1201	A	2016-10-14 11:41:16.627838-05	\N
120152	CARACOL	CAR	1201	A	2016-10-14 11:41:16.627838-05	\N
120153	FEBRES CORDERO (LAS JUNTAS)	FEB	1201	A	2016-10-14 11:41:16.627838-05	\N
120154	PIMOCHA	PIM	1201	A	2016-10-14 11:41:16.627838-05	\N
120155	LA UNIÓN	LA 	1201	A	2016-10-14 11:41:16.627838-05	\N
120250	BABA	BAB	1202	A	2016-10-14 11:41:16.627838-05	\N
120251	GUARE	GUA	1202	A	2016-10-14 11:41:16.627838-05	\N
120252	ISLA DE BEJUCAL	ISL	1202	A	2016-10-14 11:41:16.627838-05	\N
120350	MONTALVO	MON	1203	A	2016-10-14 11:41:16.627838-05	\N
120450	PUEBLOVIEJO	PUE	1204	A	2016-10-14 11:41:16.627838-05	\N
120451	PUERTO PECHICHE	PUE	1204	A	2016-10-14 11:41:16.627838-05	\N
120452	SAN JUAN	SAN	1204	A	2016-10-14 11:41:16.627838-05	\N
120501	QUEVEDO	QUE	1205	A	2016-10-14 11:41:16.627838-05	\N
120502	SAN CAMILO	SAN	1205	A	2016-10-14 11:41:16.627838-05	\N
120503	SAN JOSÉ	SAN	1205	A	2016-10-14 11:41:16.627838-05	\N
120504	GUAYACÁN	GUA	1205	A	2016-10-14 11:41:16.627838-05	\N
120505	NICOLÁS INFANTE DÍAZ	NIC	1205	A	2016-10-14 11:41:16.627838-05	\N
120506	SAN CRISTÓBAL	SAN	1205	A	2016-10-14 11:41:16.627838-05	\N
120507	SIETE DE OCTUBRE	SIE	1205	A	2016-10-14 11:41:16.627838-05	\N
120508	24 DE MAYO	24 	1205	A	2016-10-14 11:41:16.627838-05	\N
120509	VENUS DEL RÍO QUEVEDO	VEN	1205	A	2016-10-14 11:41:16.627838-05	\N
120510	VIVA ALFARO	VIV	1205	A	2016-10-14 11:41:16.627838-05	\N
120550	QUEVEDO	QUE	1205	A	2016-10-14 11:41:16.627838-05	\N
120551	BUENA FÉ	BUE	1205	A	2016-10-14 11:41:16.627838-05	\N
120552	MOCACHE	MOC	1205	A	2016-10-14 11:41:16.627838-05	\N
120553	SAN CARLOS	SAN	1205	A	2016-10-14 11:41:16.627838-05	\N
120554	VALENCIA	VAL	1205	A	2016-10-14 11:41:16.627838-05	\N
120555	LA ESPERANZA	LA 	1205	A	2016-10-14 11:41:16.627838-05	\N
120650	CATARAMA	CAT	1206	A	2016-10-14 11:41:16.627838-05	\N
120651	RICAURTE	RIC	1206	A	2016-10-14 11:41:16.627838-05	\N
120701	10 DE NOVIEMBRE	10 	1207	A	2016-10-14 11:41:16.627838-05	\N
120750	VENTANAS	VEN	1207	A	2016-10-14 11:41:16.627838-05	\N
120751	QUINSALOMA	QUI	1207	A	2016-10-14 11:41:16.627838-05	\N
120752	ZAPOTAL	ZAP	1207	A	2016-10-14 11:41:16.627838-05	\N
120753	CHACARITA	CHA	1207	A	2016-10-14 11:41:16.627838-05	\N
120754	LOS ÁNGELES	LOS	1207	A	2016-10-14 11:41:16.627838-05	\N
120850	VINCES	VIN	1208	A	2016-10-14 11:41:16.627838-05	\N
120851	ANTONIO SOTOMAYOR (CAB. EN PLAYAS DE VINCES)	ANT	1208	A	2016-10-14 11:41:16.627838-05	\N
120852	PALENQUE	PAL	1208	A	2016-10-14 11:41:16.627838-05	\N
120950	PALENQUE	PAL	1209	A	2016-10-14 11:41:16.627838-05	\N
121001	SAN JACINTO DE BUENA FÉ	SAN	1210	A	2016-10-14 11:41:16.627838-05	\N
121002	7 DE AGOSTO	7 D	1210	A	2016-10-14 11:41:16.627838-05	\N
121003	11 DE OCTUBRE	11 	1210	A	2016-10-14 11:41:16.627838-05	\N
121050	SAN JACINTO DE BUENA FÉ	SAN	1210	A	2016-10-14 11:41:16.627838-05	\N
121051	PATRICIA PILAR	PAT	1210	A	2016-10-14 11:41:16.627838-05	\N
121150	VALENCIA	VAL	1211	A	2016-10-14 11:41:16.627838-05	\N
121250	MOCACHE	MOC	1212	A	2016-10-14 11:41:16.627838-05	\N
121350	QUINSALOMA	QUI	1213	A	2016-10-14 11:41:16.627838-05	\N
130101	PORTOVIEJO	POR	1301	A	2016-10-14 11:41:16.627838-05	\N
130102	12 DE MARZO	12 	1301	A	2016-10-14 11:41:16.627838-05	\N
130103	COLÓN	COL	1301	A	2016-10-14 11:41:16.627838-05	\N
130104	PICOAZÁ	PIC	1301	A	2016-10-14 11:41:16.627838-05	\N
130105	SAN PABLO	SAN	1301	A	2016-10-14 11:41:16.627838-05	\N
130106	ANDRÉS DE VERA	AND	1301	A	2016-10-14 11:41:16.627838-05	\N
130107	FRANCISCO PACHECO	FRA	1301	A	2016-10-14 11:41:16.627838-05	\N
130108	18 DE OCTUBRE	18 	1301	A	2016-10-14 11:41:16.627838-05	\N
130109	SIMÓN BOLÍVAR	SIM	1301	A	2016-10-14 11:41:16.627838-05	\N
130150	PORTOVIEJO	POR	1301	A	2016-10-14 11:41:16.627838-05	\N
130151	ABDÓN CALDERÓN (SAN FRANCISCO)	ABD	1301	A	2016-10-14 11:41:16.627838-05	\N
130152	ALHAJUELA (BAJO GRANDE)	ALH	1301	A	2016-10-14 11:41:16.627838-05	\N
130153	CRUCITA	CRU	1301	A	2016-10-14 11:41:16.627838-05	\N
130154	PUEBLO NUEVO	PUE	1301	A	2016-10-14 11:41:16.627838-05	\N
130155	RIOCHICO (RÍO CHICO)	RIO	1301	A	2016-10-14 11:41:16.627838-05	\N
130156	SAN PLÁCIDO	SAN	1301	A	2016-10-14 11:41:16.627838-05	\N
130157	CHIRIJOS	CHI	1301	A	2016-10-14 11:41:16.627838-05	\N
130250	CALCETA	CAL	1302	A	2016-10-14 11:41:16.627838-05	\N
130251	MEMBRILLO	MEM	1302	A	2016-10-14 11:41:16.627838-05	\N
130252	QUIROGA	QUI	1302	A	2016-10-14 11:41:16.627838-05	\N
130301	CHONE	CHO	1303	A	2016-10-14 11:41:16.627838-05	\N
130302	SANTA RITA	SAN	1303	A	2016-10-14 11:41:16.627838-05	\N
130350	CHONE	CHO	1303	A	2016-10-14 11:41:16.627838-05	\N
130351	BOYACÁ	BOY	1303	A	2016-10-14 11:41:16.627838-05	\N
130352	CANUTO	CAN	1303	A	2016-10-14 11:41:16.627838-05	\N
130353	CONVENTO	CON	1303	A	2016-10-14 11:41:16.627838-05	\N
130354	CHIBUNGA	CHI	1303	A	2016-10-14 11:41:16.627838-05	\N
130355	ELOY ALFARO	ELO	1303	A	2016-10-14 11:41:16.627838-05	\N
130356	RICAURTE	RIC	1303	A	2016-10-14 11:41:16.627838-05	\N
130357	SAN ANTONIO	SAN	1303	A	2016-10-14 11:41:16.627838-05	\N
130401	EL CARMEN	EL 	1304	A	2016-10-14 11:41:16.627838-05	\N
130402	4 DE DICIEMBRE	4 D	1304	A	2016-10-14 11:41:16.627838-05	\N
130450	EL CARMEN	EL 	1304	A	2016-10-14 11:41:16.627838-05	\N
130451	WILFRIDO LOOR MOREIRA (MAICITO)	WIL	1304	A	2016-10-14 11:41:16.627838-05	\N
130452	SAN PEDRO DE SUMA	SAN	1304	A	2016-10-14 11:41:16.627838-05	\N
130550	FLAVIO ALFARO	FLA	1305	A	2016-10-14 11:41:16.627838-05	\N
130551	SAN FRANCISCO DE NOVILLO (CAB. EN	SAN	1305	A	2016-10-14 11:41:16.627838-05	\N
130552	ZAPALLO	ZAP	1305	A	2016-10-14 11:41:16.627838-05	\N
130601	DR. MIGUEL MORÁN LUCIO	DR.	1306	A	2016-10-14 11:41:16.627838-05	\N
130602	MANUEL INOCENCIO PARRALES Y GUALE	MAN	1306	A	2016-10-14 11:41:16.627838-05	\N
130603	SAN LORENZO DE JIPIJAPA	SAN	1306	A	2016-10-14 11:41:16.627838-05	\N
130650	JIPIJAPA	JIP	1306	A	2016-10-14 11:41:16.627838-05	\N
130651	AMÉRICA	AMÉ	1306	A	2016-10-14 11:41:16.627838-05	\N
130652	EL ANEGADO (CAB. EN ELOY ALFARO)	EL 	1306	A	2016-10-14 11:41:16.627838-05	\N
130653	JULCUY	JUL	1306	A	2016-10-14 11:41:16.627838-05	\N
130654	LA UNIÓN	LA 	1306	A	2016-10-14 11:41:16.627838-05	\N
130655	MACHALILLA	MAC	1306	A	2016-10-14 11:41:16.627838-05	\N
130656	MEMBRILLAL	MEM	1306	A	2016-10-14 11:41:16.627838-05	\N
130657	PEDRO PABLO GÓMEZ	PED	1306	A	2016-10-14 11:41:16.627838-05	\N
130658	PUERTO DE CAYO	PUE	1306	A	2016-10-14 11:41:16.627838-05	\N
130659	PUERTO LÓPEZ	PUE	1306	A	2016-10-14 11:41:16.627838-05	\N
130750	JUNÍN	JUN	1307	A	2016-10-14 11:41:16.627838-05	\N
130801	LOS ESTEROS	LOS	1308	A	2016-10-14 11:41:16.627838-05	\N
130802	MANTA	MAN	1308	A	2016-10-14 11:41:16.627838-05	\N
130803	SAN MATEO	SAN	1308	A	2016-10-14 11:41:16.627838-05	\N
130804	TARQUI	TAR	1308	A	2016-10-14 11:41:16.627838-05	\N
130805	ELOY ALFARO	ELO	1308	A	2016-10-14 11:41:16.627838-05	\N
130850	MANTA	MAN	1308	A	2016-10-14 11:41:16.627838-05	\N
130851	SAN LORENZO	SAN	1308	A	2016-10-14 11:41:16.627838-05	\N
130852	SANTA MARIANITA (BOCA DE PACOCHE)	SAN	1308	A	2016-10-14 11:41:16.627838-05	\N
130901	ANIBAL SAN ANDRÉS	ANI	1309	A	2016-10-14 11:41:16.627838-05	\N
130902	MONTECRISTI	MON	1309	A	2016-10-14 11:41:16.627838-05	\N
130903	EL COLORADO	EL 	1309	A	2016-10-14 11:41:16.627838-05	\N
130904	GENERAL ELOY ALFARO	GEN	1309	A	2016-10-14 11:41:16.627838-05	\N
130905	LEONIDAS PROAÑO	LEO	1309	A	2016-10-14 11:41:16.627838-05	\N
130950	MONTECRISTI	MON	1309	A	2016-10-14 11:41:16.627838-05	\N
130951	JARAMIJÓ	JAR	1309	A	2016-10-14 11:41:16.627838-05	\N
130952	LA PILA	LA 	1309	A	2016-10-14 11:41:16.627838-05	\N
131050	PAJÁN	PAJ	1310	A	2016-10-14 11:41:16.627838-05	\N
131051	CAMPOZANO (LA PALMA DE PAJÁN)	CAM	1310	A	2016-10-14 11:41:16.627838-05	\N
131052	CASCOL	CAS	1310	A	2016-10-14 11:41:16.627838-05	\N
131053	GUALE	GUA	1310	A	2016-10-14 11:41:16.627838-05	\N
131054	LASCANO	LAS	1310	A	2016-10-14 11:41:16.627838-05	\N
131150	PICHINCHA	PIC	1311	A	2016-10-14 11:41:16.627838-05	\N
131151	BARRAGANETE	BAR	1311	A	2016-10-14 11:41:16.627838-05	\N
131152	SAN SEBASTIÁN	SAN	1311	A	2016-10-14 11:41:16.627838-05	\N
131250	ROCAFUERTE	ROC	1312	A	2016-10-14 11:41:16.627838-05	\N
131301	SANTA ANA	SAN	1313	A	2016-10-14 11:41:16.627838-05	\N
131302	LODANA	LOD	1313	A	2016-10-14 11:41:16.627838-05	\N
131350	SANTA ANA DE VUELTA LARGA	SAN	1313	A	2016-10-14 11:41:16.627838-05	\N
131351	AYACUCHO	AYA	1313	A	2016-10-14 11:41:16.627838-05	\N
131352	HONORATO VÁSQUEZ (CAB. EN VÁSQUEZ)	HON	1313	A	2016-10-14 11:41:16.627838-05	\N
131353	LA UNIÓN	LA 	1313	A	2016-10-14 11:41:16.627838-05	\N
131354	OLMEDO	OLM	1313	A	2016-10-14 11:41:16.627838-05	\N
131355	SAN PABLO (CAB. EN PUEBLO NUEVO)	SAN	1313	A	2016-10-14 11:41:16.627838-05	\N
131401	BAHÍA DE CARÁQUEZ	BAH	1314	A	2016-10-14 11:41:16.627838-05	\N
131402	LEONIDAS PLAZA GUTIÉRREZ	LEO	1314	A	2016-10-14 11:41:16.627838-05	\N
131450	BAHÍA DE CARÁQUEZ	BAH	1314	A	2016-10-14 11:41:16.627838-05	\N
131451	CANOA	CAN	1314	A	2016-10-14 11:41:16.627838-05	\N
131452	COJIMÍES	COJ	1314	A	2016-10-14 11:41:16.627838-05	\N
131453	CHARAPOTÓ	CHA	1314	A	2016-10-14 11:41:16.627838-05	\N
131454	10 DE AGOSTO	10 	1314	A	2016-10-14 11:41:16.627838-05	\N
131455	JAMA	JAM	1314	A	2016-10-14 11:41:16.627838-05	\N
131456	PEDERNALES	PED	1314	A	2016-10-14 11:41:16.627838-05	\N
131457	SAN ISIDRO	SAN	1314	A	2016-10-14 11:41:16.627838-05	\N
131458	SAN VICENTE	SAN	1314	A	2016-10-14 11:41:16.627838-05	\N
131550	TOSAGUA	TOS	1315	A	2016-10-14 11:41:16.627838-05	\N
131551	BACHILLERO	BAC	1315	A	2016-10-14 11:41:16.627838-05	\N
131552	ANGEL PEDRO GILER (LA ESTANCILLA)	ANG	1315	A	2016-10-14 11:41:16.627838-05	\N
131650	SUCRE	SUC	1316	A	2016-10-14 11:41:16.627838-05	\N
131651	BELLAVISTA	BEL	1316	A	2016-10-14 11:41:16.627838-05	\N
131652	NOBOA	NOB	1316	A	2016-10-14 11:41:16.627838-05	\N
131653	ARQ. SIXTO DURÁN BALLÉN	ARQ	1316	A	2016-10-14 11:41:16.627838-05	\N
131750	PEDERNALES	PED	1317	A	2016-10-14 11:41:16.627838-05	\N
131751	COJIMÍES	COJ	1317	A	2016-10-14 11:41:16.627838-05	\N
131752	10 DE AGOSTO	10 	1317	A	2016-10-14 11:41:16.627838-05	\N
131753	ATAHUALPA	ATA	1317	A	2016-10-14 11:41:16.627838-05	\N
131850	OLMEDO	OLM	1318	A	2016-10-14 11:41:16.627838-05	\N
131950	PUERTO LÓPEZ	PUE	1319	A	2016-10-14 11:41:16.627838-05	\N
131951	MACHALILLA	MAC	1319	A	2016-10-14 11:41:16.627838-05	\N
131952	SALANGO	SAL	1319	A	2016-10-14 11:41:16.627838-05	\N
132050	JAMA	JAM	1320	A	2016-10-14 11:41:16.627838-05	\N
132150	JARAMIJÓ	JAR	1321	A	2016-10-14 11:41:16.627838-05	\N
132250	SAN VICENTE	SAN	1322	A	2016-10-14 11:41:16.627838-05	\N
132251	CANOA	CAN	1322	A	2016-10-14 11:41:16.627838-05	\N
140150	MACAS	MAC	1401	A	2016-10-14 11:41:16.627838-05	\N
140151	ALSHI (CAB. EN 9 DE OCTUBRE)	ALS	1401	A	2016-10-14 11:41:16.627838-05	\N
140152	CHIGUAZA	CHI	1401	A	2016-10-14 11:41:16.627838-05	\N
140153	GENERAL PROAÑO	GEN	1401	A	2016-10-14 11:41:16.627838-05	\N
140154	HUASAGA (CAB.EN WAMPUIK)	HUA	1401	A	2016-10-14 11:41:16.627838-05	\N
140155	MACUMA	MAC	1401	A	2016-10-14 11:41:16.627838-05	\N
140156	SAN ISIDRO	SAN	1401	A	2016-10-14 11:41:16.627838-05	\N
140157	SEVILLA DON BOSCO	SEV	1401	A	2016-10-14 11:41:16.627838-05	\N
140158	SINAÍ	SIN	1401	A	2016-10-14 11:41:16.627838-05	\N
140159	TAISHA	TAI	1401	A	2016-10-14 11:41:16.627838-05	\N
140160	ZUÑA (ZÚÑAC)	ZUÑ	1401	A	2016-10-14 11:41:16.627838-05	\N
140161	TUUTINENTZA	TUU	1401	A	2016-10-14 11:41:16.627838-05	\N
140162	CUCHAENTZA	CUC	1401	A	2016-10-14 11:41:16.627838-05	\N
140163	SAN JOSÉ DE MORONA	SAN	1401	A	2016-10-14 11:41:16.627838-05	\N
140164	RÍO BLANCO	RÍO	1401	A	2016-10-14 11:41:16.627838-05	\N
140201	GUALAQUIZA	GUA	1402	A	2016-10-14 11:41:16.627838-05	\N
140202	MERCEDES MOLINA	MER	1402	A	2016-10-14 11:41:16.627838-05	\N
140250	GUALAQUIZA	GUA	1402	A	2016-10-14 11:41:16.627838-05	\N
140251	AMAZONAS (ROSARIO DE CUYES)	AMA	1402	A	2016-10-14 11:41:16.627838-05	\N
140252	BERMEJOS	BER	1402	A	2016-10-14 11:41:16.627838-05	\N
140253	BOMBOIZA	BOM	1402	A	2016-10-14 11:41:16.627838-05	\N
140254	CHIGÜINDA	CHI	1402	A	2016-10-14 11:41:16.627838-05	\N
140255	EL ROSARIO	EL 	1402	A	2016-10-14 11:41:16.627838-05	\N
140256	NUEVA TARQUI	NUE	1402	A	2016-10-14 11:41:16.627838-05	\N
140257	SAN MIGUEL DE CUYES	SAN	1402	A	2016-10-14 11:41:16.627838-05	\N
140258	EL IDEAL	EL 	1402	A	2016-10-14 11:41:16.627838-05	\N
140350	GENERAL LEONIDAS PLAZA GUTIÉRREZ (LIMÓN)	GEN	1403	A	2016-10-14 11:41:16.627838-05	\N
140351	INDANZA	IND	1403	A	2016-10-14 11:41:16.627838-05	\N
140352	PAN DE AZÚCAR	PAN	1403	A	2016-10-14 11:41:16.627838-05	\N
140353	SAN ANTONIO (CAB. EN SAN ANTONIO CENTRO	SAN	1403	A	2016-10-14 11:41:16.627838-05	\N
140354	SAN CARLOS DE LIMÓN (SAN CARLOS DEL	SAN	1403	A	2016-10-14 11:41:16.627838-05	\N
140355	SAN JUAN BOSCO	SAN	1403	A	2016-10-14 11:41:16.627838-05	\N
140356	SAN MIGUEL DE CONCHAY	SAN	1403	A	2016-10-14 11:41:16.627838-05	\N
140357	SANTA SUSANA DE CHIVIAZA (CAB. EN CHIVIAZA)	SAN	1403	A	2016-10-14 11:41:16.627838-05	\N
140358	YUNGANZA (CAB. EN EL ROSARIO)	YUN	1403	A	2016-10-14 11:41:16.627838-05	\N
140450	PALORA (METZERA)	PAL	1404	A	2016-10-14 11:41:16.627838-05	\N
140451	ARAPICOS	ARA	1404	A	2016-10-14 11:41:16.627838-05	\N
140452	CUMANDÁ (CAB. EN COLONIA AGRÍCOLA SEVILLA DEL ORO)	CUM	1404	A	2016-10-14 11:41:16.627838-05	\N
140453	HUAMBOYA	HUA	1404	A	2016-10-14 11:41:16.627838-05	\N
140454	SANGAY (CAB. EN NAYAMANACA)	SAN	1404	A	2016-10-14 11:41:16.627838-05	\N
140550	SANTIAGO DE MÉNDEZ	SAN	1405	A	2016-10-14 11:41:16.627838-05	\N
140551	COPAL	COP	1405	A	2016-10-14 11:41:16.627838-05	\N
140552	CHUPIANZA	CHU	1405	A	2016-10-14 11:41:16.627838-05	\N
140553	PATUCA	PAT	1405	A	2016-10-14 11:41:16.627838-05	\N
140554	SAN LUIS DE EL ACHO (CAB. EN EL ACHO)	SAN	1405	A	2016-10-14 11:41:16.627838-05	\N
140555	SANTIAGO	SAN	1405	A	2016-10-14 11:41:16.627838-05	\N
140556	TAYUZA	TAY	1405	A	2016-10-14 11:41:16.627838-05	\N
140557	SAN FRANCISCO DE CHINIMBIMI	SAN	1405	A	2016-10-14 11:41:16.627838-05	\N
140650	SUCÚA	SUC	1406	A	2016-10-14 11:41:16.627838-05	\N
140651	ASUNCIÓN	ASU	1406	A	2016-10-14 11:41:16.627838-05	\N
140652	HUAMBI	HUA	1406	A	2016-10-14 11:41:16.627838-05	\N
140653	LOGROÑO	LOG	1406	A	2016-10-14 11:41:16.627838-05	\N
140654	YAUPI	YAU	1406	A	2016-10-14 11:41:16.627838-05	\N
140655	SANTA MARIANITA DE JESÚS	SAN	1406	A	2016-10-14 11:41:16.627838-05	\N
140750	HUAMBOYA	HUA	1407	A	2016-10-14 11:41:16.627838-05	\N
140751	CHIGUAZA	CHI	1407	A	2016-10-14 11:41:16.627838-05	\N
140752	PABLO SEXTO	PAB	1407	A	2016-10-14 11:41:16.627838-05	\N
140850	SAN JUAN BOSCO	SAN	1408	A	2016-10-14 11:41:16.627838-05	\N
140851	PAN DE AZÚCAR	PAN	1408	A	2016-10-14 11:41:16.627838-05	\N
140852	SAN CARLOS DE LIMÓN	SAN	1408	A	2016-10-14 11:41:16.627838-05	\N
140853	SAN JACINTO DE WAKAMBEIS	SAN	1408	A	2016-10-14 11:41:16.627838-05	\N
140854	SANTIAGO DE PANANZA	SAN	1408	A	2016-10-14 11:41:16.627838-05	\N
140950	TAISHA	TAI	1409	A	2016-10-14 11:41:16.627838-05	\N
140951	HUASAGA (CAB. EN WAMPUIK)	HUA	1409	A	2016-10-14 11:41:16.627838-05	\N
140952	MACUMA	MAC	1409	A	2016-10-14 11:41:16.627838-05	\N
140953	TUUTINENTZA	TUU	1409	A	2016-10-14 11:41:16.627838-05	\N
140954	PUMPUENTSA	PUM	1409	A	2016-10-14 11:41:16.627838-05	\N
141050	LOGROÑO	LOG	1410	A	2016-10-14 11:41:16.627838-05	\N
141051	YAUPI	YAU	1410	A	2016-10-14 11:41:16.627838-05	\N
141052	SHIMPIS	SHI	1410	A	2016-10-14 11:41:16.627838-05	\N
141150	PABLO SEXTO	PAB	1411	A	2016-10-14 11:41:16.627838-05	\N
141250	SANTIAGO	SAN	1412	A	2016-10-14 11:41:16.627838-05	\N
141251	SAN JOSÉ DE MORONA	SAN	1412	A	2016-10-14 11:41:16.627838-05	\N
150150	TENA	TEN	1501	A	2016-10-14 11:41:16.627838-05	\N
150151	AHUANO	AHU	1501	A	2016-10-14 11:41:16.627838-05	\N
150152	CARLOS JULIO AROSEMENA TOLA (ZATZA-YACU)	CAR	1501	A	2016-10-14 11:41:16.627838-05	\N
150153	CHONTAPUNTA	CHO	1501	A	2016-10-14 11:41:16.627838-05	\N
150154	PANO	PAN	1501	A	2016-10-14 11:41:16.627838-05	\N
150155	PUERTO MISAHUALLI	PUE	1501	A	2016-10-14 11:41:16.627838-05	\N
150156	PUERTO NAPO	PUE	1501	A	2016-10-14 11:41:16.627838-05	\N
150157	TÁLAG	TÁL	1501	A	2016-10-14 11:41:16.627838-05	\N
150158	SAN JUAN DE MUYUNA	SAN	1501	A	2016-10-14 11:41:16.627838-05	\N
150350	ARCHIDONA	ARC	1503	A	2016-10-14 11:41:16.627838-05	\N
150351	AVILA	AVI	1503	A	2016-10-14 11:41:16.627838-05	\N
150352	COTUNDO	COT	1503	A	2016-10-14 11:41:16.627838-05	\N
150353	LORETO	LOR	1503	A	2016-10-14 11:41:16.627838-05	\N
150354	SAN PABLO DE USHPAYACU	SAN	1503	A	2016-10-14 11:41:16.627838-05	\N
150355	PUERTO MURIALDO	PUE	1503	A	2016-10-14 11:41:16.627838-05	\N
150450	EL CHACO	EL 	1504	A	2016-10-14 11:41:16.627838-05	\N
150451	GONZALO DíAZ DE PINEDA (EL BOMBÓN)	GON	1504	A	2016-10-14 11:41:16.627838-05	\N
150452	LINARES	LIN	1504	A	2016-10-14 11:41:16.627838-05	\N
150453	OYACACHI	OYA	1504	A	2016-10-14 11:41:16.627838-05	\N
150454	SANTA ROSA	SAN	1504	A	2016-10-14 11:41:16.627838-05	\N
150455	SARDINAS	SAR	1504	A	2016-10-14 11:41:16.627838-05	\N
150750	BAEZA	BAE	1507	A	2016-10-14 11:41:16.627838-05	\N
150751	COSANGA	COS	1507	A	2016-10-14 11:41:16.627838-05	\N
150752	CUYUJA	CUY	1507	A	2016-10-14 11:41:16.627838-05	\N
150753	PAPALLACTA	PAP	1507	A	2016-10-14 11:41:16.627838-05	\N
150754	SAN FRANCISCO DE BORJA (VIRGILIO DÁVILA)	SAN	1507	A	2016-10-14 11:41:16.627838-05	\N
150755	SAN JOSÉ DEL PAYAMINO	SAN	1507	A	2016-10-14 11:41:16.627838-05	\N
150756	SUMACO	SUM	1507	A	2016-10-14 11:41:16.627838-05	\N
150950	CARLOS JULIO AROSEMENA TOLA	CAR	1509	A	2016-10-14 11:41:16.627838-05	\N
160150	PUYO	PUY	1601	A	2016-10-14 11:41:16.627838-05	\N
160151	ARAJUNO	ARA	1601	A	2016-10-14 11:41:16.627838-05	\N
160152	CANELOS	CAN	1601	A	2016-10-14 11:41:16.627838-05	\N
160153	CURARAY	CUR	1601	A	2016-10-14 11:41:16.627838-05	\N
160154	DIEZ DE AGOSTO	DIE	1601	A	2016-10-14 11:41:16.627838-05	\N
160155	FÁTIMA	FÁT	1601	A	2016-10-14 11:41:16.627838-05	\N
160156	MONTALVO (ANDOAS)	MON	1601	A	2016-10-14 11:41:16.627838-05	\N
160157	POMONA	POM	1601	A	2016-10-14 11:41:16.627838-05	\N
160158	RÍO CORRIENTES	RÍO	1601	A	2016-10-14 11:41:16.627838-05	\N
160159	RÍO TIGRE	RÍO	1601	A	2016-10-14 11:41:16.627838-05	\N
160160	SANTA CLARA	SAN	1601	A	2016-10-14 11:41:16.627838-05	\N
160161	SARAYACU	SAR	1601	A	2016-10-14 11:41:16.627838-05	\N
160162	SIMÓN BOLÍVAR (CAB. EN MUSHULLACTA)	SIM	1601	A	2016-10-14 11:41:16.627838-05	\N
160163	TARQUI	TAR	1601	A	2016-10-14 11:41:16.627838-05	\N
160164	TENIENTE HUGO ORTIZ	TEN	1601	A	2016-10-14 11:41:16.627838-05	\N
160165	VERACRUZ (INDILLAMA) (CAB. EN INDILLAMA)	VER	1601	A	2016-10-14 11:41:16.627838-05	\N
160166	EL TRIUNFO	EL 	1601	A	2016-10-14 11:41:16.627838-05	\N
160250	MERA	MER	1602	A	2016-10-14 11:41:16.627838-05	\N
160251	MADRE TIERRA	MAD	1602	A	2016-10-14 11:41:16.627838-05	\N
160252	SHELL	SHE	1602	A	2016-10-14 11:41:16.627838-05	\N
160350	SANTA CLARA	SAN	1603	A	2016-10-14 11:41:16.627838-05	\N
160351	SAN JOSÉ	SAN	1603	A	2016-10-14 11:41:16.627838-05	\N
160450	ARAJUNO	ARA	1604	A	2016-10-14 11:41:16.627838-05	\N
160451	CURARAY	CUR	1604	A	2016-10-14 11:41:16.627838-05	\N
170101	BELISARIO QUEVEDO	BEL	1701	A	2016-10-14 11:41:16.627838-05	\N
170102	CARCELÉN	CAR	1701	A	2016-10-14 11:41:16.627838-05	\N
170103	CENTRO HISTÓRICO	CEN	1701	A	2016-10-14 11:41:16.627838-05	\N
170104	COCHAPAMBA	COC	1701	A	2016-10-14 11:41:16.627838-05	\N
170105	COMITÉ DEL PUEBLO	COM	1701	A	2016-10-14 11:41:16.627838-05	\N
170106	COTOCOLLAO	COT	1701	A	2016-10-14 11:41:16.627838-05	\N
170107	CHILIBULO	CHI	1701	A	2016-10-14 11:41:16.627838-05	\N
170108	CHILLOGALLO	CHI	1701	A	2016-10-14 11:41:16.627838-05	\N
170109	CHIMBACALLE	CHI	1701	A	2016-10-14 11:41:16.627838-05	\N
170110	EL CONDADO	EL 	1701	A	2016-10-14 11:41:16.627838-05	\N
170111	GUAMANÍ	GUA	1701	A	2016-10-14 11:41:16.627838-05	\N
170112	IÑAQUITO	IÑA	1701	A	2016-10-14 11:41:16.627838-05	\N
170113	ITCHIMBÍA	ITC	1701	A	2016-10-14 11:41:16.627838-05	\N
170114	JIPIJAPA	JIP	1701	A	2016-10-14 11:41:16.627838-05	\N
170115	KENNEDY	KEN	1701	A	2016-10-14 11:41:16.627838-05	\N
170116	LA ARGELIA	LA 	1701	A	2016-10-14 11:41:16.627838-05	\N
170117	LA CONCEPCIÓN	LA 	1701	A	2016-10-14 11:41:16.627838-05	\N
170118	LA ECUATORIANA	LA 	1701	A	2016-10-14 11:41:16.627838-05	\N
170119	LA FERROVIARIA	LA 	1701	A	2016-10-14 11:41:16.627838-05	\N
170120	LA LIBERTAD	LA 	1701	A	2016-10-14 11:41:16.627838-05	\N
170121	LA MAGDALENA	LA 	1701	A	2016-10-14 11:41:16.627838-05	\N
170122	LA MENA	LA 	1701	A	2016-10-14 11:41:16.627838-05	\N
170123	MARISCAL SUCRE	MAR	1701	A	2016-10-14 11:41:16.627838-05	\N
170124	PONCEANO	PON	1701	A	2016-10-14 11:41:16.627838-05	\N
170125	PUENGASÍ	PUE	1701	A	2016-10-14 11:41:16.627838-05	\N
170126	QUITUMBE	QUI	1701	A	2016-10-14 11:41:16.627838-05	\N
170127	RUMIPAMBA	RUM	1701	A	2016-10-14 11:41:16.627838-05	\N
170128	SAN BARTOLO	SAN	1701	A	2016-10-14 11:41:16.627838-05	\N
170129	SAN ISIDRO DEL INCA	SAN	1701	A	2016-10-14 11:41:16.627838-05	\N
170130	SAN JUAN	SAN	1701	A	2016-10-14 11:41:16.627838-05	\N
170131	SOLANDA	SOL	1701	A	2016-10-14 11:41:16.627838-05	\N
170132	TURUBAMBA	TUR	1701	A	2016-10-14 11:41:16.627838-05	\N
170150	QUITO DISTRITO METROPOLITANO	QUI	1701	A	2016-10-14 11:41:16.627838-05	\N
170151	ALANGASÍ	ALA	1701	A	2016-10-14 11:41:16.627838-05	\N
170152	AMAGUAÑA	AMA	1701	A	2016-10-14 11:41:16.627838-05	\N
170153	ATAHUALPA	ATA	1701	A	2016-10-14 11:41:16.627838-05	\N
170154	CALACALÍ	CAL	1701	A	2016-10-14 11:41:16.627838-05	\N
170155	CALDERÓN	CAL	1701	A	2016-10-14 11:41:16.627838-05	\N
170156	CONOCOTO	CON	1701	A	2016-10-14 11:41:16.627838-05	\N
170157	CUMBAYÁ	CUM	1701	A	2016-10-14 11:41:16.627838-05	\N
170158	CHAVEZPAMBA	CHA	1701	A	2016-10-14 11:41:16.627838-05	\N
170159	CHECA	CHE	1701	A	2016-10-14 11:41:16.627838-05	\N
170160	EL QUINCHE	EL 	1701	A	2016-10-14 11:41:16.627838-05	\N
170161	GUALEA	GUA	1701	A	2016-10-14 11:41:16.627838-05	\N
170162	GUANGOPOLO	GUA	1701	A	2016-10-14 11:41:16.627838-05	\N
170163	GUAYLLABAMBA	GUA	1701	A	2016-10-14 11:41:16.627838-05	\N
170164	LA MERCED	LA 	1701	A	2016-10-14 11:41:16.627838-05	\N
170165	LLANO CHICO	LLA	1701	A	2016-10-14 11:41:16.627838-05	\N
170166	LLOA	LLO	1701	A	2016-10-14 11:41:16.627838-05	\N
170167	MINDO	MIN	1701	A	2016-10-14 11:41:16.627838-05	\N
170168	NANEGAL	NAN	1701	A	2016-10-14 11:41:16.627838-05	\N
170169	NANEGALITO	NAN	1701	A	2016-10-14 11:41:16.627838-05	\N
170170	NAYÓN	NAY	1701	A	2016-10-14 11:41:16.627838-05	\N
170171	NONO	NON	1701	A	2016-10-14 11:41:16.627838-05	\N
170172	PACTO	PAC	1701	A	2016-10-14 11:41:16.627838-05	\N
170173	PEDRO VICENTE MALDONADO	PED	1701	A	2016-10-14 11:41:16.627838-05	\N
170174	PERUCHO	PER	1701	A	2016-10-14 11:41:16.627838-05	\N
170175	PIFO	PIF	1701	A	2016-10-14 11:41:16.627838-05	\N
170176	PÍNTAG	PÍN	1701	A	2016-10-14 11:41:16.627838-05	\N
170177	POMASQUI	POM	1701	A	2016-10-14 11:41:16.627838-05	\N
170178	PUÉLLARO	PUÉ	1701	A	2016-10-14 11:41:16.627838-05	\N
170179	PUEMBO	PUE	1701	A	2016-10-14 11:41:16.627838-05	\N
170180	SAN ANTONIO	SAN	1701	A	2016-10-14 11:41:16.627838-05	\N
170181	SAN JOSÉ DE MINAS	SAN	1701	A	2016-10-14 11:41:16.627838-05	\N
170182	SAN MIGUEL DE LOS BANCOS	SAN	1701	A	2016-10-14 11:41:16.627838-05	\N
170183	TABABELA	TAB	1701	A	2016-10-14 11:41:16.627838-05	\N
170184	TUMBACO	TUM	1701	A	2016-10-14 11:41:16.627838-05	\N
170185	YARUQUÍ	YAR	1701	A	2016-10-14 11:41:16.627838-05	\N
170186	ZAMBIZA	ZAM	1701	A	2016-10-14 11:41:16.627838-05	\N
170187	PUERTO QUITO	PUE	1701	A	2016-10-14 11:41:16.627838-05	\N
170201	AYORA	AYO	1702	A	2016-10-14 11:41:16.627838-05	\N
170202	CAYAMBE	CAY	1702	A	2016-10-14 11:41:16.627838-05	\N
170203	JUAN MONTALVO	JUA	1702	A	2016-10-14 11:41:16.627838-05	\N
170250	CAYAMBE	CAY	1702	A	2016-10-14 11:41:16.627838-05	\N
170251	ASCÁZUBI	ASC	1702	A	2016-10-14 11:41:16.627838-05	\N
170252	CANGAHUA	CAN	1702	A	2016-10-14 11:41:16.627838-05	\N
170253	OLMEDO (PESILLO)	OLM	1702	A	2016-10-14 11:41:16.627838-05	\N
170254	OTÓN	OTÓ	1702	A	2016-10-14 11:41:16.627838-05	\N
170255	SANTA ROSA DE CUZUBAMBA	SAN	1702	A	2016-10-14 11:41:16.627838-05	\N
170350	MACHACHI	MAC	1703	A	2016-10-14 11:41:16.627838-05	\N
170351	ALÓAG	ALÓ	1703	A	2016-10-14 11:41:16.627838-05	\N
170352	ALOASÍ	ALO	1703	A	2016-10-14 11:41:16.627838-05	\N
170353	CUTUGLAHUA	CUT	1703	A	2016-10-14 11:41:16.627838-05	\N
170354	EL CHAUPI	EL 	1703	A	2016-10-14 11:41:16.627838-05	\N
170355	MANUEL CORNEJO ASTORGA (TANDAPI)	MAN	1703	A	2016-10-14 11:41:16.627838-05	\N
170356	TAMBILLO	TAM	1703	A	2016-10-14 11:41:16.627838-05	\N
170357	UYUMBICHO	UYU	1703	A	2016-10-14 11:41:16.627838-05	\N
170450	TABACUNDO	TAB	1704	A	2016-10-14 11:41:16.627838-05	\N
170451	LA ESPERANZA	LA 	1704	A	2016-10-14 11:41:16.627838-05	\N
170452	MALCHINGUÍ	MAL	1704	A	2016-10-14 11:41:16.627838-05	\N
170453	TOCACHI	TOC	1704	A	2016-10-14 11:41:16.627838-05	\N
170454	TUPIGACHI	TUP	1704	A	2016-10-14 11:41:16.627838-05	\N
170501	SANGOLQUÍ	SAN	1705	A	2016-10-14 11:41:16.627838-05	\N
170502	SAN PEDRO DE TABOADA	SAN	1705	A	2016-10-14 11:41:16.627838-05	\N
170503	SAN RAFAEL	SAN	1705	A	2016-10-14 11:41:16.627838-05	\N
170550	SANGOLQUI	SAN	1705	A	2016-10-14 11:41:16.627838-05	\N
170551	COTOGCHOA	COT	1705	A	2016-10-14 11:41:16.627838-05	\N
170552	RUMIPAMBA	RUM	1705	A	2016-10-14 11:41:16.627838-05	\N
170750	SAN MIGUEL DE LOS BANCOS	SAN	1707	A	2016-10-14 11:41:16.627838-05	\N
170751	MINDO	MIN	1707	A	2016-10-14 11:41:16.627838-05	\N
170752	PEDRO VICENTE MALDONADO	PED	1707	A	2016-10-14 11:41:16.627838-05	\N
170753	PUERTO QUITO	PUE	1707	A	2016-10-14 11:41:16.627838-05	\N
170850	PEDRO VICENTE MALDONADO	PED	1708	A	2016-10-14 11:41:16.627838-05	\N
170950	PUERTO QUITO	PUE	1709	A	2016-10-14 11:41:16.627838-05	\N
180101	ATOCHA – FICOA	ATO	1801	A	2016-10-14 11:41:16.627838-05	\N
180102	CELIANO MONGE	CEL	1801	A	2016-10-14 11:41:16.627838-05	\N
180103	HUACHI CHICO	HUA	1801	A	2016-10-14 11:41:16.627838-05	\N
180104	HUACHI LORETO	HUA	1801	A	2016-10-14 11:41:16.627838-05	\N
180105	LA MERCED	LA 	1801	A	2016-10-14 11:41:16.627838-05	\N
180106	LA PENÍNSULA	LA 	1801	A	2016-10-14 11:41:16.627838-05	\N
180107	MATRIZ	MAT	1801	A	2016-10-14 11:41:16.627838-05	\N
180108	PISHILATA	PIS	1801	A	2016-10-14 11:41:16.627838-05	\N
180109	SAN FRANCISCO	SAN	1801	A	2016-10-14 11:41:16.627838-05	\N
180150	AMBATO	AMB	1801	A	2016-10-14 11:41:16.627838-05	\N
180151	AMBATILLO	AMB	1801	A	2016-10-14 11:41:16.627838-05	\N
180152	ATAHUALPA (CHISALATA)	ATA	1801	A	2016-10-14 11:41:16.627838-05	\N
180153	AUGUSTO N. MARTÍNEZ (MUNDUGLEO)	AUG	1801	A	2016-10-14 11:41:16.627838-05	\N
180154	CONSTANTINO FERNÁNDEZ (CAB. EN CULLITAHUA)	CON	1801	A	2016-10-14 11:41:16.627838-05	\N
180155	HUACHI GRANDE	HUA	1801	A	2016-10-14 11:41:16.627838-05	\N
180156	IZAMBA	IZA	1801	A	2016-10-14 11:41:16.627838-05	\N
180157	JUAN BENIGNO VELA	JUA	1801	A	2016-10-14 11:41:16.627838-05	\N
180158	MONTALVO	MON	1801	A	2016-10-14 11:41:16.627838-05	\N
180159	PASA	PAS	1801	A	2016-10-14 11:41:16.627838-05	\N
180160	PICAIGUA	PIC	1801	A	2016-10-14 11:41:16.627838-05	\N
180161	PILAGÜÍN (PILAHÜÍN)	PIL	1801	A	2016-10-14 11:41:16.627838-05	\N
180162	QUISAPINCHA (QUIZAPINCHA)	QUI	1801	A	2016-10-14 11:41:16.627838-05	\N
180163	SAN BARTOLOMÉ DE PINLLOG	SAN	1801	A	2016-10-14 11:41:16.627838-05	\N
180164	SAN FERNANDO (PASA SAN FERNANDO)	SAN	1801	A	2016-10-14 11:41:16.627838-05	\N
180165	SANTA ROSA	SAN	1801	A	2016-10-14 11:41:16.627838-05	\N
180166	TOTORAS	TOT	1801	A	2016-10-14 11:41:16.627838-05	\N
180167	CUNCHIBAMBA	CUN	1801	A	2016-10-14 11:41:16.627838-05	\N
180168	UNAMUNCHO	UNA	1801	A	2016-10-14 11:41:16.627838-05	\N
180250	BAÑOS DE AGUA SANTA	BAÑ	1802	A	2016-10-14 11:41:16.627838-05	\N
180251	LLIGUA	LLI	1802	A	2016-10-14 11:41:16.627838-05	\N
180252	RÍO NEGRO	RÍO	1802	A	2016-10-14 11:41:16.627838-05	\N
180253	RÍO VERDE	RÍO	1802	A	2016-10-14 11:41:16.627838-05	\N
180254	ULBA	ULB	1802	A	2016-10-14 11:41:16.627838-05	\N
180350	CEVALLOS	CEV	1803	A	2016-10-14 11:41:16.627838-05	\N
180450	MOCHA	MOC	1804	A	2016-10-14 11:41:16.627838-05	\N
180451	PINGUILÍ	PIN	1804	A	2016-10-14 11:41:16.627838-05	\N
180550	PATATE	PAT	1805	A	2016-10-14 11:41:16.627838-05	\N
180551	EL TRIUNFO	EL 	1805	A	2016-10-14 11:41:16.627838-05	\N
180552	LOS ANDES (CAB. EN POATUG)	LOS	1805	A	2016-10-14 11:41:16.627838-05	\N
180553	SUCRE (CAB. EN SUCRE-PATATE URCU)	SUC	1805	A	2016-10-14 11:41:16.627838-05	\N
180650	QUERO	QUE	1806	A	2016-10-14 11:41:16.627838-05	\N
180651	RUMIPAMBA	RUM	1806	A	2016-10-14 11:41:16.627838-05	\N
180652	YANAYACU - MOCHAPATA (CAB. EN YANAYACU)	YAN	1806	A	2016-10-14 11:41:16.627838-05	\N
180701	PELILEO	PEL	1807	A	2016-10-14 11:41:16.627838-05	\N
180702	PELILEO GRANDE	PEL	1807	A	2016-10-14 11:41:16.627838-05	\N
180750	PELILEO	PEL	1807	A	2016-10-14 11:41:16.627838-05	\N
180751	BENÍTEZ (PACHANLICA)	BEN	1807	A	2016-10-14 11:41:16.627838-05	\N
180752	BOLÍVAR	BOL	1807	A	2016-10-14 11:41:16.627838-05	\N
180753	COTALÓ	COT	1807	A	2016-10-14 11:41:16.627838-05	\N
180754	CHIQUICHA (CAB. EN CHIQUICHA GRANDE)	CHI	1807	A	2016-10-14 11:41:16.627838-05	\N
180755	EL ROSARIO (RUMICHACA)	EL 	1807	A	2016-10-14 11:41:16.627838-05	\N
180756	GARCÍA MORENO (CHUMAQUI)	GAR	1807	A	2016-10-14 11:41:16.627838-05	\N
180757	GUAMBALÓ (HUAMBALÓ)	GUA	1807	A	2016-10-14 11:41:16.627838-05	\N
180758	SALASACA	SAL	1807	A	2016-10-14 11:41:16.627838-05	\N
180801	CIUDAD NUEVA	CIU	1808	A	2016-10-14 11:41:16.627838-05	\N
180802	PÍLLARO	PÍL	1808	A	2016-10-14 11:41:16.627838-05	\N
180850	PÍLLARO	PÍL	1808	A	2016-10-14 11:41:16.627838-05	\N
180851	BAQUERIZO MORENO	BAQ	1808	A	2016-10-14 11:41:16.627838-05	\N
180852	EMILIO MARÍA TERÁN (RUMIPAMBA)	EMI	1808	A	2016-10-14 11:41:16.627838-05	\N
180853	MARCOS ESPINEL (CHACATA)	MAR	1808	A	2016-10-14 11:41:16.627838-05	\N
180854	PRESIDENTE URBINA (CHAGRAPAMBA -PATZUCUL)	PRE	1808	A	2016-10-14 11:41:16.627838-05	\N
180855	SAN ANDRÉS	SAN	1808	A	2016-10-14 11:41:16.627838-05	\N
180856	SAN JOSÉ DE POALÓ	SAN	1808	A	2016-10-14 11:41:16.627838-05	\N
180857	SAN MIGUELITO	SAN	1808	A	2016-10-14 11:41:16.627838-05	\N
180950	TISALEO	TIS	1809	A	2016-10-14 11:41:16.627838-05	\N
180951	QUINCHICOTO	QUI	1809	A	2016-10-14 11:41:16.627838-05	\N
190101	EL LIMÓN	EL 	1901	A	2016-10-14 11:41:16.627838-05	\N
190102	ZAMORA	ZAM	1901	A	2016-10-14 11:41:16.627838-05	\N
190150	ZAMORA	ZAM	1901	A	2016-10-14 11:41:16.627838-05	\N
190151	CUMBARATZA	CUM	1901	A	2016-10-14 11:41:16.627838-05	\N
190152	GUADALUPE	GUA	1901	A	2016-10-14 11:41:16.627838-05	\N
190153	IMBANA (LA VICTORIA DE IMBANA)	IMB	1901	A	2016-10-14 11:41:16.627838-05	\N
190154	PAQUISHA	PAQ	1901	A	2016-10-14 11:41:16.627838-05	\N
190155	SABANILLA	SAB	1901	A	2016-10-14 11:41:16.627838-05	\N
190156	TIMBARA	TIM	1901	A	2016-10-14 11:41:16.627838-05	\N
190157	ZUMBI	ZUM	1901	A	2016-10-14 11:41:16.627838-05	\N
190158	SAN CARLOS DE LAS MINAS	SAN	1901	A	2016-10-14 11:41:16.627838-05	\N
190250	ZUMBA	ZUM	1902	A	2016-10-14 11:41:16.627838-05	\N
190251	CHITO	CHI	1902	A	2016-10-14 11:41:16.627838-05	\N
190252	EL CHORRO	EL 	1902	A	2016-10-14 11:41:16.627838-05	\N
190253	EL PORVENIR DEL CARMEN	EL 	1902	A	2016-10-14 11:41:16.627838-05	\N
190254	LA CHONTA	LA 	1902	A	2016-10-14 11:41:16.627838-05	\N
190255	PALANDA	PAL	1902	A	2016-10-14 11:41:16.627838-05	\N
190256	PUCAPAMBA	PUC	1902	A	2016-10-14 11:41:16.627838-05	\N
190257	SAN FRANCISCO DEL VERGEL	SAN	1902	A	2016-10-14 11:41:16.627838-05	\N
190258	VALLADOLID	VAL	1902	A	2016-10-14 11:41:16.627838-05	\N
190259	SAN ANDRÉS	SAN	1902	A	2016-10-14 11:41:16.627838-05	\N
190350	GUAYZIMI	GUA	1903	A	2016-10-14 11:41:16.627838-05	\N
190351	ZURMI	ZUR	1903	A	2016-10-14 11:41:16.627838-05	\N
190352	NUEVO PARAÍSO	NUE	1903	A	2016-10-14 11:41:16.627838-05	\N
190450	28 DE MAYO (SAN JOSÉ DE YACUAMBI)	28 	1904	A	2016-10-14 11:41:16.627838-05	\N
190451	LA PAZ	LA 	1904	A	2016-10-14 11:41:16.627838-05	\N
190452	TUTUPALI	TUT	1904	A	2016-10-14 11:41:16.627838-05	\N
190550	YANTZAZA (YANZATZA)	YAN	1905	A	2016-10-14 11:41:16.627838-05	\N
190551	CHICAÑA	CHI	1905	A	2016-10-14 11:41:16.627838-05	\N
190552	EL PANGUI	EL 	1905	A	2016-10-14 11:41:16.627838-05	\N
190553	LOS ENCUENTROS	LOS	1905	A	2016-10-14 11:41:16.627838-05	\N
190650	EL PANGUI	EL 	1906	A	2016-10-14 11:41:16.627838-05	\N
190651	EL GUISME	EL 	1906	A	2016-10-14 11:41:16.627838-05	\N
190652	PACHICUTZA	PAC	1906	A	2016-10-14 11:41:16.627838-05	\N
190653	TUNDAYME	TUN	1906	A	2016-10-14 11:41:16.627838-05	\N
190750	ZUMBI	ZUM	1907	A	2016-10-14 11:41:16.627838-05	\N
190751	PAQUISHA	PAQ	1907	A	2016-10-14 11:41:16.627838-05	\N
190752	TRIUNFO-DORADO	TRI	1907	A	2016-10-14 11:41:16.627838-05	\N
190753	PANGUINTZA	PAN	1907	A	2016-10-14 11:41:16.627838-05	\N
190850	PALANDA	PAL	1908	A	2016-10-14 11:41:16.627838-05	\N
190851	EL PORVENIR DEL CARMEN	EL 	1908	A	2016-10-14 11:41:16.627838-05	\N
190852	SAN FRANCISCO DEL VERGEL	SAN	1908	A	2016-10-14 11:41:16.627838-05	\N
190853	VALLADOLID	VAL	1908	A	2016-10-14 11:41:16.627838-05	\N
190854	LA CANELA	LA 	1908	A	2016-10-14 11:41:16.627838-05	\N
190950	PAQUISHA	PAQ	1909	A	2016-10-14 11:41:16.627838-05	\N
190951	BELLAVISTA	BEL	1909	A	2016-10-14 11:41:16.627838-05	\N
190952	NUEVO QUITO	NUE	1909	A	2016-10-14 11:41:16.627838-05	\N
200150	PUERTO BAQUERIZO MORENO	PUE	2001	A	2016-10-14 11:41:16.627838-05	\N
200151	EL PROGRESO	EL 	2001	A	2016-10-14 11:41:16.627838-05	\N
200152	ISLA SANTA MARÍA (FLOREANA) (CAB. EN PTO. VELASCO IBARRA)	ISL	2001	A	2016-10-14 11:41:16.627838-05	\N
200250	PUERTO VILLAMIL	PUE	2002	A	2016-10-14 11:41:16.627838-05	\N
200251	TOMÁS DE BERLANGA (SANTO TOMÁS)	TOM	2002	A	2016-10-14 11:41:16.627838-05	\N
200350	PUERTO AYORA	PUE	2003	A	2016-10-14 11:41:16.627838-05	\N
200351	BELLAVISTA	BEL	2003	A	2016-10-14 11:41:16.627838-05	\N
200352	SANTA ROSA (INCLUYE LA ISLA BALTRA)	SAN	2003	A	2016-10-14 11:41:16.627838-05	\N
210150	NUEVA LOJA	NUE	2101	A	2016-10-14 11:41:16.627838-05	\N
210151	CUYABENO	CUY	2101	A	2016-10-14 11:41:16.627838-05	\N
210152	DURENO	DUR	2101	A	2016-10-14 11:41:16.627838-05	\N
210153	GENERAL FARFÁN	GEN	2101	A	2016-10-14 11:41:16.627838-05	\N
210154	TARAPOA	TAR	2101	A	2016-10-14 11:41:16.627838-05	\N
210155	EL ENO	EL 	2101	A	2016-10-14 11:41:16.627838-05	\N
210156	PACAYACU	PAC	2101	A	2016-10-14 11:41:16.627838-05	\N
210157	JAMBELÍ	JAM	2101	A	2016-10-14 11:41:16.627838-05	\N
210158	SANTA CECILIA	SAN	2101	A	2016-10-14 11:41:16.627838-05	\N
210159	AGUAS NEGRAS	AGU	2101	A	2016-10-14 11:41:16.627838-05	\N
210250	EL DORADO DE CASCALES	EL 	2102	A	2016-10-14 11:41:16.627838-05	\N
210251	EL REVENTADOR	EL 	2102	A	2016-10-14 11:41:16.627838-05	\N
210252	GONZALO PIZARRO	GON	2102	A	2016-10-14 11:41:16.627838-05	\N
210253	LUMBAQUÍ	LUM	2102	A	2016-10-14 11:41:16.627838-05	\N
210254	PUERTO LIBRE	PUE	2102	A	2016-10-14 11:41:16.627838-05	\N
210255	SANTA ROSA DE SUCUMBÍOS	SAN	2102	A	2016-10-14 11:41:16.627838-05	\N
210350	PUERTO EL CARMEN DEL PUTUMAYO	PUE	2103	A	2016-10-14 11:41:16.627838-05	\N
210351	PALMA ROJA	PAL	2103	A	2016-10-14 11:41:16.627838-05	\N
210352	PUERTO BOLÍVAR (PUERTO MONTÚFAR)	PUE	2103	A	2016-10-14 11:41:16.627838-05	\N
210353	PUERTO RODRÍGUEZ	PUE	2103	A	2016-10-14 11:41:16.627838-05	\N
210354	SANTA ELENA	SAN	2103	A	2016-10-14 11:41:16.627838-05	\N
210450	SHUSHUFINDI	SHU	2104	A	2016-10-14 11:41:16.627838-05	\N
210451	LIMONCOCHA	LIM	2104	A	2016-10-14 11:41:16.627838-05	\N
210452	PAÑACOCHA	PAÑ	2104	A	2016-10-14 11:41:16.627838-05	\N
210453	SAN ROQUE (CAB. EN SAN VICENTE)	SAN	2104	A	2016-10-14 11:41:16.627838-05	\N
210454	SAN PEDRO DE LOS COFANES	SAN	2104	A	2016-10-14 11:41:16.627838-05	\N
210455	SIETE DE JULIO	SIE	2104	A	2016-10-14 11:41:16.627838-05	\N
210550	LA BONITA	LA 	2105	A	2016-10-14 11:41:16.627838-05	\N
210551	EL PLAYÓN DE SAN FRANCISCO	EL 	2105	A	2016-10-14 11:41:16.627838-05	\N
210552	LA SOFÍA	LA 	2105	A	2016-10-14 11:41:16.627838-05	\N
210553	ROSA FLORIDA	ROS	2105	A	2016-10-14 11:41:16.627838-05	\N
210554	SANTA BÁRBARA	SAN	2105	A	2016-10-14 11:41:16.627838-05	\N
210650	EL DORADO DE CASCALES	EL 	2106	A	2016-10-14 11:41:16.627838-05	\N
210651	SANTA ROSA DE SUCUMBÍOS	SAN	2106	A	2016-10-14 11:41:16.627838-05	\N
210652	SEVILLA	SEV	2106	A	2016-10-14 11:41:16.627838-05	\N
210750	TARAPOA	TAR	2107	A	2016-10-14 11:41:16.627838-05	\N
210751	CUYABENO	CUY	2107	A	2016-10-14 11:41:16.627838-05	\N
210752	AGUAS NEGRAS	AGU	2107	A	2016-10-14 11:41:16.627838-05	\N
220150	PUERTO FRANCISCO DE ORELLANA (EL COCA)	PUE	2201	A	2016-10-14 11:41:16.627838-05	\N
220151	DAYUMA	DAY	2201	A	2016-10-14 11:41:16.627838-05	\N
220152	TARACOA (NUEVA ESPERANZA: YUCA)	TAR	2201	A	2016-10-14 11:41:16.627838-05	\N
220153	ALEJANDRO LABAKA	ALE	2201	A	2016-10-14 11:41:16.627838-05	\N
220154	EL DORADO	EL 	2201	A	2016-10-14 11:41:16.627838-05	\N
220155	EL EDÉN	EL 	2201	A	2016-10-14 11:41:16.627838-05	\N
220156	GARCÍA MORENO	GAR	2201	A	2016-10-14 11:41:16.627838-05	\N
220157	INÉS ARANGO (CAB. EN WESTERN)	INÉ	2201	A	2016-10-14 11:41:16.627838-05	\N
220158	LA BELLEZA	LA 	2201	A	2016-10-14 11:41:16.627838-05	\N
220159	NUEVO PARAÍSO (CAB. EN UNIÓN	NUE	2201	A	2016-10-14 11:41:16.627838-05	\N
220160	SAN JOSÉ DE GUAYUSA	SAN	2201	A	2016-10-14 11:41:16.627838-05	\N
220161	SAN LUIS DE ARMENIA	SAN	2201	A	2016-10-14 11:41:16.627838-05	\N
220201	TIPITINI	TIP	2202	A	2016-10-14 11:41:16.627838-05	\N
220250	NUEVO ROCAFUERTE	NUE	2202	A	2016-10-14 11:41:16.627838-05	\N
220251	CAPITÁN AUGUSTO RIVADENEYRA	CAP	2202	A	2016-10-14 11:41:16.627838-05	\N
220252	CONONACO	CON	2202	A	2016-10-14 11:41:16.627838-05	\N
220253	SANTA MARÍA DE HUIRIRIMA	SAN	2202	A	2016-10-14 11:41:16.627838-05	\N
220254	TIPUTINI	TIP	2202	A	2016-10-14 11:41:16.627838-05	\N
220255	YASUNÍ	YAS	2202	A	2016-10-14 11:41:16.627838-05	\N
220350	LA JOYA DE LOS SACHAS	LA 	2203	A	2016-10-14 11:41:16.627838-05	\N
220351	ENOKANQUI	ENO	2203	A	2016-10-14 11:41:16.627838-05	\N
220352	POMPEYA	POM	2203	A	2016-10-14 11:41:16.627838-05	\N
220353	SAN CARLOS	SAN	2203	A	2016-10-14 11:41:16.627838-05	\N
220354	SAN SEBASTIÁN DEL COCA	SAN	2203	A	2016-10-14 11:41:16.627838-05	\N
220355	LAGO SAN PEDRO	LAG	2203	A	2016-10-14 11:41:16.627838-05	\N
220356	RUMIPAMBA	RUM	2203	A	2016-10-14 11:41:16.627838-05	\N
220357	TRES DE NOVIEMBRE	TRE	2203	A	2016-10-14 11:41:16.627838-05	\N
220358	UNIÓN MILAGREÑA	UNI	2203	A	2016-10-14 11:41:16.627838-05	\N
220450	LORETO	LOR	2204	A	2016-10-14 11:41:16.627838-05	\N
220451	AVILA (CAB. EN HUIRUNO)	AVI	2204	A	2016-10-14 11:41:16.627838-05	\N
220452	PUERTO MURIALDO	PUE	2204	A	2016-10-14 11:41:16.627838-05	\N
220453	SAN JOSÉ DE PAYAMINO	SAN	2204	A	2016-10-14 11:41:16.627838-05	\N
220454	SAN JOSÉ DE DAHUANO	SAN	2204	A	2016-10-14 11:41:16.627838-05	\N
220455	SAN VICENTE DE HUATICOCHA	SAN	2204	A	2016-10-14 11:41:16.627838-05	\N
230101	ABRAHAM CALAZACÓN	ABR	2301	A	2016-10-14 11:41:16.627838-05	\N
230102	BOMBOLÍ	BOM	2301	A	2016-10-14 11:41:16.627838-05	\N
230103	CHIGUILPE	CHI	2301	A	2016-10-14 11:41:16.627838-05	\N
230104	RÍO TOACHI	RÍO	2301	A	2016-10-14 11:41:16.627838-05	\N
230105	RÍO VERDE	RÍO	2301	A	2016-10-14 11:41:16.627838-05	\N
230106	SANTO DOMINGO DE LOS COLORADOS	SAN	2301	A	2016-10-14 11:41:16.627838-05	\N
230107	ZARACAY	ZAR	2301	A	2016-10-14 11:41:16.627838-05	\N
230150	SANTO DOMINGO DE LOS COLORADOS	SAN	2301	A	2016-10-14 11:41:16.627838-05	\N
230151	ALLURIQUÍN	ALL	2301	A	2016-10-14 11:41:16.627838-05	\N
230152	PUERTO LIMÓN	PUE	2301	A	2016-10-14 11:41:16.627838-05	\N
230153	LUZ DE AMÉRICA	LUZ	2301	A	2016-10-14 11:41:16.627838-05	\N
230154	SAN JACINTO DEL BÚA	SAN	2301	A	2016-10-14 11:41:16.627838-05	\N
230155	VALLE HERMOSO	VAL	2301	A	2016-10-14 11:41:16.627838-05	\N
230156	EL ESFUERZO	EL 	2301	A	2016-10-14 11:41:16.627838-05	\N
230157	SANTA MARÍA DEL TOACHI	SAN	2301	A	2016-10-14 11:41:16.627838-05	\N
240101	BALLENITA	BAL	2401	A	2016-10-14 11:41:16.627838-05	\N
240102	SANTA ELENA	SAN	2401	A	2016-10-14 11:41:16.627838-05	\N
240150	SANTA ELENA	SAN	2401	A	2016-10-14 11:41:16.627838-05	\N
240151	ATAHUALPA	ATA	2401	A	2016-10-14 11:41:16.627838-05	\N
240152	COLONCHE	COL	2401	A	2016-10-14 11:41:16.627838-05	\N
240153	CHANDUY	CHA	2401	A	2016-10-14 11:41:16.627838-05	\N
240154	MANGLARALTO	MAN	2401	A	2016-10-14 11:41:16.627838-05	\N
240155	SIMÓN BOLÍVAR (JULIO MORENO)	SIM	2401	A	2016-10-14 11:41:16.627838-05	\N
240156	SAN JOSÉ DE ANCÓN	SAN	2401	A	2016-10-14 11:41:16.627838-05	\N
240250	LA LIBERTAD	LA 	2402	A	2016-10-14 11:41:16.627838-05	\N
240301	CARLOS ESPINOZA LARREA	CAR	2403	A	2016-10-14 11:41:16.627838-05	\N
240302	GRAL. ALBERTO ENRÍQUEZ GALLO	GRA	2403	A	2016-10-14 11:41:16.627838-05	\N
240303	VICENTE ROCAFUERTE	VIC	2403	A	2016-10-14 11:41:16.627838-05	\N
240304	SANTA ROSA	SAN	2403	A	2016-10-14 11:41:16.627838-05	\N
240350	SALINAS	SAL	2403	A	2016-10-14 11:41:16.627838-05	\N
240351	ANCONCITO	ANC	2403	A	2016-10-14 11:41:16.627838-05	\N
240352	JOSÉ LUIS TAMAYO (MUEY)	JOS	2403	A	2016-10-14 11:41:16.627838-05	\N
900151	LAS GOLONDRINAS	LAS	9001	A	2016-10-14 11:41:16.627838-05	\N
900351	MANGA DEL CURA	MAN	9003	A	2016-10-14 11:41:16.627838-05	\N
900451	EL PIEDRERO	EL 	9004	A	2016-10-14 11:41:16.627838-05	\N
080265	SANTA LUCÍA DE LAS PEÑAS	SAN	0802	A	2016-10-18 10:02:22.031498-05	\N
01	AZUAY	AZU	00	A	2016-10-14 11:41:16.627838-05	(072)
0101	CUENCA	CUE	01	A	2016-10-14 11:41:16.627838-05	\N
010101	BELLAVISTA	BEL	0101	A	2016-10-14 11:41:16.627838-05	\N
09	GUAYAS	GUA	00	A	2016-10-14 11:41:16.627838-05	(042)
14	MORONA SANTIAGO	MOR	00	A	2016-10-14 11:41:16.627838-05	(072)
22	ORELLANA	ORE	00	A	2016-10-14 11:41:16.627838-05	(062)
\.


--
-- TOC entry 3456 (class 0 OID 16611)
-- Dependencies: 236
-- Data for Name: personas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY personas (id, ci_docuemto, pasaporte, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, id_localidad, calle, transversal, numero, ruc) FROM stdin;
\.


--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 237
-- Name: personas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('personas_id_seq', 1, false);


--
-- TOC entry 3458 (class 0 OID 16619)
-- Dependencies: 238
-- Data for Name: telefonos_personas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY telefonos_personas (id, id_persona, numero, fecha, estado) FROM stdin;
\.


--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 239
-- Name: telefonos_personas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('telefonos_personas_id_seq', 1, false);


SET search_path = usuarios, pg_catalog;

--
-- TOC entry 3460 (class 0 OID 16632)
-- Dependencies: 241
-- Data for Name: usuarios; Type: TABLE DATA; Schema: usuarios; Owner: postgres
--

COPY usuarios (id, nick, clave_clave, id_estado, fecha_creacion) FROM stdin;
1001843646001	MONTESDEOCA_BENAVIDES_ED_1001843646001	$2y$10$V9svrCj5hZX/vN3VAK7OuuIiysPikTpo6WFaxufxH3iFBhXgD8KI.	A	2016-10-20 09:28:20.967768-05
\.


SET search_path = ventas, pg_catalog;

--
-- TOC entry 3461 (class 0 OID 16638)
-- Dependencies: 242
-- Data for Name: detalle_factura; Type: TABLE DATA; Schema: ventas; Owner: postgres
--

COPY detalle_factura (id, id_factura, id_producto) FROM stdin;
\.


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 243
-- Name: detalle_factura_id_seq; Type: SEQUENCE SET; Schema: ventas; Owner: postgres
--

SELECT pg_catalog.setval('detalle_factura_id_seq', 1, false);


--
-- TOC entry 3463 (class 0 OID 16643)
-- Dependencies: 244
-- Data for Name: facturas; Type: TABLE DATA; Schema: ventas; Owner: postgres
--

COPY facturas (id, numero_factura, numero_autorizacion, ruc_emisor, denominacion, direccion_matriz, direccion_sucursal, fecha_autorizacion, adquiriente, ruc_ci_pas, fecha_emicion, guia_remision, fecha_caducidad_factura, datos_imprenta, subtotal_iva, subtotal_sin_iva, descuentos, valor_iva, ice, total, estado) FROM stdin;
\.


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 245
-- Name: facturas_id_seq; Type: SEQUENCE SET; Schema: ventas; Owner: postgres
--

SELECT pg_catalog.setval('facturas_id_seq', 1, false);


--
-- TOC entry 3465 (class 0 OID 16652)
-- Dependencies: 246
-- Data for Name: formas_pago; Type: TABLE DATA; Schema: ventas; Owner: postgres
--

COPY formas_pago (id, nombre, descripcion, estado, fecha) FROM stdin;
\.


--
-- TOC entry 3466 (class 0 OID 16658)
-- Dependencies: 247
-- Data for Name: formas_pago_facturas; Type: TABLE DATA; Schema: ventas; Owner: postgres
--

COPY formas_pago_facturas (id, id_factura, id_formas_pago) FROM stdin;
\.


--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 248
-- Name: formas_pago_facturas_id_seq; Type: SEQUENCE SET; Schema: ventas; Owner: postgres
--

SELECT pg_catalog.setval('formas_pago_facturas_id_seq', 1, false);


--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 249
-- Name: formas_pago_id_seq; Type: SEQUENCE SET; Schema: ventas; Owner: postgres
--

SELECT pg_catalog.setval('formas_pago_id_seq', 1, false);


--
-- TOC entry 3469 (class 0 OID 16665)
-- Dependencies: 250
-- Data for Name: producto_descuento; Type: TABLE DATA; Schema: ventas; Owner: postgres
--

COPY producto_descuento (id, id_producto, id_catalogo, estado, fecha_fin_descuento, fecha_inicio_descuento) FROM stdin;
\.


--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 251
-- Name: producto_descuento_id_seq; Type: SEQUENCE SET; Schema: ventas; Owner: postgres
--

SELECT pg_catalog.setval('producto_descuento_id_seq', 1, false);


SET search_path = auditoria, pg_catalog;

--
-- TOC entry 3159 (class 2606 OID 16708)
-- Name: auditoria_pk; Type: CONSTRAINT; Schema: auditoria; Owner: postgres
--

ALTER TABLE ONLY auditoria
    ADD CONSTRAINT auditoria_pk PRIMARY KEY (id);


--
-- TOC entry 3161 (class 2606 OID 16710)
-- Name: ingreso_usuarios_PK; Type: CONSTRAINT; Schema: auditoria; Owner: postgres
--

ALTER TABLE ONLY ingresos_usuarios
    ADD CONSTRAINT "ingreso_usuarios_PK" PRIMARY KEY (id);


SET search_path = contabilidad, pg_catalog;

--
-- TOC entry 3163 (class 2606 OID 16712)
-- Name: ambito_impuesto_PK; Type: CONSTRAINT; Schema: contabilidad; Owner: postgres
--

ALTER TABLE ONLY ambitos_impuestos
    ADD CONSTRAINT "ambito_impuesto_PK" PRIMARY KEY (id);


--
-- TOC entry 3165 (class 2606 OID 16714)
-- Name: grupo_impuesto_PK; Type: CONSTRAINT; Schema: contabilidad; Owner: postgres
--

ALTER TABLE ONLY grupo_impuestos
    ADD CONSTRAINT "grupo_impuesto_PK" PRIMARY KEY (id);


--
-- TOC entry 3167 (class 2606 OID 16716)
-- Name: impuesto_PK; Type: CONSTRAINT; Schema: contabilidad; Owner: postgres
--

ALTER TABLE ONLY impuestos
    ADD CONSTRAINT "impuesto_PK" PRIMARY KEY (id);


SET search_path = inventario, pg_catalog;

--
-- TOC entry 3191 (class 2606 OID 16720)
-- Name: bodega_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY sucursal
    ADD CONSTRAINT "bodega_PK" PRIMARY KEY (id);


--
-- TOC entry 3171 (class 2606 OID 16722)
-- Name: categorias_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY categorias
    ADD CONSTRAINT "categorias_PK" PRIMARY KEY (id);


--
-- TOC entry 3173 (class 2606 OID 16724)
-- Name: descripcion_producto_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY descripcion_producto
    ADD CONSTRAINT "descripcion_producto_PK" PRIMARY KEY (id);


--
-- TOC entry 3175 (class 2606 OID 16726)
-- Name: estado_descriptivo_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY estado_descriptivo
    ADD CONSTRAINT "estado_descriptivo_PK" PRIMARY KEY (id);


--
-- TOC entry 3177 (class 2606 OID 16728)
-- Name: garantia_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY garantias
    ADD CONSTRAINT "garantia_PK" PRIMARY KEY (id);


--
-- TOC entry 3169 (class 2606 OID 16730)
-- Name: id; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY catalogos
    ADD CONSTRAINT id PRIMARY KEY (id);


--
-- TOC entry 3179 (class 2606 OID 16732)
-- Name: imagenes_productos_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY imagenes_productos
    ADD CONSTRAINT "imagenes_productos_PK" PRIMARY KEY (id);


--
-- TOC entry 3181 (class 2606 OID 16734)
-- Name: marca_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY marcas
    ADD CONSTRAINT "marca_PK" PRIMARY KEY (id);


--
-- TOC entry 3183 (class 2606 OID 16736)
-- Name: modelos_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY modelos
    ADD CONSTRAINT "modelos_PK" PRIMARY KEY (id);


--
-- TOC entry 3185 (class 2606 OID 16738)
-- Name: producto_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY productos
    ADD CONSTRAINT "producto_PK" PRIMARY KEY (id);


--
-- TOC entry 3187 (class 2606 OID 16740)
-- Name: productos_impuestos_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY productos_impuestos
    ADD CONSTRAINT "productos_impuestos_PK" PRIMARY KEY (id);


--
-- TOC entry 3189 (class 2606 OID 16742)
-- Name: proveedores_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY proveedores
    ADD CONSTRAINT "proveedores_PK" PRIMARY KEY (id);


--
-- TOC entry 3195 (class 2606 OID 16744)
-- Name: tipo_catalogo_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_catalogos
    ADD CONSTRAINT "tipo_catalogo_PK" PRIMARY KEY (id);


--
-- TOC entry 3193 (class 2606 OID 16746)
-- Name: tipo_consumo_pkey; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipo_consumo
    ADD CONSTRAINT tipo_consumo_pkey PRIMARY KEY (id);


--
-- TOC entry 3201 (class 2606 OID 16748)
-- Name: tipo_imagen_producto_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_imagenes_productos
    ADD CONSTRAINT "tipo_imagen_producto_PK" PRIMARY KEY (id);


--
-- TOC entry 3203 (class 2606 OID 16750)
-- Name: tipo_pruducto_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_productos
    ADD CONSTRAINT "tipo_pruducto_PK" PRIMARY KEY (id);


--
-- TOC entry 3197 (class 2606 OID 16752)
-- Name: tipos_categorias_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_categorias
    ADD CONSTRAINT "tipos_categorias_PK" PRIMARY KEY (id);


--
-- TOC entry 3199 (class 2606 OID 16754)
-- Name: tipos_garantia_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_garantias
    ADD CONSTRAINT "tipos_garantia_PK" PRIMARY KEY (id);


--
-- TOC entry 3205 (class 2606 OID 16756)
-- Name: ubicacion_PK; Type: CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY ubicaciones
    ADD CONSTRAINT "ubicacion_PK" PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- TOC entry 3207 (class 2606 OID 16758)
-- Name: estado_PK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "estado_PK" PRIMARY KEY (id);


--
-- TOC entry 3209 (class 2606 OID 16760)
-- Name: localidad_PK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY localidades
    ADD CONSTRAINT "localidad_PK" PRIMARY KEY (id);


--
-- TOC entry 3211 (class 2606 OID 16762)
-- Name: persona_PK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY personas
    ADD CONSTRAINT "persona_PK" PRIMARY KEY (id);


--
-- TOC entry 3213 (class 2606 OID 16764)
-- Name: telefonos_personas_PK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY telefonos_personas
    ADD CONSTRAINT "telefonos_personas_PK" PRIMARY KEY (id);


SET search_path = usuarios, pg_catalog;

--
-- TOC entry 3215 (class 2606 OID 16766)
-- Name: usuarios_PK; Type: CONSTRAINT; Schema: usuarios; Owner: postgres
--

ALTER TABLE ONLY usuarios
    ADD CONSTRAINT "usuarios_PK" PRIMARY KEY (id);


SET search_path = ventas, pg_catalog;

--
-- TOC entry 3217 (class 2606 OID 16768)
-- Name: detalle_factura_pkey; Type: CONSTRAINT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY detalle_factura
    ADD CONSTRAINT detalle_factura_pkey PRIMARY KEY (id);


--
-- TOC entry 3219 (class 2606 OID 16770)
-- Name: factura_PK; Type: CONSTRAINT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY facturas
    ADD CONSTRAINT "factura_PK" PRIMARY KEY (id);


--
-- TOC entry 3223 (class 2606 OID 16772)
-- Name: formas_pago_facturas_PK; Type: CONSTRAINT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY formas_pago_facturas
    ADD CONSTRAINT "formas_pago_facturas_PK" PRIMARY KEY (id);


--
-- TOC entry 3221 (class 2606 OID 16774)
-- Name: formas_pago_pkey; Type: CONSTRAINT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY formas_pago
    ADD CONSTRAINT formas_pago_pkey PRIMARY KEY (id);


--
-- TOC entry 3225 (class 2606 OID 16776)
-- Name: producto_descuento_PK; Type: CONSTRAINT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY producto_descuento
    ADD CONSTRAINT "producto_descuento_PK" PRIMARY KEY (id);


SET search_path = contabilidad, pg_catalog;

--
-- TOC entry 3267 (class 2620 OID 16782)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: contabilidad; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON ambitos_impuestos FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3268 (class 2620 OID 16783)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: contabilidad; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON genealogia_impuestos FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3269 (class 2620 OID 16784)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: contabilidad; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON grupo_impuestos FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3270 (class 2620 OID 16785)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: contabilidad; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON impuestos FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


SET search_path = inventario, pg_catalog;

--
-- TOC entry 3272 (class 2620 OID 16786)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON categorias FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3273 (class 2620 OID 16787)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON descripcion_producto FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3274 (class 2620 OID 16788)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON estado_descriptivo FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3275 (class 2620 OID 16789)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON garantias FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3276 (class 2620 OID 16790)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON imagenes_productos FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3277 (class 2620 OID 16791)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON marcas FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3278 (class 2620 OID 16792)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON modelos FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3279 (class 2620 OID 16793)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON productos FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3280 (class 2620 OID 16794)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON productos_impuestos FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3281 (class 2620 OID 16795)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON proveedores FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3282 (class 2620 OID 16796)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON sucursal FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3284 (class 2620 OID 16797)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON tipos_categorias FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3285 (class 2620 OID 16798)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON tipos_garantias FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3286 (class 2620 OID 16799)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON tipos_imagenes_productos FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3287 (class 2620 OID 16800)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON tipos_productos FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3288 (class 2620 OID 16801)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON ubicaciones FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3283 (class 2620 OID 16802)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON tipos_catalogos FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


--
-- TOC entry 3271 (class 2620 OID 16803)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: inventario; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON catalogos FOR EACH ROW EXECUTE PROCEDURE public.fun_auditoria();


SET search_path = public, pg_catalog;

--
-- TOC entry 3289 (class 2620 OID 16804)
-- Name: estados_tg_audit; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER estados_tg_audit AFTER INSERT OR DELETE OR UPDATE ON estados FOR EACH ROW EXECUTE PROCEDURE fun_auditoria();


--
-- TOC entry 3291 (class 2620 OID 16805)
-- Name: localidades_tg_audit; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER localidades_tg_audit AFTER INSERT OR DELETE OR UPDATE ON localidades FOR EACH ROW EXECUTE PROCEDURE fun_auditoria();


--
-- TOC entry 3290 (class 2620 OID 16806)
-- Name: personas_tg_audit; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER personas_tg_audit AFTER INSERT OR DELETE OR UPDATE ON estados FOR EACH ROW EXECUTE PROCEDURE fun_auditoria();


SET search_path = contabilidad, pg_catalog;

--
-- TOC entry 3230 (class 2606 OID 16807)
-- Name: ambito_FK; Type: FK CONSTRAINT; Schema: contabilidad; Owner: postgres
--

ALTER TABLE ONLY impuestos
    ADD CONSTRAINT "ambito_FK" FOREIGN KEY (ambito) REFERENCES ambitos_impuestos(id);


--
-- TOC entry 3229 (class 2606 OID 16812)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: contabilidad; Owner: postgres
--

ALTER TABLE ONLY grupo_impuestos
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3226 (class 2606 OID 16817)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: contabilidad; Owner: postgres
--

ALTER TABLE ONLY ambitos_impuestos
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3231 (class 2606 OID 16822)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: contabilidad; Owner: postgres
--

ALTER TABLE ONLY impuestos
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3227 (class 2606 OID 16827)
-- Name: hijo_impuesto_FK; Type: FK CONSTRAINT; Schema: contabilidad; Owner: postgres
--

ALTER TABLE ONLY genealogia_impuestos
    ADD CONSTRAINT "hijo_impuesto_FK" FOREIGN KEY (id_impuesto_hijo) REFERENCES impuestos(id);


--
-- TOC entry 3228 (class 2606 OID 16832)
-- Name: padre_impuesto_FK; Type: FK CONSTRAINT; Schema: contabilidad; Owner: postgres
--

ALTER TABLE ONLY genealogia_impuestos
    ADD CONSTRAINT "padre_impuesto_FK" FOREIGN KEY (id_impuesto_padre) REFERENCES impuestos(id);


SET search_path = inventario, pg_catalog;

--
-- TOC entry 3232 (class 2606 OID 16852)
-- Name: Catalogos_producto_fkey; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY catalogos
    ADD CONSTRAINT "Catalogos_producto_fkey" FOREIGN KEY (producto) REFERENCES productos(id);


--
-- TOC entry 3244 (class 2606 OID 16857)
-- Name: categoria_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY productos
    ADD CONSTRAINT "categoria_FK" FOREIGN KEY (categoria) REFERENCES categorias(id);


--
-- TOC entry 3257 (class 2606 OID 16862)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_imagenes_productos
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3239 (class 2606 OID 16867)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY imagenes_productos
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3253 (class 2606 OID 16872)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY sucursal
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3237 (class 2606 OID 16877)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY garantias
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3255 (class 2606 OID 16882)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_categorias
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3242 (class 2606 OID 16887)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY marcas
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3243 (class 2606 OID 16892)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY modelos
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3236 (class 2606 OID 16897)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY estado_descriptivo
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3259 (class 2606 OID 16902)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY ubicaciones
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3258 (class 2606 OID 16907)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_productos
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3254 (class 2606 OID 16912)
-- Name: estado_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_catalogos
    ADD CONSTRAINT "estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3245 (class 2606 OID 16917)
-- Name: estado_descriptivo_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY productos
    ADD CONSTRAINT "estado_descriptivo_FK" FOREIGN KEY (estado_descriptivo) REFERENCES estado_descriptivo(id);


--
-- TOC entry 3256 (class 2606 OID 16922)
-- Name: estados; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY tipos_garantias
    ADD CONSTRAINT estados FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3246 (class 2606 OID 16927)
-- Name: garantia_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY productos
    ADD CONSTRAINT "garantia_FK" FOREIGN KEY (garantia) REFERENCES categorias(id);


--
-- TOC entry 3251 (class 2606 OID 16932)
-- Name: impuesto_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY productos_impuestos
    ADD CONSTRAINT "impuesto_FK" FOREIGN KEY (inpuesto) REFERENCES contabilidad.ambitos_impuestos(id);


--
-- TOC entry 3247 (class 2606 OID 16937)
-- Name: marca_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY productos
    ADD CONSTRAINT "marca_FK" FOREIGN KEY (marca) REFERENCES marcas(id);


--
-- TOC entry 3248 (class 2606 OID 16942)
-- Name: modelo_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY productos
    ADD CONSTRAINT "modelo_FK" FOREIGN KEY (modelo) REFERENCES modelos(id);


--
-- TOC entry 3235 (class 2606 OID 16947)
-- Name: producto_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY descripcion_producto
    ADD CONSTRAINT "producto_FK" FOREIGN KEY (producto) REFERENCES productos(id);


--
-- TOC entry 3240 (class 2606 OID 16952)
-- Name: producto_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY imagenes_productos
    ADD CONSTRAINT "producto_FK" FOREIGN KEY (producto) REFERENCES productos(id);


--
-- TOC entry 3252 (class 2606 OID 16957)
-- Name: producto_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY productos_impuestos
    ADD CONSTRAINT "producto_FK" FOREIGN KEY (producto) REFERENCES productos(id);


--
-- TOC entry 3249 (class 2606 OID 16962)
-- Name: producto_tipo_consumo_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY productos
    ADD CONSTRAINT "producto_tipo_consumo_FK" FOREIGN KEY (tipo_consumo) REFERENCES tipo_consumo(id);


--
-- TOC entry 3233 (class 2606 OID 16967)
-- Name: tipo_catalogo_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY catalogos
    ADD CONSTRAINT "tipo_catalogo_FK" FOREIGN KEY (tipo_catalogo) REFERENCES tipos_catalogos(id);


--
-- TOC entry 3234 (class 2606 OID 16972)
-- Name: tipo_categoria_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY categorias
    ADD CONSTRAINT "tipo_categoria_FK" FOREIGN KEY (tipo_categoria) REFERENCES tipos_categorias(id);


--
-- TOC entry 3238 (class 2606 OID 16977)
-- Name: tipo_garantia_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY garantias
    ADD CONSTRAINT "tipo_garantia_FK" FOREIGN KEY (tipo_garantia) REFERENCES tipos_garantias(id);


--
-- TOC entry 3241 (class 2606 OID 16982)
-- Name: tipo_imagen_producto; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY imagenes_productos
    ADD CONSTRAINT tipo_imagen_producto FOREIGN KEY (tipo_imagen) REFERENCES tipos_imagenes_productos(id);


--
-- TOC entry 3250 (class 2606 OID 16987)
-- Name: ubicacion_FK; Type: FK CONSTRAINT; Schema: inventario; Owner: postgres
--

ALTER TABLE ONLY productos
    ADD CONSTRAINT "ubicacion_FK" FOREIGN KEY (ubicacion) REFERENCES ubicaciones(id);


SET search_path = public, pg_catalog;

--
-- TOC entry 3260 (class 2606 OID 16992)
-- Name: id_persona_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY telefonos_personas
    ADD CONSTRAINT "id_persona_FK" FOREIGN KEY (id_persona) REFERENCES auditoria.auditoria(id);


SET search_path = ventas, pg_catalog;

--
-- TOC entry 3261 (class 2606 OID 16997)
-- Name: detalle_factura_productos; Type: FK CONSTRAINT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY detalle_factura
    ADD CONSTRAINT detalle_factura_productos FOREIGN KEY (id_producto) REFERENCES inventario.productos(id);


--
-- TOC entry 3262 (class 2606 OID 17002)
-- Name: factura_estado_FK; Type: FK CONSTRAINT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY facturas
    ADD CONSTRAINT "factura_estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3263 (class 2606 OID 17007)
-- Name: forma_pago_estado_FK; Type: FK CONSTRAINT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY formas_pago
    ADD CONSTRAINT "forma_pago_estado_FK" FOREIGN KEY (estado) REFERENCES public.estados(id);


--
-- TOC entry 3264 (class 2606 OID 17012)
-- Name: formas_pago_formas_pago_FK; Type: FK CONSTRAINT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY formas_pago_facturas
    ADD CONSTRAINT "formas_pago_formas_pago_FK" FOREIGN KEY (id_formas_pago) REFERENCES formas_pago(id);


--
-- TOC entry 3265 (class 2606 OID 17017)
-- Name: producto_catalogo_catalogo; Type: FK CONSTRAINT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY producto_descuento
    ADD CONSTRAINT producto_catalogo_catalogo FOREIGN KEY (id_catalogo) REFERENCES inventario.catalogos(id);


--
-- TOC entry 3266 (class 2606 OID 17022)
-- Name: producto_descuento_producto_FK; Type: FK CONSTRAINT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY producto_descuento
    ADD CONSTRAINT "producto_descuento_producto_FK" FOREIGN KEY (id_producto) REFERENCES inventario.productos(id);


--
-- TOC entry 3478 (class 0 OID 0)
-- Dependencies: 13
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-11-24 15:58:29 ECT

--
-- PostgreSQL database dump complete
--


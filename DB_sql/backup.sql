--
-- PostgreSQL database dump
--

-- Dumped from database version 13.0
-- Dumped by pg_dump version 13.0

-- Started on 2021-01-05 17:17:58

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'ISO_8859_8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 644 (class 1247 OID 18912)
-- Name: operazioni; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.operazioni AS ENUM (
    'F',
    'S',
    'E'
);


ALTER TYPE public.operazioni OWNER TO postgres;

--
-- TOC entry 641 (class 1247 OID 18906)
-- Name: sessi; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.sessi AS ENUM (
    'M',
    'F'
);


ALTER TYPE public.sessi OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 200 (class 1259 OID 18919)
-- Name: associazione; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.associazione (
    codice character varying(20) NOT NULL,
    ragsoc character varying(80) NOT NULL,
    sito character varying(150) NOT NULL,
    email character varying(80) NOT NULL,
    password character varying(50) NOT NULL,
    CONSTRAINT associazione_email_check CHECK (((email)::text ~~ '%_@__%.__%'::text))
);


ALTER TABLE public.associazione OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 18990)
-- Name: campo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.campo (
    codass character varying(20) NOT NULL,
    id integer NOT NULL,
    cod_sede integer NOT NULL,
    tipologia integer NOT NULL,
    attrezzatura boolean DEFAULT false
);


ALTER TABLE public.campo OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 18937)
-- Name: citta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.citta (
    istat character(6) NOT NULL,
    cap character(5) NOT NULL,
    nome character varying(100) NOT NULL,
    provincia character(2) NOT NULL,
    regione character(3) NOT NULL
);


ALTER TABLE public.citta OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 18963)
-- Name: contratti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contratti (
    codass character varying(20) NOT NULL,
    cod_fornitore character(11) NOT NULL,
    data_inizio date NOT NULL,
    data_fine date
);


ALTER TABLE public.contratti OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 19022)
-- Name: dipendente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dipendente (
    codass character varying(20) NOT NULL,
    cf character(16) NOT NULL,
    nome character varying(80) NOT NULL,
    cognome character varying(80) NOT NULL,
    sesso public.sessi NOT NULL,
    data_nascita date NOT NULL,
    email character varying(80) NOT NULL,
    password character varying(50) NOT NULL,
    telefono character varying(12),
    grado integer NOT NULL,
    data_assunzione date NOT NULL,
    data_fine date,
    cod_sede integer NOT NULL,
    CONSTRAINT dipendente_email_check CHECK (((email)::text ~~ '%_@__%.__%'::text))
);


ALTER TABLE public.dipendente OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 19085)
-- Name: esborsi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.esborsi (
    codass character varying(20) NOT NULL,
    data timestamp without time zone NOT NULL,
    id_dipendente character(16) NOT NULL,
    id_fornitore character(16) NOT NULL,
    descrizione character varying(255)
);


ALTER TABLE public.esborsi OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 19069)
-- Name: fatture; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fatture (
    codass character varying(20) NOT NULL,
    data timestamp without time zone NOT NULL,
    id_dipendente character(16) NOT NULL,
    tesserato character(16) NOT NULL,
    descrizione character varying(255),
    progressivo integer NOT NULL,
    CONSTRAINT fatture_progressivo_check CHECK ((progressivo > 0))
);


ALTER TABLE public.fatture OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 18957)
-- Name: fornitore; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fornitore (
    piva character(11) NOT NULL,
    ragione_soc character varying(150) NOT NULL,
    email character varying(80) NOT NULL,
    telefono character varying(12),
    CONSTRAINT fornitore_email_check CHECK (((email)::text ~~ '%_@__%.__%'::text))
);


ALTER TABLE public.fornitore OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 19017)
-- Name: grado_dipendenti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grado_dipendenti (
    id integer NOT NULL,
    descrizione character varying(50) NOT NULL
);


ALTER TABLE public.grado_dipendenti OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 19043)
-- Name: pagamento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pagamento (
    codass character varying(20) NOT NULL,
    data timestamp without time zone NOT NULL,
    id_dipendente character(16) NOT NULL,
    importo money NOT NULL,
    tipo_operazione public.operazioni NOT NULL,
    CONSTRAINT pagamento_check CHECK (((((tipo_operazione = 'S'::public.operazioni) OR (tipo_operazione = 'E'::public.operazioni)) AND ((importo)::numeric < (0)::numeric)) OR ((tipo_operazione = 'F'::public.operazioni) AND ((importo)::numeric <> (0)::numeric))))
);


ALTER TABLE public.pagamento OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 19117)
-- Name: prenotazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prenotazioni (
    codass character varying(20) NOT NULL,
    id_campo integer NOT NULL,
    sede integer NOT NULL,
    id_tesserato character(16) NOT NULL,
    data timestamp without time zone NOT NULL,
    ore numeric(2,1) NOT NULL,
    arbitro boolean DEFAULT false
);


ALTER TABLE public.prenotazioni OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 18942)
-- Name: sede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sede (
    codass character varying(20) NOT NULL,
    codice integer NOT NULL,
    via character varying(150) NOT NULL,
    cod_civico integer NOT NULL,
    cod_citta character(6) NOT NULL,
    nome character varying(150) NOT NULL,
    telefono character varying(12)
);


ALTER TABLE public.sede OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 19128)
-- Name: prenotazioni_per_sede; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.prenotazioni_per_sede AS
 SELECT p.codass,
    p.sede AS cod_sede,
    count(p.sede) AS num,
    round(((count(p.sede))::numeric / 12.0), 2) AS prenotazioni_mensili
   FROM (((public.prenotazioni p
     JOIN public.sede s ON (((p.sede = s.codice) AND ((p.codass)::text = (s.codass)::text))))
     JOIN public.associazione a ON (((a.codice)::text = (s.codass)::text)))
     JOIN public.citta c ON ((c.istat = s.cod_citta)))
  WHERE (date_part('year'::text, p.data) = (date_part('year'::text, CURRENT_DATE) - (1)::double precision))
  GROUP BY p.codass, p.sede;


ALTER TABLE public.prenotazioni_per_sede OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 19157)
-- Name: prenotazioni_tesserato_1campo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.prenotazioni_tesserato_1campo AS
 SELECT conteggio.codass,
    conteggio.id_tesserato,
    max(conteggio.num) AS max
   FROM ( SELECT prenotazioni.codass,
            prenotazioni.id_tesserato,
            prenotazioni.id_campo,
            count(*) AS num
           FROM public.prenotazioni
          WHERE (date_part('year'::text, prenotazioni.data) = (date_part('year'::text, CURRENT_DATE) - (1)::double precision))
          GROUP BY prenotazioni.codass, prenotazioni.id_tesserato, prenotazioni.id_campo) conteggio
  GROUP BY conteggio.codass, conteggio.id_tesserato;


ALTER TABLE public.prenotazioni_tesserato_1campo OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 19137)
-- Name: saldo_anno_prec; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.saldo_anno_prec AS
 SELECT p.codass,
    sum(p.importo) AS saldo
   FROM public.pagamento p
  WHERE (date_part('year'::text, p.data) = (date_part('year'::text, CURRENT_DATE) - (2)::double precision))
  GROUP BY p.codass;


ALTER TABLE public.saldo_anno_prec OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 19133)
-- Name: saldo_annuale; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.saldo_annuale AS
 SELECT p.codass,
    sum(p.importo) AS saldo
   FROM public.pagamento p
  WHERE (date_part('year'::text, p.data) = (date_part('year'::text, CURRENT_DATE) - (1)::double precision))
  GROUP BY p.codass;


ALTER TABLE public.saldo_annuale OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 19054)
-- Name: stipendi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stipendi (
    codass character varying(20) NOT NULL,
    data timestamp without time zone NOT NULL,
    id_dipendente character(16) NOT NULL,
    soggetto character(16) NOT NULL
);


ALTER TABLE public.stipendi OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 18925)
-- Name: tesserato; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tesserato (
    codass character varying(20) NOT NULL,
    cf character(16) NOT NULL,
    nome character varying(80) NOT NULL,
    cognome character varying(80) NOT NULL,
    data_nascita date NOT NULL,
    email character varying(80) NOT NULL,
    password character varying(50) NOT NULL,
    telefono character varying(12),
    arbitro boolean DEFAULT false,
    data_iscrizione date NOT NULL,
    scadenza_iscrizione date NOT NULL,
    sesso public.sessi NOT NULL,
    CONSTRAINT tesserato_email_check CHECK (((email)::text ~~ '%_@__%.__%'::text))
);


ALTER TABLE public.tesserato OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 18978)
-- Name: tipologia_campo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipologia_campo (
    codass character varying(20) NOT NULL,
    id integer NOT NULL,
    sport character varying(50),
    terreno character varying(50) NOT NULL,
    larghezza smallint NOT NULL,
    lunghezza smallint NOT NULL,
    CONSTRAINT tipologia_campo_larghezza_check CHECK ((larghezza > 0)),
    CONSTRAINT tipologia_campo_lunghezza_check CHECK ((lunghezza > 0))
);


ALTER TABLE public.tipologia_campo OWNER TO postgres;

--
-- TOC entry 3120 (class 0 OID 18919)
-- Dependencies: 200
-- Data for Name: associazione; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.associazione (codice, ragsoc, sito, email, password) FROM stdin;
POLRM	Polisportiva Romana	polisportivaromana.it	info@polisportivaromana.it	polisportiva01
\.



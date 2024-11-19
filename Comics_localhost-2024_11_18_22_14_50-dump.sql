--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: refresh_top_customers(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.refresh_top_customers() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    REFRESH MATERIALIZED VIEW Top_Customers;
END;
$$;


ALTER FUNCTION public.refresh_top_customers() OWNER TO postgres;

--
-- Name: reward_high_value_customers(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reward_high_value_customers() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (NEW.comic_id = 1) THEN
        INSERT INTO SpecialOffers (customer_name, customer_birthday)
        SELECT name, birthday FROM Customers WHERE id = NEW.customer_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.reward_high_value_customers() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: characters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.characters (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    powers text[],
    weaknesses text[],
    affiliations text[]
);


ALTER TABLE public.characters OWNER TO postgres;

--
-- Name: characters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.characters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.characters_id_seq OWNER TO postgres;

--
-- Name: characters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.characters_id_seq OWNED BY public.characters.id;


--
-- Name: comics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comics (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    price numeric(10,2),
    category character varying(50)
);


ALTER TABLE public.comics OWNER TO postgres;

--
-- Name: comics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comics_id_seq OWNER TO postgres;

--
-- Name: comics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comics_id_seq OWNED BY public.comics.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    birthday date,
    email character varying(255),
    purchase_history text[]
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: herovillainbattles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.herovillainbattles (
    id integer NOT NULL,
    hero_id integer,
    villain_id integer,
    battle_date date,
    result character varying(10)
);


ALTER TABLE public.herovillainbattles OWNER TO postgres;

--
-- Name: herovillainbattles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.herovillainbattles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.herovillainbattles_id_seq OWNER TO postgres;

--
-- Name: herovillainbattles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.herovillainbattles_id_seq OWNED BY public.herovillainbattles.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    id integer NOT NULL,
    comic_id integer,
    customer_id integer,
    purchase_date timestamp without time zone DEFAULT now(),
    total_amount numeric(10,2)
);


ALTER TABLE public.transactions OWNER TO postgres;

--
-- Name: popular_comics; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.popular_comics AS
 SELECT comics.id,
    comics.title,
    count(transactions.id) AS purchase_count
   FROM (public.comics
     JOIN public.transactions ON ((comics.id = transactions.comic_id)))
  GROUP BY comics.id, comics.title
 HAVING (count(transactions.id) > 50);


ALTER VIEW public.popular_comics OWNER TO postgres;

--
-- Name: specialoffers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specialoffers (
    id integer NOT NULL,
    customer_name character varying(255),
    customer_birthday date
);


ALTER TABLE public.specialoffers OWNER TO postgres;

--
-- Name: specialoffers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.specialoffers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialoffers_id_seq OWNER TO postgres;

--
-- Name: specialoffers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.specialoffers_id_seq OWNED BY public.specialoffers.id;


--
-- Name: top_customers; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.top_customers AS
 SELECT customers.name,
    count(transactions.customer_id) AS total_purchases,
    sum(transactions.total_amount) AS total_spent
   FROM (public.customers
     JOIN public.transactions ON ((customers.id = transactions.customer_id)))
  GROUP BY customers.name
 HAVING (count(transactions.customer_id) > 10)
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.top_customers OWNER TO postgres;

--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transactions_id_seq OWNER TO postgres;

--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: villagersandmortalarms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.villagersandmortalarms (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    availability boolean
);


ALTER TABLE public.villagersandmortalarms OWNER TO postgres;

--
-- Name: villagersandmortalarms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.villagersandmortalarms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.villagersandmortalarms_id_seq OWNER TO postgres;

--
-- Name: villagersandmortalarms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.villagersandmortalarms_id_seq OWNED BY public.villagersandmortalarms.id;


--
-- Name: characters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters ALTER COLUMN id SET DEFAULT nextval('public.characters_id_seq'::regclass);


--
-- Name: comics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comics ALTER COLUMN id SET DEFAULT nextval('public.comics_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: herovillainbattles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.herovillainbattles ALTER COLUMN id SET DEFAULT nextval('public.herovillainbattles_id_seq'::regclass);


--
-- Name: specialoffers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialoffers ALTER COLUMN id SET DEFAULT nextval('public.specialoffers_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: villagersandmortalarms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.villagersandmortalarms ALTER COLUMN id SET DEFAULT nextval('public.villagersandmortalarms_id_seq'::regclass);


--
-- Data for Name: characters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.characters (id, name, powers, weaknesses, affiliations) FROM stdin;
1	Wonder Woman	{"super strength","combat skills"}	{"loss of magic"}	{"Justice League"}
2	Flash	{"super speed","time travel"}	{"extreme cold"}	{"Justice League"}
3	Aquaman	{"underwater breathing",strength}	{dehydration}	{"Justice League"}
4	Green Lantern	{"energy projection",flight}	{fear}	{"Justice League"}
5	Joker	{intelligence,chaos}	{insanity}	{"Legion of Doom"}
6	Thanos	{"immense strength","infinity gauntlet"}	{overconfidence}	{"Villains United"}
7	Deadpool	{regeneration,combat}	{"unstable mind"}	{None}
8	Magneto	{"magnetism control"}	{"emotional ties"}	{"Brotherhood of Mutants"}
9	Spider-Man	{wall-crawling,agility}	{"emotional losses"}	{Avengers}
10	Thor	{"lightning control",strength}	{"loss of hammer"}	{Avengers}
\.


--
-- Data for Name: comics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comics (id, title, description, price, category) FROM stdin;
1	El Retorno del Caballero Oscuro	Batman en una nueva misión	18.50	superhero
2	La Caída del Joker	Villano al borde del colapso	16.99	villain
3	Green Lantern: El Amanecer	Aventuras cósmicas	19.99	superhero
4	Flash: Carrera Contra el Tiempo	Velocidad sin límites	14.75	superhero
5	Aquaman y el Reino Perdido	Viaje a las profundidades	21.00	superhero
6	La Venganza de Magneto	Un clásico de villanos	13.50	villain
7	Avengers: Infinity Battle	Los héroes contra un nuevo villano	25.00	superhero
8	Deadpool: El Anti-Héroe	Un antihéroe peculiar	12.00	villain
9	Spider-Man: Enredado	La red más compleja	17.99	superhero
10	Thor y el Martillo de la Eternidad	Poder divino en acción	23.50	superhero
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, name, birthday, email, purchase_history) FROM stdin;
1	Juan Pérez	1985-06-15	juan.perez@mail.com	\N
2	Luisa Martínez	1992-12-22	luisa.martinez@mail.com	\N
3	Carlos Gómez	1979-03-08	carlos.gomez@mail.com	\N
4	Ana Torres	1995-09-18	ana.torres@mail.com	\N
5	Ricardo López	1988-07-30	ricardo.lopez@mail.com	\N
6	Sofía Rodríguez	2000-04-25	sofia.rodriguez@mail.com	\N
7	Daniela Fernández	1993-11-11	daniela.fernandez@mail.com	\N
8	Andrés Morales	1983-08-14	andres.morales@mail.com	\N
9	Paula Herrera	1990-01-01	paula.herrera@mail.com	\N
10	Diego Castro	1997-10-10	diego.castro@mail.com	\N
\.


--
-- Data for Name: herovillainbattles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.herovillainbattles (id, hero_id, villain_id, battle_date, result) FROM stdin;
1	1	5	2024-01-01	hero
2	1	5	2024-02-01	hero
3	1	5	2024-03-01	hero
4	1	5	2024-04-01	hero
5	2	6	2024-01-01	hero
6	2	6	2024-02-01	villain
7	3	7	2024-03-01	villain
8	4	8	2024-04-01	hero
9	4	8	2024-05-01	hero
10	4	8	2024-06-01	hero
11	4	8	2024-07-01	hero
\.


--
-- Data for Name: specialoffers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specialoffers (id, customer_name, customer_birthday) FROM stdin;
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transactions (id, comic_id, customer_id, purchase_date, total_amount) FROM stdin;
1	1	2	2024-11-17 21:16:05.594156	15.99
2	2	3	2024-11-17 21:16:05.594156	12.50
3	3	4	2024-11-17 21:16:05.594156	22.00
4	4	5	2024-11-17 21:16:05.594156	14.75
5	5	6	2024-11-17 21:16:05.594156	21.00
6	6	7	2024-11-17 21:16:05.594156	13.50
7	7	8	2024-11-17 21:16:05.594156	25.00
8	8	9	2024-11-17 21:16:05.594156	12.00
9	9	10	2024-11-17 21:16:05.594156	17.99
10	10	1	2024-11-17 21:16:05.594156	23.50
11	2	3	2024-11-17 21:16:05.594156	12.50
12	3	4	2024-11-17 21:16:05.594156	22.00
13	5	5	2024-11-17 21:16:05.594156	21.00
14	1	7	2024-11-17 21:16:05.594156	15.99
15	6	8	2024-11-17 21:16:05.594156	13.50
16	9	9	2024-11-17 21:16:05.594156	17.99
17	10	10	2024-11-17 21:16:05.594156	23.50
18	3	2	2024-11-17 21:16:05.594156	22.00
19	4	1	2024-11-17 21:16:05.594156	14.75
20	7	6	2024-11-17 21:16:05.594156	25.00
\.


--
-- Data for Name: villagersandmortalarms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.villagersandmortalarms (id, name, description, availability) FROM stdin;
1	Ciudadano Desesperado	Siempre en peligro	t
2	El Escudo de Capitán América	Un arma legendaria	t
3	La Gente del Pueblo	Testigos comunes	t
4	El Lazo de la Verdad	Arma de Wonder Woman	t
5	El Martillo de Thor	Poder divino en un arma	t
6	Espada Láser	Arma de héroes intergalácticos	t
7	El Batarang	Un clásico de Batman	t
8	El Bastón de Loki	Artefacto mágico	t
9	Ciudadano Rebelde	Dispuesto a ayudar	t
10	La Ballesta de Daryl	Para cazadores	f
\.


--
-- Name: characters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.characters_id_seq', 10, true);


--
-- Name: comics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comics_id_seq', 10, true);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_id_seq', 10, true);


--
-- Name: herovillainbattles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.herovillainbattles_id_seq', 11, true);


--
-- Name: specialoffers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.specialoffers_id_seq', 1, false);


--
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transactions_id_seq', 20, true);


--
-- Name: villagersandmortalarms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.villagersandmortalarms_id_seq', 10, true);


--
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (id);


--
-- Name: comics comics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comics
    ADD CONSTRAINT comics_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: herovillainbattles herovillainbattles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.herovillainbattles
    ADD CONSTRAINT herovillainbattles_pkey PRIMARY KEY (id);


--
-- Name: specialoffers specialoffers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialoffers
    ADD CONSTRAINT specialoffers_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: villagersandmortalarms villagersandmortalarms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.villagersandmortalarms
    ADD CONSTRAINT villagersandmortalarms_pkey PRIMARY KEY (id);


--
-- Name: idx_top_customers; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_top_customers ON public.top_customers USING btree (total_purchases DESC, total_spent DESC);


--
-- Name: transactions high_value_customer_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER high_value_customer_trigger AFTER INSERT ON public.transactions FOR EACH ROW EXECUTE FUNCTION public.reward_high_value_customers();


--
-- Name: herovillainbattles herovillainbattles_hero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.herovillainbattles
    ADD CONSTRAINT herovillainbattles_hero_id_fkey FOREIGN KEY (hero_id) REFERENCES public.characters(id);


--
-- Name: herovillainbattles herovillainbattles_villain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.herovillainbattles
    ADD CONSTRAINT herovillainbattles_villain_id_fkey FOREIGN KEY (villain_id) REFERENCES public.characters(id);


--
-- Name: transactions transactions_comic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_comic_id_fkey FOREIGN KEY (comic_id) REFERENCES public.comics(id);


--
-- Name: transactions transactions_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: top_customers; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.top_customers;


--
-- PostgreSQL database dump complete
--


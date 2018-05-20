--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.9
-- Dumped by pg_dump version 9.5.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: antonio_zeus
--

CREATE TABLE addresses (
    user_id integer NOT NULL,
    street character varying(30) NOT NULL,
    city character varying(30) NOT NULL,
    state character varying(30) NOT NULL
);


ALTER TABLE addresses OWNER TO antonio_zeus;

--
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: antonio_zeus
--

INSERT INTO addresses VALUES (1, '1 Market Street', 'San Francisco', 'CA');
INSERT INTO addresses VALUES (2, '2 Elm Street', 'San Francisco', 'CA');
INSERT INTO addresses VALUES (3, '3 Main Street', 'Boston', 'MA');


--
-- Name: addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: antonio_zeus
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (user_id);


--
-- Name: addresses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: antonio_zeus
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


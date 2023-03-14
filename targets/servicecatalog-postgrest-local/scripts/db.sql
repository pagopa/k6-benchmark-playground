-- clean
DROP SCHEMA if exists servicecatalog CASCADE;

-- crea e imposta lo schema
create schema "servicecatalog";
SET search_path = "servicecatalog", "$user", public;

-- per le stringhe random
create extension if not exists pgcrypto;

--
-- dati catastali
--

create type geo_level as enum (
	'comune',
	'provincia',
	'regione',
	'nazione'
);
create table in_geo (id varchar, name varchar, level geo_level, parent_id varchar, primary key (id));
-- 1 nazione
insert into in_geo
values (encode(gen_random_bytes(20),'hex'), encode(gen_random_bytes(20),'hex'), 'nazione', null);
-- 20 regioni
insert into in_geo
select encode(gen_random_bytes(20),'hex'), encode(gen_random_bytes(20),'hex'), 'regione', in_geo.id  
from generate_series(1, 20), in_geo
where in_geo.level = 'nazione';
-- 5 province per regione
insert into in_geo
select encode(gen_random_bytes(20),'hex'), encode(gen_random_bytes(20),'hex'), 'provincia', in_geo.id 
from generate_series(1, 5), in_geo 
where in_geo.level = 'regione';
-- 100 comuni per provincia
insert into in_geo
select encode(gen_random_bytes(20),'hex'), encode(gen_random_bytes(20),'hex'), 'comune', in_geo.id 
from generate_series(1, 100), in_geo 
where in_geo.level = 'provincia';

-- vista unificata, esprime la gerarchia
create view geo
as (
		select c.id, c.name, c.level, array[c.id, p.id, r.id] as hierarchy from 
		in_geo c 
		inner join in_geo p on c.parent_id = p.id
		inner join in_geo r on p.parent_id = r.id
		where c.level = 'comune'
		union
		select p.id, p.name, p.level, array[p.id, r.id] as geo from 
		in_geo p
		inner join in_geo r on p.parent_id = r.id
		where p.level = 'provincia'
		union
		select r.id, r.name, r.level, array[r.id] as geo from 
		in_geo r
		where r.level = 'regione'
);

--
-- Enti
--
create table in_institutions (id varchar, name varchar,  primary key (id));
insert into in_institutions
select encode(gen_random_bytes(20),'hex'), encode(gen_random_bytes(20),'hex') from generate_series(1, 30000);

--
-- Servizi
--

create table in_services (id varchar, name varchar, description text, institution_id varchar, geo_id varchar,
						  primary key (id), 
						  constraint fk_institution foreign key (institution_id) references in_institutions(id),
						  constraint fk_geo foreign key (geo_id) references in_geo(id)
						 );

insert into in_services
select encode(gen_random_bytes(20),'hex'), encode(gen_random_bytes(20),'hex'),
-- random text generated with: https://www.loremipzum.com/libraries/system/g4L1s3.php
'<p>Corrrrrno di bue e latte screméto disgrazieto maledetto, è una guerra psicologica la nostra. è un libro sugli uccelli perdere e perderemo: cicos cicos Canos Canos. Come dicono i francesi a frappé non ho afferreto; non ho afferreto. Ti chiami Crisantemi:  prezzemolo e finocchio sono una persona che gira i mari di tutto il mondo? Andiamo a goderci gli ultimi attimi di pace sua moglie batte a Bologna, ti chiami Crisantemi. La pediartrite scapolare mi tira il nervo:  ha parlato Alain Delon ti ho comprato ai primi di novembre. I maschi e le femmine che sono gli unisex;  sono 2 giorni che non mangio ce l''ho sulla punta dei polmoni. </p><p>è un libro sugli uccelli ma no per un eroe: io vado a messa ogni domenica mattina. Il mondo sta per finire uomo;  lei va coi portieri e batte nei giardini con Giamburrasca tre bistecche alla volta ti fotti uomo. Se fai lo stronzolo ti spalleggio ti spezzo i menischi; i maschi e le femmine che sono gli unisex. Tu non sei né figlio d''emigrante né figlio di preta pura ho afferreto benissimo, una torta di mare perché mettono le vongole vereci sopra. è una famiglia schifosa;  a forza di grattarmi mi stai facendo venire l''orchite Maradònna benedetta dell’incoroneta. Il bambino sembra scemo in realtà lo è non avrà mica preso cortisoncomicitina; tu sei proprio figlio di puttena Neto. Sono quattro ore che stiamo parlando di tagliatelle tu non sei né figlio d''emigrante né figlio di preta pura: te l''ho detto mille volte di non chiamarmi vecchio. </p>',
i.id, (select id from geo order by random() limit 1)
from generate_series(1, 20) "g" , in_institutions "i";


--
-- Vista da esporre in lettura
--

create materialized view services as
select s.id, s.name, s.description, s.institution_id, i.name as institution_name, g.hierarchy as geo_ids, to_tsvector(s.name || ' ' || s.description) as searchable_text
from 
	in_institutions i 
	inner join in_services s on i.id = s.institution_id
	inner join geo g on g.id = s.geo_id;

CREATE UNIQUE INDEX idx_services_service_id ON services (id);
CREATE INDEX idx_services_institution_id ON services USING hash (institution_id);
CREATE INDEX idx_services_geo_ids ON services USING GIN (geo_ids);
CREATE INDEX idx_services_searchable_text ON services USING GIN (searchable_text);

--explain analyze
--select * from services where institution_id = 'f8843b382589666a695168e45e208395f3b62c8e'

--explain analyze
--select geo_ids from services where geo_ids @> array[cast('0b9f609103c0ad46ed351d9b146a6d0b13c13d23' as varchar)]

--select * from in_institutions

--select * from in_geo


-- drop materialized view services cascade;




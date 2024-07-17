-- scd.fobsconcept definition

-- DROP TYPE scd.fobsconcept;

CREATE TYPE scd.fobsconcept AS (
	observation_id int4,
	person_id int4,
	observation_concept_id int4,
	observation_date date,
	value_as_string varchar,
	value_as_numeric numeric,
	unit_as_string varchar,
	concept_id int4,
	concept_code varchar(50));

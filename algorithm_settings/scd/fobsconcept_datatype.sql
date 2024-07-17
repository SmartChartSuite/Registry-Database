-- scd.fobsconcept definition

-- DROP TYPE scd.fobsconcept;

CREATE TYPE scd.fobsconcept AS (
	observation_id int4,
	person_id int4,
	observation_concept_id int4,
	value_as_string varchar,
	value_as_numeric numeric,
	concept_id int4,
	concept_code varchar(50));

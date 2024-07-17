-- DROP FUNCTION scd.query_fobs_with_numeric_value(int4, _text);

CREATE OR REPLACE FUNCTION scd.query_fobs_with_numeric_value(param_person_id integer, concept_codes text[])
 RETURNS scd.fobsconcept[]
 LANGUAGE plpgsql
AS $function$
DECLARE
	my_fobsconcepts scd.fobsconcept[];
BEGIN
	my_fobsconcepts := ARRAY(
        SELECT 
            ROW(
                o.observation_id, 
                o.person_id, 
                o.observation_concept_id, 
                o.observation_date,
                o.value_as_string, 
                CASE 
                    WHEN array_length(regexp_split_to_array(o.value_as_string, '\^'), 1) = 6 THEN
                        CAST(NULLIF(regexp_replace(split_part(o.value_as_string, '^', 4), '[^0-9.-]+', '', 'g'), '') AS numeric)
                    ELSE
                        NULL
				END,
                CASE 
                    WHEN array_length(regexp_split_to_array(o.value_as_string, '\^'), 1) = 6 THEN
                        split_part(o.value_as_string, '^', 5)
                    ELSE
                        NULL
				END,
                c.concept_id, 
                c.concept_code
            )::scd.fobsconcept
        FROM
            scd.f_observation_view o
        INNER JOIN
            vocab.concept c 
        ON
            o.observation_concept_id = c.concept_id
		WHERE
			o.person_id = param_person_id AND c.concept_code = ANY(concept_codes)
    );
	 RETURN my_fobsconcepts;
END $function$
;

-- Permissions

ALTER FUNCTION scd.query_fobs_with_numeric_value(int4, _text) OWNER TO postgres;
GRANT ALL ON FUNCTION scd.query_fobs_with_numeric_value(int4, _text) TO postgres;


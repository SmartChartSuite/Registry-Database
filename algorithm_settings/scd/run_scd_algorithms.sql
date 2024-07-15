-- DROP FUNCTION scd.run_algorithms(int4, int4);

CREATE OR REPLACE FUNCTION scd.run_algorithms(person_id integer, case_id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
-- scd classification algorithm. This writes the result to measurement table and returns 
-- the concept value that is value of the classification.
	declare 
		return_val integer;
	begin
		-- run scd classification algorithm. This writes results to measurement table.
		-- The results can be read with person_id and measurement_concept_id = 2000000188
		select * into return_val from scd.classifypatient(person_id);
	
		-- add more algorithms below
	
		-- TODO: we figure out what to return. we may return table with outputs from algorithms
		return 0;
	end;
$function$
;

-- Permissions

ALTER FUNCTION scd.run_algorithms(int4, int4) OWNER TO postgres;
GRANT ALL ON FUNCTION scd.run_algorithms(int4, int4) TO postgres;


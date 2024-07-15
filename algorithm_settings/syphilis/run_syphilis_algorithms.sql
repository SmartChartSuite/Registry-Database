-- DROP FUNCTION syphilis.run_algorithms(int4, int4);

CREATE OR REPLACE FUNCTION syphilis.run_algorithms(person_id integer, case_id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
-- syphilis classification algorithm. This writes the result to measurement table and returns 
-- the concept value that is value of the classification.
	declare 
		return_val integer;
	begin
		-- add algorithms below
	
		-- TODO: we figure out what to return. we may return table with outputs from algorithms
		return 0;
	end;
$function$
;

-- Permissions

ALTER FUNCTION syphilis.run_algorithms(int4, int4) OWNER TO postgres;
GRANT ALL ON FUNCTION syphilis.run_algorithms(int4, int4) TO postgres;


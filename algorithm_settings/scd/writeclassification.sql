-- DROP FUNCTION scd.writeclassification(int4, int4);

CREATE OR REPLACE FUNCTION scd.writeclassification(patient_id integer, cohort_definition_class integer)
 RETURNS vocab.concept
 LANGUAGE plpgsql
AS $function$
DECLARE
    concept_row vocab.concept%ROWTYPE;
    next_measurement_id integer;
BEGIN
    LOCK TABLE scd.measurement IN EXCLUSIVE MODE;
    
    -- Calculate the next measurement_id
    SELECT COALESCE(MAX(measurement_id), 0) + 1 INTO next_measurement_id
    FROM scd.measurement;

    IF cohort_definition_class = 1 THEN
        INSERT INTO scd.measurement (measurement_id, person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, value_as_concept_id)
            VALUES(next_measurement_id, patient_id, 2000000188, CURRENT_DATE, CURRENT_TIMESTAMP, 32880, 2000000182);
        SELECT * INTO concept_row FROM vocab.concept WHERE concept_id = 2000000182;

    ELSIF cohort_definition_class = 2 THEN
        INSERT INTO scd.measurement (measurement_id, person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, value_as_concept_id)
            VALUES(next_measurement_id, patient_id, 2000000188, CURRENT_DATE, CURRENT_TIMESTAMP, 32880, 2000000183);
        SELECT * INTO concept_row FROM vocab.concept WHERE concept_id = 2000000183;

    ELSIF cohort_definition_class = 3 THEN
        INSERT INTO scd.measurement (measurement_id, person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, value_as_concept_id)
            VALUES(next_measurement_id, patient_id, 2000000188, CURRENT_DATE, CURRENT_TIMESTAMP, 32880, 2000000184);
        SELECT * INTO concept_row FROM vocab.concept WHERE concept_id = 2000000184;

    ELSIF cohort_definition_class = 9 THEN
        INSERT INTO scd.measurement (measurement_id, person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, value_as_concept_id)
            VALUES(next_measurement_id, patient_id, 2000000188, CURRENT_DATE, CURRENT_TIMESTAMP, 32880, 2000000185);
        SELECT * INTO concept_row FROM vocab.concept WHERE concept_id = 2000000185;

    ELSIF cohort_definition_class = 0 THEN
        INSERT INTO scd.measurement (measurement_id, person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, value_as_concept_id)
            VALUES(next_measurement_id, patient_id, 2000000188, CURRENT_DATE, CURRENT_TIMESTAMP, 32880, 2000000186);
        SELECT * INTO concept_row FROM vocab.concept WHERE concept_id = 2000000186;

    ELSE
        RAISE EXCEPTION 'Invalid cohort_definition_class value: %', cohort_definition_class;
    END IF;

    RETURN concept_row;
END;
$function$
;

-- Permissions

ALTER FUNCTION scd.writeclassification(int4, int4) OWNER TO postgres;
GRANT ALL ON FUNCTION scd.writeclassification(int4, int4) TO postgres;


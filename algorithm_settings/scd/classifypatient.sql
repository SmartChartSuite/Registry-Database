-- DROP FUNCTION scd.classifypatient(int4);

CREATE OR REPLACE FUNCTION scd.classifypatient(personid integer)
 RETURNS vocab.concept
 LANGUAGE plpgsql
AS $function$
DECLARE
    reticulocyte scd.fobsconcept[];
    absolute_reticulocyte scd.fobsconcept[];
    total_bilirubin scd.fobsconcept[];
    direct_bilirubin scd.fobsconcept[];
    ldh scd.fobsconcept[];
    hgb_a scd.fobsconcept[];
    hgb_a1 scd.fobsconcept[];
    hgb_a2 scd.fobsconcept[];
    hgb_c scd.fobsconcept[];
    hgb_d scd.fobsconcept[];
    hgb_e scd.fobsconcept[];
    hgb_f scd.fobsconcept[];
    hgb_s scd.fobsconcept[];
    hgb_other scd.fobsconcept[];
    hgb_all scd.fobsconcept[];
    hgb_cde scd.fobsconcept[];
    reticulocyte_count integer;
    absolute_reticulocyte_count integer;
    total_bilirubin_count integer;
    direct_bilirubin_count integer;
    ldh_count integer;
    hgb_a_count integer;
    hgb_a1_count integer;
    hgb_a2_count integer;
    hgb_c_count integer;
    hgb_d_count integer;
    hgb_f_count integer;
    hgb_s_count integer;
    hgb_other_count integer;
    lab_count integer;
    hgb_count integer;
    score integer;
    result_concept vocab.concept;
BEGIN
    -- Call the function for different measurement source values and store the results into respective arrays
    -- Reticulocyte
    SELECT * INTO reticulocyte FROM scd.query_fobs_with_numeric_value(personId, ARRAY['17849-1']);
    -- Absolute Reticulocyte
    SELECT * INTO absolute_reticulocyte FROM scd.query_fobs_with_numeric_value(personId, ARRAY['14196-0']);
    -- Total Bilirubin
    SELECT * INTO total_bilirubin FROM scd.query_fobs_with_numeric_value(personId, ARRAY['1975-2']);
    -- Direct Bilirubin
    SELECT * INTO direct_bilirubin FROM scd.query_fobs_with_numeric_value(personId, ARRAY['1968-7']);
    -- LDH
    SELECT * INTO ldh FROM scd.query_fobs_with_numeric_value(personId, ARRAY['14804-9']);
    -- HGB A
    SELECT * INTO hgb_a FROM scd.query_fobs_with_numeric_value(personId, ARRAY['20572-4', '42244-4']);
    -- HGB A1
    SELECT * INTO hgb_a1 FROM scd.query_fobs_with_numeric_value(personId, ARRAY['4547-6']);
    -- HGB A2
    SELECT * INTO hgb_a2 FROM scd.query_fobs_with_numeric_value(personId, ARRAY['42244-4', '42245-1']);
    -- HGB C
    SELECT * INTO hgb_c FROM scd.query_fobs_with_numeric_value(personId, ARRAY['4563-3', '44920-7']);
    -- HGB D
    SELECT * INTO hgb_d FROM scd.query_fobs_with_numeric_value(personId, ARRAY['44921-5']);
    -- HGB E
    SELECT * INTO hgb_e FROM scd.query_fobs_with_numeric_value(personId, ARRAY['44922-3']);
    -- HGB F
    SELECT * INTO hgb_f FROM scd.query_fobs_with_numeric_value(personId, ARRAY['465-5', '42246-9']);
    -- HGB S
    SELECT * INTO hgb_s FROM scd.query_fobs_with_numeric_value(personId, ARRAY['4625-0', '44923-1']);
    -- HGB Other
    SELECT * INTO hgb_other FROM scd.query_fobs_with_numeric_value(personId, ARRAY['42248-5']);

    -- Concatenating all hgb arrays into hgb_all
    hgb_all := hgb_a || hgb_a1 || hgb_a2 || hgb_c || hgb_d || hgb_f || hgb_s || hgb_other;
    hgb_cde = hgb_c || hgb_d || hgb_e;

    -- Count each measurement type
    reticulocyte_count := array_length(reticulocyte, 1);
    absolute_reticulocyte_count := array_length(absolute_reticulocyte, 1);
    total_bilirubin_count := array_length(total_bilirubin, 1);
    direct_bilirubin_count := array_length(direct_bilirubin, 1);
    ldh_count := array_length(ldh, 1);
    hgb_a_count := array_length(hgb_a, 1);
    hgb_a1_count := array_length(hgb_a1, 1);
    hgb_a2_count := array_length(hgb_a2, 1);
    hgb_c_count := array_length(hgb_c, 1);
    hgb_d_count := array_length(hgb_d, 1);
    hgb_f_count := array_length(hgb_f, 1);
    hgb_s_count := array_length(hgb_s, 1);
    hgb_other_count := array_length(hgb_other, 1);

    lab_count := reticulocyte_count + absolute_reticulocyte_count + total_bilirubin_count + direct_bilirubin_count +
                 ldh_count + hgb_a_count + hgb_a1_count + hgb_a2_count + hgb_c_count + hgb_d_count + hgb_f_count +
                 hgb_s_count + hgb_other_count;

    hgb_count := hgb_a_count + hgb_a1_count + hgb_a2_count + hgb_c_count + hgb_d_count + hgb_f_count +
                 hgb_s_count + hgb_other_count;

    score := 0;

    -- Electrophoresis tests
    IF hgb_count > 1 AND lab_count >= 15 THEN
        IF array_length(hgb_s, 1) >= 1 THEN
            IF hgb_s[1].value_as_numeric >= 0.50 THEN
                SELECT * INTO result_concept FROM scd.writeclassification(personId, 1); --hemoglobin electrophoresis confirmation of disease
                RETURN result_concept;
            ELSIF hgb_s[1].value_as_numeric =< 0.50 AND hgb_s[1].value_as_numeric >= 0.10 THEN
                SELECT * INTO result_concept FROM scd.writeclassification(personId, 2); --MOST likely has sickle cell disease but no electrophoresis or genetic confirmation 
            ELSIF array_length(hgb_a, 1) >= 1 THEN
                IF hgb_a[1].value_as_numeric >= 0.5 AND hgb_a[1].value_as_numeric =< 0.65
                AND hgb_s[1].value_as_numeric >= 0.35 AND hgb_s[1].value_as_numeric =< 0.45 THEN 
                    SELECT * INTO result_concept FROM scd.writeclassification(personId, 9); --Confirmed Sickle Cell Trait through Electrophoresis
                    RETURN result_concept;
                END IF;
            ELSIF array_length(hgb_cde, 1) >= 1 THEN --Confirmed Sickle Cell Disease through compound heterozygote
                IF array_length(hgb_c, 1) >= 1 THEN
                    IF hgb_s[1].value_as_numeric >= 0.40 AND hgb_s[1].value_as_numeric =< 0.48
                    AND hgb_c[1].value_as_numeric >= 0.40 AND hgb_c[1].value_as_numeric =< 0.48 THEN
                        SELECT * INTO result_concept FROM scd.writeclassification(personId, 1);
                        RETURN result_concept;
                    END IF;
                END IF;
                IF array_length(hgb_d, 1) >= 1 THEN
                    IF hgb_s[1].value_as_numeric >= 0.40 AND hgb_s[1].value_as_numeric =< 0.48
                    AND hgb_d[1].value_as_numeric >= 0.40 AND hgb_d[1].value_as_numeric =< 0.48 THEN
                        SELECT * INTO result_concept FROM scd.writeclassification(personId, 1);
                        RETURN result_concept;
                    END IF;
                END IF;
                IF array_length(hgb_e, 1) >= 1 THEN
                    IF hgb_s[1].value_as_numeric >= 0.40 AND hgb_s[1].value_as_numeric =< 0.48
                    AND hgb_e[1].value_as_numeric >= 0.40 AND hgb_e[1].value_as_numeric =< 0.48 THEN
                        SELECT * INTO result_concept FROM scd.writeclassification(personId, 1);
                        RETURN result_concept;
                    END IF;
                END IF;
            END IF;
        END IF;
    ELSIF hgb_count > 1 AND lab_count < 15 THEN
        SELECT * INTO result_concept FROM scd.writeclassification(personId, 2);
    -- Non Electrophoresis tests
    ELSIF hgb_count = 0 AND lab_count > 0 THEN
        -- total_b > 1.1 and not exist (direct_b > total_b * 0.5 //taken on the same day)
        score := score + (SELECT COUNT(*) FROM unnest(total_bilirubin)
                          WHERE measurement_as_value > 1.1
                          AND NOT EXISTS (SELECT 1 FROM unnest(direct_bilirubin)
                                          WHERE measurement_as_value > total_bilirubin.measurement_as_value * 0.5
                                          AND ABS(measurement_date - total_bilirubin.measurement_date) < 1));

        score := score + (SELECT COUNT(*) FROM unnest(reticulocyte)
                          WHERE measurement_as_value > 0.02);

        score := score + (SELECT COUNT(*) FROM unnest(ldh)
                          WHERE measurement_as_value > 250);

        score := score + (SELECT COUNT(*) FROM unnest(hgb_all)
                          WHERE measurement_as_value < 11 AND unit_concept_id = 15794); -- < 11 g/dl

        IF score > 15 THEN
            SELECT * INTO result_concept FROM scd.writeclassification(personId, 2);
            RETURN result_concept;
        ELSE
            SELECT * INTO result_concept FROM scd.writeclassification(personId, 3);
            RETURN result_concept;
        END IF;
    -- No tests
    ELSE
        SELECT * INTO result_concept FROM scd.writeclassification(personId, 0);
        RETURN result_concept;
    END IF;

    RETURN result_concept;
END;
$function$
;

-- Permissions

ALTER FUNCTION scd.classifypatient(int4) OWNER TO postgres;
GRANT ALL ON FUNCTION scd.classifypatient(int4) TO postgres;


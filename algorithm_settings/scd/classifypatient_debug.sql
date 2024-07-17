-- DROP FUNCTION scd.classifypatient_debug(int4);

CREATE OR REPLACE FUNCTION scd.classifypatient_debug(personid integer)
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
    hgb_e_count integer;
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
    hgb_all := hgb_a || hgb_a1 || hgb_a2 || hgb_c || hgb_d || hgb_e || hgb_f || hgb_s || hgb_other;
    hgb_cde := hgb_c || hgb_d || hgb_e;

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
    hgb_e_count := array_length(hgb_e, 1);
    hgb_f_count := array_length(hgb_f, 1);
    hgb_s_count := array_length(hgb_s, 1);
    hgb_other_count := array_length(hgb_other, 1);

    lab_count := reticulocyte_count + absolute_reticulocyte_count + total_bilirubin_count + direct_bilirubin_count +
                 ldh_count + hgb_a_count + hgb_a1_count + hgb_a2_count + hgb_c_count + hgb_d_count + hgb_e_count +
                 hgb_f_count + hgb_s_count + hgb_other_count;

    hgb_count := hgb_a_count + hgb_a1_count + hgb_a2_count + hgb_c_count + hgb_d_count + hgb_e_count +
                 hgb_f_count + hgb_s_count + hgb_other_count;

    -- Display counts and first element of each array
    RAISE NOTICE 'Reticulocyte count: %, First element: %', reticulocyte_count, reticulocyte[1];
    RAISE NOTICE 'Absolute Reticulocyte count: %, First element: %', absolute_reticulocyte_count, absolute_reticulocyte[1];
    RAISE NOTICE 'Total Bilirubin count: %, First element: %', total_bilirubin_count, total_bilirubin[1];
    RAISE NOTICE 'Direct Bilirubin count: %, First element: %', direct_bilirubin_count, direct_bilirubin[1];
    RAISE NOTICE 'LDH count: %, First element: %', ldh_count, ldh[1];
    RAISE NOTICE 'HGB A count: %, First element: %', hgb_a_count, hgb_a[1];
    RAISE NOTICE 'HGB A1 count: %, First element: %', hgb_a1_count, hgb_a1[1];
    RAISE NOTICE 'HGB A2 count: %, First element: %', hgb_a2_count, hgb_a2[1];
    RAISE NOTICE 'HGB C count: %, First element: %', hgb_c_count, hgb_c[1];
    RAISE NOTICE 'HGB D count: %, First element: %', hgb_d_count, hgb_d[1];
    RAISE NOTICE 'HGB E count: %, First element: %', hgb_e_count, hgb_e[1];
    RAISE NOTICE 'HGB F count: %, First element: %', hgb_f_count, hgb_f[1];
    RAISE NOTICE 'HGB S count: %, First element: %', hgb_s_count, hgb_s[1];
    RAISE NOTICE 'HGB Other count: %, First element: %', hgb_other_count, hgb_other[1];

    -- Display overall counts
    RAISE NOTICE 'Lab count: %', lab_count;
    RAISE NOTICE 'HGB count: %', hgb_count;
    -- Electrophoresis tests
    IF hgb_count > 1 AND lab_count >= 15 THEN
        IF array_length(hgb_s, 1) >= 1 THEN
            IF hgb_s[1].value_as_numeric >= 50 THEN
                RAISE NOTICE 'HGB_S >= 0.50';
                SELECT * INTO result_concept FROM scd.writeclassification(personId, 1); --hemoglobin electrophoresis confirmation of disease
                RETURN result_concept;
            ELSIF hgb_s[1].value_as_numeric =< 50 AND hgb_s[1].value_as_numeric >= 10 THEN
                RAISE NOTICE 'HGB_S 10-50';
                SELECT * INTO result_concept FROM scd.writeclassification(personId, 2); --MOST likely has sickle cell disease but no electrophoresis or genetic confirmation 
            ELSIF array_length(hgb_a, 1) >= 1 THEN
                RAISE NOTICE 'HGB_A length >= 1';
                IF hgb_a[1].value_as_numeric >= 50 AND hgb_a[1].value_as_numeric =< 65
                AND hgb_s[1].value_as_numeric >= 35 AND hgb_s[1].value_as_numeric =< 45 THEN 
                    RAISE NOTICE 'HGB_A and HGB_S determined classification 9';
                    SELECT * INTO result_concept FROM scd.writeclassification(personId, 9); --Confirmed Sickle Cell Trait through Electrophoresis
                    RETURN result_concept;
                END IF;
            ELSIF array_length(hgb_cde, 1) >= 1 THEN --Confirmed Sickle Cell Disease through compound heterozygote
                RAISE NOTICE 'HGB C, D, or E >= 1';
                IF array_length(hgb_c, 1) >= 1 THEN
                    IF hgb_s[1].value_as_numeric >= 40 AND hgb_s[1].value_as_numeric =< 48
                    AND hgb_c[1].value_as_numeric >= 40 AND hgb_c[1].value_as_numeric =< 48 THEN
                        RAISE NOTICE 'HGB_S and HGB_C heterozygote classification 1';
                        SELECT * INTO result_concept FROM scd.writeclassification(personId, 1);
                        RETURN result_concept;
                    END IF;
                END IF;
                IF array_length(hgb_d, 1) >= 1 THEN
                    IF hgb_s[1].value_as_numeric >= 40 AND hgb_s[1].value_as_numeric =< 48
                    AND hgb_d[1].value_as_numeric >= 40 AND hgb_d[1].value_as_numeric =< 48 THEN
                        RAISE NOTICE 'HGB_S and HGB_D heterozygote classification 1';
                        SELECT * INTO result_concept FROM scd.writeclassification(personId, 1);
                        RETURN result_concept;
                    END IF;
                END IF;
                IF array_length(hgb_e, 1) >= 1 THEN
                    IF hgb_s[1].value_as_numeric >= 40 AND hgb_s[1].value_as_numeric =< 48
                    AND hgb_e[1].value_as_numeric >= 40 AND hgb_e[1].value_as_numeric =< 48 THEN
                        RAISE NOTICE 'HGB_S and HGB_E heterozygote classification 1';
                        SELECT * INTO result_concept FROM scd.writeclassification(personId, 1);
                        RETURN result_concept;
                    END IF;
                END IF;
            END IF;
        END IF;
    ELSIF hgb_count > 1 AND lab_count < 15 THEN
        RAISE NOTICE 'HGB_S and lab_count < 15 classification 2';
        SELECT * INTO result_concept FROM scd.writeclassification(personId, 2);
    -- Non Electrophoresis tests
    ELSIF hgb_count = 0 AND lab_count > 0 THEN
        -- total_b > 1.1 and not exist (direct_b > total_b * 0.5 taken on the same day)
        score := score + (SELECT COUNT(*) FROM unnest(total_bilirubin)
                          WHERE value_as_numeric > 1.1
                          AND NOT EXISTS (SELECT 1 FROM unnest(direct_bilirubin)
                                          WHERE value_as_numeric > total_bilirubin.value_as_numeric * 0.5
                                          AND ABS(observation_date - total_bilirubin.observation_date) < 1));

        score := score + (SELECT COUNT(*) FROM unnest(reticulocyte)
                          WHERE value_as_numeric > 0.02);

        score := score + (SELECT COUNT(*) FROM unnest(ldh)
                          WHERE value_as_numeric > 250);

        score := score + (SELECT COUNT(*) FROM unnest(hgb_all)
                          WHERE value_as_numeric < 11 AND unit_as_string LIKE '%g/dl%'); -- < 11 g/dl
        RAISE NOTICE 'non-electrophoresis value count:%', score;
        IF score > 15 THEN
            SELECT * INTO result_concept FROM scd.writeclassification(personId, 2);
            RETURN result_concept;
        ELSE
            SELECT * INTO result_concept FROM scd.writeclassification(personId, 3);
            RETURN result_concept;
        END IF;
    -- No tests
    ELSE
        RAISE NOTICE 'No criteria found, classification 0';
        SELECT * INTO result_concept FROM scd.writeclassification(personId, 0);
        RETURN result_concept;
    END IF;

    RETURN result_concept;
END;
$function$
;

-- Permissions

ALTER FUNCTION scd.classifypatient_debug(int4) OWNER TO postgres;
GRANT ALL ON FUNCTION scd.classifypatient_debug(int4) TO postgres;


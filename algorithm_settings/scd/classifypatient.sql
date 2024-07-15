-- DROP FUNCTION scd.classifypatient(int4);

CREATE OR REPLACE FUNCTION scd.classifypatient(personid integer)
 RETURNS vocab.concept
 LANGUAGE plpgsql
AS $function$
DECLARE
    reticulocyte scd.measurement_record[];
    absolute_reticulocyte scd.measurement_record[];
    total_bilirubin scd.measurement_record[];
    direct_bilirubin scd.measurement_record[];
    ldh scd.measurement_record[];
    hgb_a scd.measurement_record[];
    hgb_a1 scd.measurement_record[];
    hgb_a2 scd.measurement_record[];
    hgb_c scd.measurement_record[];
    hgb_d scd.measurement_record[];
    hgb_e scd.measurement_record[];
    hgb_f scd.measurement_record[];
    hgb_s scd.measurement_record[];
    hgb_other scd.measurement_record[];
    hgb_all scd.measurement_record[];
    hgb_cde scd.measurement_record[];
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
    -- Selecting measurements into arrays
    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value = '17849-1' 
                 ORDER BY m.measurement_date DESC) INTO reticulocyte;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value = '14196-0' 
                 ORDER BY m.measurement_date DESC) INTO absolute_reticulocyte;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value = '1975-2' 
                 ORDER BY m.measurement_date DESC) INTO total_bilirubin;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value = '1968-7' 
                 ORDER BY m.measurement_date DESC) INTO direct_bilirubin;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value = '14804-9' 
                 ORDER BY m.measurement_date DESC) INTO ldh;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value IN ('20572-4','42244-4') 
                 ORDER BY m.measurement_date DESC) INTO hgb_a;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value = '4547-6' 
                 ORDER BY m.measurement_date DESC) INTO hgb_a1;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value IN ('42244-4','42245-1') 
                 ORDER BY m.measurement_date DESC) INTO hgb_a2;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value IN ('4563-3','44920-7') 
                 ORDER BY m.measurement_date DESC) INTO hgb_c;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value = '44921-5' 
                 ORDER BY m.measurement_date DESC) INTO hgb_d;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value = '44922-3' 
                 ORDER BY m.measurement_date DESC) INTO hgb_e;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value IN ('465-5','42246-9') 
                 ORDER BY m.measurement_date DESC) INTO hgb_f;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value IN ('4625-0', '44923-1') 
                 ORDER BY m.measurement_date DESC) INTO hgb_s;

    SELECT ARRAY(SELECT ROW(m.*)::scd.measurement_record FROM scd.measurement m 
                 WHERE m.person_id = personId AND m.measurement_source_value = '42248-5' 
                 ORDER BY m.measurement_date DESC) INTO hgb_other;

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
            IF hgb_s[1].measurement_as_number >= 0.50 THEN
                SELECT * INTO result_concept FROM scd.writeclassification(personId, 1); --hemoglobin electrophoresis confirmation of disease
                RETURN result_concept;
            ELSIF hgb_s[1].measurement_as_number =< 0.50 AND hgb_s[1].measurement_as_number >= 0.10 THEN
                SELECT * INTO result_concept FROM scd.writeclassification(personId, 2); --MOST likely has sickle cell disease but no electrophoresis or genetic confirmation 
            ELSIF array_length(hgb_a, 1) >= 1 THEN
                IF hgb_a[1].measurement_as_number >= 0.5 AND hgb_a[1].measurement_as_number =< 0.65
                AND hgb_s[1].measurement_as_number >= 0.35 AND hgb_s[1].measurement_as_number =< 0.45 THEN 
                    SELECT * INTO result_concept FROM scd.writeclassification(personId, 9); --Confirmed Sickle Cell Trait through Electrophoresis
                    RETURN result_concept;
                END IF;
            ELSIF array_length(hgb_cde, 1) >= 1 THEN --Confirmed Sickle Cell Disease through compound heterozygote
                IF array_length(hgb_c, 1) >= 1 THEN
                    IF hgb_s[1].measurement_as_number >= 0.40 AND hgb_s[1].measurement_as_number =< 0.48
                    AND hgb_c[1].measurement_as_number >= 0.40 AND hgb_c[1].measurement_as_number =< 0.48 THEN
                        SELECT * INTO result_concept FROM scd.writeclassification(personId, 1);
                        RETURN result_concept;
                    END IF;
                END IF;
                IF array_length(hgb_d, 1) >= 1 THEN
                    IF hgb_s[1].measurement_as_number >= 0.40 AND hgb_s[1].measurement_as_number =< 0.48
                    AND hgb_d[1].measurement_as_number >= 0.40 AND hgb_d[1].measurement_as_number =< 0.48 THEN
                        SELECT * INTO result_concept FROM scd.writeclassification(personId, 1);
                        RETURN result_concept;
                    END IF;
                END IF;
                IF array_length(hgb_e, 1) >= 1 THEN
                    IF hgb_s[1].measurement_as_number >= 0.40 AND hgb_s[1].measurement_as_number =< 0.48
                    AND hgb_e[1].measurement_as_number >= 0.40 AND hgb_e[1].measurement_as_number =< 0.48 THEN
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

ALTER FUNCTION scd.classifypatient(int4) OWNER TO sascs;
GRANT ALL ON FUNCTION scd.classifypatient(int4) TO sascs;


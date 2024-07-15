-- see the result(s)
select 	fp.family_name as family_name,
		fp.given1_name  as given_name, 
		vc.concept_name as class_desc, 
		vc.concept_code as class_code, 
		m.measurement_datetime as calculated_time 
	from 
		scd.measurement m join vocab.concept c on m.measurement_concept_id = c.concept_id
		join vocab.concept vc on m.value_as_concept_id = vc.concept_id 
		join scd.person p on m.person_id = p.person_id 
		join scd.f_person fp on m.person_id = fp.person_id 
	where m.person_id = 1 and m.measurement_concept_id = 2000000188;

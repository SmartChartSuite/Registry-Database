-- scd.measurement_record definition

-- DROP TYPE scd.measurement_record;

CREATE TYPE scd.measurement_record AS (
	measurement_id int4,
	person_id int4,
	measurement_concept_id int4,
	measurement_date date,
	measurement_datetime timestamp,
	measurement_time varchar(10),
	measurement_type_concept_id int4,
	operator_concept_id int4,
	value_as_number numeric,
	value_as_concept_id int4,
	unit_concept_id int4,
	range_low numeric,
	range_high numeric,
	provider_id int4,
	visit_occurrence_id int4,
	visit_detail_id int4,
	measurement_source_value varchar(50),
	measurement_source_concept_id int4,
	unit_source_value varchar(50),
	unit_source_concept_id int4,
	value_source_value varchar(500),
	measurement_event_id int8,
	meas_event_field_concept_id int4);

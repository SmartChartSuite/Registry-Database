-- scd."_fobsconcept" definition

-- DROP TYPE scd."_fobsconcept";

CREATE TYPE scd."_fobsconcept" (
	INPUT = array_in,
	OUTPUT = array_out,
	RECEIVE = array_recv,
	SEND = array_send,
	ANALYZE = array_typanalyze,
	ALIGNMENT = 8,
	STORAGE = any,
	CATEGORY = A,
	ELEMENT = scd.fobsconcept,
	DELIMITER = ',');

# SMART-PACER-Registry-Database

This is to set up the Registry Manager DB and Registry Viewer API DB. 

1. use omoponfhir_v5_4_setup/ to setup OMOP and load vocabularies. There are some modifications needed to support the registry.

2. use registry-setup/ to set up Registry specific schemas. 

If you are setup a new schemas, ignore files that start with "ONLY_FOR_EXISTING_SCHEMA". 
#!/bin/sh
rm *.sql
pg_dump -s mcodes_prep_repo  > mcodes_prep_repo_schema.sql
pg_dump --attribute-inserts  --no-owner --data-only --no-privileges  -v mcodes_prep_repo  -t icd10cm > icd10cm_data.sql 
pg_dump --attribute-inserts  --no-owner --data-only --no-privileges  -v mcodes_prep_repo  -t icd10cm_eindex > icd10cm_eindex_data.sql 
pg_dump --attribute-inserts  --no-owner --data-only --no-privileges  -v mcodes_prep_repo  -t icd10cm_dindex > icd10cm_dindex_data.sql 
pg_dump --attribute-inserts  --no-owner --data-only --no-privileges  -v mcodes_prep_repo  -t ctd > ctd_data.sql 
pg_dump --attribute-inserts  --no-owner --data-only --no-privileges  -v mcodes_prep_repo  -t icd10cm_index > icd10cm_index_data.sql 
pg_dump --attribute-inserts  --no-owner --data-only --no-privileges  -v mcodes_prep_repo  -t  icd10cm_neoplasms > icd10cm_neoplasms_data.sql
pg_dump --attribute-inserts  --no-owner --data-only --no-privileges  -v mcodes_prep_repo  -t  icd10pcs   > icd10pcs_data.sql
pg_dump --attribute-inserts  --no-owner --data-only --no-privileges  -v mcodes_prep_repo  -t icd10pcs_defs >  icd10pcs_defs_data.sql 
pg_dump --attribute-inserts  --no-owner --data-only --no-privileges  -v mcodes_prep_repo  -t icd10pcs_aggregates >  icd10pcs_aggregates_data.sql 
pg_dump --attribute-inserts  --no-owner --data-only --no-privileges  -v mcodes_prep_repo  -t  icd10pcs_index > icd10pcs_index_data.sql

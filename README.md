## Mcodes_prep is a CLI application (Elixir - No web) that  transforms ICD-10-CM and ICD-10-PCS xml files to Postgres Tables

### After Transformation you can search in a Terminal for a Disease Code, an Operation and for a disease synonym. NDC - National Drug Catalog was Added


### Setup

#### You need 
* A working installation of elixir and postgresql
* Before to download please install Git Large File Storage - LFS
* https://www.cms.gov/medicare/icd-10/2021-icd-10-cm Code Tables, Tabular and Index –
* https://www.cms.gov/medicare/icd-10/2022-icd-10-pcs/20XX ICD-10-PCS Order File (Long and Abbreviated Titles) - Updated December 1, 20xx (ZIP)
* http://ctdbase.org/downloads/CTD_diseases.csv.gz :: gzip -d CTD_diseases.csv.gz
* https://www.fda.gov/drugs/drug-approvals-and-databases/national-drug-code-directory
#### Unzip the files to data directory

#### For ICD-10-CM You need the files
icd10cm_tabular_2021.xml


##### For ICD-10-PCS of the Year 2022 You need the files
* icd10pcs_order_2022.txt
* icd10pcs_tables_2022.xm
* icd10pcs_index_2022.xml 
* icd10pcs_definitions_2022.xml

##### For NDC  You need the files
* package.txt           
* product.txt  

#### In the main Dir issue the commands 

 * mix deps.get
 * mix ecto.create
 * Optional mix ecto.migrate
 * build the project: ./build_escript.sh 
 * and run it by: ./mcodes_prep. Then h for help

 ### You can skip the the tranformation from XML Files to Postgresql Tables
      by runing the script db_ready/to_mcodes_dev witch inserts the data to the PG
      and you are ready for the queries. In this step you don't need to run ecto.migrate

 ### Please Check and the image directory     

## Mcodes_prep is a CLI application that  transforms ICD-10-CM and ICD-10-PCS xml files to Postgres Tables

### After Transformation you can search The Postgresql tables  in a Terminal

### Setup

#### You need 
* A working installation of elixir and postgresql
* https://www.cms.gov/medicare/icd-10/20XX-icd-10-cm/20XX Code Tables, Tabular and Index – Updated 12/16/20xx (ZIP)
* https://www.cms.gov/medicare/icd-10/20XX-icd-10-pcs/20XX ICD-10-PCS Order File (Long and Abbreviated Titles) - Updated December 1, 20xx (ZIP)
* http://ctdbase.org/downloads/CTD_diseases.csv.gz :: gzip -d CTD_diseases.csv.gz

#### Unzip the files to data directory

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
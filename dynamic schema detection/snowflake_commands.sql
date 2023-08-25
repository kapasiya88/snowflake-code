--create a STORAGE INTEGRATION
CREATE or replace STORAGE INTEGRATION S3_Snowflake 
	TYPE = EXTERNAL_STAGE 
	STORAGE_PROVIDER = S3
	ENABLED = TRUE 
	STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::211678918935:role/mysnowflakerole-kajal'
	STORAGE_ALLOWED_LOCATIONS = ('s3://s3-source-data-demo');

--get the properties of STORAGE INTEGRATION
DESC INTEGRATION S3_Snowflake;

--create a parquet file format
create or replace file format parquet_format
type=parquet ;

show file formats;

--create external stage for a particular folder from S3.One stage can refer to one file format.
create or replace stage parquet_data_stage 
url="s3://s3-source-data-demo/parquetdata/" 
storage_integration = S3_Snowflake
file_format = parquet_format;

desc stage parquet_data_stage;

--shows all stages.
show  stages;

--list all the files present in an external stage.
list @parquet_data_stage;

select * from @parquet_data_stage;

--snowflake command to get the schema of external stage dynamically.
select * from TABLE(INFER_SCHEMA (LOCATION=>'@parquet_data_stage',FILE_FORMAT=>'parquet_format'));

--create snowflake table based on dynamic schema detection from external stage.
create or replace table sampleparquet using template(select ARRAY_AGG(OBJECT_CONSTRUCT(*)) from TABLE(INFER_SCHEMA (LOCATION=>'@parquet_data_stage',FILE_FORMAT=>'parquet_format')));

desc table sampleparquet;

--create snowpipe
create or replace pipe parquetload
auto_ingest=true
as 
copy into sampleparquet
from @parquet_data_stage
MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE 
file_format=(format_name=parquet_format)

show pipes;

select * from sampleparquet;

--query to get the copy commands status
select * from table(information_schema.copy_history(table_name=>'sampleparquet',start_time=> DATEADD(hours, -1, CURRENT_TIMESTAMP())));
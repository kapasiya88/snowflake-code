--create a STORAGE INTEGRATION
CREATE or replace STORAGE INTEGRATION S3_Snowflake 
	TYPE = EXTERNAL_STAGE 
	STORAGE_PROVIDER = S3
	ENABLED = TRUE 
	STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::211678918935:role/mysnowflakerole-kajal'
	STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-sourcedata');

--get the properties of STORAGE INTEGRATION
DESC INTEGRATION S3_Snowflake;

--create a json file format
create or replace file format json_format
type=JSON ;

show file formats;

--create external stage for a particular folder from S3.One stage can refer to one file format.
create or replace stage json_data_stage 
url="s3://snowflake-sourcedata/" 
storage_integration = S3_Snowflake
file_format = json_format;

desc stage json_data_stage;

--shows all stages.
show  stages;

--list all the files present in an external stage.
list @json_data_stage;

--select the columns directly from external stage.
select t.$1 from @json_data_stage t;

-- create an external table without partition.
create or replace external table sales_json1 (
    product_id string as (value:product_id:oid::string),
    id string as (value:product_id:id :: string),
      product_name string as (value:product_name :: string ),
      quantity number as (value:quantity :: number),
      supplier string as (value:supplier :: string),
      unit_cost string as (value:unit_cost :: string)
)
with location=@json_data_stage,
file_format=(format_name=json_format);

-- create an external table with partition.
create or replace external table sales_json2 (
    product_id string as (value:product_id:oid::string),
    id string as (value:product_id:id :: string),
      product_name string as (value:product_name :: string ),
      quantity number as (value:quantity :: number),
      supplier string as (value:supplier :: string),
      unit_cost string as (value:unit_cost :: string),
      file_partition number(2,0) as (split_part(METADATA$FILENAME,'/',2) :: int))
      PARTITION BY (file_partition)
with location=@json_data_stage ,
file_format=(format_name=json_format);

-- test the functionality.
-- set the result cache false.
alter session set use_cached_result = false;

-- here all the partitions will be scanned and then filter will be applied.
select *
from sales_json1
where split_part(METADATA$FILENAME,'/',2)=23;

-- here only the required partition will be scanned.
select * from sales_json2 where file_partition=23;




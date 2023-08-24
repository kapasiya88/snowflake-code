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
url="s3://snowflake-sourcedata/jsondata-sample/" 
storage_integration = S3_Snowflake
file_format = json_format;

desc stage json_data_stage;

--shows all stages.
show  stages;

--list all the files present in an external stage.
list @json_data_stage;

--select the columns directly from external stage.
select t.$1 from @json_data_stage t;

--select columns from external stage by splitting the json data format and keeping the nested objects intact.
SELECT
      $1:product_id:oid :: string as product_id,
      $1:product_id:id :: string as id,
      $1:product_name :: string as product_name,
      $1:quantity :: number as quantity,
      $1:supplier :: string as supplier,
      $1:unit_cost :: string as unit_cost
FROM @json_data_stage 
order by $1:product_id:oid;

--select columns from external stage by splitting the json data format and after flattening the nested objects as well.
SELECT
      t.$1:product_id:oid :: string as product_id,
      t.$1:product_id:id :: string as id,
      t.$1:product_name :: string as product_name,
      t.$1:quantity :: number as quantity,
      t.$1:supplier :: string as supplier,
      t.$1:unit_cost :: string as unit_cost,
      f1.value::string as unit_cost_individual
FROM @json_data_stage t,
table(flatten(t.$1:unit_cost)) f1
order by t.$1:product_id:oid;

--create external table directly on external stage without any transformation.so there will be only one 
--column of variant type.
--Also created a sqs notification on the source bucket to pull the data directly into external table.
--Normally if external table is created on external stage then any new files in external stage won't be 
--reflected automatically in external table.You need to refresh the external table manually.
--But if you want that to happen automatically,you can create a SQS notification for the bucket by 
--giving SQS notification channel of external table and then refresh will happen automatically though it 
--will take some time.
create or replace external table sales_json (
    json_data variant as (value::variant)
)
with location=@json_data_stage,
file_format=(format_name=json_format);

--get the sqs notification channel ARN for the external table and paste in s3 notification configuration.
--NOTE:As botht the external tables are pointing to same external stage,SQS notification channel is same.
--And hence it will publish the message to both tables.
show  external tables;

select * from sales_json;

-- Manually refresh the external table metadata once using ALTER EXTERNAL TABLE with the REFRESH parameter.
-- This ensures the metadata is synchronized with any changes to the file list that occurred since Step 2. 
--Thereafter, the S3 event notifications trigger the metadata refresh automatically.
ALTER EXTERNAL TABLE sales_json REFRESH;


--create external table directly on external stage by separating the columns.
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

select t.METADATA$FILENAME,t.METADATA$FILE_ROW_NUMBER,t.* from sales_json1 t;

ALTER EXTERNAL TABLE sales_json1 REFRESH;
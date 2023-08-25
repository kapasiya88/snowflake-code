This project is used to create a snowflake table based on dynamic detection of schema from s3.\

1)	Create a s3 bucket with default settings (s3-source-data-demo).
create a folder to upload source files (sourcedata).
create a folder for target files (parquetdata).

2) create IAM role to provide access to snowflake to AWS.
Role name: mysnowflakerole-kajal
Refer mysnowflakerole-kajal.json

3) setup snowflake infrastructure:
refer snowflake_commands.sql

4)  update the ARN and external id from the integration object created in above step to the IAM role 
created in step 2.

a) DESC INTEGRATION S3_Snowflake;

b) edit mysnowflakerole-kajal -> trust relationships

copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID from 4(a) and paste to 4(b)

5) copy the sqs notification channel from the below command for your pipe.
show pipes;

paste to bucket which is source to snowflake:
s3-source-data-demo -> properties -> event_notifications

a) Event name
call_snowflake_Table

b) prefix
parquetdata/

c) event types:
all object create events

d) destination:
SQS queue
enter SQS queue ARN (copy it from step 5)

6) create a glue crawler to crawl the source files from sourcedata and run it.

7) create a glue job which will read the glue catalogue and generate the parquet file into target folder
 (parquetdata).

 8) create appropriate role to run the crawler and glue job.

 9) run the glue job and check the parquet files created in parquetdata.If yes then check the files in 
 external stage and snowflake table.

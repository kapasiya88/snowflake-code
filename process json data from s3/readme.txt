This project is used to ingest the json data from S3 to snowflake using external stage and external tables.
Whenever there is a new object in the source S3 bucket,an sqs notification will push the data into external 
tables without any manual refresh.
1)	Create a source s3 bucket with default settings (s3-source-data-demo).

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

5) show  external tables;
copy the sqs notification channel for the table.

paste to bucket which is source to snowflake:
snowflake-sourcedata -> properties -> event_notifications

a) Event name
call_snowflake_externalTable

b) prefix
jsondata-sample/

c) event types:
all object create events

d) destination:
SQS queue
enter SQS queue ARN (copy it from step 5)

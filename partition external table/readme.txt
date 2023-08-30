This project is used to ingest the json data from S3 to snowflake using external stage and external tables
where external tables are partitioned for better performance.

1)	Create a source s3 bucket with default settings (snowflake-sourcedata).

2) create IAM role to provide access to snowflake to AWS.
Role name: mysnowflakerole-kajal
Refer mysnowflakerole-kajal.json

3)  update the ARN and external id from the integration object created in above step to the IAM role 
created in step 2.

a) DESC INTEGRATION S3_Snowflake;

b) edit mysnowflakerole-kajal -> trust relationships

copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID from 3(a) and paste to 3(b)

4) setup snowflake infrastructure and perform the analysis.
refer snowflake_commands.sql

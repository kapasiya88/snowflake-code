--check the current role.
select current_role(); --ACCOUNTADMIN

-- create sample table.
create table snowflake_parctice.practice.call_center
select * from snowflake_sample_data.tpcds_sf100tcl.call_center;

--get the data from candidate table.
select * from snowflake_parctice.practice.call_center;


-- user role mapping table
create or replace table snowflake_parctice.practice.user_role_mapping
(cc_division_name varchar(10),role_name varchar(70));

insert into snowflake_parctice.practice.user_role_mapping values 
('pri','PRV_BANKING_ANALYST'),
('anti','PRSNL_BANKING_ANALYST');

select * from snowflake_parctice.practice.user_role_mapping;

-- custom role creation
create role PRV_BANKING_ANALYST;

create role PRSNL_BANKING_ANALYST;

-- grant the privilege's on database, schema and tables

grant usage on warehouse compute_wh to role PRV_BANKING_ANALYST;
grant usage on database snowflake_parctice to role PRV_BANKING_ANALYST;
grant usage on schema practice to role PRV_BANKING_ANALYST;
grant select on table call_center to role PRV_BANKING_ANALYST;

grant usage on warehouse compute_wh to role PRSNL_BANKING_ANALYST;
grant usage on database snowflake_parctice to role PRSNL_BANKING_ANALYST;
grant usage on schema practice to role PRSNL_BANKING_ANALYST;
grant select on table call_center to role PRSNL_BANKING_ANALYST;


-- assign role to currently executing user for testing 
select current_user(); --KAJALDSPORTSMANIA
grant role PRV_BANKING_ANALYST to user KAJALDSPORTSMANIA;
grant role PRSNL_BANKING_ANALYST to user KAJALDSPORTSMANIA;

-- create a row access policy and add the policy using alter statement
create or replace row access policy division_plcy as (division_code varchar) returns boolean ->
exists 
(Select 1 from snowflake_parctice.practice.user_role_mapping 
where role_name=current_role() and cc_division_name=division_code);

Alter table snowflake_parctice.practice.call_center add row access policy
division_plcy on (cc_division_name);

--test the results with role PRV_BANKING_ANALYST
-- only rows pertaining to cc_division_name which is visible in user_role_mapping table against role 
-- PRV_BANKING_ANALYST are visible.
Use role PRV_BANKING_ANALYST;
Use warehouse compute_wh;
select * from snowflake_parctice.practice.call_center;



--test the results with role PRSNL_BANKING_ANALYST
-- only rows pertaining to cc_division_name which is visible in user_role_mapping table against role 
-- PRSNL_BANKING_ANALYST are visible.
Use role PRSNL_BANKING_ANALYST;
Use warehouse compute_wh;
select * from snowflake_parctice.practice.call_center;

--test the results with role accountadmin
-- only rows pertaining to cc_division_name which is visible in user_role_mapping table against role 
-- accountadmin are visible.
Use role accountadmin;
select * from snowflake_parctice.practice.call_center; 

-- 0 records   
-- Why no records? As we don’t have account admin role defined in the role mapping table. 
-- That’s why restricts the output.

-- Let’s insert below records into role mapping table and will see
Insert into snowflake_parctice.practice.user_role_mapping values ('pri','ACCOUNTADMIN'),
Insert into snowflake_parctice.practice.user_role_mapping values ('anti','ACCOUNTADMIN');

Use role accountadmin;
Select * from table;

-- Now you will see the records for cc_division_name in ('pri','anti')
-- create a masking policy on ssn_txt column
create or replace masking policy mask_ssn  as (ssn_txt string) returns string ->
case when current_role() in ('ACCOUNTADMIN') then ssn_txt
when current_role() in ('SYSADMIN') then regexp_replace(ssn_txt,substring(ssn_txt,1,7),'xxx-xx-')
when current_role() in ('PUBLIC') then 'xxx-xx-xxxx'
else '***Masked***'
end;

-- masking policy to mask first name
create or replace masking policy mask_fname as (first_name string) returns string ->
  case
    when current_role() in ('ACCOUNTADMIN') then first_name
    when current_role() in ('SYSADMIN') then 'xxxxxx'
    else NULL
  end;

  -- masking policy to mask last name
create or replace masking policy mydb.myschema.mask_lname as (last_name string) returns string ->
  case
    when current_role() in ('ACCOUNTADMIN') then last_name
    when current_role() in ('SYSADMIN') then 'xxxxxx'
    else NULL
  end;

  -- masking policy to mask date of birth name
create or replace masking policy mydb.myschema.mask_dob as (DoB string) returns string ->
  case
    when current_role() in ('ACCOUNTADMIN') then regexp_replace(DoB,substring(DoB,1,8),'xxxx-xx-')
    when current_role() in ('SYSADMIN') then 'xxxx-xx-xx'
    else NULL
  end;

--create a table and apply masking policy onn ssn_txt column.
create or replace table customer(
    id number,
    first_name string,
    last_name string,
    DoB string,
    ssn string masking policy mask_ssn,  --apply masking while creating the table
    country string,
    city string,
    zipcode string);

-- apply mask_dob masking policy to customer.dob column
alter table if exists mydb.myschema.customer modify column dob set masking policy mydb.myschema.mask_dob;

-- apply mask_fname masking policy to customer.first_name column
alter table if exists customer modify column first_name set masking policy mydb.myschema.mask_fname;


-- apply mask_lname masking policy to customer.last_name column
alter table if exists mydb.myschema.customer modify column last_name set masking policy mydb.myschema.mask_lname;


--------

-- conditional masking

create or replace masking policy mask_zipcode as (zipcode string,country boolean) returns string ->
  case
  when current_role() = 'ACCOUNTADMIN' then zipcode
    when country = 'USA' then zipcode
    else '***Masked***'
end;

-- apply masking policy
alter table if exists mydb.myschema.customer 
modify column zipcode set masking policy mydb.myschema.mask_zipcode using (zipcode,country);
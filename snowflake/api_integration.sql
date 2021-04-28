USE ROLE ACCOUNTADMIN;

create or replace api integration api_integration
  api_provider = aws_api_gateway
  api_aws_role_arn = 'arn:aws:iam::your_aws_account_id:role/snowflake_role_name'
  api_allowed_prefixes = ('api_gateway_stage')
  enabled = true;

describe integration api_integration;

-- use this command to allow other roles to create external functions
grant usage on  integration api_integration to role sysadmin;

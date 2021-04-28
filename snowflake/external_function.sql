use role sysadmin;

-- the role that you use need to have access to the api integration

create or replace external function heycar_helper.my_external_function(input variant)
  returns variant
  api_integration = api_integration
  as 'api_gateway_endpoint/stage/resource';

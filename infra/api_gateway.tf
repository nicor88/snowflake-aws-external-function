data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_api_gateway_rest_api" "snowflake_external_function" {
  name        = "snowflake-external-function"
  description = "API gateway to call Lambda functions from Snowflake"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_lambda_permission" "allow_lambda_invocation" {
  statement_id  = "allow-lambda-invoke-from-api-gateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.snowflake_external_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.snowflake_external_function.id}/*/*/*"
}

resource "aws_api_gateway_resource" "function_resource" {
  rest_api_id = aws_api_gateway_rest_api.snowflake_external_function.id
  parent_id   = aws_api_gateway_rest_api.snowflake_external_function.root_resource_id
  path_part   = var.function_name
}

resource "aws_api_gateway_method" "function_resource_method" {
   rest_api_id   = aws_api_gateway_rest_api.snowflake_external_function.id
   resource_id   = aws_api_gateway_resource.function_resource.id
   http_method   = "POST"
   authorization = "AWS_IAM" # NONE,AWS_IAM
}


data "aws_iam_policy_document" "gateway_policy" {
  statement {
    actions = ["execute-api:Invoke"]
    resources = [
      "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.snowflake_external_function.id}/*/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${aws_iam_role.snowflake_iam_role.name}/snowflake"]
    }

  }
}

resource "aws_api_gateway_rest_api_policy" "test" {
  rest_api_id = aws_api_gateway_rest_api.snowflake_external_function.id

  policy = data.aws_iam_policy_document.gateway_policy.json
}

resource "aws_api_gateway_integration" "lambda_integration" {
   rest_api_id = aws_api_gateway_rest_api.snowflake_external_function.id
   resource_id = aws_api_gateway_method.function_resource_method.resource_id
   http_method = aws_api_gateway_method.function_resource_method.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.snowflake_external_function.invoke_arn
}


resource "aws_api_gateway_deployment" "test_deployment" {
  depends_on = [
     aws_api_gateway_integration.lambda_integration
   ]
  rest_api_id = aws_api_gateway_rest_api.snowflake_external_function.id

  triggers = {
    redeployment = sha1(jsonencode(data.archive_file.function_package.output_base64sha256))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "test" {
  deployment_id = aws_api_gateway_deployment.test_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.snowflake_external_function.id
  stage_name    = "test"
}

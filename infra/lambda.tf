data "archive_file" "function_package" {
  type        = "zip"
  source_dir  = "../${path.module}/lambda_function/"
  output_path = "../${path.module}/packaging/function_code.zip"
}

resource "aws_lambda_function" "snowflake_external_function" {
  function_name    = "snowflake-external-function-${var.function_name}"
  filename         = data.archive_file.function_package.output_path
  source_code_hash = data.archive_file.function_package.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 30
  memory_size      = 128
}
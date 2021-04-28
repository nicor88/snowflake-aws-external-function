data "aws_iam_policy_document" "user_snowflake" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.snowflake_user_arn]
    }
  }
}

resource "aws_iam_role" "snowflake_iam_role" {
  name               = "generic-snowflake-role"
  assume_role_policy = data.aws_iam_policy_document.user_snowflake.json
}

data "aws_iam_policy_document" "snowflake-role-iam-policy" {
  statement {
    actions = [
      "execute-api:Invoke",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "snowflake-policy" {
  name   = "snowflake-policy"
  role   = aws_iam_role.snowflake_iam_role.name
  policy = data.aws_iam_policy_document.snowflake-role-iam-policy.json
}

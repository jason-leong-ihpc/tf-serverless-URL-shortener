data "archive_file" "lambda_get_zip" {
  type        = "zip"
  source_dir  = "${path.module}/retrieve-url-lambda"
  output_path = "${path.module}/retrieve-url-lambda.zip"
}

resource "aws_lambda_function" "http_api_lambda" {
  filename         = data.archive_file.lambda_get_zip.output_path
  function_name    = "${local.name_prefix}-retrieve-url-lambda"
  description      = "Lambda function to read from dynamodb"
  runtime          = "python3.12"
  handler          = "app.lambda_handler"
  source_code_hash = data.archive_file.lambda_get_zip.output_base64sha256
  role             = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DDB_TABLE = "" # todo: fill with apporpriate value
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${local.name_prefix}-api-executionrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_exec_role" {
  name = "${local.name_prefix}-api-ddbaccess"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:Scan"
            ],
            "Resource": "${aws_dynamodb_table.shortener_table.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "lambda_get_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_role.arn
}

# resource "aws_cloudwatch_log_group" "lambda_log_group" {
#   name              = "/aws/lambda/${aws_lambda_function.http_api_lambda.function_name}"
#   retention_in_days = 7

#   lifecycle {
#     create_before_destroy = false
#   }
# }
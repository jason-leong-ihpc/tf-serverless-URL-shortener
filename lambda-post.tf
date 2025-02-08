data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/create-url-lambda"
  output_path = "${path.module}/create-url-lambda.zip"
}

resource "aws_lambda_function" "create-url-lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${local.name_prefix}-create-url-lambda"
  description      = "Lambda function to write to dynamodb"
  runtime          = "python3.13"
  handler          = "app.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.create-url-lambda-exec.arn

  environment {
    variables = {
    #   DDB_TABLE = aws_dynamodb_table.table.name
    }
  }
}

resource "aws_iam_role" "create-url-lambda-exec" {
  name = "${local.name_prefix}-create-url-lambda-executionrole"

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

resource "aws_iam_policy" "create-url-lambda-exec-role" {
  name = "${local.name_prefix}-create-url-lambda-ddbaccess"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
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
        },
        {
            "Effect": "Allow",
            "Action": [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.create-url-lambda-exec.name
  policy_arn = aws_iam_policy.create-url-lambda-exec-role.arn
}
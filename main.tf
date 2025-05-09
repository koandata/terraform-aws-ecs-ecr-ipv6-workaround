resource "aws_secretsmanager_secret" "ecr" {
  name_prefix = var.name_prefix
}

resource "random_pet" "random" {}

resource "aws_iam_role" "lambda" {
  name_prefix = var.name_prefix

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

locals {
  ecr_repo_arns = compact(concat([var.ecr_repo_arn], var.ecr_repo_arns))
}

resource "aws_iam_role_policy" "ecr" {
  role = aws_iam_role.lambda.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action   = "secretsmanager:UpdateSecret"
        Resource = aws_secretsmanager_secret.ecr.arn
        Effect   = "Allow"
      },
      ],
      [for repo_arn in local.ecr_repo_arns: {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ]
        Resource = repo_arn
        Effect   = "Allow"
      }
      ])
  })
}

resource "aws_iam_role_policy_attachment" "logs" {
  role = aws_iam_role.lambda.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = "${var.name_prefix}${random_pet.random.id}"
  role          = aws_iam_role.lambda.arn

  handler  = "lambda.handler"
  runtime  = "python3.13"
  filename = "${path.module}/lambda.zip"
  environment {
    variables = {
      "SECRET_ARN" = aws_secretsmanager_secret.ecr.arn
    }
  }

  source_code_hash = data.archive_file.lambda.output_base64sha256
}

resource "aws_lambda_invocation" "oneoff" {
  function_name = aws_lambda_function.lambda.function_name

  triggers = {
    redeployment = sha1(jsonencode([
      aws_lambda_function.lambda.environment,
      data.archive_file.lambda.output_base64sha256
    ]))
  }

  input = "{}"
}

// the token should be valid for 12 hours, let's run the Lambda every 11 hours
resource "aws_cloudwatch_event_rule" "every_11_hours" {
  name                = "${var.name_prefix}every-11-hours"
  schedule_expression = "cron(0 */11 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_11_hours.name
  target_id = "lambda-target"
  arn       = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_11_hours.arn
}



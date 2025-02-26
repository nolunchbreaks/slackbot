 provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "lambda_role" {
  name = "chatops_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "lambda_policy" {
  name       = "chatops_lambda_policy_attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "chatops_bot" {
  function_name    = "ChatOpsBot"
  role             = aws_iam_role.lambda_role.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.8"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SLACK_BOT_TOKEN     = var.slack_bot_token
      SLACK_SIGNING_SECRET = var.slack_signing_secret
    }
  }
}

resource "aws_api_gateway_rest_api" "chatops_api" {
  name        = "ChatOpsAPI"
  description = "API Gateway for ChatOps Bot"
}

resource "aws_api_gateway_resource" "lambda_resource" {
  rest_api_id = aws_api_gateway_rest_api.chatops_api.id
  parent_id   = aws_api_gateway_rest_api.chatops_api.root_resource_id
  path_part   = "slack"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.chatops_api.id
  resource_id   = aws_api_gateway_resource.lambda_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.chatops_api.id
  resource_id             = aws_api_gateway_resource.lambda_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.chatops_bot.invoke_arn
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatops_bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.chatops_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.chatops_api.id
  stage_name  = "prod"
}

resource "aws_sns_topic" "alerts_topic" {
  name = "chatops_alerts"
}

resource "aws_cloudwatch_metric_alarm" "example_alarm" {
  alarm_name          = "ExampleAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  alarm_actions = [aws_sns_topic.alerts_topic.arn]
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.alerts_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.chatops_bot.arn
}

resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatops_bot.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts_topic.arn
}

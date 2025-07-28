provider "aws" {
  region = var.aws_region
}

resource "aws_ssm_parameter" "html_string" {
  name  = "/dynamic/html/string"
  type  = "String"
  value = "Hello Interviewer!"
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "lambda_ssm" {
  name       = "lambda_ssm_permission"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "lambda_logs" {
  name       = "lambda_logs"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Comprimir código lambda Python
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function_payload.zip"
}

resource "aws_lambda_function" "html_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "htmlLambdaFunction"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMIC_PARAM = aws_ssm_parameter.html_string.name
    }
  }
}

resource "aws_api_gateway_rest_api" "html_api" {
  name        = "html-api"
  description = "API para servir HTML dinámico"
}

resource "aws_api_gateway_resource" "html_resource" {
  rest_api_id = aws_api_gateway_rest_api.html_api.id
  parent_id   = aws_api_gateway_rest_api.html_api.root_resource_id
  path_part   = "html"
}

resource "aws_api_gateway_method" "get_html_method" {
  rest_api_id   = aws_api_gateway_rest_api.html_api.id
  resource_id   = aws_api_gateway_resource.html_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.html_api.id
  resource_id             = aws_api_gateway_resource.html_resource.id
  http_method             = aws_api_gateway_method.get_html_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.html_lambda.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.html_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.html_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "html_api_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.html_api.id
}

resource "aws_api_gateway_stage" "html_api_stage" {
  deployment_id = aws_api_gateway_deployment.html_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.html_api.id
  stage_name    = "prod"
}
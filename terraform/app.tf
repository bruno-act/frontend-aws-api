locals {
  // This needs to match the app settings in the API project 
  // appsettings.Development.json
  config_prefix = "/${local.naming_prefix}/api-config"
  application_config = {
    "Logging/LogLevel/Default"              = "Information",
    "Logging/LogLevel/Microsoft.AspNetCore" = "Warning",

    "ConnectionStrings/DefaultConnection" = "Host=${local.aws_db_instance_app_endpoint};Database=${local.aws_db_instance_app_db_name};Username=${local.aws_db_instance_app_username};Password=${random_password.password.result}"

    "AWSSDKConfig/Region"   = var.region
  }
}

resource "aws_ssm_parameter" "api_config" {

  for_each = local.application_config

  name  = "${local.config_prefix}/${each.key}"
  type  = "SecureString"
  value = each.value

  # SSM parameter value may be overridden manually.
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_lambda_permission" "app_apigw_lambda" {
  for_each      =  var.lambda_functions
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api[each.key].function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}

resource "aws_lambda_function" "api" {
  function_name = "${local.naming_prefix}-app-api"
  for_each      = var.lambda_functions

  filename = "hello_world.zip"

  role    = aws_iam_role.api_lambda.arn
  runtime = each.value.runtime
  handler = each.value.handler

  memory_size = var.api_function_memory_size
  timeout     = var.api_function_timeout

  vpc_config {
    subnet_ids         = aws_subnet.private_data_subnet_cidrs[*].id
    security_group_ids = [aws_security_group.api_lambda.id]
  }

  environment {
    variables = {
      CONFIG_PARAMETER     = local.config_prefix
    }
  }
}

resource "aws_security_group" "api_lambda" {
  name        = "${local.naming_prefix}-app-api"
  description = "Lambbda to DB"
  vpc_id      = aws_vpc.phi_api.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.naming_prefix}-app-api"
  }
}

data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_lambda" {
  name               = "${local.naming_prefix}-app-api"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json

  inline_policy {
    name   = "application-permissions"
    policy = data.aws_iam_policy_document.api_app_permissions.json
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.api_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.api_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}


// These are the permissions the application needs to function
data "aws_iam_policy_document" "api_app_permissions" {
  statement {
    sid = "AllStarsForNow"
    actions = [
      "sts:AssumeRole",
      "cognito:*",
      "s3:*",
      "ssm:*"

    ]
    resources = ["*"]
  }
}

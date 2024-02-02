data "aws_region" "region" {}
data "aws_caller_identity" "identity" {}

locals {
  openAPI_spec = {
    for endpoint, spec in var.api_endpoints : endpoint => {
      for method, lambda in spec : method => {
        x-amazon-apigateway-integration = {
          type       = "aws_proxy"
          httpMethod = "POST"
          uri        = "arn:aws:apigateway:${data.aws_region.region.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:${lambda}/invocations"
        }
      }
    }
  }
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name = "afrocentric-phi-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  body = jsonencode({
    openapi = "3.0.1"
    paths   = local.openAPI_spec
  })
}

resource "aws_acm_certificate" "api_app_region" {
  domain_name       = local.api_domain
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "api_app_region" {
  certificate_arn         = aws_acm_certificate.api_app_region.arn
  validation_record_fqdns = [for record in aws_route53_record.api : record.fqdn]
}

resource "aws_api_gateway_domain_name" "proxy" {
  depends_on = [aws_acm_certificate_validation.api_app_region]

  regional_certificate_arn = aws_acm_certificate_validation.api_app_region.certificate_arn
  domain_name     = local.api_domain
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  security_policy = "TLS_1_2"
}

resource "aws_route53_record" "api" {
  for_each = {
    for dvo in aws_acm_certificate.api_app_region.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_gw_stage" {
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.api_gateway_stage_name
}

resource "aws_api_gateway_base_path_mapping" "rest_api" {
  api_id      = aws_api_gateway_rest_api.rest_api.id
  domain_name = aws_api_gateway_domain_name.proxy.id
  stage_name  = aws_api_gateway_stage.api_gw_stage.stage_name
}

resource "aws_route53_record" "api_route" {
  name    = aws_api_gateway_domain_name.proxy.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.main.zone_id

  alias {
    name                   = aws_api_gateway_domain_name.proxy.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.proxy.regional_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_api_gateway_rest_api.rest_api.name}"
  retention_in_days = 7
}
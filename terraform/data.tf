data "aws_route53_zone" "main" {
  name = var.domain
}

locals {

  app_domain  = "app.${var.domain}"
  api_domain  = "api.${var.domain}"
  auth_domain = "auth.${var.domain}"
}

data "aws_caller_identity" "current" {}

# #--------------------------------------------------------------------------------------
# # VPC
# #--------------------------------------------------------------------------------------
# data "aws_vpc" "central_vpc" {
#   tags = {
#     # Name = "afrocentric-phi-api-vpc"
#     Name = "afrocentric-testing-vpc-sa-vpc"
#   }
# }

# #--------------------------------------------------------------------------------------
# # Subnets
# #--------------------------------------------------------------------------------------

# data "aws_subnets" "web" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.central_vpc.id]
#   }
#   filter {
#     name   = "tag:IngressEnabled"
#     values = ["true"]
#   }
#   filter {
#     name   = "tag:EgressEnabled"
#     values = ["true"]
#   }
# }

# data "aws_subnets" "app" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.central_vpc.id]
#   }
#   filter {
#     name   = "tag:IngressEnabled"
#     values = ["false"]
#   }
#   filter {
#     name   = "tag:EgressEnabled"
#     values = ["true"]
#   }
# }

# data "aws_subnets" "data" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.central_vpc.id]
#   }
#   filter {
#     name   = "tag:IngressEnabled"
#     values = ["false"]
#   }
#   filter {
#     name   = "tag:EgressEnabled"
#     values = ["false"]
#   }
# }

#  _   _   ___  ___  ________ _   _ _____ 
# | \ | | / _ \ |  \/  |_   _| \ | |  __ \
# |  \| |/ /_\ \| .  . | | | |  \| | |  \/
# | . ` ||  _  || |\/| | | | | . ` | | __ 
# | |\  || | | || |  | |_| |_| |\  | |_\ \
# \_| \_/\_| |_/\_|  |_/\___/\_| \_/\____/
#
# 

locals {
  mandatory_tags = merge(var.tags, {
    "application" = var.application_name.long
    "client"      = var.client_name.long
    "purpose"     = var.purpose
    "owner"       = var.owner
    "repo"        = var.code_repo
    "nukeable"    = var.nukeable

    "app:region"      = var.region
    "app:namespace"   = var.namespace
    "app:environment" = var.environment
  })

  naming_prefix = join("-", [
    var.client_name.short,
    var.application_name.short,
    var.environment,
    var.namespace
  ])
}


#  _____ _   _ ___________ _   _ _____ 
# |  _  | | | |_   _| ___ \ | | |_   _|
# | | | | | | | | | | |_/ / | | | | |  
# | | | | | | | | | |  __/| | | | | |  
# \ \_/ / |_| | | | | |   | |_| | | |  
#  \___/ \___/  \_/ \_|    \___/  \_/  
# 
# We use various IaC tools and have found SSM Parameters
# a great way to share the output values between systems

locals {
  outputs = {
    "LambdaLayerArns" = {
      secure = false
      value  = "${aws_lambda_layer_version.lambda_layer.arn} ${aws_lambda_layer_version.lambda_layer2.arn}"
    }
  }
}


resource "aws_ssm_parameter" "outputs" {

  for_each = local.outputs

  name        = "/${local.naming_prefix}/tf-output/${each.key}"
  description = "Give other systems a handle on this code's outputs"

  type   = each.value["secure"] ? "SecureString" : "String"
  key_id = aws_kms_key.general.key_id

  value = jsonencode(each.value["value"])

  tags = {
    Name = "${local.naming_prefix}-output-${each.key}"
  }
}

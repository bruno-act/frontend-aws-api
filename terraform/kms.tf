## general
resource "aws_kms_key" "general" {
  description = "${local.naming_prefix}-general"

  enable_key_rotation     = true
  deletion_window_in_days = 7
}
resource "aws_kms_alias" "general" {
  name          = "alias/${local.naming_prefix}-general"
  target_key_id = aws_kms_key.general.key_id
}

resource "aws_kms_key_policy" "general" {
  key_id = aws_kms_key.general.id
  policy = jsonencode({
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = "*"
      },
    ]
    Version = "2012-10-17"
  })
}


## s3
resource "aws_kms_key" "s3" {
  description = "${local.naming_prefix}-s3"

  enable_key_rotation     = true
  deletion_window_in_days = 7
}
resource "aws_kms_alias" "s3" {
  name          = "alias/${local.naming_prefix}-s3"
  target_key_id = aws_kms_key.s3.key_id
}

resource "null_resource" "tf_guard_provider_account_match" {
  count = tonumber(data.aws_caller_identity.current.account_id == var.aws_account_id ? "1" : "fail")
}

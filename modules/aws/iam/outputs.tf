output "iam_role_arn_flow_log_cloudwatch" {
  value = aws_iam_role.flow_log_cloudwatch.arn
}

# output "iam_policy_json_cloudwatch_kms" {
#   value = data.aws_iam_policy_document.cloudwatch.json
# }
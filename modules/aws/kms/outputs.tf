output "kms_cloudwatch_flow_log_id" {
  value = aws_kms_key.cloudwatch_flow_log.id
}

output "performance_insights_kms_id" {
  value = aws_kms_key.performance_insights_kms.id
}
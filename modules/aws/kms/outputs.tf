output "s3_encryption_key_id" {
  description = "key id of customer managed key to encrypt s3"
  value = aws_kms_key.s3_encryption_key.id
}

output "secretsmanager_encryption_key_id" {
  description = "key id of customer managed key to encrypt secrets manager"
  value = aws_kms_key.secretsmanager_encryption_key.id
}

output "cloudwatch_encryption_key_id" {
  description = "key id of customer managed key to encrypt cloudwatch"
  value = aws_kms_key.cloudwatch_encryption_key.id
}

output "performance_insights_key_id" {
  description = "key id rds performance insights"
  value = aws_kms_key.performance_insights_kms.arn
}

output "sns_encryption_key_id" {
  description = "key id of customer managed key to encrypt sns"
  value = aws_kms_key.sns_encryption_key.id
}

# output "kms_id_cloudwatch" {
#   value = aws_kms_key.cloudwatch.id
# }
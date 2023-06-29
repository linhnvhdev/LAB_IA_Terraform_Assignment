output "s3_encryption_key_id" {
  description = "key id of customer managed key to encrypt s3"
  value = module.s3_encryption_key.key_id
}

output "secretsmanager_encryption_key_id" {
  description = "key id of customer managed key to encrypt secrets manager"
  value = module.secretsmanager_encryption_key.key_id
}

output "cloudwatch_encryption_key_id" {
  description = "key id of customer managed key to encrypt cloudwatch"
  value = module.cloudwatch_encryption_key.key_arn   
}

output "performance_insights_key_id" {
  description = "key id rds performance insights"
  value = module.performance_insights_kms.key_arn
}

output "sns_encryption_key_id" {
  description = "key id of customer managed key to encrypt sns"
  value = module.sns_encryption_key.key_id
}

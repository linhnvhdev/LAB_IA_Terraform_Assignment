output "s3_encryption_key_id" {
  description = "key id of customer managed key to encrypt s3"
  value = aws_kms_key.s3_encryption_key.id
}

output "secretsmanager_encryption_key_id" {
  description = "key id of customer managed key to encrypt secrets manager"
  value = aws_kms_key.secretsmanager_encryption_key.id
}
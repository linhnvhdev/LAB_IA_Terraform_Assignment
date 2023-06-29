output "bucket_id" {
  description = "the bucket id"
  value       = module.main.s3_bucket_id
}

output "elbv2_logging_bucket_id"{
  description = "elbv2 logging bucket name"
  value = module.elbv2_logging.s3_bucket_id
}

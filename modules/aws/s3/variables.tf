variable "name" {
  description = "bucket name"
  type        = string
  default     = "sascloud-1wfq1h3"
}

variable "bucket_acl" {
  description = "Canned acl"
  type        = string
  default     = "log-delivery-write"
}

variable "sse_algorithm" {
  description = "Encryption algorithm to use"
  type        = string
  default     = "AES256"
}

variable "s3_kms_key_id" {
  description = "s3 kms key"
  type = string
}
variable "name" {
  description = "bucket name"
  type        = string
  default     = "sadcloud"
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

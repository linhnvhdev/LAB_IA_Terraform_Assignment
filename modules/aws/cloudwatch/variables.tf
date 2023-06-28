variable "name" {
  description = "cloudwatch name"
  type        = string
  default     = "sadcloud-cloudwatch"
}

variable "kms_key_id" {
  description = "kms key id for cloudwatch log"
  type = string
}

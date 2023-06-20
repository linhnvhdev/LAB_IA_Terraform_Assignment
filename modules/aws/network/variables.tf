variable "name" {
  description = "Name for instances and group"
  type        = string
  default     = "sadcloud"
}

variable "kms_key_id" {
  description = "kms key id for cloudwatch log"
  type = string
}
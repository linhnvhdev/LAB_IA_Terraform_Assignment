variable "name" {
  description = "sns name"
  type        = string
  default     = "sadcloud"
}
variable "sns_kms_key_id" {
  description = "sns kms key"
  type = string
}
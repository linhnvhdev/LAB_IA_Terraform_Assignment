variable "name" {
  description = "Name for instances and group"
  type        = string
  default     = "sadcloud"
}

variable "iam_role_arn_flow_log_cloudwatch" {
  type = string
}

variable "cloudwatch_arn_flow_logs" {
  type = string
}
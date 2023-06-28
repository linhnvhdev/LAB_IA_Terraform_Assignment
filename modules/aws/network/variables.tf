variable "name" {
  description = "Name for instances and group"
  type        = string
  default     = "sadcloud"
}

variable "flow_log_role_arn" {
  type = string
}

variable "cloudwatch_flow_log_arn" {
  type = string
}
variable "name" {
  description = "rds instance name"
  type        = string
  default     = "sadcloudrds"
}
############## Network ##############

variable "main_subnet_id" {
  description = "ID of main subnet"
  default = "default_main_subnet_id"
}

variable "secondary_subnet_id" {
  description = "ID of secondary subnet"
  default = "default_secondary_subnet_id"
}

variable "kms_key_id" {
  description = "kms key id for performance insights"
  type = string
}

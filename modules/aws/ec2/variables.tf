variable "name" {
  description = "Name for instances and group"
  type        = string
  default     = "sadcloud-ec2"
}

############## Network ##############

variable "vpc_id" {
  description = "ID of created VPC"
  default = "default_vpc_id"
}

variable "main_subnet_id" {
  description = "ID of created VPC"
  default = "default_main_subnet_id"
}

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

variable "vpc_cidr_v4" {
  description = "Ipv4 CIDR of created VPC"
  default = "10.0.0.0/16"
}

variable "vpc_cidr_v6" {
  description = "Ipv6 CIDR of created VPC"
}
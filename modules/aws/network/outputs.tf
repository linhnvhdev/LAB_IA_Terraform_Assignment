
output "vpc_id" {
  description = "ID of created VPC"
  value       = length(module.aws_vpc_main[0].vpc_id) > 0 ? module.aws_vpc_main[0].vpc_id : null
}

output "vpc_cidr" {
  description = "CIDR of created VPC"
  value       = length(module.aws_vpc_main[0].vpc_id) > 0 ? module.aws_vpc_main[0].vpc_ipv6_cidr_block : null
}

output "main_subnet_id" {
  description = "ID of created subnet"
  value       = length(aws_subnet.main) > 0 ? aws_subnet.main[0].id : null
}

output "secondary_subnet_id" {
  description = "ID of created secondary subnet"
  value       = length(aws_subnet.secondary) > 0 ? aws_subnet.secondary[0].id : null
}

output "subnet_cidr" {
  description = "CIDR of created subnet"
  value       = length(module.aws_vpc_main) > 0 ? module.aws_vpc_main[0].vpc_id : null
}

output "vpc_cidr_v6" {
  description = "CIDR v6 of created VPC"
  value = length(module.aws_vpc_main) > 0 ? module.aws_vpc_main[0].vpc_cidr_v6 : null
}

output "cloudwatch_name" {
  description = "name of cloudwatch log gorup for vpc"
  value = aws_cloudwatch_log_group.flow_log_group.name
}
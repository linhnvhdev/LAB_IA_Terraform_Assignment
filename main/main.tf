# Creates a single VPC with a subnet, internet gateway, and associated route table.
module "network" {
  source = "../modules/aws/network"
}

############## SERVICES ##############

module "cloudtrail" {
  source = "../modules/aws/cloudtrail"
}

module "cloudwatch" {
  source = "../modules/aws/cloudwatch"
}

module "config" {
  source = "../modules/aws/config"
}

module "ebs" {
  source = "../modules/aws/ebs"
}

module "ec2" {
  source = "../modules/aws/ec2"

   main_subnet_id = module.network.main_subnet_id
   vpc_id = module.network.vpc_id
}

module "elbv2" {
  source = "../modules/aws/elbv2"

  main_subnet_id = module.network.main_subnet_id
  secondary_subnet_id = module.network.secondary_subnet_id
  vpc_id = module.network.vpc_id
}

module "iam" {
  source = "../modules/aws/iam"
}

module "kms" {
  source = "../modules/aws/kms"
}

module "rds" {
  source = "../modules/aws/rds"

  main_subnet_id = module.network.main_subnet_id
  secondary_subnet_id = module.network.secondary_subnet_id
}

module "s3" {
  source = "../modules/aws/s3"
}

module "ses" {
  source = "../modules/aws/ses"
}

module "sns" {
  source = "../modules/aws/sns"
}

module "secretsmanager" {
  source = "../modules/aws/secretsmanager"
}
# Creates a single VPC with a subnet, internet gateway, and associated route table.
module "network" {
  source = "../modules/aws/network"
  kms_key_id = module.kms.cloudwatch_encryption_key_id
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
  ebs_encrypt_key = module.kms.ebs_encryption_key_arn
}

module "ec2" {
  source = "../modules/aws/ec2"

   main_subnet_id = module.network.main_subnet_id
   vpc_id = module.network.vpc_id
   vpc_cidr_v4 = module.network.vpc_cidr
   vpc_cidr_v6 = module.network.vpc_cidr_v6
}

module "elbv2" {
  source = "../modules/aws/elbv2"

  main_subnet_id = module.network.main_subnet_id
  secondary_subnet_id = module.network.secondary_subnet_id
  vpc_id = module.network.vpc_id
  logging_bucket = module.s3.elbv2_logging_bucket_id
}

module "iam" {
  source = "../modules/aws/iam"
}

module "kms" {
  source = "../modules/aws/kms"
  cloudwatch_name = module.network.cloudwatch_name
}

module "rds" {
  source = "../modules/aws/rds"

  main_subnet_id = module.network.main_subnet_id
  secondary_subnet_id = module.network.secondary_subnet_id
  kms_key_id = module.kms.performance_insights_key_id
}

module "s3" {
  source = "../modules/aws/s3"
  s3_kms_key_id = module.kms.s3_encryption_key_id
}

module "ses" {
  source = "../modules/aws/ses"
}

module "sns" {
  source = "../modules/aws/sns"
  sns_kms_key_id = module.kms.sns_encryption_key_id
}

module "secretsmanager" {
  source = "../modules/aws/secretsmanager"
  ec2_password = var.ec2_secret
  kms_key_id = module.kms.secretsmanager_encryption_key_id
}
module "iam_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 4.0"
  name = "sadcloudInlineGroup"
  
}

resource "aws_iam_group_policy" "inline_group_policy" {
  group = "sadcloudInlineGroupPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "NotAction": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "NotResource": "ec2:*",
      "Condition": {
          "Bool": {
              "aws:MultiFactorAuthPresent": ["true"]
          }
      }
    }
  ]
}
EOF
}

module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.0"

  create_role = true

  role_name             = "inline_role"
  trusted_role_services = ["ec2.amazonaws.com"]
}

module "iam_role_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4.0"

  name   = "inline-role-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "NotAction": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "allow_all_and_no_mfa" {

  count =  1 
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "*"
      },
      "Effect": "Allow",
      "Sid": "",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
EOF
}

module "iam_account" {
    source   =   "terraform-aws-modules/iam/aws//modules/iam-account"
    version   =   "~>4.0"

    account_alias = "cloudsec-training-ndt"

    minimum_password_length        =   15
    require_lowercase_characters   =   true
    require_numbers                =   true
    require_uppercase_characters   =   true
    require_symbols                =   true
    password_reuse_prevention      =   24
    max_password_age               =   0 
}

module "policy" {
    source   =   "terraform-aws-modules/iam/aws//modules/iam-policy"
    version   =   "~>4.0"
    name          =   "wildcard-IAM-policy"
    path          =   "/"

    policy        = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Effect":     "Allow",
            "Resource":[
                "arn:aws:s3:::khanhtq34-assignment3-terraform-bucket-2"
            ]
        }
    ]
}
EOF
}

module "admin_not_indicated"{
    source     = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
    version    = "~>4.0"

    name       = "sadcloud_superuser"
}

resource "aws_iam_policy" "admin_not_indicated_policy"{
  count =  1 
  name  = "sadcloud_superuser_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetBucketLocation"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::khanhtq34-assignment3-terraform-bucket-2"
      ],
      "Condition": {
          "Bool": {
              "aws:MultiFactorAuthPresent": ["true"]
          }
      }
    }
  ]
}
EOF
}

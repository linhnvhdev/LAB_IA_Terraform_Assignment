data "aws_caller_identity" "current" {}


module "main" {
  source = "terraform-aws-modules/kms/aws"
  description = "sadcloud key"
  enable_key_rotation = true
  aliases = ["alias/unrotated"]
}

module "exposed" {
  source = "terraform-aws-modules/kms/aws"
  description = "sadcloud key"
  enable_key_rotation = true
  aliases = ["alias/exposed"]
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "key-insecure-1",
  "Statement": [
    {
      "Sid": "Default IAM policy for KMS keys",
      "Effect": "Allow",
      "Principal": {"AWS" : "arn:aws:iam::${data.aws_caller_identity.current.id}:root"},
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOF
}
//Row 24 to allow from root, normally it would be "Principal": {"AWS" : "${data.aws_caller_identity.current.arn}"}


module "s3_encryption_key" {
  source = "terraform-aws-modules/kms/aws"
  description = "key for s3 buckets"
  enable_key_rotation = true
  aliases = ["alias/s3_encrypt"]
  policy = <<EOF
  {
  "Version": "2012-10-17",
  "Id": "key",
  "Statement": [
    {
      "Sid": "Default IAM policy for KMS keys",
      "Effect": "Allow",
      "Principal": {"AWS" : "arn:aws:iam::${data.aws_caller_identity.current.id}:root"},
      "Action": "kms:*",
      "Resource": "*"
    },
        {
      "Sid": "s3",
      "Effect": "Allow",
      "Principal": {"Service" : "s3.amazonaws.com"},
      "Action": ["kms:Encrypt","kms:Decrypt"],
      "Resource": "*"
    }
  ]
}
  EOF
}


module "secretsmanager_encryption_key" {
  source = "terraform-aws-modules/kms/aws"
  description = "key for secrets manager"
  enable_key_rotation = true
  aliases = ["alias/secret_manager"]
}
module "cloudwatch_encryption_key" {
  source = "terraform-aws-modules/kms/aws"
  description = "key for cloudwatch"
  enable_key_rotation = true
  aliases = ["alias/cloudwatch_encrypt"]
  policy = data.aws_iam_policy_document.cloudwatch_encrypt.json
}

data "aws_iam_policy_document" "cloudwatch_encrypt" {
  version = "2012-10-17"

  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid = "AllowCloudWatchLogs"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.ap-southeast-1.amazonaws.com"]
    }

    actions   = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = ["*"]
  }
}

module "performance_insights_kms" {
  source = "terraform-aws-modules/kms/aws"
  description = "performance insights kms key"
  enable_key_rotation = true
  aliases = ["alias/performance_insights"]
}

module "sns_encryption_key" {
  source = "terraform-aws-modules/kms/aws"
  description = "key for sns"
  enable_key_rotation = true
  aliases = ["alias/sns_encrypt"]
}

module "ebs_encryption_key" {
  source = "terraform-aws-modules/kms/aws"
  description = "key for ebs"
  enable_key_rotation = true
  aliases = ["alias/ebs_encrypt"]
}


resource "aws_kms_key" "main" {
  description             = "sadcloud key"
  enable_key_rotation = true
  count =  1 
}

resource "aws_kms_alias" "main" {
  name          = "alias/unrotated"
  target_key_id = aws_kms_key.main[0].key_id

  count =  1 
}

resource "aws_kms_key" "exposed" {
  description             = "sadcloud key"
  enable_key_rotation = true

  count =  1 

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "key-insecure-1",
  "Statement": [
    {
      "Sid": "Default IAM policy for KMS keys",
      "Effect": "Allow",
      "Principal": {"AWS" : "*"},
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "exposed" {
  name          = "alias/exposed"
  target_key_id = aws_kms_key.exposed[0].key_id

  count =  1 
}

resource "aws_kms_key" "s3_encryption_key" {
  description         = "key for s3 buckets"
  enable_key_rotation = true
  count               = 1
}

resource "aws_kms_key" "secretsmanager_encryption_key" {
    description = "key for secrets manager"
    enable_key_rotation = true
 }

 resource "aws_kms_key" "cloudwatch_encryption_key" {
  description = "key for cloudwatch"
  enable_key_rotation = true
}

resource "aws_kms_key" "performance_insights_kms" {
  description = "performance insights kms key"
  enable_key_rotation = true
}
 resource "aws_kms_key" "sns_encryption_key" {
    description = "key for sns"
    enable_key_rotation = true
 }

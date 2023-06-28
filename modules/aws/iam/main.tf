resource "aws_iam_group" "inline_group" {
  name = "sadcloudInlineGroup"

  count =  1 
}

resource "aws_iam_group_policy" "inline_group_policy" {
    group = aws_iam_group.inline_group[0].id

    count =  1 

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "NotAction": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*",
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

# resource "aws_iam_user" "inline_user" {
#   name = "sadcloudInlineUser"

#   count = 1
# }

# resource "aws_iam_user_policy" "inline_user_policy" {
#   user = aws_iam_user.inline_user[0].name

#   count =  1 

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "NotAction": "s3:DeleteBucket",
#       "Effect": "Allow",
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

resource "aws_iam_role" "inline_role" {

  count =  1 

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "inline_role_policy" {
  name = "inline-role-policy"
  role = aws_iam_role.inline_role[0].id

  count =  1 


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

resource "aws_iam_account_password_policy" "main" {
  count =  1 

  minimum_password_length        =  15
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  password_reuse_prevention      =  30
  max_password_age =  0 
}

resource "aws_iam_policy" "policy" {
  count =  1 

  name_prefix = "wildcard_IAM_policy"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "NotAction": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "NotResource": [
        "ec2:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_group" "admin_not_indicated" {
  count =  1 

  name = "sadcloud_superuser"
  path = "/"
}

resource "aws_iam_policy" "admin_not_indicated_policy"{
  count =  1 


  name  = "sadcloud_superuser_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "NotAction": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "NotResource": [
        "ec2:*"
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

resource "aws_iam_group_policy_attachment" "admin_not_indicated_policy-attach" {
  group = aws_iam_group.admin_not_indicated[0].id
  policy_arn = aws_iam_policy.admin_not_indicated_policy[0].arn
  count =  1 
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "flow_log_cloudwatch" {
  name               = "flow_log_cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "flow_log_cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [var.cloudwatch_arn]
  }
}

resource "aws_iam_role_policy" "flow_log_cloudwatch" {
  name   = "flow_log_cloudwatch"
  role   = aws_iam_role.flow_log_cloudwatch.id
  policy = data.aws_iam_policy_document.flow_log_cloudwatch.json
}

# data "aws_caller_identity" "current" {}

# data "aws_partition" "current" {}

# data "aws_region" "current" {}

# data "aws_iam_policy_document" "cloudwatch" {
#   policy_id = "key-policy-cloudwatch"
#   statement {
#     sid = "Enable IAM User Permissions"
#     actions = [
#       "kms:*",
#     ]
#     effect = "Allow"
#     principals {
#       type = "AWS"
#       identifiers = [
#         format(
#           "arn:%s:iam::%s:root",
#           data.aws_partition.current.partition,
#           data.aws_caller_identity.current.account_id
#         )
#       ]
#     }
#     resources = ["*"]
#   }
#   statement {
#     sid = "AllowCloudWatchLogs"
#     actions = [
#       "kms:Encrypt*",
#       "kms:Decrypt*",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:Describe*"
#     ]
#     effect = "Allow"
#     principals {
#       type = "Service"
#       identifiers = [
#         format(
#           "logs.%s.amazonaws.com",
#           data.aws_region.current.name
#         )
#       ]
#     }
#     resources = ["*"]
#   }
# }
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
      "Resource": "*"
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

  minimum_password_length        =  6
  require_lowercase_characters   = false
  require_numbers                = false
  require_uppercase_characters   = false
  require_symbols                = false
  password_reuse_prevention      =  0
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
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
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



resource "aws_iam_policy" "admin_not_indicated_policy" {
  count =  1 


  name  = "sadcloud_superuser_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
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

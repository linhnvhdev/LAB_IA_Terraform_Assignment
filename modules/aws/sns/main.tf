module "main" {
  source  = "terraform-aws-modules/sns/aws"
  name  = var.name
  kms_master_key_id = var.sns_kms_key_id
}

resource "aws_sns_topic_policy" "main-policy" {
  arn = module.main.topic_arn

  policy = data.aws_iam_policy_document.sns-topic-policy[0].json
  count = 1
}

data "aws_iam_policy_document" "sns-topic-policy" {
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      module.main.topic_arn,
    ]
  }
  count = 1
}

resource "aws_cloudwatch_metric_alarm" "main" {

  count = 1 
  alarm_name                = var.name
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "GetRequests"
  namespace                 = "AWS/S3"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "10000"

  alarm_actions = null
}

module "kms_cloudwatch_flow_log" {
  source = "../kms"
}

resource "aws_cloudwatch_log_group" "flow_log" {
  name = "/aws/vpc-flow-logs"
  kms_key_id = module.kms_cloudwatch_flow_log.kms_cloudwatch_flow_log_id
}

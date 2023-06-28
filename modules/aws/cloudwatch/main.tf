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

resource "aws_cloudwatch_log_group" "flow_log" {
  name = "flow_log"
}
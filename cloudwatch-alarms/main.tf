# --- cloudwatch-alarms/main.tf ---

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  for_each            = toset(var.instance_ids)
  alarm_name          = "${var.cpu_alarm_name}-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.period
  statistic           = "Average"
  threshold           = var.cpu_threshold
  dimensions = {
    InstanceId = each.value
  }
  alarm_actions = [aws_sns_topic.alarm_notifications.arn]
}

resource "aws_cloudwatch_metric_alarm" "disk_alarm" {
  for_each            = toset(var.instance_ids)
  alarm_name          = "${var.disk_alarm_name}-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "disk_used_percent"
  namespace           = var.custom_namespace
  period              = var.period
  statistic           = "Average"
  threshold           = var.disk_threshold
  dimensions = {
    InstanceId = each.value
  }
  alarm_actions = [aws_sns_topic.alarm_notifications.arn]
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  for_each            = toset(var.instance_ids)
  alarm_name          = "${var.memory_alarm_name}-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "mem_used_percent"
  namespace           = var.custom_namespace
  period              = var.period
  statistic           = "Average"
  threshold           = var.memory_threshold
  dimensions = {
    InstanceId = each.value
  }
  alarm_actions = [aws_sns_topic.alarm_notifications.arn]
}

resource "aws_sns_topic" "alarm_notifications" {
  name = "alarm-notifications-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarm_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn = aws_sns_topic.alarm_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "SNS:Publish",
        Resource  = aws_sns_topic.alarm_notifications.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:*"
          }
        }
      }
    ]
  })
}

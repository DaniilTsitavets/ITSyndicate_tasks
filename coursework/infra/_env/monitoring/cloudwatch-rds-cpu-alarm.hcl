locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///terraform-aws-modules/cloudwatch/aws//modules/metric-alarm?version=5.7.1"
}

dependency "sns" {
  config_path = find_in_parent_folders("sns")
}

inputs = {
  alarm_name          = "${local.env_vars.locals.environment}-cloudwatch-rds-cpu-alarm"
  alarm_description   = "If RDS CPU utilization is higher than 80% send log to SNS"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 3
  datapoints_to_alarm = 2
  threshold           = 80
  period              = 300

  namespace   = "AWS/RDS"
  metric_name = "CPUUtilization"
  statistic   = "Average"
  dimensions = {
    DBInstanceIdentifier = "${local.env_vars.locals.environment}-db"
  }

  alarm_actions = ["${dependency.sns.outputs.topic_arn}"]
}